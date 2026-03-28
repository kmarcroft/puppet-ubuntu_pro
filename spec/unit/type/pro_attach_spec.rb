require 'spec_helper'

describe Puppet::Type.type(:pro_attach) do
  let(:resource) do
    Puppet::Type.type(:pro_attach).new(
      name: 'test',
      token: 'test-token-value',
      ensure: :attached,
    )
  end

  it 'accepts a name' do
    expect(resource[:name]).to eq('test')
  end

  it 'defaults ensure to attached' do
    res = Puppet::Type.type(:pro_attach).new(name: 'test2', token: 'tok')
    expect(res[:ensure]).to eq(:attached)
  end

  it 'wraps raw token string in Sensitive' do
    expect(resource[:token]).to be_a(Puppet::Pops::Types::PSensitiveType::Sensitive)
  end

  it 'redacts token in is_to_s' do
    expect(resource.parameter(:token).is_to_s('anything')).to eq('[redacted]')
  end

  it 'redacts token in should_to_s' do
    expect(resource.parameter(:token).should_to_s('anything')).to eq('[redacted]')
  end

  it 'rejects empty token' do
    expect {
      Puppet::Type.type(:pro_attach).new(name: 'bad', token: '', ensure: :attached)
    }.to raise_error(Puppet::Error, %r{must not be empty})
  end
end
