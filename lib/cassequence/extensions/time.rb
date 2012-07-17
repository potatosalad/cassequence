class Time
  def self.from_string(value)
    if value.to_i == 0
      raise      
    else
      Time.at(value.to_i) rescue nil
    end
  end
end