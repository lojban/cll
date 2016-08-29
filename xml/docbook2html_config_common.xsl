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

  <!-- Allow non-trivial classes on examples -->
  <xsl:template match="example[@role]" mode="class.value">
    <xsl:value-of select="concat(@role,' example')"/>
  </xsl:template>

  <!-- default is at
       http://docbook.sourceforge.net/release/xsl/1.76.1/doc/html/generate.toc.html
       -->
  <xsl:param name="generate.toc">
    book      toc,title,figure,equation
    chapter   title
    section   title
  </xsl:param>

  <!-- Override generated text; see
       http://www.sagehill.net/docbookxsl/CustomGentext.html for an intro to what's happening here.

      The file we're modifying lives at /usr/share/sgml/docbook/xsl-ns-stylesheets-*/common/en.xml
  -->
  <xsl:param name="local.l10n.xml" select="document('')"/>

  <l:i18n xmlns:l="http://docbook.sourceforge.net/xmlns/l10n/1.0">
    <l:l10n language="en">
      <l:context name="index">
        <!-- In indexes do "foo: 1, 7" for "see foo on pages 1 and
             7", instead of the default which is a comma (??)
             -->
        <l:template name="term-separator" text=": "/>
      </l:context>
    </l:l10n>
  </l:i18n>

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

  <!-- ==================================================================== -->

  <!-- Special navigation links -->
  <xsl:template name="toc-link">
    <xsl:variable name="home" select="/*[1]"/>

    <div class="toc-link" align="center">
      <a accesskey="h">
        <xsl:attribute name="href">
          <xsl:call-template name="href.target">
            <xsl:with-param name="object" select="$home"/>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:call-template name="gentext">
          <xsl:with-param name="key">TableofContents</xsl:with-param>
        </xsl:call-template>
      </a>
    </div>
  </xsl:template>

  <xsl:template name="back-to-info-link">
    <div class="back-to-info-link" align="center">
      <a accesskey="b" href="http://www.lojban.org/cll">Book Info Page</a>
    </div>
  </xsl:template>

</xsl:stylesheet>
