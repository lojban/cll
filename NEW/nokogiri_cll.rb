# a possible alternate approach
#
# http://martinfowler.com/bliki/MovingAwayFromXslt.html


#*******************************
#
# CLI Arguments:
#
# 1.  Build type (latex or html)
#
# 2.  Source xml file
#
# NOTE: OTHER DOCUMENTATION IS WITH THE "descend" method below!, so that
# yard knows where to put it.  Generate HTML docs by running "yard
# doc [this file]".
#
#*******************************

require 'nokogiri'
require 'yaml'
require 'debugger'
require 'erubis'

$converters = Hash.new

def templated( template )
  lambda do |text, node, attrs, depth, converters|
    locals = attrs.merge( { "text" => text, "node" => node } )
    return Erubis::Eruby.new(template).result(locals)
  end
end
def latex_wrap( macro )
  lambda do |text, node, attrs, depth, converters|
    return "\\#{macro}{#{text}}"
  end
end

def join_text_raw( text )
  text.split("\n").join(' ')
end

def join_text( )
  lambda do |text, node, attrs, depth, converters|
    join_text_raw( text )
  end
end

def test_text( )
  lambda do |text, node, attrs, depth, converters|
    return "--" + text + "--"
  end
end

def strip_leading_whitespace( )
  lambda do |text, node, attrs, depth, converters|
    return text.sub(%r{^\s*}m,"\n")
  end
end

def slugify_raw( text )
  text.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
end

require_relative "#{ARGV[0]}_converters"

def get_converter( node, converters )
  if node.element?
    if converters[node.name.to_sym]
      return converters[node.name.to_sym]
    else
      $stderr.puts "DEFAULT used on #{node.name.to_sym}"
      return converters[:DEFAULT]
    end
  else
    return converters[:TEXT]
  end
end

# = Documentation
#
# This is the main documentation for this code.
#
# A note on how we gather data: Actual text lives in text nodes.
# Text nodes are not elements.  So what we do is for each element,
# we gather all the child text in order and then run post_proc on it
# (and before text and after text go before and after verbatim).
# The child elements might be elements or they might be text nodes,
# but eventually there are text nodes at the bottom, and from them
# we just gather their text.
#
# == Converters
#
# FIXME: more intro stuff
#
#     Note on quoting, relevant because we're generating LaTeX:
#     'foo\bar' and 'foo\\bar' return exactly the same thing in Ruby.
#     This means that while you can do '\foo{bar}' and there's no
#     problem, you can't do '\foo{bar}\\' and get what you want, because
#     the \\ collapses; you need to do '\foo{bar}\\\\'
#
# Converters take the following:
#
# [:before] Text pasted verbatim, pasted in before the results of any
#          children.
#
# [:after] Same as before, but it comes after the children.
#
# [:post_proc] An array of Post Proc Methods (see below) that
#                       are run against the text of this node itself
#                       before it's used for anything.  If not an
#                       array, treated as though it were an array
#                       with that single element
#
# [:new_converters] BLAH
#
# == Post Proc Methods
#
#
#

note the existance of nokogiri's traverse method.  useful?

def descend( node, depth, converters )
  conv = get_converter( node, converters )
  $stderr.puts "In Descend: depth: #{depth}, #{node.name}, elem: #{node.element?}, text: #{node.text}, #{conv}"
  my_text=""
  my_text += conv[:before].to_s

  if node.element?
    # Collect raw attributes as a hash
    attrs = Hash.new
    node.attributes.map { |x| attrs[x[0]] = x[1].value }

    child_text = ""

    node.children.select { |x| x.element? or x.text? }.each do |child|
      new_converters = conv[:new_converters] || converters
      child_text += descend child, (depth + 1), new_converters
    end
    if conv.has_key?(:post_proc)
        # Loop over post_proc
        ppct = conv[:post_proc]
        if ! ppct.is_a? Array
          ppct = [ ppct ]
        end
        ppct.each do |proc|
          child_text = proc.call( child_text, node, attrs, depth, converters )
        end
    end
    my_text += child_text
  else
    my_text += node.text
  end
  my_text += conv[:after].to_s
  $stderr.puts "mt: #{my_text}"
  return my_text
end

print descend Nokogiri::XML(open ARGV[1]).children.select { |x| x.element? and x.name == 'book' }[0], 0, $converters[:initial_coverters]
