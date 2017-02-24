require 'test_plugin_helper'

class SpecificTemplateControllerTest < ActionController::TestCase
  let(:host) { FactoryGirl.create(:host, :managed) }
  let(:operatingsystem) { FactoryGirl.create(:operatingsystem) }
  let(:content) { 'template content' }
  let(:template_kind) { TemplateKind.create(:name => 'PXELinux default local boot') }
  let(:template) do
    FactoryGirl.create(
      :provisioning_template,
      :template_kind => template_kind,
      :template => content
    )
  end

  # TODO
  # test 'should deploy rendered boot template' do
  #   @request.env['REMOTE_ADDR'] = host.ip
  #   ProvisioningTemplate.expects(:find_by_name).returns(template)
  #   host.expects(:operatingsystem).returns(operatingsystem)
  #   operatingsystem.expects(:template_kinds).returns([template_kind])
  #   expects(:unattended_render).returns(content)

  #   put :update, 'PXELinux default local boot'
  #   assert_response :success
  #   assert_equal content, @response.body
  # end

  # test 'should restore TFTP data' do
  #   @request.env['REMOTE_ADDR'] = host.ip
  #   delete :remove
  #   assert_response :success
  #   assert_empty @response.body
  # end
end
