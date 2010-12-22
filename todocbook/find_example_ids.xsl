<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  extension-element-prefixes="exsl str"
  version="1.0">

  <xsl:output method="xml" doctype-system="dtd/docbook-5.0.dtd" doctype-public="-//OASIS//DTD DocBook XML V5.0//EN" />

  <xsl:template match="//example">
    <xsl:value-of select="@xml:id"/>
    <xsl:for-each select=".//anchor/@xml:id[contains(.,'cll_chapter')]">
      <xsl:text>&#x09;</xsl:text>
      <xsl:value-of select="."/>
    </xsl:for-each>
    <xsl:text>&#x0A;</xsl:text>
  </xsl:template>

  <xsl:template match="//text()">
  </xsl:template>

</xsl:stylesheet>
