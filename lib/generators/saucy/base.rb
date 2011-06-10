require 'rails/generators'
require 'rails/generators/base'

module Saucy
  module Generators
    # Base generator for Saucy generators. Setups up the source root.
    class Base < ::Rails::Generators::Base
      # @return [String] source root for tempates within a saucy generator
      def self.source_root
        @_saucy_source_root ||=
          File.expand_path(File.join(File.dirname(__FILE__),
                                     generator_name,
                                     'templates'))
      end
    end
  end
end

