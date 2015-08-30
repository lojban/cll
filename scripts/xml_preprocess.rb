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
# @param name [String] The name of the note we're replacing; if this
#       doesn't match, just return false.  Used to save a bunch of
#       "if" statements.
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
    newnode = wrap_up name, node, { name: newname, mylang: lang, role: name }, indexbits
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
  children = node.children.to_a
  children.each_index do |child_index|
    child = children[child_index]
    sibling = (child_index+1 == children.length) ? nil : children[child_index+1]
    if not child
        next
    end
    if child.text?
      words = child.text.gsub('--',"\u00A0").split( %r{\s+} )
      # Hide ellipses for now
      words.delete('…')
      words.each_index do |word_index|
        word = words[word_index]
        unless word =~ %r{^\s*$}
          td = Nokogiri::XML::Node.new( 'td', $document )
          td.content = word
          if word_index == words.length-1 && word[-1] == "-" && sibling && !(sibling.text?) && sibling.element? && sibling.name == 'quote'
              td << sibling.dup
              children[child_index+1] = nil
          end
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

#**************************************************
# NEW-STYLE FUNCTIONS
#**************************************************
# Add index information ; put the index entry element as the first
# child of this node
def indexify!( node:, indextype:, role: nil )
  if role == nil
    role = node.name
  end
  node.children.first.add_previous_sibling %Q{<indexterm type="#{indextype}"><primary role="#{role}">#{node.text}</primary></indexterm>}
  return node
end

# Converts a node's name and sets the role (to the old name by
# default), with an optional language
def convert!( node:, newname:, role: nil, lang: nil )
  unless role
    role = node.name
  end
  if lang
    node['xml:lang'] = lang
  end
  node['role'] = role
  node.name = newname
  node
end

# Loops over the children of a node, complaining if a bad child is
# found and handling non-element children.
def handle_children( node:, allowed_children_names:, &proc )
  node.children.each do |child|
    unless child.element?
      next
    end

    if ! allowed_children_names.include? child.name 
      abort "Found a bad element, #{child.name}, as a child of #{node.name}.  Context: #{node.to_xml}"
    end
    
    yield child
  end
end

# Wrap node in a glossary entry
def glossify node, orignode
  $stderr.puts "glosscheck: #{orignode} -- #{orignode['glossary']} -- #{orignode['valid']}"
  if orignode['glossary'] == 'false' or orignode['valid'] == 'false'
    return node
  else
    node.replace(%Q{<glossterm linkend="valsi-#{slugify(orignode.text)}">#{node}</glossterm>})
  end
end

# Makes something into a table/informaltable with one colgroup
def tableify node

  # Convert title to caption (see
  # http://www.sagehill.net/docbookxsl/Tables.html )
  node.css("title").each { |e| convert 'title', e, 'caption' }
  caption = node.css('caption')
  node.css('caption').remove

  # Add a colgroup and caption as the first children, to make docbook happy
  node.children.first.add_previous_sibling "#{caption}<colgroup/>"

  # Save the old name
  node['role'] = node.name
  node['class'] = node.name

  # Turn it into a table
  if node.css('caption').length > 0
    node.name = 'table'
  else
    node.name = 'informaltable'
  end

  return node
end

# Break a table into two tables; anything that matches css_string
# goes into the second table, preserving order
def table_split( node, css_string )
  if node['split'] != 'false' && node.css(css_string).length > 0 && node.css(css_string).length != node.children.length
    newnode = node.clone
    newnode.children.each do |child|
      if child.css(css_string).length == 0
        child.remove
      end
    end
    node.children.each do |child|
      if child.css(css_string).length > 0
        child.remove
      end
    end
    node.add_next_sibling newnode
  end

  node
end

#**************************************************
# MAIN CODE
#**************************************************

$document = Nokogiri::XML(File.open ARGV[0]) do |config|
  config.default_xml.noblanks
end

##      <lujvo-making>
##        <jbo>bralo'i</jbo>
##        <gloss><quote>big-boat</quote></gloss>
##        <natlang>ship</natlang>
##      </lujvo-making>
#
# Turn lujvo-making into an informaltable with one column per row
$document.css('lujvo-making').each do |node|
  # Convert children into docbook elements
  node.css('jbo,natlang,gloss').each { |e| convert!( node: e, newname: 'para' ) }
  node.css('score').each { |e| convert!( node: e, newname: 'para', role: 'lujvo-score' ) }
  node.css('inlinemath').each { |e| convert!( node: e, newname: 'mathphrase' ) ; e.replace("<inlineequation role='inlinemath'>#{e}</inlineequation>" ) }
  node.css('rafsi').each { |e| convert!( node: e, newname: 'foreignphrase', lang: 'jbo' ) }
  node.css('veljvo').each { |e| convert!( node: e, newname: 'foreignphrase', lang: 'jbo' ) ; indexify!(node: e, indextype: 'lojban-phrase') ; e.replace("<para>from #{e}</para>") }

  # Make things into rows
  node.children.each { |e| e.replace("<tr><td>#{e}</td></tr>") }

  tableify node
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
$document.css('interlinear-gloss').each do |node|
  unless node.xpath('jbo').length > 0 and (node.xpath('natlang').length > 0 or node.xpath('gloss').length > 0 or node.xpath('math').length > 0)
    abort "Found a bad interlinear-gloss element; it must have one jbo sub-element and at least one gloss or natlang or math sub-element.  Context: #{node.to_xml}"
  end

  handle_children( node: node, allowed_children_names: [ 'jbo', 'gloss', 'math', 'natlang', 'para' ] ) do |child|
    if child.name == 'jbo' or child.name == 'gloss'
      table_row_by_words child
    elsif child.name == 'math'
      child.replace("<tr class='informalequation'><td colspan='0'>#{child}</td></tr>")
    else
      convert!( node: child, newname: 'para' )
      child.replace("<tr class='para'><td colspan='0'>#{child}</td></tr>")
    end
  end

  tableify node

  # If there are natlang, comment or para lines, turn it into *two* tables
  table_split( node, 'td[colspan="0"] [role=natlang],td[colspan="0"] [role=comment],td[colspan="0"] [role=para]' )
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
$document.css('interlinear-gloss-itemized').each do |node|
  handle_children( node: node, allowed_children_names: [ 'jbo', 'gloss', 'natlang', 'sumti', 'selbri', 'elidable', 'comment' ] ) do |child|
    if child.name == 'jbo' or child.name == 'gloss'
      handle_children( node: child, allowed_children_names: [ 'sumti', 'selbri', 'elidable', 'cmavo', 'comment' ] ) do |grandchild|
        if grandchild.name == 'elidable'
          if grandchild.text == ''
            grandchild.content = '-'
          else
            grandchild.content = "[#{grandchild.content}]"
          end
        end
        convert!( node: grandchild, newname: 'para' )
      end

      child.children.each { |e| e.replace("<td>#{e}</td>") }
      child['class'] = child.name
      child.name = 'tr'
    else
      convert!( node: child, newname: 'para' )

      child.replace("<tr class='para'><td colspan='0'>#{child}</td></tr>")
    end
  end

  tableify node

  # If there are natlang, comment or para lines, turn it into *two* tables
  table_split( node, 'td[colspan="0"] [role=natlang],td[colspan="0"] [role=comment],td[colspan="0"] [role=para]' )
end


# Math
## <natlang>Both <inlinemath>2 + 2 = 4</inlinemath> and <inlinemath>2 x 2 = 4</inlinemath>.</natlang>
$document.css('inlinemath').each { |e| convert!( node: e, newname: 'mathphrase' ) ; e.replace("<inlineequation role='inlinemath'>#{e}</inlineequation>" ) }

## <math>3:22:40 + 0:3:33 = 3:26:13</math>
$document.css('math').each { |e| convert!( node: e, newname: 'mathphrase' ) ; e.replace("<informalequation role='math'>#{e}</informalequation>" ) }

##       <pronunciation>
##         <jbo>.e'o ko ko kurji</jbo>
##         <jbo role="pronunciation">.E'o ko ko KURji</jbo>
##       </pronunciation>
$document.css('pronunciation').each do |node|
  handle_children( node: node, allowed_children_names: [ 'jbo', 'ipa', 'natlang', 'comment' ] ) do |child|
    role = "pronunciation-#{child.name}"
    convert!( node: child, newname: 'para', role: role )
    child.replace(%Q{<listitem role="#{role}">#{child}</listitem>}) 
  end

  convert!( node: node, newname: 'itemizedlist' )
end

##       <compound-cmavo>
##         <jbo>.iseci'i</jbo>
##         <jbo>.i se ci'i</jbo>
##       </compound-cmavo>
$document.css('compound-cmavo').each do |node|
  handle_children( node: node, allowed_children_names: [ 'jbo' ] ) do |child|
    convert!( node: child, newname: 'member' )
  end

  convert!( node: node, newname: 'simplelist' )
end

## <valsi>risnyjelca</valsi> (heart burn) might have a place structure like:</para>
$document.css('valsi').each do |node|
  # We make a glossary entry unless it's marked valid=false
  if node[:valid] == 'false'
    convert!( node: node, newname: 'foreignphrase' )
  else
    orignode = node.dup
    convert!( node: node, newname: 'foreignphrase', lang: 'jbo' )
    indexify!( node: node, indextype: 'lojban-words', role: orignode.name )
    node = glossify node, orignode
    $stderr.puts "valsi: #{node.to_xml}"
  end
end

##    <simplelist>
##      <member><grammar-template>
##          X .i BAI bo Y
##      </grammar-template></member>
$document.css('grammar-template').each do |node|
  # Phrasal version
  if [ 'title', 'term', 'member', 'secondary' ].include? node.parent.name
    convert!( node: node, newname: 'phrase' )
  else
    # Block version
    convert!( node: node, newname: 'para' )
    node.replace("<blockquote role='grammar-template'>#{node}</blockquote>")
  end
end

## <para><definition><content>x1 is a nest/house/lair/den for inhabitant x2</content></definition></para>
$document.css('definition').each do |node|
  if [ 'title', 'term', 'member', 'secondary' ].include? node.parent.name
    # Phrasal version
    convert!( node: node, newname: 'phrase' )
  else
    # Block version
    convert!( node: node, newname: 'para' )
    node.replace("<blockquote role='definition'>#{node}</blockquote>")
  end
end

# Turn it into an informaltable with maximally wide rows
$document.css('lojbanization').each do |node|
  handle_children( node: node, allowed_children_names: [ 'jbo', 'natlang' ] ) do |child|
    origname=child.name
    convert!( node: child, newname: 'para', role: child['role'] )
    child.replace("<tr class='#{origname}'><td colspan='0'>#{child}</td></tr>")
  end
  tableify node
end

$document.css('jbophrase').each do |node|
  # For now, jbophrase makes an *index* but not a *glossary*
  indexify!( node: node, indextype: 'lojban-phrase' )
  convert!( node: node, newname: 'foreignphrase', lang: 'jbo' )

  if node.parent.name == 'example'
    convert!( node: node, newname: 'para', role: 'jbophrase' )
  end
end

$document.traverse do |node|
  unless node.element?
    next
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
  #
  #       More:
  #
  #      <cmavo-entry>
  #        <cmavo>pu'u</cmavo>
  #        <description>process of</description>
  #        <gismu>pruce</gismu>
  #        <rafsi>pup</rafsi>
  #        <description role="place-structure">x1 is a process of (the bridi)</description>
  #      </cmavo-entry>
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
#         <cmavo>ju'i</cmavo>
#         <gismu>[jundi]</gismu>
#         <attitudinal-scale point="sai">attention</attitudinal-scale>
#         <attitudinal-scale point="cu'i">at ease</attitudinal-scale>
#         <attitudinal-scale point="nai">ignore me/us</attitudinal-scale>
#         <description role="long">
# 
#           <quote>Attention/Lo/Hark/Behold/Hey!/Listen, X</quote>; indicates an important communication that the listener should listen to.
#         </description>

        if child.xpath('./cmavo').length > 0 and child.xpath('./description').length > 0
          newchildren = []
          oldchild = child.clone

          child.xpath('.//comment()').remove

          child.xpath('./cmavo').each do |cmavo|
            td = Nokogiri::XML::Node.new( 'td', $document )
            td.content = cmavo.text
            newchildren << td
            cmavo.remove
          end

          if child.xpath('./gismu').length > 0
            child.xpath('./gismu').each do |gismu|
              td = Nokogiri::XML::Node.new( 'td', $document )
              td.content = gismu.text
              newchildren << td
              gismu.remove
            end
          end

          if child.xpath('./selmaho').length > 0
            child.xpath('./selmaho').each do |selmaho|
              td = Nokogiri::XML::Node.new( 'td', $document )
              td.content = selmaho.text
              newchildren << td
              selmaho.remove
            end
          end

          if child.xpath('./series').length > 0
            child.xpath('./series').each do |series|
              td = Nokogiri::XML::Node.new( 'td', $document )
              td.content = series.text
              newchildren << td
              series.remove
            end
          end

          if child.xpath('./foreignphrase[@role="rafsi"]').length > 0
            child.xpath('./foreignphrase[@role="rafsi"]').each do |rafsi|
              td = Nokogiri::XML::Node.new( 'td', $document )
              td.content = rafsi.text
              newchildren << td
              rafsi.remove
            end
          end

          if child.xpath('./attitudinal-scale[@point="sai"]').length > 0
            td = Nokogiri::XML::Node.new( 'td', $document )
            td.content = child.xpath('./attitudinal-scale[@point="sai"]').map { |x| x.text }.join(' ; ')
            newchildren << td
            child.xpath('./attitudinal-scale[@point="sai"]').remove
          end

          if child.xpath("./attitudinal-scale[@point=\"cu'i\"]").length > 0
            td = Nokogiri::XML::Node.new( 'td', $document )
            td.content = child.xpath("./attitudinal-scale[@point=\"cu'i\"]").map { |x| x.text }.join(' ; ')
            newchildren << td
            child.xpath("./attitudinal-scale[@point=\"cu'i\"]").remove
          end

          if child.xpath('./attitudinal-scale[@point="nai"]').length > 0
            td = Nokogiri::XML::Node.new( 'td', $document )
            td.content = child.xpath('./attitudinal-scale[@point="nai"]').map { |x| x.text }.join(' ; ')
            newchildren << td
            child.xpath('./attitudinal-scale[@point="nai"]').remove
          end

          descs=child.xpath('./description')

          # Check if we missed something (we have if there's
          # anything left except descriptions)
          if descs.length != child.children.length
            abort "Unhandled node in cmavo-list.  #{descs.length} != #{child.children.length} I'm afraid you'll have to look at the code to see which one.  Here's the whole thing: #{oldchild.to_xml}\n\nhere's what we have left: #{child.to_xml}\n\nand here's what we have so far: #{Nokogiri::XML::NodeSet.new( $document, newchildren ).to_xml}"
          end

          short_descs=[]
          long_descs=[]
          descs.each do |desc|
            if desc.attributes['role'] and (desc.attributes['role'].value == 'place-structure' or desc.attributes['role'].value == 'long')
              long_descs << desc
            else
              short_descs << desc
            end
          end

          short_descs.each do |desc|
            td = Nokogiri::XML::Node.new( 'td', $document )
            td.content = desc.text
            newchildren << td
          end

          trs = []

          tr1 = Nokogiri::XML::Node.new( 'tr', $document )
          tr1.children = Nokogiri::XML::NodeSet.new( $document, newchildren )
          tr1[:class] = 'cmavo-entry-main'

          trs << tr1

          long_descs.each do |desc|
            convert!( node: desc, newname: 'para', role: desc['role'] )
            trs << $document.parse("<tr class='cmavo-entry-long-desc'><td colspan='0'>#{desc}</td></tr>").first
          end

          group = Nokogiri::XML::NodeSet.new( $document, trs )

          child = child.replace group
        else
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
              role="attitudinal-scale-#{grandchild[:point]}"
            end

            wrap_up grandchild.name, grandchild, { name: 'para', role: role }, grandchild.children
          end

          child.children.each { |e| e.replace("<td>#{e}</td>") }
          child['class'] = child.name
          child.name = 'tr'
        end
      else
        abort "Bad node in cmavo-list: #{child.to_xml}"
      end

    end

    tableify node
  end

  wrap_up 'compound', node, { name: 'para', role: 'cmavo-compound' }, node.children

  wrap_up 'diphthong', node, { name: 'foreignphrase', mylang: 'jbo', role: node.name }, node.children
  wrap_up 'rafsi', node, { name: 'foreignphrase', mylang: 'jbo', role: node.name }, node.children
  wrap_up 'letteral', node, { name: 'foreignphrase', mylang: 'jbo', role: node.name }, node.children
  wrap_up 'cmevla', node, { name: 'foreignphrase', mylang: 'jbo', role: node.name }, node.children
  wrap_up 'morphology', node, { name: 'foreignphrase', mylang: 'jbo', role: node.name }, node.children

  if (not node.parent) or node.parent.name != 'cmavo-entry'
    convert 'cmavo', node, 'emphasis'
    convert 'gismu', node, 'para'
  end

  convert 'comment', node, 'emphasis'

  wrap_up 'content', node, { name: 'phrase', role: 'definition-content' }, node.children

end

# Drop attributes that docbook doesn't recognize
$document.xpath('//@glossary').remove
$document.xpath('//@delineated').remove
$document.xpath('//@elidable').remove
$document.xpath('//@valid').remove
$document.xpath('//@split').remove

doc = $document.to_xml
# Put in our own header
doc = doc.gsub( %r{^.*<book [^>]*>}m, '<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE book PUBLIC "-//OASIS//DTD DocBook XML V5.0//EN" "dtd/docbook-5.0.dtd"[
<!ENTITY % allent SYSTEM "xml/iso-pub.ent">
%allent;
]>
<book xmlns:xlink="http://www.w3.org/1999/xlink">
' )

puts doc

exit 0
