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
      <a accesskey="b" href="https://mw.lojban.org/papri/CLL_v1.1_HTML">Book Info Page</a>
    </div>
  </xsl:template>

  <!-- Outer Headers and footers -->
  <xsl:template name="user.header.navigation">
  </xsl:template>

  <xsl:template name="user.footer.navigation">
    <xsl:call-template name="toc-link"/>
    <xsl:call-template name="back-to-info-link"/>
  </xsl:template>

  <!-- Inner Headers and footers -->
  <xsl:template name="user.header.content">
    <xsl:call-template name="toc-link"/>
    <xsl:call-template name="back-to-info-link"/>
    <hr/>
  </xsl:template>
  <xsl:template name="user.footer.content">
    <hr/>
  </xsl:template>

  <!-- ==================================================================== -->

  <!-- header; just calls my.navigation -->
  <xsl:template name="header.navigation">
    <xsl:param name="prev" select="/d:foo"/>
    <xsl:param name="next" select="/d:foo"/>
    <xsl:param name="nav.context"/>

    <xsl:variable name="home" select="/*[1]"/>
    <xsl:variable name="up" select="parent::*"/>

    <xsl:call-template name="my.navigation">
      <xsl:with-param name="prev" select="$prev"/>
      <xsl:with-param name="next" select="$next"/>
      <xsl:with-param name="nav.context" select="$nav.context"/>
    </xsl:call-template>
  </xsl:template>

  <!-- footer; just calls my.navigation -->
  <xsl:template name="footer.navigation">
    <xsl:param name="prev" select="/d:foo"/>
    <xsl:param name="next" select="/d:foo"/>
    <xsl:param name="nav.context"/>

    <xsl:variable name="home" select="/*[1]"/>
    <xsl:variable name="up" select="parent::*"/>
    <xsl:call-template name="my.navigation">
      <xsl:with-param name="prev" select="$prev"/>
      <xsl:with-param name="next" select="$next"/>
      <xsl:with-param name="nav.context" select="$nav.context"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Originally from /usr/share/sgml/docbook/xsl-ns-stylesheets-1.78.1/xhtml/chunk-common.xsl ; heavily modified -->
  <xsl:template name="my.navigation">
    <xsl:param name="prev" select="/d:foo"/>
    <xsl:param name="next" select="/d:foo"/>
    <xsl:param name="nav.context"/>

    <xsl:variable name="home" select="/*[1]"/>
    <xsl:variable name="up" select="parent::*"/>

    <div class="navheader">
      <!-- First the chapter name -->
      <table width="100%" summary="Chapter Header">
        <tr>
          <th colspan="3" align="center">
            <xsl:apply-templates select="$up" mode="object.title.markup"/>
          </th>
        </tr>
      </table>
      <!-- Then the two navigation beacons -->
      <table width="100%" summary="Navigation header">
        <tr>
          <td width="50%" align="{$direction.align.end}">
            <xsl:if test="$prev">
              <a accesskey="p">
                <xsl:attribute name="href">
                  <xsl:call-template name="href.target">
                    <xsl:with-param name="object" select="$prev"/>
                  </xsl:call-template>
                </xsl:attribute>
                <!-- Produces the word "prev", localized -->
                <xsl:call-template name="navig.content">
                  <xsl:with-param name="direction" select="'prev'"/>
                </xsl:call-template>
                <!-- Produces ": " or so -->
                <xsl:value-of select="$xref.label-title.separator"/>
                <!-- Produces like "Section 2.5" or "Lojban Word Glossary -->
                <xsl:apply-templates select="$prev" mode="object.xref.markup"/>
              </a>
            </xsl:if>
          </td>
          <td width="50%" align="{$direction.align.start}">
            <xsl:if test="$next">
              <a accesskey="n">
                <xsl:attribute name="href">
                  <xsl:call-template name="href.target">
                    <xsl:with-param name="object" select="$next"/>
                  </xsl:call-template>
                </xsl:attribute>
                <!-- Produces the word "next", localized -->
                <xsl:call-template name="navig.content">
                  <xsl:with-param name="direction" select="'next'"/>
                </xsl:call-template>
                <!-- Produces ": " or so -->
                <xsl:value-of select="$xref.label-title.separator"/>
                <!-- Produces like "Section 2.5" or "Lojban Word Glossary -->
                <xsl:apply-templates select="$next" mode="object.xref.markup"/>
              </a>
            </xsl:if>
          </td>
        </tr>
      </table>
    </div>
  </xsl:template>

  <!-- ==================================================================== -->

</xsl:stylesheet>
