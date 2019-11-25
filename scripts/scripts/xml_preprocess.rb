require 'nokogiri'
require 'yaml'
# require 'byebug'

mydir=File.expand_path(File.dirname(__FILE__))
require "#{mydir}/util.rb"

#**************************************************
# FUNCTIONS
#**************************************************

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
      words = child.text.gsub('--',"\u00A0").split( %r{\s+} )
      # Hide ellipses for now
      words.delete('…')
      words.each_index do |word_index|
        word = words[word_index]
        unless word =~ %r{^\s*$}
          td = $document.parse("<td></td>").first
          # Handle dashes
          if word == '[-]'
            td.content = '-'
          elsif word == '-'
            td.content = ''
          else
            td.content = word
          end

          # Handle word-hyphen-quote, i.e.: lerfu-<quote>c</quote>,
          # which should stay together
          if word_index == words.length-1 && word[-1] == "-" && child.next && !(child.next.text?) && child.next.element? && child.next.name == 'quote'
            td << child.next.dup
            # Skip processing the quote since we just included it
            child.next['skip'] = 'true'
          end
          newchildren << td
        end
      end
    elsif child.element? and child['skip'] != 'true'
      newchildren << $document.parse("<td>#{child}</td>").first
    end
  end
  newnode = node.replace( "<tr class='#{node.name}'></tr>" ).first
  newnode.children = Nokogiri::XML::NodeSet.new( $document, newchildren )

  return newnode
end

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
  if ['tr', 'td'].include? newname
    node['class'] = role
  else
    node['role'] = role
  end
  node.name = newname
  node
end

# Loops over the children of a node, complaining if a bad child is
# found and handling non-element children.
def handle_children( node:, allowed_children_names:, ignore_others: false, &proc )
  node.children.each do |child|
    unless child.element?
      next
    end

    if ! allowed_children_names.include?( child.name )
      if ignore_others
        next
      else
        abort "Found a bad element, #{child.name}, as a child of #{node.name}.  Context: #{node.to_xml}"
      end
    end

    yield child
  end
end

# Wrap node in a glossary entry
def glossify node, orignode
  $stderr.puts "glosscheck: #{orignode} -- #{orignode['glossary']} -- #{orignode['valid']}"
  if orignode['glossary'] == 'false' or orignode['valid'] == 'false' or orignode['valid'] == 'maybe'
    return node
  else
    convert!( node: node, newname: 'glossterm' )
    node['linkend'] = "valsi-#{slugify(orignode.text)}"
    return node
  end
end

# Makes something into a table/informaltable with one colgroup
def tableify node

  # Convert title to caption (see
  # http://www.sagehill.net/docbookxsl/Tables.html )
  node.css("title").each { |e| convert!( node: e, newname: 'caption' ) }
  caption = node.css('caption')
  node.css('caption').remove

  # Add a colgroup and caption as the first children, to make docbook happy
  node.children.first.add_previous_sibling "#{caption}<colgroup/>"

  # Save the old name
  if ! node['role']
    node['role'] = node.name
  end
  if ! node['class']
    node['class'] = node.name
  end

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
      unless child.element?
        next
      end

      if child.css(css_string).length == 0
        child.remove
      end
    end
    node.children.each do |child|
      unless child.element?
        next
      end

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
  config.strict
  config.options = Nokogiri::XML::ParseOptions::DTDLOAD   # Needed for the external DTD to be loaded
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
  node.css('dbinlinemath').each { |e| convert!( node: e, newname: 'mathphrase' ) ; e.replace("<inlineequation role='dbinlinemath'>#{e}</inlineequation>" ) }
  node.css('rafsi').each { |e| convert!( node: e, newname: 'foreignphrase', lang: 'jbo' ) }
  node.css('veljvo').each { |e| convert!( node: e, newname: 'foreignphrase', lang: 'jbo' ) ; indexify!(node: e, indextype: 'lojban-phrase') ; e.replace("<para>from #{e}</para>") }

  # Make things into rows
  node.children.each { |e| e.element? && e.replace("<tr><td>#{e}</td></tr>") }

  tableify node
end

# Handle interlinear-gloss, making word-by-word tables.
#
#     <interlinear-gloss>
#       <jbo>pa re ci vo mu xa ze bi so no</jbo>
#       <gloss>one two three four five six seven eight nine zero</gloss>
#       <dbmath>1234567890</dbmath>
#       <natlang>one billion, two hundred and thirty-four million, five hundred and sixty-seven thousand, eight hundred and ninety.</natlang>
#       
#     </interlinear-gloss>
$document.css('interlinear-gloss').each do |node|
  unless (node.css('jbo').length > 0 or node.css('jbophrase').length > 0) and (node.css('natlang').length > 0 or node.css('gloss').length > 0 or node.css('dbmath').length > 0 or node.css('mmlmath').length > 0)
    abort "Found a bad interlinear-gloss element; it must have one jbo or jbophrase sub-element and at least one gloss or natlang or dbmath/mmlmath sub-element.  Context: #{node.to_xml}"
  end

  handle_children( node: node, allowed_children_names: [ 'jbo', 'jbophrase', 'gloss', 'dbmath', 'mmlmath', 'natlang', 'para' ] ) do |child|
    if child.name == 'jbo' or child.name == 'gloss'
      table_row_by_words child
    elsif child.name == 'dbmath'
      child.replace("<tr class='informalequation'><td colspan='0'>#{child}</td></tr>")
    elsif child.name == 'mmlmath'
      child.replace("<tr class='informalequation'><td colspan='0'>#{child}</td></tr>" )
    else
      convert!( node: child, newname: 'para' )
      child.replace("<tr class='para'><td colspan='0'>#{child}</td></tr>" )
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
            if grandchild[:elidable] != 'false'
              grandchild.content = "[#{grandchild.content}]"
            end
          end
        end
        convert!( node: grandchild, newname: 'para' )
      end

      child.children.each { |e| e.element? && e.replace("<td>#{e}</td>") }
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
## <natlang>Both <dbinlinemath>2 + 2 = 4</dbinlinemath> and <dbinlinemath>2 x 2 = 4</dbinlinemath>.</natlang>
$document.css('dbinlinemath').each { |e| convert!( node: e, newname: 'mathphrase' ) ; e.replace("<inlineequation role='dbinlinemath'>#{e}</inlineequation>" ) }
$document.css('mmlinlinemath').each { |e| e.replace( "<inlineequation role='mmlinlinemath'><math>#{e.children.to_xml}</math></inlineequation>" ) }

## <dbmath>3:22:40 + 0:3:33 = 3:26:13</dbmath>
$document.css('dbmath').each { |e| convert!( node: e, newname: 'mathphrase' ) ; e.replace("<informalequation role='dbmath'>#{e}</informalequation>" ) }
$document.css('mmlmath').each { |e| e.replace( "<informalequation role='mmlmath'><math display='block'>#{e.children.to_xml}</math></informalequation>" ) }

##       <pronunciation>
##         <jbo>.e'o ko ko kurji</jbo>
##         <jbo role="pronunciation">.E'o ko ko KURji</jbo>
##       </pronunciation>
##
##       <compound-cmavo>
##         <jbo>.iseci'i</jbo>
##         <jbo>.i se ci'i</jbo>
##       </compound-cmavo>
$document.css('pronunciation, compound-cmavo').each do |node|
  handle_children( node: node, allowed_children_names: [ 'jbo', 'ipa', 'natlang', 'comment' ] ) do |child|
    role = "#{node.name}-#{child.name}"
    convert!( node: child, newname: 'para', role: role )
    child.replace(%Q{<listitem role="#{role}">#{child}</listitem>}) 
  end

  convert!( node: node, newname: 'itemizedlist' )
end

## <valsi>risnyjelca</valsi> (heart burn) might have a place structure like:</para>
$document.css('valsi').each do |node|
  # We make a glossary entry unless it's marked valid=false, but
  # don't insert links in titles, please.  Or index references.
  if node[:valid] == 'false' or node[:valid] == 'maybe' or [ 'title', 'term', 'primary', 'secondary' ].include? node.parent.name
    convert!( node: node, newname: 'foreignphrase', lang: 'jbo' )
  else
    orignode = node.dup
    node = glossify node, orignode
    node = node.replace("<foreignphrase xml:lang='jbo'>#{node}</foreignphrase>")
    indexify!( node: node, indextype: 'lojban-word', role: orignode.name )
    # $stderr.puts "valsi: #{node.to_xml}"
  end
end

##    <simplelist>
##      <member><grammar-template>
##          X .i BAI bo Y
##      </grammar-template></member>
$document.css('grammar-template').each do |node|
  # Phrasal version
  if [ 'title', 'term', 'member', 'secondary', 'td' ].include? node.parent.name
    convert!( node: node, newname: 'phrase' )
  else
    # Block version
    convert!( node: node, newname: 'para' )
    node.replace("<blockquote role='grammar-template'>#{node}</blockquote>")
  end
end

## <para><definition><content>x1 is a nest/house/lair/den for inhabitant x2</content></definition></para>
$document.css('definition').each do |node|
  node.css('content').each do |child|
    convert!( node: child, newname: 'phrase', role: 'definition-content' )
  end
  if [ 'title', 'term', 'member', 'secondary', 'td' ].include? node.parent.name
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
  # Don't insert links in titles, please.  Or index references.
  if ! [ 'title', 'term', 'primary', 'secondary' ].include? node.parent.name
    # For now, jbophrase makes an *index* but not a *glossary*
    indexify!( node: node, indextype: 'lojban-phrase' )
  end

  convert!( node: node, newname: 'foreignphrase', lang: 'jbo' )

  if node.parent.name == 'example'
    convert!( node: node, newname: 'para', role: 'jbophrase' )
  end
end

$document.css('cmavo-list').each do |node|
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
  handle_children( node: node, allowed_children_names: [ 'cmavo-list-head', 'title', 'cmavo-entry' ] ) do |child|
    if child.name == 'cmavo-list-head'
      origname=child.name
      new = convert!( node: child, newname: 'tr' )
      new.replace( %Q{<thead role="#{origname}">#{new}</thead>} )
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

      handle_children( node: child, allowed_children_names: [ 'gismu', 'cmavo', 'selmaho', 'series', 'rafsi-group', 'rafsi', 'compound', 'modal-place', 'attitudinal-scale', 'pseudo-cmavo', 'description' ] ) do |grandchild|
        role=grandchild.name
        if grandchild[:role]
          role=grandchild[:role]
        elsif grandchild.name == 'series'
          role='cmavo-series'
        elsif grandchild.name == 'compound'
          role='cmavo-compound'
        elsif grandchild.name == 'modal-place'
          role="modal-place-#{grandchild[:se]}"
        elsif grandchild.name == 'attitudinal-scale'
          role="attitudinal-scale-#{grandchild[:point]}".gsub("'",'h')
        end

        convert!( node: grandchild, newname: 'para', role: role )
      end

      child.children.each { |e| e.element? && e.replace("<td class='#{e['role']}'>#{e}</td>") }
      convert!( node: child, newname: 'tr' )
    else
      abort "Bad node in cmavo-list: #{child.to_xml}"
    end

  end

  tableify node
end

$document.css('.rafsi-group rafsi').each do |node|
  convert!( node: node, newname: 'phrase', lang: 'jbo' )
end

$document.css('letteral,diphthong,cmevla,morphology,rafsi').each do |node|
  convert!( node: node, newname: 'foreignphrase', lang: 'jbo' )
end

$document.css('comment').each do |node|
  convert!( node: node, newname: 'emphasis' )
end

$document.css('comment').each do |node|
  convert!( node: node, newname: 'emphasis' )
end

# Drop attributes that docbook doesn't recognize
$document.xpath('//@glossary').remove
$document.xpath('//@delineated').remove
$document.xpath('//@elidable').remove
$document.xpath('//@valid').remove
$document.xpath('//@split').remove
$document.xpath('//@se').remove
$document.xpath('//@point').remove

doc = $document.to_xml
# Put in our own header
header = File.open( 'scripts/header.xml', 'r' ) { |f| f.read }
doc = doc.gsub( %r{^.*<book [^>]*>}m, header )

puts doc

exit 0
