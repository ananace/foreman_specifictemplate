module ForemanSpecifictemplate
  module UnattendedControllerExtensions
    def host_template
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
        super
      end
    end

    def load_template_vars
      super unless params[:kind] == 'specifictemplate'
    end

    def built
      begin
        @host.parameters.where(name: 'specifictemplate').each(&:destroy)
      rescue => e
        logger.error e.message
      end

      super
    end
  end
end
