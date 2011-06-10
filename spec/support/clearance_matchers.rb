module ClearanceMatchers
  class DenyAccessMatcher
    include Shoulda::ActionController::Matchers

    def initialize(context)
      @context = context
    end

    def matches?(controller)
      if @method
        @context.__send__(@method, *@args)
      end

      begin
        if @flash
          controller.should set_the_flash.to(@flash)
        else
          controller.should_not set_the_flash
        end

        url = controller.__send__(:sign_in_url)
        controller.should redirect_to(url).in_context(@context)

        true
      rescue RSpec::Expectations::ExpectationNotMetError => failure
        @failure_message = failure.message
        false
      end
    end

    def flash(flash)
      @flash = flash
      self
    end

    def on(method, *args)
      @method = method
      @args   = args
      self
    end

    def failure_message_for_should
      @failure_message
    end
  end

  def deny_access
    DenyAccessMatcher.new(self)
  end
end


RSpec.configure do |config|
  config.include ClearanceMatchers
end
