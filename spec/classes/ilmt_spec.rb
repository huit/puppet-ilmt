require 'spec_helper'

describe 'ilmt', :type => :class do
  describe 'without package param' do
    let(:params) { { } }

    it {
      expect {
        should contain_file('response_file')
      }.to raise_error(Puppet::Error)
    }
  end
end
