require 'spec_helper'

describe 'weave', :type => :class do

  ['Debian', 'RedHat'].each do |osfamily|
    context "on #{osfamily}" do
      it { is_expected.to contain_class('weave::params') }
      it { is_expected.to contain_class('weave::install').that_comes_before('weave::config') }
      it { is_expected.to contain_class('weave::config') }
      it { is_expected.to contain_class('weave::service').that_subscribes_to('weave::config') }

      it { is_expected.to contain_service('weave') }

      if osfamily == 'Debian'
        let(:facts) { {
          :osfamily               => osfamily,
          :lsbdistid              => 'Ubuntu',
          :operatingsystem        => 'Ubuntu',
          :lsbdistcodename        => 'trusty',
          :operatingsystemrelease => '14.04',
          :kernelrelease          => '3.8.0-29-generic'
        } }
        service_config_file = '/etc/default/weave'
        init_file = '/etc/init/weave.conf'

        it { should contain_service('weave').with_hasrestart('false') }
        it { should contain_file('/etc/init.d/weave').with_ensure('link').with_target('/lib/init/upstart-job') }
      end

      if osfamily == 'RedHat'
        let(:facts) { {
          :osfamily => osfamily,
          :operatingsystem => 'RedHat',
          :operatingsystemrelease => '7.0'
        } }
        service_config_file = '/etc/sysconfig/weave'
        init_file = '/etc/systemd/system/weave.service'

        it { should contain_file(service_config_file) }
        it { should contain_file(init_file) }
        it { should contain_service('weave').with_hasrestart('false') }
      end

      context 'When passing a non-bool as create_bridge' do
        let(:params) {{
          :create_bridge => 'hello'
        }}
        it { expect { should compile }.to raise_error(/is not a boolean/) }
      end

      context 'When passing an invalid IP address as expose' do
        let(:params) {{
          :expose => 'hello'
        }}
        it { expect { should compile }.to raise_error(/weave::expose::ip should be an IP address/) }
      end

      context 'When requesting to install via a package with defaults' do
        let(:params) {{
          :install_method => 'package'
        }}
        it { should contain_package('weave').with(:ensure => 'latest') }
      end

      context 'When requesting to install via a custom package and version' do
        let(:params) {{
          :install_method => 'package',
          :package_ensure => 'specific_release',
          :package_name   => 'custom_weave_package'
        }}
        it { should contain_package('custom_weave_package').with(:ensure => 'specific_release') }
      end

      context "When installing via URL by default" do
        it { should contain_staging__file('weave').with(:source => 'https://github.com/zettio/weave/releases/download/latest_release/weave') }
      end

      context "When installing via URL by with a special version" do
        let(:params) {{
          :version   => '0.9.0',
        }}
        it { should contain_staging__file('weave').with(:source => 'https://github.com/zettio/weave/releases/download/0.9.0/weave') }
      end

      context "When installing via URL by with a custom url" do
        let(:params) {{
          :download_url   => 'http://myurl',
        }}
        it { should contain_staging__file('weave').with(:source => 'http://myurl') }
      end

      context 'with a custom service name' do
        let(:params) { {'service_name' => 'weave.io'} }
        it { should contain_service('weave').with_name('weave.io') }
      end

      context 'with service_enable set to false' do
        let(:params) { {'service_enable' => 'false'} }
        it { should contain_service('weave').with_enable('false') }
      end

      context 'with service_enable set to true' do
        let(:params) { {'service_enable' => 'true'} }
        it { should contain_service('weave').with_enable('true') }
      end

      context 'with custom password' do
        let(:params) { {'password' => 'testpass'} }
        it { should contain_file(service_config_file).with_content(/WEAVE_PASSWORD="testpass"/) }
      end

      context "When specifying cluster peers to join" do
        let :params do
          { :peers => ['10.0.0.1'] }
        end

        it { should contain_file(init_file).with_content(/weave launch 10.0.0.1/) }
      end

      context 'with expose' do
        let(:params) { {'expose' => '10.0.0.1/24'} }
        it { should contain_weave__expose('weave-expose-10.0.0.1/24').with_ip('10.0.0.1/24') }
        it { should contain_weave__expose('weave-expose-10.0.0.1/24').with_create_bridge('false') }
        it { should have_weave__expose_resource_count(1) }
      end
    end
  end

  context 'specific to RedHat 6' do
    let(:facts) { {
      :osfamily => 'RedHat',
      :operatingsystem => 'RedHat',
      :operatingsystemrelease => '6.5'
    } }

    it { should contain_service('weave').with_hasrestart('true') }
    it { should contain_file('/etc/init.d/weave') }
  end

  context "When including the current IP in cluster peers" do
    let(:facts) { {
      :osfamily               => 'Debian',
      :lsbdistid              => 'Ubuntu',
      :operatingsystem        => 'Ubuntu',
      :lsbdistcodename        => 'trusty',
      :operatingsystemrelease => '14.04',
      :kernelrelease          => '3.8.0-29-generic',
      :ipaddress_eth0         => '10.0.0.1'
    } }
    let :params do
      { :peers => ['10.0.0.1', '10.0.0.2'] }
    end

    it { should contain_file('/etc/init/weave.conf').with_content(/weave launch 10.0.0.2/) }
  end

  context 'unsupported operating system' do
    describe 'weave class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('weave') }.to raise_error(Puppet::Error, /^This module only works on Debian and Red Hat based systems/) }
    end
  end
end
