require 'nokogiri'
require 'yaml'
# require 'byebug'

mydir=File.expand_path(File.dirname(__FILE__))
require "#{mydir}/util.rb"

$document = Nokogiri::XML(File.open ARGV[0]) do |config|
  config.default_xml.noblanks
  config.strict
  config.options = Nokogiri::XML::ParseOptions::DTDLOAD   # Needed for the external DTD to be loaded
end

# Drop stuff we don't want, because display: none makes epub sad
$document.css('.glossary h3').remove
$document.css('.whole-index h3').remove

puts $document.to_xml

exit 0
