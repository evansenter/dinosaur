class Array
  def self.wrap(object)
    object.kind_of?(Array) ? object : [object]
  end
end
