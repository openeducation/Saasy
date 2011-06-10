require 'generators/saucy/base'
require 'rails/generators/active_record/migration'

module Saucy
  module Generators
    class ViewsGenerator < Base
      include Rails::Generators::Migration
      extend ActiveRecord::Generators::Migration

      desc <<-DESC
Description:
    Copy saucy views to your application.
DESC


      def copy_views
        views_path = File.join(File.dirname(File.expand_path(__FILE__)), '../../../../app/views')
        directory views_path, 'app/views'
      end
    end
  end
end

