<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:docbook="http://docbook.org/ns/docbook"
  version="1.0">

  <xsl:import href="docbook2html_config_common.xsl"/>
  <xsl:import href="docbook2html_config_xhtml.xsl"/>

  <!-- Add in the back to book info link -->
  <xsl:template name="user.header.content">
    <xsl:call-template name="back-to-info-link"/>
    <hr/>
  </xsl:template>

  <xsl:template name="user.footer.content">
    <hr/>
    <xsl:call-template name="back-to-info-link"/>
  </xsl:template>
</xsl:stylesheet>
