<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:docbook="http://docbook.org/ns/docbook"
  version="1.0">

  <xsl:param name="use.id.as.filename" select="'1'"/>
  <xsl:param name="html.stylesheet" select="'final.css'"/>
  <xsl:param name="index.on.type" select="1"/>
  <xsl:param name="index.on.role" select="1"/>
  <xsl:param name="index.links.to.section" select="0"/>
  <xsl:param name="emphasis.propagates.style" select="1"/>
  
  <xsl:param name="xref.with.number.and.title" select="0"/>

  <xsl:param name="section.autolabel" select="1"></xsl:param>
  <xsl:param name="section.autolabel.max.depth">8</xsl:param>
  <xsl:param name="section.label.includes.component.label" select="1"></xsl:param>

  <!-- default is at
       http://docbook.sourceforge.net/release/xsl/1.76.1/doc/html/generate.toc.html
       -->
  <xsl:param name="generate.toc">
    book      toc,title,figure,equation
    chapter   title
    section   title
  </xsl:param>

  <!-- FIXME: do we even use admonitions? (see
       http://newbiedoc.sourceforge.net/tutorials/docbook-guide/admon-docbook-guide.html.en for what those are).  Why are these set?
       -->
  <xsl:param name="admon.graphics" select="'1'"/>
  <xsl:param name="admon.graphics.path"></xsl:param>

  <!-- deal with colspan=0, which doesn't actually work properly in
       the HTML output from docbook; we turn it into 12321, since
       that's an easy number to search for, "100%" doesn't work in
       Prince, and we're *ahem* unlikely to have a table that large

       Starter code stolen from /usr/share/sgml/docbook/xsl-ns-stylesheets/xhtml/htmltbl.xsl 
  -->
  <xsl:template match="@colspan" mode="htmlTableAtt">
    <xsl:if test="number(.) != 1">
      <xsl:choose>
        <xsl:when test="number(.) = 0">
          <xsl:attribute name="{local-name(.)}">
            <xsl:text>12321</xsl:text>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="{local-name(.)}">
            <xsl:value-of select="."/>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="itemizedlist[@role='bullets']" mode="class.value">
    <xsl:value-of select="'bullets'"/>
  </xsl:template>

</xsl:stylesheet>
