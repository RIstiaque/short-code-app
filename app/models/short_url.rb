# ShortUrl Model which that maps urls to short codes.
class ShortUrl < ApplicationRecord

  CHARACTERS = [*'0'..'9', *'a'..'z', *'A'..'Z'].freeze

  validate :validate_full_url

  # Converts the id of a ShortUrl to a shortcode.
  #
  # Returns a string
  def short_code
    return unless self[:id].present?

    char_len = CHARACTERS.length
    char_arr = []

    calculated_id = self[:id]

    # Calculates the shortcode using the length & values of CHARACTERS.
    loop do
      char_arr.push(calculated_id % char_len)
      calculated_id /= char_len

      break unless calculated_id.positive?
    end

    char_arr.reverse!
    char_arr.map { |idx| CHARACTERS[idx] }.join
  end

  def update_title!
  end

  private

  # Validates the full url of a ShortUrl.
  def validate_full_url
    uri = URI.parse(self[:full_url])
    valid = uri.host.present? && uri.is_a?(URI::HTTP)

    errors.add(:full_url, 'is not a valid url') unless valid
  rescue URI::InvalidURIError
    errors.add(:full_url, 'is not a valid url')
  end
end
