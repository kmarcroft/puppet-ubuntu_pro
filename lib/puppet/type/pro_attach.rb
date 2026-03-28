# frozen_string_literal: true

Puppet::Type.newtype(:pro_attach) do
  @doc = <<-DOC
    @summary Manages Ubuntu Pro subscription attachment.

    The token property is Sensitive and is never written to disk,
    logged, or exposed in the process table. It is passed to the
    `pro attach` command exclusively via stdin.
  DOC

  ensurable do
    newvalue(:attached) do
      provider.attach
    end

    newvalue(:detached) do
      provider.detach
    end

    defaultto :attached
  end

  newparam(:name, namevar: true) do
    desc 'An arbitrary name for this resource instance.'
  end

  newparam(:token) do
    desc 'The Ubuntu Pro subscription token (Sensitive).'

    # Accept both raw strings and Sensitive-wrapped values,
    # but always store as Sensitive internally.
    munge do |value|
      if value.is_a?(Puppet::Pops::Types::PSensitiveType::Sensitive)
        value
      else
        Puppet::Pops::Types::PSensitiveType::Sensitive.new(value)
      end
    end

    # SECURITY: never log the token value
    def is_to_s(_value)
      '[redacted]'
    end

    def should_to_s(_value)
      '[redacted]'
    end

    def change_to_s(_old, _new)
      '[redacted token change]'
    end

    validate do |value|
      raw = if value.is_a?(Puppet::Pops::Types::PSensitiveType::Sensitive)
              value.unwrap
            else
              value
            end
      raise Puppet::Error, 'token must not be empty' if raw.nil? || raw.empty?
    end
  end
end
