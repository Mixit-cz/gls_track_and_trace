require 'gls_track_and_trace/package_history'
require 'gls_track_and_trace/address'

module GlsTrackAndTrace
  class PackageDetails

    PACKAGE_DETAILS_MAPPING = {
      package_number: 'TuNo',
      national_reference: 'NationalRef',
      consignee_address: 'ConsigneeAddress',
      shipper_address: 'ShipperAddress',
      requester_address: 'RequesterAddress',
      delivered_at: 'DeliveryDateTime',
      picked_at: 'PickupDateTime',
      product: 'Product',
      services: 'Services',
      weight: 'TuWeight',
      customer_reference: 'CustomerReference',
      package_history: 'History'
    }

    attr_reader :package_number, :national_reference, :consignee_address,
      :shipper_address, :requester_address, :delivered_at, :picked_at,
      :product, :services, :weight, :customer_reference, :package_history

    def initialize(attributes)
      attributes.each do |attr_name, attr_value|
        instance_variable_set "@#{attr_name}", attr_value
      end
    end

    def self.from_xml(xml)
      attributes = {}
      PACKAGE_DETAILS_MAPPING.each do |key, mapped_attr|
        attributes[key] = parse_attribute(xml, mapped_attr)
      end
      new(attributes)
    end

    private

    def self.parse_attribute(xml, mapped_attr)
      el = xml.get_elements("*[local-name() = '#{mapped_attr}']")
      if el.length > 0
        if mapped_attr == "History"
          el.map { |ph| PackageHistory.from_xml(ph) }
        elsif mapped_attr == "TuWeight"
          el.first.text.to_f
        elsif mapped_attr == "CustomerReference"
          el.first.get_elements("*[local-name() = 'ReferenceValue']").first.text.to_i
        elsif mapped_attr.end_with?("Address")
          Address.from_xml(el.first)
        elsif mapped_attr.end_with?("DateTime") && !el.first.attributes['xsi:nil']
          Time.new *(%w{ Year Month Day Hour Minut }.map do |atttr|
            el.first.get_elements("*[local-name() = '#{atttr}']").first.text.to_i
          end)
        else
          el.first.text
        end
      end
    end

  end
end
