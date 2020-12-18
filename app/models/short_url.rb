# ShortUrl Model which that maps urls to short codes.
class ShortUrl < ApplicationRecord

  CHARACTERS = [*'0'..'9', *'a'..'z', *'A'..'Z'].freeze

  validates_presence_of :full_url
  validate :validate_full_url

  after_create :fetch_and_store_title

  # Calls UpdateTitleJob to fetch and set the ShortUrl's title.
  def fetch_and_store_title
    UpdateTitleJob.perform_now(self[:id])
  end

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

  # Updates the title of a ShortUrl by creating an instance of UpdateTitleJob.
  def update_title!
    self[:title] = reload.title
    save!
  end

  # Finds the ShortUrl associated to the code, if it exists.
  #
  # code: String, shortcode to convert to base 10.
  #
  # Returns an instance of a ShortUrl.
  def self.find_by_short_code(code)
    id = 0
    char_len = CHARACTERS.length
    key_arr = code.split('')

    key_arr.each_with_index do |char, idx|
      if idx.zero?
        id += CHARACTERS.index(char) * char_len
      elsif idx == key_arr.length - 1
        id += CHARACTERS.index(char)
      else
        id = (id + CHARACTERS.index(char)) * char_len
      end
    end

    ShortUrl.find_by!(id: id)
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
