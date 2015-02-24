require 'spec_helper_acceptance'

describe 'weave class' do

  context 'default parameters' do
    let(:pp) {"
      class { 'docker': }
      class { 'weave':
        require => Class['docker'],
      }
    "}

    it 'should apply with no errors' do
      apply_manifest(pp, :catch_failures=>true)
    end
    it 'should be idempotent' do
      apply_manifest(pp, :catch_changes=>true)
    end

    describe service('weave') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

  end
end
