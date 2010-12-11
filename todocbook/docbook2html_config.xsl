<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:docbook="http://docbook.org/ns/docbook"
                version="1.0">
  <xsl:param name="use.id.as.filename" select="'1'"/>
  <xsl:param name="admon.graphics" select="'1'"/>
  <xsl:param name="admon.graphics.path"></xsl:param>
  <xsl:param name="chunk.section.depth" select="0"></xsl:param>
  <xsl:param name="html.stylesheet" select="'docbook2html.css'"/>

  <xsl:template match="itemizedlist[@role='word_spacing_list']" mode="class.value">
    <xsl:value-of select="'word_spacing_list'"/>
  </xsl:template>

  <xsl:template match="docbook:listitem[@role='word_list']">
    <xsl:for-each select="str:tokenize(.)">
      <listitem><para>
          <xsl:value-of select="text()"/>
      </para></listitem>
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
