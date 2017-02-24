class SpecificTemplateController < ApplicationController
  # Skip default filters for specific template actions
  FILTERS = [
    :require_login,
    :session_expiry,
    :update_activity_time,
    :set_taxonomy,
    :authorize,
    :verify_authenticity_token
  ].freeze

  FILTERS.each do |f|
    skip_before_action f
  end

  before_action :skip_secure_headers
  before_action :find_host

  def update(template_name)
    template = ProvisioningTemplate.find_by_name(template_name)
    raise Foreman::Exception.new(N_("Template '%s' was not found"), template_name) unless template

    kind = template.try :kind
    raise Foreman::Exception.new(N_("Template '%s' is of unknown kind"), template_name) unless kind
    raise Foreman::Exception.new(N_("Template '%s' (of kind %s) is not valid for OS"), template_name, kind) unless @host.operatingsystem.template_kinds.include?(kind)

    content = unattended_render template, template_name
    raise Foreman::Exception.new(N_("Template '%s' didn't render correctly"), template_name unless content

    logger.info "Deploying forced TFTP #{kind} configuration for #{@host.name} from template #{template_name}"
    @host.interfaces.each do |iface|
      next unless iface.tftp? || iface.tftp6?

      iface.send(:unique_feasible_tftp_proxies).each do |proxy|
        mac_addresses = iface.respond_to?(:mac_addresses_for_tftp, true) && iface.send(:mac_addresses_for_tftp) || [mac]
        mac_addresses.each do |mac|
          proxy.set(kind, mac_addr, :pxeconfig => content)
        end
      end
    end
  rescue => e
    render_error(
      :message => 'Failed to set PXE to template %{template_name}: %{error}',
      :status => :error,
      :template_name => template_name,
      :error => e
    )
  end
  
  def remove
    # All you need to do to return to proper TFTP settings
    @host.interfaces.each do |iface|
      next unless iface.managed

      iface.send :rebuild_tftp
    end
  end

  private

  def skip_secure_headers
    SecureHeaders.opt_out_of_all_protection(request)
  end

  def render_error(options)
    message = options.delete(:message)
    status = options.delete(:status) || :not_found
    logger.error message % options
    render :plain => "#{message % options}\n", :status => status
  end

  def find_host
    @host = find_host_by_ip
    return true if @host
    render_error(
      :message => 'Could not find host for request %{request_ip}',
      :status => :not_found,
      :request_ip => ip_from_request_env
    )
    false
  end

  def find_host_by_ip
    # try to find host based on our client ip address
    ip = ip_from_request_env

    # in case we got back multiple ips (see #1619)
    ip = ip.split(',').first

    # host is readonly because of association so we reload it if we find it
    host = Host.joins(:provision_interface).where(:nics => { :ip => ip }).first
    host ? Host.find(host.id) : nil
  end

  def ip_from_request_env
    ip = request.env['REMOTE_ADDR']

    # check if someone is asking on behalf of another system (load balancer etc)
    if request.env['HTTP_X_FORWARDED_FOR'].present? && (ip =~ Regexp.new(Setting[:remote_addr]))
      ip = request.env['HTTP_X_FORWARDED_FOR']
    end

    ip
  end
end
