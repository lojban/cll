<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:docbook="http://docbook.org/ns/docbook"
  version="1.0">

  <xsl:template name="user.head.content">
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.1/MathJax.js?config=MML_HTMLorMML"></script>
    <meta name="viewport" content="width=device-width, initial-scale=1" />
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
