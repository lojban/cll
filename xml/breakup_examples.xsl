<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  extension-element-prefixes="exsl str"
  version="1.0">

  <xsl:import href="identity.xsl"/>

  <xsl:output method="xml" doctype-system="dtd/docbook-5.0.dtd" doctype-public="-//OASIS//DTD DocBook XML V5.0//EN" />

  <!-- lojban words -->
  <xsl:template match="//example">
    <xsl:if test="count(.//title[boolean(child::anchor)]) = 1">
      <!-- OK example -->
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </xsl:if>
    <xsl:if test="count(.//title[boolean(child::anchor)]) > 1">
      <!--
      <xsl:text>BAD EXAMPLE</xsl:text>
      -->

      <xsl:variable name="example" select="."/>
      <xsl:variable name="randomid" select="@xml:id"/>

<!--
    <example role="interlinear-gloss-example" xml:id="example-random-id-483c">
      <title>
        <anchor xml:id="c5e1d3"/>
        <anchor xml:id="cll_chapter5-section1-example3"/>   </title><title>
      </title>
      <interlinear-gloss>
</interlinear-gloss><interlinear-gloss>        <jbo>ta bloti</jbo>
        <gloss>That is-a-boat.</gloss>
        <en>That is a boat.</en>
      </interlinear-gloss>
    </example>
-->
      <xsl:for-each select=".//title[boolean(child::anchor)]">
        <xsl:text>&#x0A;</xsl:text>
        <xsl:variable name="randomidnum" select="concat($randomid,concat('-',position()))"/>
        <xsl:variable name="titlepos" select="position()"/>
        <example xml:id="{$randomidnum}">
          <xsl:attribute name="role">
            <xsl:value-of select="../@role"/>
          </xsl:attribute>
          <xsl:copy select=".">
            <xsl:apply-templates select="@*|node()"/>
          </xsl:copy>
          <xsl:for-each select="../interlinear-gloss[boolean(child::jbo)]">
            <xsl:if test="position() = $titlepos">
          <xsl:copy select="$igs">
            <xsl:apply-templates select="@*|node()"/>
          </xsl:copy>
        </xsl:if>
      </xsl:for-each>
        </example>
        <xsl:text>&#x0A;</xsl:text>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
