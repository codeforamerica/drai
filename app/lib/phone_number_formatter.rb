module PhoneNumberFormatter
  def self.format(phone_number_string)
    return phone_number_string unless phone_number_string.present?

    cleaned_string = phone_number_string.gsub(/\D+/, "")
    if (cleaned_string.length == 11) && (cleaned_string[0] == '1')
      "+" + cleaned_string
    elsif cleaned_string.length == 10
      "+1" + cleaned_string
    end
  end
end
