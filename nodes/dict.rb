class DinoDict < DinoCore
  init_with_arguments
  
  add_function("get") do |this, argument|
    this.eval[argument.eval]
  end
  
  def eval
    @eval ||= arguments.inject({}) { |hash, (k_v_hash)| hash.tap { hash[k_v_hash[:key].eval] = k_v_hash[:value] } }
  end
end
