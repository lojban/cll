<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:docbook="http://docbook.org/ns/docbook"
  version="1.0">

  <xsl:import href="docbook2html_config_common.xsl"/>
  <!-- We only actually have 2 levels, but if we're going to chunk, let's chunk. -->
  <xsl:param name="chunk.section.depth" select="8"></xsl:param>

  <!-- The goal here is chunking with no navigation -->
  <xsl:param name="suppress.navigation" select="1"></xsl:param>

  <!-- These things tell docbook to act like HTML5, which makes it
       generate more <dd/>s to go with <dt>s, and other things that
       make epubcheck happy -->
  <xsl:param name="div.element">section</xsl:param>
  <xsl:param name="table.border.off" select="1"></xsl:param>
</xsl:stylesheet>
