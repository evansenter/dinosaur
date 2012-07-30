class DinoCall < DinoCore
  init_with_function_name_and_arguments
  
  def eval
    puts "Eval: #{function_name} with #{arguments.map(&:class).join(', ')}"
    arguments.map! { |i| i.is_a?(DinoCall) ? i.eval : i }
    
    if function_name.end_with?(?.)
      resolve(arguments.first.class, function_name[0..-2])[arguments.first, *arguments[1..-1]]
    else
      resolve(DinoBase.context.class, function_name)[*arguments]
    end
  end
  
  def resolve(context, function_name)
    # Simple method resolution.
    original_context = context
    
    while context != Object
      if function = context.functions[function_name]
        return function
      else
        context = context.superclass
      end
    end
    
    raise "Method not found: '#{function_name}' starting at context #{original_context.name}"
  end
end
