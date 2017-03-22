module GlsTrackAndTrace
  class PackageHistory

    PACKAGE_HISTORY_MAPPING = {
      date: 'Date',
      location_code: 'LocationCode',
      location_name: 'LocationName',
      country_name: 'CountryName',
      code: 'Code',
      description: 'Desc',
    }

    attr_reader :date, :location_code, :location_name, :country_name, :code,
      :description

    def initialize(attributes)
      attributes.each do |attr_name, attr_value|
        instance_variable_set "@#{attr_name}", attr_value
      end
    end

    def self.from_xml(xml)
      attributes = {}
      PACKAGE_HISTORY_MAPPING.each do |key, mapped_attr|
        attributes[key] = parse_attribute(xml, mapped_attr)
      end
      new(attributes)
    end

    private

    def self.parse_attribute(xml, mapped_attr)
      el = xml.get_elements("*[local-name() = '#{mapped_attr}']")
      if el.length > 0
        if mapped_attr == "Date" && !el.first.attributes['xsi:nil']
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
