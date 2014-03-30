
require 'nokogiri'
require 'yaml'

def title_maker( text, node, depth, converters )
  chars=["=", "-", "*", "+", "#", ":"]
  text = text.sub(%r{^\s*},'')
  return "\n" + text + "\n" + (chars[depth] * text.length)
end

def join_text( text, node, depth, converters )
  return text.split("\n").join(' ')
end

def test_text( text, node, depth, converters )
  return "--" + text + "--"
end

def strip_leading_whitespace( text, node, depth, converters )
  return text.sub(%r{^\s*}m,"\n")
end


index_converters = {
  :primary => {
  },
  :secondary => {
    :before => " ; ",
  },
  :TEXT => {
    #:before => "<TEXT: ",
    #:after => " >\n",
  },
}

initial_coverters = {
  :book => {
    #:before => "book: ",
    #:after => ": end book",
    # :new_converters => initial_coverters,
  },
  :info => {
    :after => "\nContents:\n\n.. toctree::\n    :maxdepth: 2\n",
  },
  :para => {
    :post_proc_self_text => :strip_leading_whitespace,
  },
  :chapter => {
    #:before => "chap: ",
    #:after => ": end chap",
    # :new_converters => initial_coverters,
  },
  :indexterm => {
    :before => "\n.. index::\n    single: ",
    :after => "\n\n",
    :new_converters => index_converters,
  },
  :title => {
    :post_proc_child_text => :title_maker,
  },
  :copyright => {
    :before => ":Copyright: ",
    :post_proc_child_text => :join_text,
  },
  :author => {
    :before => ":Author: ",
    :post_proc_child_text => :join_text,
  },
  :DEFAULT => {
  },
  :TEXT => {
    #:before => "<TEXT: ",
    #:after => " >\n",
  },
}

def get_converter( node, converters )
  if node.element?
    if converters[node.name.to_sym]
      return converters[node.name.to_sym]
    else
      return converters[:DEFAULT]
    end
  else
    return converters[:TEXT]
  end
end

def descend( node, depth, converters )
  $stderr.puts "In Descend: depth: #{depth}, #{node.name}"
  my_text=""
  my_text += get_converter( node, converters )[:before].to_s
  if node.element?
    child_text = ""
    node.children.select { |x| x.element? or x.text? }.each do |child|
      new_converters = get_converter( node, converters )[:new_converters] || converters
      if child.text? and get_converter( node, converters ).has_key?(:post_proc_self_text)
        temp_text = descend child, (depth + 1), new_converters
        child_text += self.send( get_converter( node, converters )[:post_proc_self_text], temp_text, node, depth, converters )
      else
        child_text += descend child, (depth + 1), new_converters
      end
    end
    if get_converter( node, converters ).has_key?(:post_proc_child_text)
      child_text = self.send( get_converter( node, converters )[:post_proc_child_text], child_text, node, depth, converters )
    end
    my_text += child_text
  else
    my_text += node.text
  end
  my_text += get_converter( node, converters )[:after].to_s
  $stderr.puts "mt: #{my_text}"
  return my_text
end

#Nokogiri::XML(open "/home/rlpowell/lojban/dag-cll/coverage/build/cll.xml").traverse {|node| if node.element? ; counter[node.name] = true ; end }; 
print descend Nokogiri::XML(open "/home/rlpowell/lojban/dag-cll/coverage/build/cll.xml").children.select { |x| x.element? and x.name == 'book' }[0], 0, initial_coverters
