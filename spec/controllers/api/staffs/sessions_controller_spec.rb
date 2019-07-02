require 'rails_helper'

RSpec.describe Api::Staffs::SessionsController, type: :controller do

  describe 'POST staff/sign_in' do
    context 'when staff exist and authorized' do
      let(:staff) { create(:staff) }
      it 'should return authorized staff' do
        post :create, params: { staff: { password: '123456', mobile_number: staff.mobile_number } }

        expect(response.status).to eq(201)
      end
    end

    context 'when staff does not exist' do
      it 'should return authorized staff' do
        post :create, params: { staff: { password: '123456', mobile_number: '000' } }

        expect(response.status).to eq(401)
      end
    end
  end

end
