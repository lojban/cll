
$converters[:info_converters] = {
  :title => {
    :post_proc => templated( %q{
        <div>
          <h1 class="title">
            <%= text %>
          </h1>
        </div>
    } )
  },
  :author => {
    :post_proc => templated( %q{
        <div>
          <div class="author">
            <h3 class="author">by <%= text %></h3>
          </div>
        </div>
    } )
  },
  :subtitle => {
    :post_proc => templated( %q{
        <div>
          <h2 class="subtitle"><%= text %></h2>
        </div>
    } )
  },
  :publisher => {
    :post_proc => templated( %q{
        <div>
          <p class="copyright"><%= text %></p>
        </div>
    } )
  },
  :DEFAULT => {
  },
  :TEXT => {
  },
}

$converters[:index_converter] =  {
  :post_proc => templated( %q{
<% 
indexterm_divs={}
node.xpath(%Q{//indexterm[@type='#{type}']}).each do |indexterm|
  cap=indexterm.xpath('.//primary').text.upcase[0]
  indexterm_divs[cap] ||= {}
  pt = indexterm.xpath('.//primary').text
  st = indexterm.xpath('.//secondary').text
  tt = indexterm.xpath('.//tertiary').text
  sect_id = indexterm.xpath('ancestor::section').attribute('id').text
  sect_title = indexterm.xpath('ancestor::section').xpath('.//title').first.text

  if tt.length > 1
    indexterm_divs[cap][pt] ||= {}
    indexterm_divs[cap][pt][st] ||= {}
    indexterm_divs[cap][pt][st][tt] ||= {}
    indexterm_divs[cap][pt][st][tt][:indexterms] ||= []
    indexterm_divs[cap][pt][st][tt][:indexterms] << [ sect_id, sect_title ]
  else
    if st.length > 1
      indexterm_divs[cap][pt] ||= {}
      indexterm_divs[cap][pt][st] ||= {}
      indexterm_divs[cap][pt][st][:indexterms] ||= []
      indexterm_divs[cap][pt][st][:indexterms] << [ sect_id, sect_title ]
    else
      indexterm_divs[cap][pt] ||= {}
      indexterm_divs[cap][pt][:indexterms] ||= []
      indexterm_divs[cap][pt][:indexterms] << [ sect_id, sect_title ]
    end
  end
end

# $stderr.puts YAML::dump(indexterm_divs)

# mt:
# ---
# F:
#   father:
#     example:
#       :indexterms:
#       - - section-bridi
#         - The concept of the bridi
# J:
#   John and Sam:
#     example:
#       :indexterms:
#       - - section-bridi
#         - The concept of the bridi

%>
<div class="index">
  <div class="titlepage">
    <div>
      <div>
        <h1 class="title"><a id="<%= slugify_raw( node.xpath('./title').text ) %>"></a><%= text %></h1>
      </div>
    </div>
  </div>
  <div class="index">
    <% indexterm_divs.keys.each do |div| %>
      <div class="indexdiv">
        <h3><%= div %></h3>
        <dl>
          <% indexterm_divs[div].keys.each do |indexterm_text| %>
            <%# indexterm_divs[div][indexterm_text].each do |indexterm| %>
            <dt><%# indexterm.xpath('.//primary').text %>,
            <a class="indexterm" href="#<%= slugify_raw( node.xpath('./title').text ) %>">The concept of the bridi
            </a>
            </dt>
            <dd>
            <dl>
              <dt>compared with predication, 
              <a class="indexterm" href="#idm207513587712">The concept of the bridi
              </a>
              </dt>
              <dt>concept of, 
              <a class="indexterm" href="#idm207513599808">The concept of the bridi
              </a>
              </dt>
            </dl>
            </dd>
          <% end %>
        </dl>
      </div>
    <% end %>
    <div class="indexdiv">
[snip]
    </div>
  </div>
</div>
  } ),
}

$converters[:indexterm_converter] =  {
  :post_proc => templated( '' ),
}

$converters[:section_converters] = {
  :title => {
    :before => '<div class="section"><div class="titlepage"><div><div><h2 class="title" style="clear: both"><a id="section-bridi"></a>',
    :post_proc => join_text,
    :after => '</h2></div></div></div>',
  },
  :indexterm => $converters[:indexterm_converter],
  :DEFAULT => {
  },
  :TEXT => {
  },
}

$converters[:chapter_converters] = {
  :title => {
    :before => '<div class="chapter"><div class="titlepage"><div><div><h1 class="title"><a id="chapter-tour"></a>',
    :post_proc => join_text,
    :after => '</h1></div></div></div>',
  },
  :section => {
    :new_converters => $converters[:section_converters],
  },
  :indexterm => $converters[:indexterm_converter],
  :DEFAULT => {
  },
  :TEXT => {
  },
}

$converters[:initial_coverters] = {
  :para => {
    :post_proc => strip_leading_whitespace,
  },
  :chapter => {
    :new_converters => $converters[:chapter_converters],
  },
  :indexterm => $converters[:indexterm_converter],
  :index => $converters[:index_converter],
  :DEFAULT => {
  },
  :TEXT => {
  },
}

#*****************************
#
# Particularly verbose bits go here
#
#*****************************
$converters[:initial_coverters][:book] = {
    :before => %q{
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<!-- FIXME: dynamically generate the below -->
<title>STATIC TITLE: The Complete Lojban Language</title>
<link rel="stylesheet" type="text/css" href="docbook2html.css" />
<meta name="generator" content="DocBook XSL Stylesheets V1.78.1" />
</head>
<body>
    },
    :after => %q{
</body>
</html>
    },

}

#*************
# NB: there is lots of duplicated code here; maybe you should fix that.
#*************
$converters[:initial_coverters][:info] = {
    :new_converters => $converters[:info_converters],
  :post_proc => templated( %q{
<div class="book">
  <div class="titlepage">
    <%= text %>
  </div>
  <hr />
</div>
<div class="toc">
  <p>
    <strong>Table of Contents</strong>
  </p>
  <dl class="toc">
    <% node.xpath('//chapter').each do |chapter| %>
      <dt>
        <span class="chapter">
          <a href="#<%= chapter.attribute('id') || raise("no xml:id for chapter #{chapter.xpath('./title').text}") %>"><%= chapter.xpath('./title').text %></a>
        </span>
      </dt>
      <% if chapter.xpath('./section').length > 0 %>
        <dd>
          <dl>
            <% chapter.xpath('./section').each do |section| %>
              <dt>
                <span class="section">
                  <a href="#<%= section.attribute('id') || raise("no xml:id for section #{section.xpath('./title').text}") %>"><%= section.xpath('./title').text %></a>
                </span>
              </dt>
            <% end %>
          </dl>
        </dd>
      <% end %>
    <% end %>
    <% node.xpath('//glossary').each do |glossary| %>
      <dt>
        <span class="glossary">
          <a href="#<%= slugify_raw( glossary.xpath('./title').text ) %>"><%= glossary.xpath('./title').text %></a>
        </span>
      </dt>
    <% end %>
    <% node.xpath('//index').each do |index| %>
      <dt>
        <span class="index">
          <a href="#<%= slugify_raw( index.xpath('./title').text ) %>"><%= index.xpath('./title').text %></a>
        </span>
      </dt>
    <% end %>
  </dl>
</div>
} )
}
