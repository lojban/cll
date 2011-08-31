<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  extension-element-prefixes="exsl str"
  version="1.0">

  <xsl:output method="xml" doctype-system="dtd/docbook-5.0.dtd" doctype-public="-//OASIS//DTD DocBook XML V5.0//EN" />

  <!-- turn a string into a lowercase & dashes slug -->
  <xsl:template name="make_slug">
    <xsl:param name="input" select="''"/>
    <!-- This bit below just replaces ' with h-->
    <xsl:variable name="slug1">
      <xsl:value-of select="translate( $input, &#x22;&#x27;&#x22;, 'h' )"/>
    </xsl:variable>
    <!-- This bit below just deletes " -->
    <xsl:variable name="slug2">
      <xsl:value-of select='translate( $slug1, &#x27;&#x22;&#x27;, "" )'/>
    </xsl:variable>
    <xsl:variable name="slug3">
      <xsl:value-of select="translate( $slug2, '@#$%^*()?+/=[]{}!', '' )"/>
    </xsl:variable>
    <xsl:variable name="slug4">
      <xsl:value-of select="normalize-space($slug3)"/>
    </xsl:variable>
    <!-- lowercase, and replace space with - -->
    <xsl:variable name="slug">
      <xsl:value-of select="translate( $slug4,
        '&#x20;&#x9;&#xD;&#xA;ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '----abcdefghijklmnopqrstuvwxyz' )"/>
    </xsl:variable>
    <xsl:value-of select="$slug"/>
  </xsl:template>

  <!-- lojban words -->
  <!-- If you change the match here, also change it in
       docbook2html_preprocess.xsl ; search for LOJBAN WORDS MATCH
       -->
  <xsl:template match="//valsi">
    <xsl:variable name="slug">
      <xsl:call-template name="make_slug">
        <xsl:with-param name="input" select="text()"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="$slug"/>
    <xsl:text>&#x09;</xsl:text>
    <xsl:value-of select="text()"/>
    <xsl:text>&#x0A;</xsl:text>
  </xsl:template>

  <xsl:template match="//text()">
  </xsl:template>

</xsl:stylesheet>
