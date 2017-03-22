module GlsTrackAndTrace
  class Address

    ADDRESS_MAPPING = {
      name1: 'Name1',
      name2: 'Name2',
      name3: 'Name3',
      contact_name: 'ContactName',
      street1: 'Street1',
      block_no1: 'BlockNo1',
      street2: 'Street2',
      block_no2: 'BlockNo2',
      zip_code: 'ZipCode',
      city: 'City',
      province: 'Province',
      country: 'Country'
    }

    attr_reader :name1, :name2, :name3, :contact_name, :street1, :block_no1,
      :street2, :block_no2, :zip_code, :city, :province, :country

    def initialize(attributes)
      attributes.each do |attr_name, attr_value|
        instance_variable_set "@#{attr_name}", attr_value
      end
    end

    def self.from_xml(xml)
      attributes = {}
      ADDRESS_MAPPING.each do |key, mapped_attr|
        attributes[key] = parse_attribute(xml, mapped_attr)
      end
      new(attributes)
    end

    private

    def self.parse_attribute(xml, mapped_attr)
      el = xml.get_elements("*[local-name() = '#{mapped_attr}']")
      if el.length > 0
        el.first.text
      end
    end

  end
end
