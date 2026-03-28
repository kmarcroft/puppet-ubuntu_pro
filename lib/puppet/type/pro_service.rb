Puppet::Type.newtype(:pro_service) do
  @doc = <<-DOC
    @summary Manages individual Ubuntu Pro services (esm-infra, livepatch, etc.)
  DOC

  ensurable do
    newvalue(:enabled) do
      provider.enable
    end

    newvalue(:disabled) do
      provider.disable
    end

    defaultto :enabled
  end

  newparam(:name, namevar: true) do
    desc 'The name of the Ubuntu Pro service (e.g. esm-infra, esm-apps, livepatch).'
  end
end
