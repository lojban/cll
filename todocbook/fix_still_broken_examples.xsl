<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  extension-element-prefixes="exsl str"
  version="1.0">

  <xsl:import href="identity.xsl"/>

  <xsl:output method="xml" doctype-system="dtd/docbook-5.0.dtd" doctype-public="-//OASIS//DTD DocBook XML V5.0//EN" />

  <xsl:template match="//programlisting[boolean(child::anchor)]">
    <!--
    <xsl:text>BAD EXAMPLE</xsl:text>
    -->
    <xsl:text>&#x0A;</xsl:text>
    <example role="interlinear-gloss-example" xml:id="RANDOM">
      <xsl:text>&#x0A;</xsl:text>
      <title>
        <xsl:for-each select="./anchor">
          <xsl:text>&#x0A;</xsl:text>
          <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
          </xsl:copy>
        </xsl:for-each>
      </title>
      <xsl:text>&#x0A;</xsl:text>
      <programlisting>
        <xsl:for-each select="(node()|@*)[name() != 'anchor']">
          <xsl:copy>
            <xsl:apply-templates select="@*|node()|text()"/>
          </xsl:copy>
        </xsl:for-each>
      </programlisting>
      <xsl:text>&#x0A;</xsl:text>
    </example>
    <xsl:text>&#x0A;</xsl:text>
  </xsl:template>

</xsl:stylesheet>
