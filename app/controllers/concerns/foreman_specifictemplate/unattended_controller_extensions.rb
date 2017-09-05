module ForemanSpecifictemplate
  module UnattendedControllerExtensions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :host_template, :specifictemplate
      alias_method_chain :load_template_vars, :specifictemplate
    end

    def host_template_with_specifictemplate
      if params[:kind] == 'specifictemplate'
        controller = SpecifictemplateController.new
        controller.request = request
        controller.response = response
        return controller.process(:update)
      end

      host_template_without_specifictemplate
    end

    def load_template_vars_with_specifictemplate
      load_template_vars_without_specifictemplate unless params[:kind] == 'specifictemplate'
    end
  end
end
