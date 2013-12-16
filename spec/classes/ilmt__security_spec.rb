require 'spec_helper'

describe 'ilmt::security', :type => :class do
  describe 'securitylevel 0' do
    let(:params) { { :securitylevel => 0 } }

    it { should compile.with_all_deps }
  end

  describe 'securitylevel 1' do
    let(:params) { { :securitylevel      => 1,
                     :servercert         => 'foo',
                     :servercertfilepath => '/tmp/cert.arm' } }

    it { should compile.with_all_deps }

    it { should contain_file('ilmt_server_certificate').with( {
      :ensure  => 'present',
      :path    => '/tmp/cert.arm',
      :content => 'foo',
      :owner   => 'root',
      :group   => 'root',
      :mode    => '0600'
    } ) }
  end

  describe 'securitylevel 2' do
    let(:params) { { :securitylevel      => 2,
                     :agentcert          => 'bar',
                     :agentcertfilepath  => '/tmp/agent.arm',
                     :servercert         => 'foo',
                     :servercertfilepath => '/tmp/cert.arm' } }

    it { should compile.with_all_deps }

    it { should contain_file('ilmt_agent_certificate').with( {
      :ensure  => 'present',
      :path    => '/tmp/agent.arm',
      :content => 'bar',
      :owner   => 'root',
      :group   => 'root',
      :mode    => '0600'
    } ) }

    it { should contain_file('ilmt_server_certificate').with( {
      :ensure  => 'present',
      :path    => '/tmp/cert.arm',
      :content => 'foo',
      :owner   => 'root',
      :group   => 'root',
      :mode    => '0600'
    } ) }
  end
end
