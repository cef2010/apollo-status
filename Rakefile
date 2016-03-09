# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'ApolloStatus'
  app.info_plist['LSUIElement'] = true
  app.deployment_target = '10.10'
  app.frameworks += [ 'ServiceManagement']
end

class Motion::Project::App
  class << self
    alias_method :build_before_copy_helper, :build
    def build platform, options = {}
      # First let the normal `build' method perform its work.
      build_before_copy_helper(platform, options)
      # Now the app is built, but not codesigned yet.
      destination = File.join(config.app_bundle(platform), 'Library/LoginItems')
      info 'Create', destination
      FileUtils.mkdir_p destination
      helper_path = File.dirname(__FILE__)+'/ApolloStatus-app-launcher/build/MacOSX-10.11-Development/ApolloStatus-app-launcher.app'
      info 'Copy', helper_path
      FileUtils.cp_r helper_path, destination
    end
  end
end
