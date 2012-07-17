class Integer
  def self.from_string(value)
    value.to_i == 0 ? raise : value.to_i
  end
end