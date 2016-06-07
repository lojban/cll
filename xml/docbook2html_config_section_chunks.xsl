<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:docbook="http://docbook.org/ns/docbook"
  version="1.0">

  <xsl:import href="docbook2html_config_common.xsl"/>
  <xsl:import href="docbook2html_config_xhtml.xsl"/>
  <!-- We only actually have 2 levels, but if we're going to chunk, let's chunk. -->
  <xsl:param name="chunk.section.depth" select="8"></xsl:param>

</xsl:stylesheet>
