module ForemanSpecifictemplate
  class Engine < ::Rails::Engine
    engine_name 'foreman_specifictemplate'

    config.autoload_paths += Dir["#{config.root}/app/controllers/concerns"]

    initializer 'foreman_specifictemplate.register_plugin', :before => :finisher_hook do |_app|
      Foreman::Plugin.register :foreman_specifictemplate do
        requires_foreman '>= 1.14'
      end
    end

    config.to_prepare do
      begin
        ::UnattendedController.send :prepend, ForemanSpecifictemplate::UnattendedControllerExtensions
      rescue => e
        Rails.logger.warn "ForemanSpecifictemplate: skipping engine hook (#{e}, #{e.backtrace})"
      end
    end
  end
end
