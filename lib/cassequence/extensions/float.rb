class Float 
  def self.from_string(value)
    if value == '0.0'
      value.to_f
    else
      value.to_f == 0.0 ? raise : value.to_f
    end
  end
end