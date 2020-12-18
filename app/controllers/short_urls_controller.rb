# frozen_string_literal: true

# ShortUrls Controller
class ShortUrlsController < ApplicationController
  # Since we're working on an API, we don't have authenticity tokens
  skip_before_action :verify_authenticity_token

  # Returns a JSON object of the top 100 most visited shortcodes.
  def index
    render_or_error do
      short_codes = ShortUrl.order(click_count: :desc).limit(100).map(&:short_code)

      { urls: short_codes }
    end
  end

  # Creates a ShortUrl object with the given url.
  #
  # params:
  #   full_url: The url that will be used to create the ShortUrl.
  #
  # Returns a JSON object of the created ShortUrl's shortcode.
  def create
    render_or_error(:created) do
      full_url = params.require(:full_url)

      short_url = ShortUrl.create!(full_url: full_url)

      { short_code: short_url.short_code }
    end
  end

  # Increments the ShortUrl's view count.
  # Redirect to the accompanying ShortUrl's full URL.
  #
  # params:
  #   id: The shortcode used to identity the URL.
  #
  # Redirects to the associated URL.
  def show
    render_or_error(:found) do
      short_code = params[:id].to_s

      short_code_valid = ShortUrl.validate_short_code(short_code)
      raise StandardError, 'Shortcode `${short_code}` is invalid.' unless short_code_valid

      short_url = ShortUrl.find_by_short_code(short_code)

      short_url.update!(click_count: short_url.click_count + 1)

      short_url
    end
  end
end
