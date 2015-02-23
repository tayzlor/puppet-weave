require 'spec_helper'

describe 'weave' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "weave class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('weave::params') }
        it { is_expected.to contain_class('weave::install').that_comes_before('weave::config') }
        it { is_expected.to contain_class('weave::config') }
        it { is_expected.to contain_class('weave::service').that_subscribes_to('weave::config') }

        it { is_expected.to contain_service('weave') }
        it { is_expected.to contain_package('weave').with_ensure('present') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'weave class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('weave') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
