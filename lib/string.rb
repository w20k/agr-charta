class String
  def underscore
    gsub(/::/, '/')
      .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr('-', '_')
      .downcase
  end

  def camelcase(first_letter = :upper)
    text = split(/[_\-]+/).map { |word| word[0..0].upcase + word[1..-1].downcase }.join
    text = text[0..0].downcase + text[1..-1] if first_letter == :lower
    text
  end
end
