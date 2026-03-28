require 'json'
require 'open3'

Puppet::Type.type(:pro_attach).provide(:cli) do
  desc 'Manages Ubuntu Pro attachment via the `pro` CLI.
        The token is passed exclusively through stdin to avoid
        exposure in the process table or on disk.'

  confine osfamily: :Debian
  commands pro_cmd: 'pro'

  def exists?
    attached?
  end

  def attach
    unless attached?
      token_value = unwrap_token
      # SECURITY: pass the token via stdin only.
      # The command line only contains `pro attach --no-auto-enable -`
      # which tells pro to read the token from stdin.
      # This ensures the token never appears in /proc/<pid>/cmdline.
      cmd = [command(:pro_cmd), 'attach', '--no-auto-enable', '-']
      stdout, stderr, status = Open3.capture3(*cmd, stdin_data: token_value)
      unless status.success?
        # Scrub any accidental token leakage from error messages
        safe_stderr = stderr.gsub(token_value, '[REDACTED]')
        safe_stdout = stdout.gsub(token_value, '[REDACTED]')
        raise Puppet::Error, "pro attach failed (exit #{status.exitstatus}): #{safe_stderr} #{safe_stdout}"
      end
    end
  end

  def detach
    if attached?
      execute([command(:pro_cmd), 'detach', '--assume-yes'])
    end
  end

  private

  def attached?
    output = execute([command(:pro_cmd), 'api', 'u.pro.status.is_attached.v1'], failonfail: false)
    begin
      data = JSON.parse(output)
      data.dig('data', 'attributes', 'is_attached') == true
    rescue JSON::ParserError
      # Fallback: parse `pro status` output
      status_output = execute([command(:pro_cmd), 'status', '--format', 'json'], failonfail: false)
      begin
        status_data = JSON.parse(status_output)
        status_data['attached'] == true
      rescue JSON::ParserError
        false
      end
    end
  end

  def unwrap_token
    token = resource[:token]
    if token.is_a?(Puppet::Pops::Types::PSensitiveType::Sensitive)
      token.unwrap
    else
      token.to_s
    end
  end
end
