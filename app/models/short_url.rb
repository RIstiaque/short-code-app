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

    build_short_code(self[:id])
  end

  # Updates the title of a ShortUrl by creating an instance of UpdateTitleJob.
  def update_title!
    self[:title] = reload.title
    save!
  end

  # Finds the ShortUrl associated to the code, if it exists.
  #
  # code: String, shortcode to decode.
  #
  # Returns an instance of a ShortUrl.
  def self.find_by_short_code(code)
    code_to_arr = code.split('')

    id = decode_short_code(code_to_arr, 0, 0)

    ShortUrl.find_by!(id: id)
  end

  # Valide a shortcode based on key characters.
  #
  # code: shortcode to validate
  #
  # Returns a boolean
  def self.validate_short_code(code)
    code.count("^#{CHARACTERS.join}").zero?
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

  # Recursively find mapping to CHARACTERS using id.
  # 
  # id: Id to recursively build shortcode with.
  #
  # Returns a shortCode in reverse order.
  def build_short_code(id)
    return '' unless id.positive?

    rem_char = CHARACTERS[id % CHARACTERS.length]
    id /= CHARACTERS.length
    build_short_code(id) + rem_char
  end

  # Recursively build the id using the short code.
  #
  # char_arr: List of characters in the short code
  # idx: Current index
  # sum: Running sum throughout the recursive process
  #
  # Returns the sum
  private_class_method def self.decode_short_code(char_arr, idx, sum)
    if idx == char_arr.length - 1
      sum + CHARACTERS.index(char_arr[idx])
    else
      sum =
        if idx.zero?
          sum + CHARACTERS.index(char_arr[idx]) * CHARACTERS.length
        else
          (sum + CHARACTERS.index(char_arr[idx])) * CHARACTERS.length
        end

      decode_short_code(char_arr, idx + 1, sum)
    end
  end
end
