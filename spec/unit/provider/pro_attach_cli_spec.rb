# frozen_string_literal: true

require 'spec_helper'
require 'json'

describe Puppet::Type.type(:pro_attach).provider(:cli) do
  let(:resource) do
    Puppet::Type.type(:pro_attach).new(
      name: 'test',
      token: 'test-token-12345',
      ensure: :attached,
      provider: :cli
    )
  end

  let(:provider) { resource.provider }

  let(:attached_status) do
    JSON.generate(
      'data' => {
        'attributes' => {
          'is_attached' => true
        }
      }
    )
  end

  let(:detached_status) do
    JSON.generate(
      'data' => {
        'attributes' => {
          'is_attached' => false
        }
      }
    )
  end

  describe '#exists?' do
    it 'returns true when system is attached' do
      allow(provider).to receive(:execute).and_return(attached_status)
      expect(provider.exists?).to be true
    end

    it 'returns false when system is detached' do
      allow(provider).to receive(:execute).and_return(detached_status)
      expect(provider.exists?).to be false
    end
  end

  describe '#attach' do
    it 'passes token via stdin using Open3' do
      allow(provider).to receive(:execute).and_return(detached_status)
      allow(Open3).to receive(:capture3).and_return(
        ['Attached', '', instance_double(Process::Status, success?: true, exitstatus: 0)]
      )

      provider.attach

      expect(Open3).to have_received(:capture3).with(
        anything, 'attach', '--no-auto-enable', '-',
        stdin_data: 'test-token-12345'
      )
    end

    it 'redacts token from error output on failure' do
      allow(provider).to receive(:execute).and_return(detached_status)
      allow(Open3).to receive(:capture3).and_return(
        ['', "Invalid token: test-token-12345\n", instance_double(Process::Status, success?: false, exitstatus: 1)]
      )

      expect { provider.attach }.to raise_error(Puppet::Error, /\[REDACTED\]/)
    end

    it 'does not call pro attach when already attached' do
      allow(provider).to receive(:execute).and_return(attached_status)
      allow(Open3).to receive(:capture3)

      provider.attach

      expect(Open3).not_to have_received(:capture3)
    end
  end

  describe '#detach' do
    it 'calls pro detach when attached' do
      allow(provider).to receive(:execute).with(
        array_including('api', 'u.pro.status.is_attached.v1'), anything
      ).and_return(attached_status)
      allow(provider).to receive(:execute).with(
        array_including('detach', '--assume-yes')
      )

      provider.detach

      expect(provider).to have_received(:execute).with(
        array_including('detach', '--assume-yes')
      )
    end

    it 'does not call detach when not attached' do
      allow(provider).to receive(:execute).and_return(detached_status)

      provider.detach

      expect(provider).to have_received(:execute).once
    end
  end
end
