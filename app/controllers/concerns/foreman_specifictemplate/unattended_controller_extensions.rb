module ForemanSpecifictemplate
  module UnattendedControllerExtensions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :host_template, :specifictemplate
      alias_method_chain :load_template_vars, :specifictemplate
      alias_method_chain :build, :specifictemplate
    end

    def host_template_with_specifictemplate
      if params[:kind] == 'specifictemplate'
        if params[:redirect] == 'true'
          redirect_to url_for(controller: :specifictemplate, action: :update, template_name: params[:template_name])
        else
          controller = SpecifictemplateController.new
          controller.request = @_request
          controller.response = @_response
          controller.params = params
          controller.process(:update)
          render text: controller.response.body, status: controller.response.response_code, content_type: controller.response.content_type
        end
      else
        host_template_without_specifictemplate
      end
    end

    def load_template_vars_with_specifictemplate
      load_template_vars_without_specifictemplate unless params[:kind] == 'specifictemplate'
    end

    def built_with_specifictemplate
      begin
        @host.parameters.where(name: 'specifictemplate').each(&:destroy)
      rescue => e
        logger.error e.message
      end

      built_without_specifictemplate
    end
  end
end
