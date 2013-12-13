require 'spec_helper'

describe 'ilmt', :type => :class do
  describe 'compiles with package param' do
    let(:facts) { { :osfamily => 'RedHat' } }
    let(:params) { { :package => 'PACKAGE_URI', } }
    it { should compile.with_all_deps }
  end

  describe 'fails to compile on unsupported platform' do
    let(:facts) { { :osfamily => 'SuperFoonly' } }
    let(:params) { { :package => 'PACKAGE_URI', } }
    it {
      expect {
        should compile.with_all_deps
      }.to raise_error(Puppet::Error, /platform is not supported/)
    }
  end

  describe 'fails to compile without package param' do
    let(:params) { { } }
    it {
      expect {
        should compile.with_all_deps
      }.to raise_error(Puppet::Error, /parameter must be provided/)
    }
  end
end
