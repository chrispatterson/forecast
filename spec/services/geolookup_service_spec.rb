require "rails_helper"

RSpec.describe GeolookupService, type: :model do
  describe "#call" do
    let(:address) { "7437 Race Road Hanover, MD 21076" }
    let(:response_body) {
      "[{\"place_id\":322757774,\"licence\":\"Data © OpenStreetMap contributors, ODbL 1.0. http://osm.org/copyright\",\"osm_type\":\"way\",\"osm_id\":416820275,\"lat\":\"39.1685066\",\"lon\":\"-76.73843041917469\",\"class\":\"office\",\"type\":\"employment_agency\",\"place_rank\":30,\"importance\":5.670023651479389e-05,\"addresstype\":\"office\",\"name\":\"TEKsystems\",\"display_name\":\"TEKsystems, 7437, Race Road, The Enclave at Arundel Preserve, Lennox Park, Hanover, Anne Arundel County, Maryland, 21076, United States\",\"address\":{\"office\":\"TEKsystems\",\"house_number\":\"7437\",\"road\":\"Race Road\",\"neighbourhood\":\"The Enclave at Arundel Preserve\",\"hamlet\":\"Lennox Park\",\"village\":\"Hanover\",\"county\":\"Anne Arundel County\",\"state\":\"Maryland\",\"ISO3166-2-lvl4\":\"US-MD\",\"postcode\":\"21076\",\"country\":\"United States\",\"country_code\":\"us\"},\"boundingbox\":[\"39.1682331\",\"39.1687738\",\"-76.7389325\",\"-76.7379240\"]}]"
    }

    context "with address that doesn't match any results" do
      it "raises an error" do
        stub_request(:get, /nominatim\.openstreetmap\.org/).
        to_return(
          status: 200,
          body: '[]'
        )
        expect { GeolookupService.call("Some address search with no results") }.to raise_error(ArgumentError)
      end
    end

    context "errors from API" do
      it "raises an error if server response with malformed JSON" do
        stub_request(:get, /nominatim\.openstreetmap\.org/).
          to_return(
            status: 200,
            body: '{"malformed'
          )
        expect { GeolookupService.call(:address) }.to raise_error(JSON::ParserError)
      end

      it "raises an error when upstream server errors" do
        stub_request(:get, /nominatim\.openstreetmap\.org/).
          to_return(
            status: 500,
            body: '{}'
          )
        expect { GeolookupService.call(:address) }.to raise_error(GeolookupService::GeolookupError)
      end
    end
  end
end
