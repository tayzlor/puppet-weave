require 'spec_helper'

describe 'weave::expose' do
  let(:facts) {{ :architecture => 'x86_64' }}
  let(:title) { "expose-test" }

  describe 'with no args' do
    let(:params) {{}}

    it {
      expect { should raise_error(Puppet::Error) }
    }
  end
  describe 'with create_bridge as a non bool' do
    let(:params) {{
      'create_bridge' => 'test',
    }}
    it {
     expect { should raise_error(Puppet::Error) }
    }
  end
  describe 'with ip as a non IP Address' do
    let(:params) {{
      'ip' => 'test',
    }}
    it {
     expect { should raise_error(Puppet::Error) }
    }
  end
  describe 'with ip' do
    let(:params) {{
      'ip' => '10.0.1.1/24',
    }}
    it { should contain_exec("weave-expose-10.0.1.1/24").with({
      'command' => 'weave expose 10.0.1.1/24',
    })}
  end
  describe 'with ip and create_bridge' do
    let(:params) {{
      'ip'            => '10.0.1.1/24',
      'create_bridge' => true
    }}
    it { should contain_exec("weave-expose-10.0.1.1/24").with({
      'command' => 'weave expose 10.0.1.1/24',
      'user'    => 'root',
    })}
    it { should contain_exec("weave-create-bridge-10.0.1.1/24").with({
      'command' => 'weave create-bridge',
      'user'    => 'root',
      'require' => ["Exec[weave-expose-10.0.1.1/24]", "Class[Weave::Install]"],
    })}
  end
end
