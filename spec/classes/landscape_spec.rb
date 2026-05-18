# frozen_string_literal: true

require 'spec_helper'

describe 'ubuntu_pro::landscape' do
  on_supported_os(
    supported_os: [
      { 'operatingsystem' => 'Ubuntu', 'operatingsystemrelease' => ['22.04', '24.04'] }
    ]
  ).each do |os, os_facts|
    context "when on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          ensure: 'registered',
          account_name: 'standalone',
          registration_key: sensitive('landscape-secret')
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_package('landscape-client').with_ensure('present') }
      it { is_expected.to contain_file('/etc/default/landscape-client').with_content("RUN=1\n") }
      it { is_expected.to contain_file('/etc/landscape/client.conf').with_show_diff(false) }
      it { is_expected.to contain_service('landscape-client').with_ensure('running').with_enable(true) }

      context 'when disabled' do
        let(:params) do
          super().merge(ensure: 'disabled')
        end

        it { is_expected.to contain_service('landscape-client').with_ensure('stopped').with_enable(false) }
      end

      context 'when ensure is registered without registration key' do
        let(:params) do
          super().merge(registration_key: nil)
        end

        it { is_expected.to compile.and_raise_error(/registration_key is required/) }
      end
    end
  end
end
