require 'open-uri'

# UpdateTitleJob - Job to fetch and store the ShortUrl's title.
class UpdateTitleJob < ApplicationJob
  queue_as :default

  def perform(short_url_id)
    short_url = ShortUrl.find_by!(id: short_url_id)

    website = URI.open(short_url.full_url)
    document = Nokogiri::HTML.parse(website)

    # If a title does not exist then it will finish the calls with an empty string.
    title = document.xpath('//title').children.text

    short_url.update!(title: title)
  end
end
