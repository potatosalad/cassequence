class Boolean
  def self.from_string(value)
    if value.to_s == 'true' or value.to_s == 'false'
      value.to_s == 'true' ? true : false
    else
      raise
    end
  end
end