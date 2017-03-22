require_relative '../../test_helper'

class TestGlsTrackAndTraceClient < Minitest::Test
  def setup
    fixtures_path = File.join(__dir__, "../../fixtures")
    @ok_response = IO.read(File.join(fixtures_path, "response_ok.xml"))
    @auth_error_response = IO.read(File.join(fixtures_path, "response_auth_error.xml"))
    @no_data_found_response = IO.read(File.join(fixtures_path, "response_no_data_found.xml"))
    @client = GlsTrackAndTrace::Client.new('username', 'password')
  end

  def test_client_requires_username_and_password
    assert_raises ArgumentError do
      client = GlsTrackAndTrace::Client.new
    end
  end

  def test_get_package_details_with_wrong_package_number
    assert_raises ArgumentError do
      @client.get_package_details('abc')
    end
  end

  def test_get_package_details_with_wrong_credentials
    @client.stub :send_request, @auth_error_response do

      assert_raises GlsTrackAndTrace::AuthenticationError do
        @client.get_package_details('55123456789')
      end

    end
  end

  def test_get_package_details_with_no_data_found
    @client.stub :send_request, @no_data_found_response do

      assert_raises GlsTrackAndTrace::NoDataFoundError do
        @client.get_package_details('55123456789')
      end

    end
  end

  def test_get_package_details_data
    @client.stub :send_request, @ok_response do

      package_number = '55123456789'
      package_details = @client.get_package_details(package_number)

      assert_equal "55123456789", package_details.package_number
      assert_equal 1329461040, package_details.delivered_at.to_i
      assert_equal 10.5, package_details.weight
      assert_equal 10129729, package_details.customer_reference

      arr_package_history = package_details.package_history

      assert_equal "Array", arr_package_history.class.name
      assert_equal 1, arr_package_history.length

      package_history = arr_package_history.first

      assert_equal 1329461040, package_history.date.to_i
      assert_equal "DE 330", package_history.location_code
      assert_equal "Braunschweig", package_history.location_name
      assert_equal "Germany", package_history.country_name
      assert_equal "3.0", package_history.code
      assert_equal "Delivered", package_history.description

      consignee_address = package_details.consignee_address

      assert_equal 'Consignee Name 1', consignee_address.name1
      assert_equal 'Consignee Street 1', consignee_address.street1
      assert_equal '12-345', consignee_address.zip_code
      assert_equal 'Consignee City', consignee_address.city
      assert_equal 'PL', consignee_address.country

    end
  end

end
