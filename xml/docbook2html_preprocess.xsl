<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  extension-element-prefixes="exsl str"
  version="1.0">

  <!-- Import the identity transformation. -->
  <xsl:import href="identity.xsl"/>

  <xsl:output method="xml" doctype-system="dtd/docbook-5.0.dtd" doctype-public="-//OASIS//DTD DocBook XML V5.0//EN" />

    <xsl:param name="pdf"/>

  <xsl:template name="counted_table">
    <xsl:param name="maximal" select="''"/>
    <xsl:param name="items" select="''"/>
    <informaltable class="counted_table">
      <colgroup/>
          <xsl:for-each select="$items/jbo|$items/gloss">
            <tr>
              <xsl:choose>
                <xsl:when test="count(child::sumti) &gt;= 1 or count(child::selbri) &gt;= 1 or count(child::elidable) &gt;= 1">
                  <xsl:apply-templates select="node()|text()"/>
                </xsl:when>
                <xsl:otherwise>
                	<xsl:for-each select="str:tokenize(.)">
                    <td><xsl:value-of select="."/></td>
                  </xsl:for-each>
                </xsl:otherwise>
              </xsl:choose>
            </tr>
          </xsl:for-each>
<!--
          <xsl:for-each select="$items/gloss">
            <tr>
              <xsl:for-each select="node()|text()">
                <td><xsl:value-of select="."/></td>
              </xsl:for-each>
            </tr>
          </xsl:for-each>
-->
          <xsl:for-each select="$items/natlang">
            <xsl:variable name="startcol" select="concat('col',1)" />
            <xsl:variable name="endcol" select="concat('col',$maximal)" />
            <xsl:variable name="numcol" select="$maximal" />
            <tr>
              <td colspan="{$numcol}"><xsl:value-of select="."/></td>
            </tr>
          </xsl:for-each>
    </informaltable>
  </xsl:template>

  <!-- Turn cmavo-list nodes into tables. -->
  <xsl:template match="cmavo-list">
    <informaltable class="cmavo-list">
      <tgroup>
        <xsl:attribute name="cols">
          <xsl:value-of select="count(./cmavo-entry[1]/*)"/>
        </xsl:attribute>
        <xsl:for-each select="./cmavo-entry[1]/*">
          <colspec>
            <xsl:attribute name="colname">
              <xsl:value-of select="concat('col',position())"/>
            </xsl:attribute>
          </colspec>
        </xsl:for-each>
        <xsl:apply-templates select="cmavo-list-head"/>  
        <tbody>
          <xsl:for-each select=".//cmavo-entry">
            <row>
              <xsl:for-each select="cmavo|pseudo-cmavo|selmaho|description|gismu|rafsi|attitudinal-scale|modal-place">
                <entry><xsl:value-of select="."/></entry>
              </xsl:for-each>
            </row>
          </xsl:for-each>
        </tbody>
      </tgroup>
    </informaltable>
  </xsl:template>

  <xsl:template match="cmavo-list-head">
    <thead>
      <row>
        <xsl:for-each select="entry">
          <xsl:copy-of select="."/>
        </xsl:for-each>
      </row>
    </thead>
  </xsl:template>
  
  <!-- Turn interlinear-gloss nodes into tables.

        Such a node must have at least one jbo entry and at least one natlang entry.
  -->
  <xsl:template match="interlinear-gloss">
    <xsl:choose>
      <xsl:when test="false">
      </xsl:when>
      <!-- FIXME: We should enforce these at some point.  It's going
           to take a fair bit of manual labour, though; there are a
           bunch of examples that are just one line of English, for
           example.

      <xsl:when test="count(.//jbo) &lt; 1">
        <xsl:message>interlinear-gloss needs at least one jbo line; look for "ERROR" in the output</xsl:message>
        <xsl:text>
          ERROR: The following interlinear-gloss needs at least one jbo line:
        </xsl:text>
        <xsl:copy/>
      </xsl:when>
      <xsl:when test="count(.//natlang) &lt; 1">
        <xsl:message>interlinear-gloss needs at least one natlang line; look for "ERROR" in the output</xsl:message>
        <xsl:text>
          ERROR: The following interlinear-gloss needs at least one natlang line:
        </xsl:text>
        <xsl:copy/>
      </xsl:when>
      -->
      <xsl:otherwise>
        <!-- here is the BEGIN actual table conversion -->

        <xsl:variable name="items" select="." />

        <!-- We need to find the longest tokenized string, to size
             the table, so we sort by tokenized size and then pick
             the top one and use it to call the table builder.
        -->
        <xsl:for-each select=".//jbo|.//gloss">
          <xsl:sort select="count(str:tokenize(.))" order="descending"/>
          <xsl:if test="position()=1">
            <xsl:call-template name="counted_table">
              <xsl:with-param name="maximal" select="count(str:tokenize(.))"/>
              <xsl:with-param name="items" select="$items"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:for-each>

        <!-- END actual table conversion -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- This gets a bit complicated as we're essentially walking an
       xml table column-wise.

       Given:

       <a><b>1</b><b>2</b><b>3</b></a>
       <a><b>8</b><b>9</b><b>7</b></a>

       This code makes a table for <b>1</b> and <b>8</b>, another
       for <b>2</b> and <b>9</b>, etc.

       We do this by starting with a count of 1, finding the [1]
       subelements, then calling self with an incremented count.

  -->
  <xsl:template name="interlinear-gloss-itemized-table">
    <xsl:param name="width" select="''"/>
    <xsl:param name="starter" select="''"/>
    <xsl:param name="count" select="''"/>
    <xsl:variable name="any">
      <xsl:value-of select="count($starter/jbo/*[$count]|$starter/gloss/*[$count])"/>
    </xsl:variable>
    <!-- debug message
    <xsl:message>
      <xsl:text>&#xA;width:</xsl:text>
      <xsl:copy-of select="$width"/>
      <xsl:text>&#xA;moo:</xsl:text>
      <xsl:copy-of select="($starter/jbo/*[$count]|$starter/gloss/*[$count])"/>
    </xsl:message>
    -->
    <xsl:if test="boolean($any)">
    <informaltable class="interlinear-gloss-itemized-table-inner">
      <colgroup/>
      <xsl:for-each select="($starter/jbo/*[$count]|$starter/gloss/*[$count]|$starter/comment/*[$count])">
    <xsl:variable name="mixer">
      <xsl:value-of select="(position() + $count) mod 2"/>
    </xsl:variable>
    <tr class="interlinear-gloss-itemized-table-color-{$mixer}">
      <td class="{name(.)}">
              <xsl:apply-templates select="node()|text()"/>
            </td>
      </tr>
    </xsl:for-each>
    </informaltable>
  </xsl:if>
    <xsl:if test="boolean($count &lt; $width)">
        <xsl:call-template name="interlinear-gloss-itemized-table">
          <xsl:with-param name="width" select="$width"/>
          <xsl:with-param name="starter" select="."/>
          <xsl:with-param name="count" select="$count + 1"/>
        </xsl:call-template>
      </xsl:if>
  </xsl:template>

  <!-- Template for interlinear-gloss-itemized

       This picks, as a table (-ish) width marker, either the first
       ./jbo or first ./gloss, counts the numebr of sub-elements,
       and then calls interlinear-gloss-itemized-table with that
       value.
  -->
  <xsl:template match="interlinear-gloss-itemized">
  <xsl:if test="$pdf = 'no'">
    <xsl:choose>
      <xsl:when test="count(./jbo) &gt; 0">
        <informaltable class="interlinear-gloss-itemized-outer"> <colgroup/> <tr> <td>
              <xsl:call-template name="interlinear-gloss-itemized-table">
                <xsl:with-param name="width" select="count(./jbo[1]/*)"/>
                <xsl:with-param name="starter" select="."/>
                <xsl:with-param name="count" select="1"/>
              </xsl:call-template>
        </td> </tr> </informaltable>
        <xsl:apply-templates select="./natlang|./comment"/>
      </xsl:when>
      <xsl:when test="count(./gloss) &gt; 0">
        <informaltable class="interlinear-gloss-itemized-outer"> <colgroup/> <tr> <td>
              <xsl:call-template name="interlinear-gloss-itemized-table">
                <xsl:with-param name="width" select="count(./gloss[1]/*)"/>
                <xsl:with-param name="starter" select="."/>
                <xsl:with-param name="count" select="1"/>
              </xsl:call-template>
        </td> </tr> </informaltable>
      <xsl:for-each select="./natlang">
        <xsl:apply-templates select="node()|text()"/>
      </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          <xsl:text>No jbo or gloss in interlinear-gloss-itemized&#xA;</xsl:text>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <!-- debug message
    <xsl:message>
      <xsl:text>&#xA;stuff:</xsl:text>
      <xsl:copy-of select="./jbo[1]/*"/>
    </xsl:message>
    -->
</xsl:if>
  <xsl:if test="$pdf = 'yes'">
    <emphasis role="underline">foo</emphasis>
    <emphasis role="bold">foo</emphasis>
    <informaltable class="interlinear-gloss-itemized-table" align="left" width="100%">
      <?dblatex table-width="autowidth.all"?>
      <xsl:for-each select="./jbo|./gloss">
      <colgroup width="0*" align="left"/>
    </xsl:for-each>
      <xsl:for-each select="./jbo|./gloss">
    <tr>
              <xsl:apply-templates select="node()|text()"/>
      </tr>
    </xsl:for-each>
    </informaltable>
</xsl:if>
  </xsl:template>

  <!-- Deal with pronunciation nodes
  -->
  <xsl:template match="pronunciation">
    <xsl:choose>
      <xsl:when test="false">
      </xsl:when>
      <!-- FIXME: We should enforce something like these at some point.

      <xsl:when test="count(.//jbo) &lt; 1">
        <xsl:message>interlinear-gloss needs at least one jbo line; look for "ERROR" in the output</xsl:message>
        <xsl:text>
          ERROR: The following interlinear-gloss needs at least one jbo line:
        </xsl:text>
        <xsl:copy/>
      </xsl:when>
      <xsl:when test="count(.//natlang) &lt; 1">
        <xsl:message>interlinear-gloss needs at least one natlang line; look for "ERROR" in the output</xsl:message>
        <xsl:text>
          ERROR: The following interlinear-gloss needs at least one natlang line:
        </xsl:text>
        <xsl:copy/>
      </xsl:when>
      -->
      <xsl:otherwise>
        <itemizedlist class="pronunciation">
        <xsl:for-each select=".//jbo">
          <listitem class="pronunciation-jbo">
            <para>
              <xsl:apply-templates select="node()|text()"/>
            </para>
          </listitem>
        </xsl:for-each>
        <xsl:for-each select=".//ipa">
          <listitem class="pronunciation-ipa">
            <para>
              <xsl:apply-templates select="node()|text()"/>
            </para>
          </listitem>
        </xsl:for-each>
        </itemizedlist>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- <natlang> tags that arn't in <interlinear-gloss> tags -->
  <xsl:template match="example/natlang[not(boolean(ancestor::interlinear-gloss))]">
    <para>
      <xsl:apply-templates select="node()|text()"/>
    </para>
  </xsl:template>

  <!-- <compound-cmavo> tags; placeholder -->
  <xsl:template match="compound-cmavo">
    <simplelist>
      <xsl:for-each select=".//jbo">
        <member>
          <xsl:apply-templates select="node()|text()"/>
        </member>
      </xsl:for-each>
    </simplelist>
  </xsl:template>

  <xsl:template match="veljvo">
    <xsl:copy>
      <xsl:text>from </xsl:text>
      <jbophrase> <!-- will this get matched by the jbophrase template? -->
        <xsl:value-of select="."/>
      </jbophrase>
    </xsl:copy>
  </xsl:template>
  
  <!-- turn a string into a lowercase & dashes slug -->
  <xsl:template name="make_slug">
    <xsl:param name="input" select="''"/>
    <!-- This bit below just replaces ' with h-->
    <xsl:variable name="slug1">
      <xsl:value-of select="translate( $input, &#x22;&#x27;&#x22;, 'h' )"/>
    </xsl:variable>
    <!-- This bit below just deletes " -->
    <xsl:variable name="slug2">
      <xsl:value-of select='translate( $slug1, &#x27;&#x22;&#x27;, "" )'/>
    </xsl:variable>
    <xsl:variable name="slug3">
      <xsl:value-of select="translate( $slug2, '@#$%^*()?+/=[]{}!,', '' )"/>
    </xsl:variable>
    <xsl:variable name="slug4">
      <xsl:value-of select="normalize-space($slug3)"/>
    </xsl:variable>
    <!-- lowercase, and replace space with - -->
    <xsl:variable name="slug">
      <xsl:value-of select="translate( $slug4,
        '&#x20;&#x9;&#xD;&#xA;ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        '----abcdefghijklmnopqrstuvwxyz' )"/>
    </xsl:variable>
    <xsl:value-of select="$slug"/>
  </xsl:template>

  <xsl:template match="morphology">
    <foreignphrase xml:lang="jbo" role="morphology">
      <xsl:apply-templates select="node()|text()"/>
    </foreignphrase>
  </xsl:template>

  <xsl:template match="cmevla">
    <foreignphrase xml:lang="jbo" role="cmevla">
      <xsl:apply-templates select="node()|text()"/>
    </foreignphrase>
  </xsl:template>

  <xsl:template match="letteral">
    <foreignphrase xml:lang="jbo" role="letteral">
      <xsl:apply-templates select="node()|text()"/>
    </foreignphrase>
  </xsl:template>

  <xsl:template match="rafsi">
    <foreignphrase xml:lang="jbo" role="rafsi">
      <xsl:apply-templates select="node()|text()"/>
    </foreignphrase>
  </xsl:template>

  <xsl:template match="diphthong">
    <foreignphrase xml:lang="jbo" role="diphthong">
      <xsl:apply-templates select="node()|text()"/>
    </foreignphrase>
  </xsl:template>

  <xsl:template match="cmavo">
    <td>
      <emphasis class="cmavo">
        <xsl:value-of select="."/>
      </emphasis>
    </td>
  </xsl:template>

  <xsl:template match="comment">
    <para role="comment">
      <xsl:value-of select="."/>
    </para>
  </xsl:template>

  <xsl:template match="natlang">
    <para role="natlang">
      <xsl:value-of select="."/>
    </para>
  </xsl:template>

  <xsl:template match="grammar-template[not(boolean(parent::title)) and not(boolean(parent::term)) and not(boolean(parent::member)) and not(boolean(parent::secondary))]" priority="100">
    <blockquote role="grammar-template">
      <para>
        <xsl:apply-templates select="node()|text()"/>
      </para>
    </blockquote>
  </xsl:template>

  <xsl:template match="grammar-template" priority="1">
    <phrase role="grammar-template">
      <xsl:apply-templates select="node()|text()"/>
    </phrase>
  </xsl:template>

  <xsl:template match="oldjbophrase[not(boolean(parent::title)) and not(boolean(parent::term)) and not(boolean(parent::member)) and not(boolean(parent::secondary))]" priority="100">
    <blockquote role="oldjbophrase">
      <para>
        <xsl:apply-templates select="node()|text()"/>
      </para>
    </blockquote>
  </xsl:template>

  <xsl:template match="oldjbophrase" priority="1">
    <phrase role="oldjbophrase">
      <xsl:apply-templates select="node()|text()"/>
    </phrase>
  </xsl:template>

  <xsl:template match="definition[not(boolean(parent::title)) and not(boolean(parent::term)) and not(boolean(parent::member)) and not(boolean(parent::secondary))]" priority="100">
    <blockquote role="definition">
      <para>
        <xsl:apply-templates select="node()|text()"/>
      </para>
    </blockquote>
  </xsl:template>

  <xsl:template match="definition" priority="1">
    <phrase role="definition">
      <xsl:apply-templates select="node()|text()"/>
    </phrase>
  </xsl:template>

  <xsl:template match="content" priority="1">
    <phrase role="definition-content">
      <xsl:apply-templates select="node()|text()"/>
    </phrase>
  </xsl:template>

  <xsl:template match="inlinemath" priority="1">
    <inlineequation><mathphrase>
        <xsl:apply-templates select="node()|text()"/>
    </mathphrase></inlineequation>
  </xsl:template>

  <xsl:template match="math" priority="1">
    <informalequation><mathphrase>
        <xsl:apply-templates select="node()|text()"/>
    </mathphrase></informalequation>
  </xsl:template>

  <xsl:template match="lujvo-making">
    <informaltable class="lujvo-making">
      <tgroup cols="3">
        <tbody>
          <row>
            <xsl:for-each select="jbo">
              <entry>
                <xsl:apply-templates select="node()|text()"/>
              </entry>
            </xsl:for-each>
            <xsl:for-each select="rafsi">
              <entry>
                <xsl:apply-templates select="node()|text()"/>
              </entry>
            </xsl:for-each>
            <xsl:for-each select="score">
              <entry>
                <xsl:apply-templates select="node()|text()"/>
              </entry>
            </xsl:for-each>
          </row>
        </tbody>
      </tgroup>
    </informaltable>
  </xsl:template>

  <xsl:template match="lojbanization">
    <informaltable class="lojbanization">
      <tgroup cols="2">
        <tbody>
          <row>
            <xsl:for-each select="jbo">
              <entry>
                <xsl:value-of select="text()"/>
              </entry>
              <xsl:if test="boolean(comment)">
                <entry>
                  <xsl:value-of select="comment/text()"/>
                </entry>
              </xsl:if>
            </xsl:for-each>
          </row>
        </tbody>
      </tgroup>
    </informaltable>
  </xsl:template>

  <xsl:template match="valsi">
    <xsl:variable name="slug">
      <xsl:call-template name="make_slug">
        <xsl:with-param name="input" select="text()"/>
      </xsl:call-template>
    </xsl:variable>
    <glossterm linkend='valsi-{$slug}'>
      <foreignphrase xml:lang="jbo">
        <indexterm type="lojban-words">
          <primary>
            <xsl:apply-templates select="node()|text()"/>
          </primary>
        </indexterm>
        <xsl:apply-templates select="node()|text()"/>
      </foreignphrase>
    </glossterm>
  </xsl:template>

  <!-- For now, jbophrase makes an *index* but not a *glossary* -->
  <xsl:template match="jbophrase">
    <foreignphrase xml:lang="jbo">
      <indexterm type="lojban-phrases">
        <primary>
          <xsl:apply-templates select="node()|text()"/>
        </primary>
      </indexterm>
      <xsl:apply-templates select="node()|text()"/>
    </foreignphrase>
  </xsl:template>

  <!--
       Needs to be cannibalized to make <valsi>; <jbophrase. and
       <oldjbophrase> do not much at all

  <!- - lojban phrases and/or unglossed words - ->
  <xsl:template match="jbophrase"
    priority="1">
    <xsl:variable name="wordsnum">
      <xsl:value-of select="count(str:tokenize(text()))"/>
    </xsl:variable>
    <xsl:variable name="slug">
      <xsl:call-template name="make_slug">
        <xsl:with-param name="input" select="text()"/>
      </xsl:call-template>
    </xsl:variable>
    <!- - FIXME: the class is currently only used by the chapter2
         markup stuff, which still needs to be implemented
    - ->
    <foreignphrase xml:lang="jbo">
      <xsl:if test="boolean(@class)">
        <xsl:attribute name="class">
          <xsl:value-of select="@class"/>
        </xsl:attribute>
      </xsl:if>
      <indexterm>
        <xsl:if test="boolean($wordsnum > 1)">
          <xsl:attribute name="type">lojban-phrases</xsl:attribute>
        </xsl:if>
        <xsl:if test="boolean($wordsnum = 1)">
          <xsl:attribute name="type">lojban-words</xsl:attribute>
        </xsl:if>
        <primary><xsl:value-of select="text()"/></primary>
      </indexterm>
      <xsl:value-of select="text()"/>
    </foreignphrase>
  </xsl:template>

  <!- - turn <jbophrase> elements with single lojban words into
       glossary and indexed elements
       - ->
  <!- - If you change the match here, also change it in
       generate_glossary.xsl ; search for LOJBAN WORDS MATCH
       - ->
  <xsl:template match="jbophrase[count(str:tokenize(text())) = 1 and ( not(@glossary) or @glossary != 'false')
    and ( not(@class) or ( @class != 'morphology' and @class != 'rafsi' and @class != 'diphthong' and @class != 'letteral' ) ) ]"
    priority="2">
    <xsl:variable name="wordsnum">
      <xsl:value-of select="count(str:tokenize(text()))"/>
    </xsl:variable>
    <xsl:variable name="slug">
      <xsl:call-template name="make_slug">
        <xsl:with-param name="input" select="text()"/>
      </xsl:call-template>
    </xsl:variable>
    <!- - FIXME: the class is currently only used by the chapter2
         markup stuff, which still needs to be implemented
    - ->
    <glossterm linkend='jbogloss-{$slug}'>
      <foreignphrase xml:lang="jbo">
        <xsl:if test="boolean(@class)">
          <xsl:attribute name="class">
            <xsl:value-of select="@class"/>
          </xsl:attribute>
        </xsl:if>
        <indexterm>
          <xsl:attribute name="type">lojban-words</xsl:attribute>
          <primary>
            <xsl:apply-templates select="node()|text()"/>
          </primary>
        </indexterm>
        <xsl:apply-templates select="node()|text()"/>
      </foreignphrase>
    </glossterm>
  </xsl:template>

  -->

</xsl:stylesheet>
