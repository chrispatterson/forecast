require "rails_helper"

RSpec.describe ForecastService, type: :model do
  describe "#call" do
    let(:lat) { 43.074761 }
    let(:lon) { -89.3837613 }

    context "with invalid latitude" do
      let(:lat) { 255 }
      it "raises an error" do
        expect { ForecastService.new(lat: lat, lon: lon).call }.to raise_error(ArgumentError)
      end
    end

    context "with invalid longitude" do
      let(:lon) { 255 }
      it "raises an error" do
        expect { ForecastService.new(lat: lat, lon: lon).call }.to raise_error(ArgumentError)
      end
    end

    context "errors from API" do
      it "raises an error if server response with malformed JSON" do
        stub_request(:get, /api\.open-meteo\.com/).
        to_return(
          status: 200,
          body: '{"malformed'
        )
        expect { ForecastService.new(lat: lat, lon: lon).call }.to raise_error(JSON::ParserError)

      end
      it "raises an error when timezone is invalid" do
        stub_request(:get, /api\.open-meteo\.com/).
        to_return(
          status: 400,
          body: '{"error":true,"reason":"Invalid timezone"}'
        )
        expect { ForecastService.new(lat: lat, lon: lon).call }.to raise_error(ArgumentError)
      end

      it "raises an error when timezone is invalid" do
        stub_request(:get, /api\.open-meteo\.com/).
        to_return(
          status: 500,
          body: '{"error": true}'
        )
        expect { ForecastService.new(lat: lat, lon: lon).call }.to raise_error(ForecastService::ForecastError)
      end
    end
  end
end
