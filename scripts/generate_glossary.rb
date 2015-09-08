#!/usr/bin/env ruby

require 'rubygems'
require 'trollop'
#require 'yaml'
#require 'highline'
require 'nokogiri'
require 'fileutils'
require 'htmlentities'

# Initialize our own variables:
mydir=File.expand_path(File.dirname(__FILE__))
testing=""
builddir="build/"
initial_letter=false
new_initial_letter=false
indiv=false


require "#{mydir}/util.rb"

parser = Trollop::Parser.new do
  text "\n\nblah blah blah\n\n---"

  opt :testing, %q{testing mode: will replace all external xrefs in each chapter and turn off the glossary}, :short => 't'
  opt :build_dir, %q{The path of the build dir}, :type => String, :short => 'b'

  stop_on_unknown
end

opts = Trollop::with_standard_exception_handling parser do
  # raise Trollop::HelpNeeded if ARGV.empty? # show help screen
  parser.parse ARGV
end

if opts[:build_dir]
  builddir=opts[:build_dir]
end

# $opts_where=((opts[:where].is_a? String) ? opts[:where].chomp : false)
# $opts_search=((opts[:search].is_a? String) ? opts[:search].chomp : false)

unless opts[:testing]
    size=File.size?("#{builddir}/jbovlaste.xml")
    if ! size or size < 100 or %x{find "#{builddir}/jbovlaste.xml" -mtime +1}.length > 1
      $stderr.puts "jbovlaste file is old; refetching."
      $stderr.puts %x{wget 'http://jbovlaste.lojban.org/export/xml-export.html?lang=en&bot_key=z2BsnKYJhAB0VNsl' -O "#{builddir}/jbovlaste.xml"}
    end
    jbovlaste_tree=Nokogiri::XML(open "#{builddir}/jbovlaste.xml")
end

coder = HTMLEntities.new

tree=Nokogiri::XML(open "#{builddir}/cll_preglossary.xml")
find_lojban_words( tree ).sort { |a,b| slugify(a.text.to_s).downcase <=> slugify(b.text.to_s).downcase }.map { |x| x.text.to_s.gsub( %r{\.}, '' ) }.uniq.each do |word|
  if ! initial_letter
    puts %q{
<glossary>
<title>Lojban Word Glossary</title>
<para>All definitions in this glossary are brief and unofficial.
Only the published dictionary is a truly official reference for word
definitions.  These definitions are here simply as a quick reference.
</para>

<!-- THIS FILE IS AUTOGENERATED.  DO NOT EDIT OR CHECK IN! -->

}
  end

  slug=slugify(word)
  #puts "#{word}\t#{slug}"
  
  new_initial_letter=slug.chars.first.upcase

  if initial_letter != new_initial_letter
    if initial_letter
      puts "</glossdiv>"
    end
    puts "<glossdiv><title>#{new_initial_letter}</title>"
    initial_letter=new_initial_letter
  end

  definition=nil
  if opts[:testing]
    definition="placeholder definition"
  else
    definition=jbovlaste_tree.xpath(%Q{//valsi[@word="#{word}"]}).xpath(".//definition").text.strip.gsub(%r{\s+}, ' ')

    # Fix non-xml chars, *before* we add a bunch
    definition = coder.encode(definition, :basic)

    # Turn LaTeX stuff into xml: $1*10^{-2}$]
    definition.gsub!(%r(\$(1\*)?10\^{?([^}$]*)}?\$)){"<inlinemath>#{$1}10<superscript>#{$2}</superscript></inlinemath>"}

    # Turn LaTeX stuff into xml: $x_{1}= ; then we stop, and repeat
    # this until there's no matches
    olddef=''
    while olddef != definition
      olddef = definition.clone
      definition.gsub!(%r(\$([a-z]+)_{?([0-9]+)}?(=?)), '<inlinemath>\1<subscript>\2</subscript></inlinemath>\3$')
    end

    # Clean out the remains of the process above
    definition.gsub!(%r{\$\$},'')

    # puts "#{word}, #{definition}"

    if definition =~ %r{\$|\\}
      echo "UNHANDLED LATEX in definiton for $word: $definition"
    end

    if definition =~ %r{^\s*$}
      definition=%Q{NO JBOVLASTE DEFINITION FOR "#{word}" FOUND!}
      $stderr.puts definition
    end
  end
  puts %Q{
<glossentry xml:id="valsi-#{slug}">
<glossterm>#{word}</glossterm>
<glossdef>
  <para>#{definition}</para>
</glossdef>
</glossentry>
}
end

if initial_letter
  puts %q{

</glossdiv>
</glossary>

}
end
