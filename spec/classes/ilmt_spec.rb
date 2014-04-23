require 'spec_helper'

describe 'ilmt', :type => :class do
  describe 'fails to compile on unsupported platform' do
    let(:facts) { { :osfamily => 'SuperFoonly' } }
    let(:params) { { :package => 'PACKAGE_URI', } }
    it {
      expect { should raise_error(Puppet::Error, /platform is not supported/) }
    }
  end

  describe 'on RedHat platform' do
    let(:facts) { { :osfamily => 'RedHat' } }

    describe 'fails to compile with itlmdir param' do
      let(:params) { {
        :package => 'PACKAGE_URI',
        :itlmdir => '/opt/itlm',
      } }
      it {
        expect { should raise_error(Puppet::Error) }
      }
    end

    it { should contain_file('response_file').with( {
      :ensure => 'present',
      :path   => '/etc/response_file.txt',
      :owner  => 'root',
      :group  => 'root',
      :mode   => '0600'
    } ) }

    it { should contain_service('ilmt_service').with( {
      :ensure     => 'running',
      :name       => 'tlm',
      :hasrestart => false,
    } ) }

    describe 'with package param' do
        let(:params) { { :package => 'puppet:///modules/ilmt/foo.rpm' } }

        it { should compile.with_all_deps }

        it { should contain_file('package_file').with( {
          :ensure => 'present',
          :path   => '/tmp/ILMT-TAD4D-agent-7.5.0.115-linux-x86.rpm',
          :source => 'puppet:///modules/ilmt/foo.rpm',
          :owner  => 'root',
          :group  => 'root',
          :mode   => '0600'
        } ) }

        it { should contain_package('ilmt_package').with( {
          :ensure   => 'present',
          :name     => 'ILMT-TAD4D-agent',
          :source   => '/tmp/ILMT-TAD4D-agent-7.5.0.115-linux-x86.rpm',
          :provider => 'yum'
        } ) }
    end

    describe 'without package param' do
        let(:params) { { } }

        it { should compile.with_all_deps }

        it { should contain_package('ilmt_package').with( {
          :ensure   => 'present',
          :name     => 'ILMT-TAD4D-agent',
          :provider => 'yum'
        } ) }
    end
  end
end
