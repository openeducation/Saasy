module Saucy
  class Layouts
    def initialize
      @controllers = {}
    end

    def method_missing(controller_name, *args, &block)
      @controllers[controller_name.to_s] ||= Controller.new
    end

    def self.to_proc
      lambda do |controller|
        controller_name = controller.controller_name
        action_name = controller.action_name
        Saucy::Configuration.layouts.send(controller_name).send(action_name)
      end
    end

    private

    class Controller
      def initialize
        @actions = {}
      end

      def method_missing(method_name, *args, &block)
        action_name = method_name.to_s
        if action_name.sub!(/=$/, '')
          @actions[action_name] = args.first
        else
          @actions[action_name] ||= "saucy"
        end
      end
    end
  end
end
