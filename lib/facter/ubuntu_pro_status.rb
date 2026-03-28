# frozen_string_literal: true

# Custom fact: ubuntu_pro_status
# Reports whether the node is attached to Ubuntu Pro and which services are active.
# This fact NEVER contains the subscription token.

require 'json'

Facter.add(:ubuntu_pro_status) do
  confine osfamily: 'Debian'

  setcode do
    pro_bin = Facter::Core::Execution.which('pro')
    if pro_bin
      begin
        output = Facter::Core::Execution.execute("#{pro_bin} status --format json", timeout: 30)
        data = JSON.parse(output)
        {
          'attached' => data['attached'] || false,
          'services' => (data['services'] || []).map { |s| { 'name' => s['name'], 'status' => s['status'] } },
          'account' => data.dig('account', 'name'),
          'expires' => data['expires']
        }
      rescue StandardError
        { 'attached' => false, 'services' => [], 'error' => 'failed to parse pro status' }
      end
    else
      { 'attached' => false, 'services' => [], 'error' => 'pro command not found' }
    end
  end
end
