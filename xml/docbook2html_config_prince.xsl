<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:docbook="http://docbook.org/ns/docbook"
  version="1.0">

  <xsl:import href="docbook2html_config_common.xsl"/>

  <!-- Override generated text; see
       http://www.sagehill.net/docbookxsl/CustomGentext.html for an intro to what's happening here.

      The file we're modifying lives at /usr/share/sgml/docbook/xsl-ns-stylesheets-*/common/en.xml
  -->
  <xsl:param name="local.l10n.xml" select="document('')"/>

  <l:i18n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0">
    <l:l10n language="en">
      <l:context name="title">
        <!-- Essentially insert a seperator in the Chapter title
             which gets hacked later into being a <br/> tag
             -->
        <l:template name="chapter" text="Chapter %n--CHAPBR--%t"/>
        <!-- Drop the pointles . after the example number -->
        <l:template name="example" text="Example %n %t"/>
      </l:context>
      <l:context name="title-numbered">
        <!-- Essentially insert a seperator in the Chapter title
             which gets hacked later into being a <br/> tag
             -->
        <l:template name="chapter" text="Chapter %n--CHAPBR--%t"/>
        <!-- Drop the pointles . after the section number -->
        <l:template name="section" text="%n %t"/>
      </l:context>
    </l:l10n>
  </l:i18n>

</xsl:stylesheet>
