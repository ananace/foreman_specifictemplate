require 'ipaddr'

class SpecifictemplateController < ApplicationController
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

  before_action :set_admin_user
  before_action :skip_secure_headers
  before_action :find_host

  def update
    return render(:plain => 'Host not in build mode') unless @host and @host.build?

    template_type = params[:template_type].downcase.to_sym
    raise Foreman::Exception.new(N_("Template type '%s' unknown"), template_type) unless template_type.nil? or %i(local default).include?(template_type)
    template_name = params[:template_name]
    return remove unless template_name or template_type

    if template_type
      if template_type == :local
        iface = @host.provision_interface
        template_name = iface.send(:local_boot_template_name, kind)
      else
        template_name = @host.provisioning_template(kind: kind).name
      end
    end

    template = ProvisioningTemplate.find_by_name(template_name)
    raise Foreman::Exception.new(N_("Template '%s' was not found"), template_name) unless template

    # TODO; Check that the template is of the correct PXE type, not just that the OS
    # allows using that type. Don't want to deploy PXELinux on a PXEGrub2 host.
    kind = template.template_kind.name
    raise Foreman::Exception.new(N_("%s does not support templates of type %s"), @host.operatingsystem, kind) unless @host.operatingsystem.template_kinds.include?(kind)

    # Set up template rendering parameters
    @kernel = host.operatingsystem.kernel(host.arch)
    @initrd = host.operatingsystem.initrd(host.arch)
    if host.operatingsystem.respond_to?(:mediumpath)
      @mediapath = host.operatingsystem.mediumpath(host)
    end
    if host.operatingsystem.respond_to?(:xen)
      @xen = host.operatingsystem.xen(host.arch)
    end

    content = @host.render_template template
    raise Foreman::Exception.new(N_("Template '%s' didn't render correctly"), template.name) unless content

    logger.info "Deploying requested #{kind} configuration for #{@host.name} from template '#{template_name}'"

    @host.parameters.where(name: 'specifictemplate').first_or_initialize.tap do |p|
      p.value = template_name
      p.save
    end

    @host.interfaces.each do |iface|
      next unless iface.tftp? || iface.tftp6?

      iface.send(:unique_feasible_tftp_proxies).each do |proxy|
        mac_addresses = iface.try(:mac_addresses_for_tftp) || [iface.mac]
        mac_addresses.each do |mac_addr|
          proxy.set(kind, mac_addr, :pxeconfig => content)
        end
      end
    end

    render :inline => "Template <%= params[:template_name] %> was deployed successfully."
  rescue => e
    render_error(
      :message => 'Failed to set PXE to template %{template_name}: %{error}',
      :status => :error,
      :template_name => template_name,
      :error => e
    )
  end
  
  def remove
    logger.info "Resetting forced TFTP configuration for #{@host.name}"
    remove_specifictemplate_param

    # All you need to do to return to proper TFTP settings
    @host.interfaces.each do |iface|
      next unless iface.managed

      iface.send :rebuild_tftp
    end

    render :plain => ''
  rescue => e
    render_error(
      :message => 'Failed to reset PXE for host %{host}: %{error}',
      :status => :error,
      :host => @host,
      :error => e
    )
  end

  private

  def remove_specifictemplate_param
    @host.parameters.where(name: 'specifictemplate').each(&:destroy)
  end

  def skip_secure_headers
    SecureHeaders.opt_out_of_all_protection(request)
  end

  def render_error(options)
    status = options.delete(:status) || :not_found
    message = options.delete(:message) % options
    logger.error message
    render :text => message, :status => status, :content_type => 'text/plain'
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
    if IPAddr.new(ip).ipv6?
      search = { :ip6 => ip }
    else 
      search = { :ip => ip }
    end

    host = Host.joins(:provision_interface).where(:nics => search).first
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
