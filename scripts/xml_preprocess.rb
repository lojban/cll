require 'nokogiri'
require 'yaml'
require 'byebug'

mydir=File.expand_path(File.dirname(__FILE__))
require "#{mydir}/util.rb"

#**************************************************
# FUNCTIONS
#**************************************************

# Takes a node in the XML tree and and replaces it with a node we
# specify using a simple hash.  Copies all attributes to the new
# node.
#
# @param name [String] The name of the new node to make.
#
# @param node [Nokogiri::XML::Element] The node we're replacing.
#
# @param spec [Hash<Symbol, String>] The node to create.
#
#          Example: { name: 'para', role: 'cmavo-compound' }
#
#          Note that the attribute mylang is short for xml:lang
#
# @param children [Array<Nokogiri::XML::Element>] The nodes, if any, to insert as children of the new node.
#
# @param replace [Boolean] Whether or not to replace the node with
#                       the results of making the new node.
#
# @return [Nokogiri::XML::Element] 
def wrap_up name, node, spec, children, replace = true
  if node.name == name
    $stderr.puts "************* Node matches #{name}"
    $stderr.puts node.to_xml
    newname = spec[:name]
    partspec = spec.tap { |x| x.delete(:name) }
    newnode = Nokogiri::XML::Node.new( newname, $document )
    partspec.keys.each do |key|
      if key == :mylang
        newnode[:'xml:lang'] = partspec[:mylang]
      else
        newnode[key] = partspec[key]
      end
    end
    # Copy attributes
    if not node.attributes.empty?
      node.attribute_nodes.each do |attr|
        # drop our custom attributes that are handled elsewhere
        if [ 'valid', 'glossary', 'point', 'se', 'elidable', 'delineated' ].include? attr.name
          next
        end
        # This is basically all about xml:lang
        if attr.namespace
          newnode["#{attr.namespace.prefix}:#{attr.name}"] = attr.value
        else
          newnode[attr.name] = attr.value
        end
      end
    end
    newnode.children = children
    $stderr.puts newnode.to_xml

    if replace
      node.replace newnode
    end

    return newnode
  else
    return false
  end
end

# Converts an element's name, with the additional step of making a
# "role" attribute with the old name.
def convert name, node, newname, replace = true
  wrap_up name, node, { name: newname, role: node.name }, node.children, replace
end

# Used to turn a node into two nested nodes (this comes up
# frequently).
def convert_and_wrap name, node, inner_newname, outer_newname
  if node.name == name
    innernode = convert name, node, inner_newname
    return wrap_up inner_newname, innernode, { name: outer_newname, role: node.name }, innernode.clone
  else
    return false
  end
end

# Wrap a node and also add index information
def indexify name, node, indextype, newname, lang
  if node.name == name
    innerbit = (convert name, node.clone, 'primary', false)
    indexbits = Nokogiri::XML::Node.new( 'indexterm', $document )
    indexbits[:type] = indextype
    indexbits.children = innerbit
    newnode = wrap_up name, node, { name: newname, mylang: lang }, indexbits
    newnode.add_child node.children
    $stderr.puts newnode.to_xml
    return newnode
  else
    return node
  end
end

# Splits a node's text up by words into table columns
#
# The reason this gets complicated is things like:
#
#     <gloss>The-one-named <quote>bear</quote> [past] creates the story.</gloss>
#
# We want to break up all the bits except the quote, and still keep it all in one row.
#
def table_row_by_words node
  newchildren = []
  node.children.each do |child|
    if child.text?
      child.text.split( %r{\s+} ).each do |word|
        unless word =~ %r{^\s*$}
          td = Nokogiri::XML::Node.new( 'td', $document )
          td.content = word
          newchildren << td
        end
      end
    elsif child.element?
      td = Nokogiri::XML::Node.new( 'td', $document )
      td.children = child.clone
      newchildren << td
    end
  end
  tr = Nokogiri::XML::Node.new( 'tr', $document )
  tr.children = Nokogiri::XML::NodeSet.new( $document, newchildren )
  tr[:class] = node.name

  newnode = node.replace tr
  return newnode
end

# Splits a node's children into table columns
def table_row_by_children node
  newchildren = []
  node.children.each do |child|
    unless child.element?
      next
    end

    td = Nokogiri::XML::Node.new( 'td', $document )
    td.children = child.clone
    newchildren << td
  end
  tr = Nokogiri::XML::Node.new( 'tr', $document )
  tr.children = Nokogiri::XML::NodeSet.new( $document, newchildren )
  tr[:class] = node.name

  newnode = node.replace tr
  return newnode
end

# Turns a node into a maximally wide table row.
def flat_table_row node
  td = Nokogiri::XML::Node.new( 'td', $document )
  td[:colspan] = 0
  td.children = node.clone
  tr = Nokogiri::XML::Node.new( 'tr', $document )
  tr.children = td
  tr[:class] = node.name

  newnode = node.replace tr
  return newnode
end

# Wrap node in a glossary entry
def glossify node, text
  if node['glossary'] == 'false'
    return node
  else
    glossterm = Nokogiri::XML::Node.new( 'glossterm', $document )
    glossterm[:linkend] = "valsi-#{slugify(text)}"
    glossterm.children = node.clone
    newnode = node.replace glossterm
    return newnode
  end
end

# Makes something into an informal table with one colgroup
def tableify node
  if node.xpath('title').length > 0
    colgroup = Nokogiri::XML::Node.new( 'colgroup', $document )
    node = wrap_up node.name, node, { name: 'table', role: node.name, class: node.name }, Nokogiri::XML::NodeSet.new( $document, [ colgroup, node.children ].flatten )
  else
    colgroup = Nokogiri::XML::Node.new( 'colgroup', $document )
    node = wrap_up node.name, node, { name: 'informaltable', role: node.name, class: node.name }, Nokogiri::XML::NodeSet.new( $document, [ colgroup, node.children ].flatten )
  end

  # Convert title to caption (see
  # http://www.sagehill.net/docbookxsl/Tables.html ) and re-order things
  newchildren = []
  node.children.each { |child| child.name == 'title' and convert 'title', child, 'caption' }
  node.children.each { |child| child.name == 'caption' and newchildren << child }
  node.children.each { |child| child.name == 'colgroup' and newchildren << child }
  node.children.each { |child| child.name != 'caption' and child.name != 'colgroup' and newchildren << child }
  node.children = Nokogiri::XML::NodeSet.new( $document, newchildren )

  return node
end

#**************************************************
# MAIN CODE
#**************************************************

$document = Nokogiri::XML(File.open ARGV[0]) do |config|
  config.default_xml.noblanks
end

$document.traverse do |node|
  unless node.element?
    next
  end

  # Handle interlinear-gloss, making word-by-word tables.
  #
  #     <interlinear-gloss>
  #       <jbo>pa re ci vo mu xa ze bi so no</jbo>
  #       <gloss>one two three four five six seven eight nine zero</gloss>
  #       <math>1234567890</math>
  #       <natlang>one billion, two hundred and thirty-four million, five hundred and sixty-seven thousand, eight hundred and ninety.</natlang>
  #       
  #     </interlinear-gloss>
  if node.name == 'interlinear-gloss'
    unless node.xpath('jbo').length > 0 and (node.xpath('natlang').length > 0 or node.xpath('gloss').length > 0 or node.xpath('informalequation').length > 0)
      abort "Found a bad interlinear-gloss element; it must have one jbo sub-element and at least one gloss or natlang sub-element: #{node.to_xml}"
    end

    node.children.each do |child|
      unless child.element?
        next
      end

      if child.name == 'jbo' or child.name == 'gloss'
        table_row_by_words child
      elsif child.name == 'informalequation'
        flat_table_row child
      else
        child = convert child.name, child, 'para'

        flat_table_row child
      end
    end

    tableify node
  end

  #     Handle cmavo-list
  #
  #     <cmavo-list>
  #       <cmavo-list-head>
  #         <td>cmavo</td>
  #         <td>gismu</td>
  #         <td>comments</td>
  #       </cmavo-list-head>
  #       <title>Monosyllables of the form CVV:</title>
  #       <cmavo-entry>
  #         <cmavo>nu</cmavo>
  #         <description>event of</description>
  #       </cmavo-entry>
  #       <cmavo-entry>
  #         <gismu>fasnu</gismu>
  #         <rafsi>nun</rafsi>
  #         <description role="place-structure">x1 is an event of (the bridi)</description>
  # 
  # other options:
  # 
  #         <modal-place>as said by</modal-place>
  #         <modal-place se="se">expressing</modal-place>
  # 
  #         <series>mi-series</series>
  # 
  #         <pseudo-cmavo>[N]roi</pseudo-cmavo>
  # 
  #         <attitudinal-scale point="sai">discovery</attitudinal-scale>
  # 
  #       </cmavo-entry>
  if node.name == 'cmavo-list'
    node.children.each do |child|
      unless child.element?
        next
      end

      if child.name == 'cmavo-list-head'
        innernode = wrap_up 'cmavo-list-head', child, { name: 'tr', class: child.name }, child.children
        wrap_up 'tr', innernode, { name: 'thead', role: child.name }, innernode.clone
      elsif child.name == 'title'
        # do nothing
      elsif child.name == 'cmavo-entry'
        child.children.each do |grandchild|
          unless grandchild.element?
            next
          end

          role=grandchild.name
          if grandchild[:role]
            role=grandchild[:role]
          elsif grandchild.name == 'series'
            role='cmavo-series'
          elsif grandchild.name == 'modal-place'
            role="modal-place-#{grandchild[:se]}"
          elsif grandchild.name == 'attitudinal-scale'
            role="modal-place-#{grandchild[:point]}"
          end

          wrap_up grandchild.name, grandchild, { name: 'para', role: role }, grandchild.children
        end

        table_row_by_children child
      else
        abort "Bad node in cmavo-list: #{child.to_xml}"
      end

    end

    tableify node
  end

  # handle interlinear-gloss-itemized
  #
  #   <interlinear-gloss-itemized>
  #     <jbo>
  #       <sumti>mi</sumti>
  #       <elidable>cu</elidable>
  #       <selbri>vecnu</selbri>
  #       <sumti>ti</sumti>
  #       <sumti>ta</sumti>
  #       <sumti>zo'e</sumti>
  #     </jbo>
  #     ...
  if node.name == 'interlinear-gloss-itemized'
    node.children.each do |child|
      unless child.element?
        next
      end

      if child.name == 'jbo' or child.name == 'gloss'
        child.children.each do |grandchild|
          unless grandchild.element?
            next
          end

          convert grandchild.name, grandchild, 'para'
          #origtext = node.text
          #node = convert grandchild.name, grandchild, 'para'
          #if child.name == 'jbo'
          #  node = glossify node, origtext
          #end
        end

        table_row_by_children child
      else
        child = convert child.name, child, 'para'

        flat_table_row child
      end
    end

    tableify node
  end

  # Deal with pronunciation nodes
  if node.name == 'pronunciation'
    node.children.each do |child|
      unless child.element?
        next
      end

      role = "pronunciation-#{child.name}"
      child = wrap_up child.name, child, { name: 'para', role: role }, child.children
      child = wrap_up 'para', child, { name: 'listitem', role: role }, child.clone
    end

    convert 'pronunciation', node, 'itemizedlist'
  end

  if node.name == 'compound-cmavo'
    node.children.each do |child|
      unless child.element?
        next
      end

      if child.name == 'jbo'
        convert 'jbo', child, 'member'
      else
        abort "Unhandled compound-cmavo element #{child.name}"
      end
    end

    node = convert 'compound-cmavo', node, 'simplelist'
  end

  if node.name == 'valsi'
    if node[:valid] == 'false'
      convert 'valsi', node, 'foreignphrase'
    else
      origtext = node.text
      node = indexify 'valsi', node, 'lojban-words', 'foreignphrase', 'jbo'
      node = glossify node, origtext
      $stderr.puts node.to_xml
    end
  end

  wrap_up 'compound', node, { name: 'para', role: 'cmavo-compound' }, node.children

  if node.name == 'grammar-template'
    # Phrasal version
    if [ 'title', 'term', 'member', 'secondary' ].include? node.parent.name
      convert 'grammar-template', node, 'phrase'
      # Block version
    else
      convert_and_wrap 'grammar-template', node, 'para', 'blockquote'
    end
  end

  # For now, jbophrase makes an *index* but not a *glossary*
  node = indexify 'jbophrase', node, 'lojban-phrase', 'foreignphrase', 'jbo'
  if node and node.name == 'foreignphrase'
    if node.parent.name == 'example'
      wrap_up 'foreignphrase', node, { name: 'para', role: 'jbophrase' }, node.children
    end
  end

  # Same treatment for veljvo
  indexify 'veljvo', node, 'lojban-phrase', 'foreignphrase', 'jbo'

  if node.name == 'definition'
    if [ 'title', 'term', 'member', 'secondary' ].include? node.parent.name
      # Phrasal version
      convert 'definition', node, 'phrase'
    else
      # Block version
      convert_and_wrap 'definition', node, 'para', 'blockquote'
    end
  end

  wrap_up 'diphthong', node, { name: 'foreignphrase', mylang: 'jbo', role: node.name }, node.children
  wrap_up 'rafsi', node, { name: 'foreignphrase', mylang: 'jbo', role: node.name }, node.children
  wrap_up 'letteral', node, { name: 'foreignphrase', mylang: 'jbo', role: node.name }, node.children
  wrap_up 'cmevla', node, { name: 'foreignphrase', mylang: 'jbo', role: node.name }, node.children
  wrap_up 'morphology', node, { name: 'foreignphrase', mylang: 'jbo', role: node.name }, node.children

  wrap_up 'score', node, { name: 'para', role: 'lujvo-score' }, node.children

  convert_and_wrap 'inlinemath', node, 'mathphrase', 'inlineequation'

  convert_and_wrap 'math', node, 'mathphrase', 'informalequation'

  convert 'cmavo', node, 'emphasis'
  convert 'gismu', node, 'para'
  convert 'selmaho', node, 'para'

  convert 'comment', node, 'emphasis'

  wrap_up 'content', node, { name: 'phrase', role: 'definition-content' }, node.children

  # Turn it into an informaltable with maximally wide rows
  if node.name == 'lujvo-making'
    node.children.each do |child|
      unless child.element?
        next
      end

      child = convert child.name, child, 'para'

      flat_table_row child
    end
    tableify node
  end

  # Turn it into an informaltable with maximally wide rows
  if node.name == 'lojbanization'
    node.children.each do |child|
      unless child.element?
        next
      end

      child = convert child.name, child, 'para'

      flat_table_row child
    end
    tableify node
  end
end

doc = $document.to_xml
# Put in our own header
doc = doc.gsub( %r{^.*<book [^>]*>$}m, '<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE book PUBLIC "-//OASIS//DTD DocBook XML V5.0//EN" "dtd/docbook-5.0.dtd"[
<!ENTITY % allent SYSTEM "xml/iso-pub.ent">
%allent;
]>
<book xmlns:xlink="http://www.w3.org/1999/xlink">
' )

puts doc

exit 0
