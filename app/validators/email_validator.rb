class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attr_name, value)
    if value.blank?
      return record.errors.add(attr_name, :email_invalid, options)
    end

    value = value.strip

    if invalid_email?(value)
      record.errors.add(attr_name, :email_invalid, options)
    end
  end

  private

  def invalid_email?(value)
    return true unless matches_regex?(value)
    return true if starts_or_ends_with_period?(value)
    return true if period_adjacent_to_at_symbol?(value)
    return true if period_adjacent_to_period?(value)
    return true if contains_mailto?(value)
    return true if contains_invalid_characters?(value)

    false
  end

  def matches_regex?(value)
    value =~ Devise.email_regexp
  end

  def starts_or_ends_with_period?(value)
    value.start_with?('.') || value.end_with?('.')
  end

  def period_adjacent_to_at_symbol?(value)
    value.include?('.@') || value.include?('@.')
  end

  def period_adjacent_to_period?(value)
    value.include?('..')
  end

  def contains_invalid_characters?(value)
    value =~ /[(),*]/
  end

  def contains_mailto?(value)
    value.include?('mailto:')
  end
end
