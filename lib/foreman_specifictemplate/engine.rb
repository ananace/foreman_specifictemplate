module ForemanSpecificTemplate
  class Engine < ::Rails::Engine
    engine_name 'foreman_specifictemplate'

    initializer 'foreman_specifictemplate.register_plugin', :before => :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_specifictemplate do
        requires_foreman '>= 1.14'
      end
    end
  end
end
