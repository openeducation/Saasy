# This set of hacks extends Rails routing so that we can define pretty, unique,
# urls for account resources without having to specify every nested resource
# every time we generate a url.
#
# For example, you can generate /accounts/thoughtbot/projects/hoptoad from
# project_path(@project), because the account can be inferred from the project.
module Saucy
  module MapperExtensions
    def initialize(*args)
      @through_scope = []
      super
    end

    def through(parent, &block)
      @through_scope << parent
      resources(parent, :only => [], &block)
      @through_scope.pop
    end

  end

  class ThroughAlias
    attr_reader :route, :through

    def initialize(route, through)
      @route = route
      @through = through
    end

    def to_method(kind)
      return <<-RUBY
        def #{alias_name}_#{kind}(#{arguments.last}, options = {})
          #{route_name}_#{kind}(#{arguments.join(', ')}, options)
        end
      RUBY
    end

    private

    def alias_name
      @alias_name ||= through.inject(route_name) do |name, through|
        prefix = "#{through.to_s.singularize}_"
        name.sub(/^(new_|edit_|)#{Regexp.escape(prefix)}/, '\1')
      end
    end

    def arguments
      @arguments ||= build_arguments
    end

    def build_arguments
      other_segments = segments.dup
      first_segment = other_segments.shift
      other_segments.inject([first_segment]) { |result, member|
        result << "#{result.last}.#{member}"
      }.reverse
    end

    def segments
      parent_segments = through.map { |parent| parent.to_s.singularize }.reverse
      if include_self?
        [alias_name] + parent_segments
      else
        parent_segments
      end
    end

    def route_name
      route.name
    end

    def include_self?
      route.segment_keys.include?(:id)
    end
  end
end

ActionDispatch::Routing::Mapper.class_eval do
  include Saucy::MapperExtensions
end

ActionDispatch::Routing::Mapper::Base.class_eval do
  def match_with_through(path, options=nil)
    match_without_through(path, options)
    unless @through_scope.empty?
      route = @set.routes.last
      @set.named_routes.add_through_alias(route, @through_scope) if route.name
    end
    self
  end

  alias_method_chain :match, :through
end

ActionDispatch::Routing::RouteSet::NamedRouteCollection.class_eval do
  attr_reader :through_aliases

  def clear_with_through_aliases!
    clear_without_through_aliases!
    @through_aliases = []
  end
  alias_method_chain :clear!, :through_aliases

  def reset_with_through_aliases!
    old_through_aliases = through_aliases.dup
    reset_without_through_aliases!
    old_through_aliases.each do |through_alias|
      add_through_alias through_alias.route, through_alias.through
    end
  end
  alias_method_chain :reset!, :through_aliases

  def add_through_alias(route, through)
    @through_aliases ||= []
    through_alias = Saucy::ThroughAlias.new(route, through)
    @through_aliases << through_alias
    @module.module_eval through_alias.to_method('path')
    @module.module_eval through_alias.to_method('url')
  end
end

