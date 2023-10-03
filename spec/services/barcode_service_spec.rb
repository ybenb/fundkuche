# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BarcodeService do
  describe '.fetch_product' do
    it 'returns a product' do
      VCR.use_cassette('layered_design') do
        barcode_number = '9781801813785'
        product = BarcodeService.fetch_product(barcode_number)

        expect(product).to be_a(Product)
        expect(product.name).to eq('Layered Design For Ruby On Rails Applications')
      end
    end
  end
end
