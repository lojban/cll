def find_lojban_words( tree )
  tree.xpath('//valsi').select { |x| x.attributes['valid'].to_s != 'false' }
end

def slugify( text )
  text.gsub( %r{'}, 'h' ).gsub( %r{\.}, '' ).gsub( %r{[^a-zA-Z0-9]}, '_' ).gsub( %r{_+$}, '' ).gsub( %r{^_+}, '' )
end
