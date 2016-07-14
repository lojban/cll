<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:docbook="http://docbook.org/ns/docbook"
  version="1.0">

  <xsl:import href="docbook2html_config_common.xsl"/>
  <xsl:import href="docbook2html_config_xhtml.xsl"/>
  <!-- This gives us chapters, despite the 0 -->
  <xsl:param name="chunk.section.depth" select="0"></xsl:param>

</xsl:stylesheet>
