# frozen_string_literal: true

require 'spec_helper'

describe 'ubuntu_pro' do
  on_supported_os(
    supported_os: [
      { 'operatingsystem' => 'Ubuntu', 'operatingsystemrelease' => ['22.04', '24.04'] }
    ]
  ).each do |os, os_facts|
    context "when on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          token: sensitive('C1234567890abcdef')
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('ubuntu_pro') }
      it { is_expected.to contain_package('ubuntu-pro-client').with_ensure('present') }
      it { is_expected.to contain_pro_attach('ubuntu_pro').with_ensure('attached') }

      context 'when manage_package is disabled' do
        let(:params) do
          super().merge(manage_package: false)
        end

        it { is_expected.not_to contain_package('ubuntu-pro-client') }
      end

      context 'when ensure is detached' do
        let(:params) do
          super().merge(ensure: 'detached')
        end

        it { is_expected.to contain_pro_attach('ubuntu_pro').with_ensure('detached') }
      end

      context 'with services enabled' do
        let(:params) do
          super().merge(enable_services: %w[esm-infra livepatch])
        end

        it { is_expected.to contain_pro_service('esm-infra').with_ensure('enabled') }
        it { is_expected.to contain_pro_service('livepatch').with_ensure('enabled') }
      end

      context 'with services disabled' do
        let(:params) do
          super().merge(disable_services: ['fips'])
        end

        it { is_expected.to contain_pro_service('fips').with_ensure('disabled') }
      end
    end
  end

  context 'when on non-Ubuntu OS' do
    let(:facts) do
      {
        os: {
          name: 'CentOS',
          family: 'RedHat',
          release: { major: '8', full: '8.0' }
        }
      }
    end
    let(:params) do
      {
        token: sensitive('C1234567890abcdef')
      }
    end

    it { is_expected.to compile.and_raise_error(/only supports Ubuntu/) }
  end
end
