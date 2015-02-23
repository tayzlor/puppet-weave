require 'spec_helper_acceptance'

describe 'weave class' do

  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'weave': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe package('weave') do
      it { is_expected.to be_installed }
    end

    describe service('weave') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end
  end
end
