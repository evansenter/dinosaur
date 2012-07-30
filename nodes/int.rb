class DinoInt < DinoNumber
  init_with_value
  
  def eval
    @eval ||= value.to_i
  end
end
