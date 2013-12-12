require 'spec_helper'

describe 'ilmt', :type => :class do
  describe 'ILMT installation class' do
    let(:params) { { } }

    it {
      should contain_file('response_file')
    }
  end
end
