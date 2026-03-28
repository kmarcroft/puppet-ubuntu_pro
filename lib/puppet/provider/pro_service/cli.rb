require 'json'

Puppet::Type.type(:pro_service).provide(:cli) do
  desc 'Manages individual Ubuntu Pro services via the `pro` CLI.'

  confine osfamily: :Debian
  commands pro_cmd: 'pro'

  def exists?
    service_enabled?
  end

  def enable
    execute([command(:pro_cmd), 'enable', resource[:name], '--assume-yes'])
  end

  def disable
    execute([command(:pro_cmd), 'disable', resource[:name], '--assume-yes'])
  end

  private

  def service_enabled?
    output = execute([command(:pro_cmd), 'status', '--format', 'json'], failonfail: false)
    begin
      data = JSON.parse(output)
      services = data['services'] || []
      svc = services.find { |s| s['name'] == resource[:name] }
      svc && svc['status'] == 'enabled'
    rescue JSON::ParserError
      false
    end
  end
end
