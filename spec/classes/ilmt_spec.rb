require 'spec_helper'

describe 'ilmt', :type => :class do
  describe 'compiles without package param' do
    let(:facts) { { :osfamily => 'RedHat' } }
    it { should compile.with_all_deps }
  end

  describe 'fails to compile on unsupported platform' do
    let(:facts) { { :osfamily => 'SuperFoonly' } }
    let(:params) { { :package => 'PACKAGE_URI', } }
    it {
      expect { should raise_error(Puppet::Error, /platform is not supported/) }
    }
  end
end
