# frozen_string_literal: true

require 'httparty'

module ClassesAPI
  def self.get_class_title(classname)
    class_data = HTTParty.post(
      'https://classes.oregonstate.edu/api/?page=fose&route=search',
      body: { other: { srcdb: '999999' }, criteria: [{ field: 'alias', value: classname }] }.to_json
    )

    # api returns titles in ALL CAPS, so turn that into Title Case (capitalize each word)
    class_data['results'][0]['title'].gsub(/\w+/, &:capitalize) if class_data['count'].positive?
  end
end
