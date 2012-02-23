<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  extension-element-prefixes="exsl str"
  version="1.0">

  <!-- Import the identity transformation. -->
  <xsl:import href="identity.xsl"/>

  <!-- Import string replacement -->
  <xsl:import href="string_char_replace.xsl"/>

  <xsl:output method="xml" doctype-system="dtd/docbook-5.0.dtd" doctype-public="-//OASIS//DTD DocBook XML V5.0//EN" />

  <!--  text handling for non-verbatim sections

       glossary entries are pulled from jbovlaste, which means
         they're already in LaTeX format; keep them that way

         FIXME: This means that glossary entries look like crap in
         HTML! We need to fix them when we generate them to have
         proper docbook, then turn them into proper latex here
         -->
  <xsl:template match="text()">
    <xsl:choose>
      <xsl:when test="not(boolean(ancestor::latex-verbatim)) and not(boolean(ancestor::glossdef))">
        <xsl:call-template name="string-char-replace">
          <xsl:with-param name="from">$</xsl:with-param>
          <xsl:with-param name="to"><latex-verbatim>\textdollar</latex-verbatim></xsl:with-param>
          <xsl:with-param name="string" select="."/>
          <!--
          <xsl:call-template name="string-char-replace">
            <xsl:with-param name="from">\</xsl:with-param>
            <xsl:with-param name="to"><latex-verbatim>\textbackslash</latex-verbatim></xsl:with-param>
            <xsl:with-param name="string" select="."/>
          </xsl:call-template>
        </xsl:with-param>
          -->
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="boolean(ancestor::latex-verbatim)">
      <!--
      <xsl:call-template name="string-char-replace">
        <xsl:with-param name="from">[</xsl:with-param>
        <xsl:with-param name="to">{}[</xsl:with-param>
        <xsl:with-param name="string" select="."/>
      </xsl:call-template>
      -->
      <xsl:copy-of select="."/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:text>!@#$\$@#$ > ERROR bad text substitution</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="para[@role='selbri' and ancestor::informaltable]">
  <latex-verbatim>
    <xsl:text>\bf{</xsl:text>
    <xsl:value-of select="text()"/>
    <xsl:text>}</xsl:text>
  </latex-verbatim>
</xsl:template>

<xsl:template match="para[@role='sumti' and ancestor::informaltable]">
  <latex-verbatim>
    <xsl:text>\underline{</xsl:text>
    <xsl:value-of select="text()"/>
    <xsl:text>}</xsl:text>
  </latex-verbatim>
</xsl:template>

  <!-- backticks appear in chapter 3, and this upsets LaTeX a bit;
       fix it.
       -->
  <xsl:template match="phrase[@role='X-SAMPA']/text()">
    <xsl:call-template name="string-char-replace">
      <xsl:with-param name="string" select="."/>
      <xsl:with-param name="from">`</xsl:with-param>
      <xsl:with-param name="to"><latex-verbatim>\textasciigrave</latex-verbatim></xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="informaltable">
    <xsl:variable name="items" select="." />

    <xsl:for-each select="./tr">
      <xsl:sort select="count(./td)" data-type="number" order="descending"/>
      <xsl:if test="position()=1">
        <xsl:call-template name="counted_table">
          <xsl:with-param name="maximal" select="."/>
          <xsl:with-param name="items" select="$items"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="counted_table">
    <xsl:param name="maximal" select="''"/>
    <xsl:param name="items" select="''"/>
    <latex-verbatim>
      <!-- LaTeX table setup -->
      <xsl:text>
        % see longtable docs for these next lines
        \setlength\LTleft\parindent
        \setlength\LTright\fill
        \begin{longtable}{</xsl:text>
      <!-- LaTeX table width -->
      <xsl:for-each select="$maximal/td">
        <xsl:text>l</xsl:text>
      </xsl:for-each>
      <xsl:text>}&#10;</xsl:text>
      <xsl:for-each select="$items/tr">
        <xsl:for-each select="./td">
          <xsl:choose>
            <!-- Deal with full width columns -->
            <xsl:when test="@colspan='0'">
              <xsl:text>\multicolumn{</xsl:text>
              <xsl:value-of select="count($maximal/*)"/>
              <xsl:text>}{l}{</xsl:text>
              <xsl:value-of select="text()"/>
              <xsl:text>}</xsl:text>
            </xsl:when>
            <!-- If there are sub-elements, extract out the text or
               otherwise process, otherwise just copy everything
               -->
            <xsl:when test="./*">
                <!-- Do expansion, and mark as non-verbatim so
                     dblatex expansion will also occur -->
                     <xsl:text>{}</xsl:text>
                <non-verbatim>
                  <xsl:apply-templates select="node()|text()"/>
                </non-verbatim>
                <!-- FIXME: can probably be simply removed
                <!- - Deal with special cases - ->
                <xsl:choose>
                  <xsl:when test="@role='selbri'">
                    <xsl:text>\bf{</xsl:text>
                    <xsl:value-of select="text()"/>
                    <xsl:text>}</xsl:text>
                  </xsl:when>
                  <xsl:when test="@role='sumti'">
                    <xsl:text>\underline{</xsl:text>
                    <xsl:value-of select="text()"/>
                    <xsl:text>}</xsl:text>
                  </xsl:when>
                  <!- - Otherwise just extract the text - ->
                  <xsl:otherwise>
                    <xsl:call-template name="string-char-replace">
                      <xsl:with-param name="from">\</xsl:with-param>
                      <xsl:with-param name="to">\textbackslash</xsl:with-param>
                      <xsl:with-param name="string">
                        <xsl:call-template name="string-char-replace">
                          <xsl:with-param name="from">[</xsl:with-param>
                          <xsl:with-param name="to">{}[</xsl:with-param>
                          <xsl:with-param name="string">
                            <xsl:apply-templates select="node()|text()"/>
                          </xsl:with-param>
                        </xsl:call-template>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>
                -->
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="node()|text()"/>
            </xsl:otherwise>
          </xsl:choose>
          <!-- column terminator if not last -->
          <xsl:if test="position() != last()">
            <xsl:text>&amp;&#10;</xsl:text>
          </xsl:if>
        </xsl:for-each>
        <!-- end of row -->
        <xsl:text>\tabularnewline&#10;</xsl:text>
      </xsl:for-each>
      <xsl:text>\end{longtable}</xsl:text>
    </latex-verbatim>
  </xsl:template>

<!--
  <!- - emphasis role="cmavo" - ->
  <xsl:template match="emphasis[@role='cmavo']">
    <xsl:if test="boolean(ancestor::informaltable)">
      <xsl:copy-of select="text()"/>
    </xsl:if>
  </xsl:template>

  <!- - para role="selmaho" - ->
  <xsl:template match="para[@role='selmaho']">
    <xsl:if test="boolean(ancestor::informaltable)">
      <xsl:copy-of select="text()"/>
    </xsl:if>
  </xsl:template>

  <!- - para role="description" - ->
  <xsl:template match="para[@role='description']">
    <xsl:if test="boolean(ancestor::informaltable)">
      <xsl:copy-of select="text()"/>
    </xsl:if>
  </xsl:template>

<para role="sumti">x1</para>&amp;
<para role="elidable">cu</para>&amp;
<para role="selbri">tavla</para>&amp;
<glossterm linkend="valsi-vecnu"><foreignphrase xml:lang="jbo"><indexterm type="lojban-words"><primary>vecnu</primary></indexterm>vecnu</foreignphrase></glossterm>&amp;
<blockquote role="definition"><para><phrase role="definition-content">x1 (seller) sells x2 (goods) to x3 (buyer) for x4 (price)</phrase></para></blockquote>\tabularnewline
-->


</xsl:stylesheet>
