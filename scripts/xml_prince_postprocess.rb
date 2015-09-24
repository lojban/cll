require 'nokogiri'
require 'yaml'

mydir=File.expand_path(File.dirname(__FILE__))
require "#{mydir}/util.rb"

$document = Nokogiri::XML(File.open ARGV[0]) do |config|
  config.default_xml.noblanks
end

# Put example anchors inside the titles that we want to point at
$document.css('a[id] + p.title').each do |node|
  # puts node.to_xml
  node.children[0].previous = node.previous
  # puts node.to_xml
end

# Fix the fact that there are two things named "index" at totally
# different levels.
if $document.css('div.index')
  $document.css('div.index').each do |node|
    if node.children[0] and node.children[0].name == 'div' and node.children[0][:class] == 'titlepage'
      node[:class] = 'whole-index'
    end
  end
end

# Build the document
doc = $document.to_xml( :indent => 2)

# Hack to work with a seperator, "--CHAPBR--", inserted by xml/docbook2html_config_prince.xsl
#
# There are two cases here.  In this case:
#
#       <h1 class="title"><a id="chapter-letterals"></a>Chapter 2--CHAPBR--As Easy As A-B-C? The Lojban Letteral System And Its Uses</h1>
#
# we want to turn it into a <br/> tag for presentation on the
# chapter title page.
#
doc = doc.gsub( %r{title="Chapter [0-9]+--CHAPBR--}, 'title="' )
#
# In this case: 
#
#       <a class="xref" href="#chapter-tour" title="Chapter 1--CHAPBR--COVERAGE: FULL">Chapter 1</a>
#
# we want to remove everything up to and including the --CHAPBR--,
# so that the a's text and title give different information.
#
doc = doc.gsub( %r{--CHAPBR--}, '<br/>' )
#
# In both cases, regex is *WAY* easier, and shouldn't cause any
# trouble.

# Put in our own header
header = File.open( 'scripts/header.xml', 'r' ) { |f| f.read }
doc = doc.gsub( %r{^.*<book [^>]*>}m, header )

puts doc

exit 0
