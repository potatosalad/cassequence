class Integer
  def self.from_string(value)
    if value == '0'
      value.to_i
    else
      value.to_i == 0 ? raise : value.to_i
    end
  end
end