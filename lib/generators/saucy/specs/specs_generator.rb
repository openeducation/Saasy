require 'generators/saucy/base'

module Saucy
  module Generators
    class SpecsGenerator < Base

      desc <<DESC
Description:
    Copy saucy cucumber spec support files to your application.
DESC

      def copy_spec_files
        directory "support", "spec/support/saucy"
      end

    end
  end
end


