require 'net/http'
require 'rexml/document'
require 'erb'
require 'ostruct'

require 'gls_track_and_trace/package_details'
require 'gls_track_and_trace/errors'

module GlsTrackAndTrace
  class Client

    ENDPOINT_URL = 'https://www.gls-group.eu:443/276-I-PORTAL-WEBSERVICE/services/Tracking'

    SOAP_ACTIONS = {
      'GetTuDetail' => 'https://www.gls-group.eu/Tracking/TUDetailOperation',
      'GetTuList' => 'https://www.gls-group.eu/Tracking/TUListOperation',
      'GetTuPOD' => 'https://www.gls-group.eu/Tracking/TUPODOperation'      
    }

    def initialize(username, password, options = {})
      raise ArgumentError.new("The username needs to be specified.") unless username
      raise ArgumentError.new("The password needs to be specified.") unless password
      @usename = username
      @password = password
      @options = options
      @uri = URI.parse ENDPOINT_URL
    end

    def get_package_details(package_number)
      soap_action = 'GetTuDetail'

      unless package_number.to_s =~ /\A[0-9]{11}\z/
        raise ArgumentError.new("Wrong package number.")
      end

      soap_envelope = generate_soap_envelope soap_action,
        package_number: package_number

      soap_request = create_soap_request soap_action, soap_envelope

      parse_soap_response send_request soap_request
    end

    private

    def render_template(template_name, template_locals = {})
      template_path = File.join(__dir__, "../../templates/#{template_name}.xml.erb")
      template = ERB.new(IO.read(template_path))
      template.result(OpenStruct.new(template_locals).instance_eval { binding })
    end

    def generate_soap_envelope(soap_action, params)
      params.merge!(username: @usename, password: @password)
      action_content = render_template(soap_action, params)
      render_template('soap_envelope', {
        body_content: action_content
      })
    end

    def create_soap_request(soap_action, soap_envelope)
      headers = { 'SOAPAction' => SOAP_ACTIONS.fetch(soap_action) }
      request = Net::HTTP::Post.new @uri.request_uri, headers
      request.body = soap_envelope
      request
    end

    def send_request(request)
      http = Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl = true
      http.open_timeout = @options.fetch(:open_timeout, 5)
      http.read_timeout = @options.fetch(:read_timeout, 5)
      response = http.request(request)
      puts response.body
      response.body
    end

    def parse_soap_response(xml_response)
      doc = REXML::Document.new(xml_response)
      response_element = doc.get_elements("//*[local-name() = 'TuDetailsResponse']").first
      exit_code_element = response_element.get_elements("*[local-name() = 'ExitCode']").first
      error_code = exit_code_element.get_elements("*[local-name() = 'ErrorCode']").first.text.to_i
      error_description = exit_code_element.get_elements("*[local-name() = 'ErrorDscr']").first.text

      if error_code == 0 # not an error actually
        PackageDetails.from_xml response_element
      elsif error_code == 502 # auth failed
        raise AuthenticationError.new(error_description, error_code)
      elsif error_code == 998 # no data found
        raise NoDataFoundError.new(error_description, error_code)
      else # undocumented
        raise RequestError.new(error_description, error_code)
      end
    end

  end
end
