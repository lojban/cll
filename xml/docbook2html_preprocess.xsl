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

  <!--
       BEGIN: table helpers

       #1 tokenizes by spaces (i.e. jbo and gloss fields)

       #2 generates a full spanning tr/td for a single element (i.e. natlang fields)

       #3 generates simple tr/td for all sub elements
  -->

  <xsl:template name="tokenized_table_section">
    <xsl:param name="items" select="''"/>
    <!-- The reason this gets complicated is things like:

         <gloss>The-one-named <quote>bear</quote> [past] creates the story.</gloss>

         We want to break up all the bits except the quote, and still keep it all in one row.

      -->

    <xsl:for-each select="$items">
      <tr>
        <xsl:for-each select="node()">
          <xsl:choose>
            <xsl:when test="self::text()">
              <xsl:for-each select="str:tokenize(.)">
                <td> <xsl:apply-templates select="."/> </td>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <td> <xsl:apply-templates select="."/> </td>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </tr>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="flat_table_section">
    <xsl:param name="items" select="''"/>
    <xsl:for-each select="$items">
      <tr>
        <td colspan="0"><xsl:apply-templates select="node()|text()"/></td>
      </tr>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="regular_table_section">
    <xsl:param name="items" select="''"/>
    <xsl:for-each select="$items">
      <tr>
        <xsl:for-each select="*">
          <td><xsl:apply-templates select="."/></td>
        </xsl:for-each>
      </tr>
    </xsl:for-each>
  </xsl:template>

  <!--
       END: table helpers
  -->


  <!-- 
       BEGIN: interlinear-gloss

       Turn interlinear-gloss nodes into tables.

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
        <informaltable class="interlinear-gloss">
          <colgroup/>
          <xsl:call-template name="tokenized_table_section">  <xsl:with-param name="items" select="./jbo|./gloss"/>   </xsl:call-template>
          <xsl:call-template name="flat_table_section">       <xsl:with-param name="items" select="./natlang"/>       </xsl:call-template>
        </informaltable>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- 
       END: interlinear-gloss

       -->

  <!-- 
       BEGIN: Turn cmavo-list nodes into tables.
       
       -->
  <xsl:template match="cmavo-list">
    <informaltable class="cmavo-list">
      <colgroup/>
      <xsl:apply-templates select="cmavo-list-head"/>  
      <xsl:call-template name="regular_table_section">  <xsl:with-param name="items" select=".//cmavo-entry"/>   </xsl:call-template>
    </informaltable>
  </xsl:template>

<!--
    <cmavo-list>
      <cmavo-entry>
        <cmavo>nu</cmavo>
        <description>event of</description>
        <gismu>fasnu</gismu>
        <rafsi>nun</rafsi>
        <description role="place-structure">x1 is an event of (the bridi)</description>

other options:

        <modal-place>as said by</modal-place>
        <modal-place se="se">expressing</modal-place>

        <series>mi-series</series>

        <pseudo-cmavo>[N]roi</pseudo-cmavo>

        <attitudinal-scale point="sai">discovery</attitudinal-scale>

      </cmavo-entry>

-->

        <xsl:template match="cmavo">
          <emphasis role="cmavo">
            <xsl:value-of select="."/>
          </emphasis>
        </xsl:template>

        <!-- FIXME: <description role="place-structure"> should get
             passed through
             -->
        <xsl:template match="description">
          <para role="description">
            <xsl:value-of select="."/>
          </para>
        </xsl:template>

        <xsl:template match="gismu">
          <para role="gismu">
            <xsl:value-of select="."/>
          </para>
        </xsl:template>

        <xsl:template match="selmaho">
          <para role="selmaho">
            <xsl:value-of select="."/>
          </para>
        </xsl:template>

        <xsl:template match="rafsi">
          <para role="rafsi">
            <xsl:value-of select="."/>
          </para>
        </xsl:template>

        <!-- <compound>nairu'e</compound> -->
        <xsl:template match="compound">
          <para role="cmavo-compound">
            <xsl:value-of select="."/>
          </para>
        </xsl:template>

        <!-- <attitudinal-scale point="sai">discovery</attitudinal-scale> -->
        <xsl:template match="attitudinal-scale">
          <xsl:variable name="point">
            <xsl:value-of select="@point"/>
          </xsl:variable>
          <para role="attitudinal-scale-{$point}">
            <xsl:value-of select="."/>
          </para>
        </xsl:template>

        <!-- <series>mi-series</series> -->
        <xsl:template match="series">
          <para role="cmavo-series">
            <xsl:value-of select="."/>
          </para>
        </xsl:template>

        <!-- <pseudo-cmavo>[N]roi</pseudo-cmavo> -->
        <xsl:template match="pseudo-cmavo">
          <para role="pseudo-cmavo">
            <xsl:value-of select="."/>
          </para>
        </xsl:template>

        <!-- <modal-place>as said by</modal-place> -->
        <!-- <modal-place se="se">expressing</modal-place> -->
        <xsl:template match="modal-place">
          <xsl:variable name="se_word">
            <xsl:value-of select="@se"/>
          </xsl:variable>
          <para role="modal-place-{$se_word}">
            <xsl:value-of select="."/>
          </para>
        </xsl:template>

        <xsl:template match="cmavo-list-head">
          <xsl:for-each select="entry">
            <th><xsl:copy-of select="."/></th>
          </xsl:for-each>
        </xsl:template>

        <!-- 
       END: Turn cmavo-list nodes into tables.
  --> 

  <!-- 
       WTF was I doing here?

       Was this intended to be able to do two-color alternating?
       Probably.  To work around some bullshit in dblatex?  Also
       probably.  Is it needed anymore?  Probably not.



       This gets a bit complicated as we're essentially walking an
       xml table column-wise.

       Given:

       <a><b>1</b><b>2</b><b>3</b></a>
       <a><b>8</b><b>9</b><b>7</b></a>

       This code makes a table for <b>1</b> and <b>8</b>, another
       for <b>2</b> and <b>9</b>, etc.

       We do this by starting with a count of 1, finding the [1]
       subelements, then calling self with an incremented count.

  <xsl:template name="interlinear-gloss-itemized-table">
    <xsl:param name="width" select="''"/>
    <xsl:param name="starter" select="''"/>
    <xsl:param name="count" select="''"/>
    <xsl:variable name="any">
      <xsl:value-of select="count($starter/jbo/*[$count]|$starter/gloss/*[$count])"/>
    </xsl:variable>
    <!- - debug message
    <xsl:message>
      <xsl:text>&#xA;width:</xsl:text>
      <xsl:copy-of select="$width"/>
      <xsl:text>&#xA;moo:</xsl:text>
      <xsl:copy-of select="($starter/jbo/*[$count]|$starter/gloss/*[$count])"/>
    </xsl:message>
    - ->
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

  <!- - Template for interlinear-gloss-itemized

       This picks, as a table (-ish) width marker, either the first
       ./jbo or first ./gloss, counts the numebr of sub-elements,
       and then calls interlinear-gloss-itemized-table with that
       value.
  - ->
  <xsl:template match="interlinear-gloss-itemized">
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
    <!- - debug message
    <xsl:message>
      <xsl:text>&#xA;stuff:</xsl:text>
      <xsl:copy-of select="./jbo[1]/*"/>
    </xsl:message>
    - ->
  </xsl:template>
  -->

<!--

    BEGIN: handle interlinear-gloss-itemized

      <interlinear-gloss-itemized>
        <jbo>
          <sumti>mi</sumti>
          <elidable>cu</elidable>
          <selbri>vecnu</selbri>
          <sumti>ti</sumti>
          <sumti>ta</sumti>
          <sumti>zo'e</sumti>
        </jbo>
-->

        <xsl:template match="selbri">
          <para role="selbri">
            <xsl:value-of select="."/>
          </para>
        </xsl:template>

        <xsl:template match="sumti">
          <para role="sumti">
            <xsl:value-of select="."/>
          </para>
        </xsl:template>

        <xsl:template match="elidable">
          <para role="elidable">
            <xsl:value-of select="."/>
          </para>
        </xsl:template>

        <!-- main handling here -->

        <xsl:template match="interlinear-gloss-itemized">
          <informaltable class="interlinear-gloss-itemized">
            <colgroup/>
            <xsl:call-template name="regular_table_section">  <xsl:with-param name="items" select="./jbo|./gloss"/>   </xsl:call-template>
            <xsl:call-template name="flat_table_section">       <xsl:with-param name="items" select="./natlang"/>       </xsl:call-template>
          </informaltable>
        </xsl:template>

<!--

    END: handle interlinear-gloss-itemized

    -->

  <!-- Deal with pronunciation nodes -->
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
        <itemizedlist role="pronunciation">
          <xsl:for-each select=".//jbo">
            <listitem role="pronunciation-jbo">
              <para role="pronunciation-jbo">
                <xsl:apply-templates select="node()|text()"/>
              </para>
            </listitem>
          </xsl:for-each>
          <xsl:for-each select=".//ipa">
            <listitem role="pronunciation-ipa">
              <para role="pronunciation-ipa">
                <xsl:apply-templates select="node()|text()"/>
              </para>
            </listitem>
          </xsl:for-each>
        </itemizedlist>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- natlang tags that arn't in interlinear-gloss tags -->
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
        <jbophrase> <!-- FIXME: will this get matched by the jbophrase template? It should be. -->
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

    <xsl:template match="comment">
      <para role="comment">
        <xsl:value-of select="."/>
      </para>
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
          <colgroup/>
          <xsl:call-template name="flat_table_section">       <xsl:with-param name="items" select="./*"/>       </xsl:call-template>
        </informaltable>
    </xsl:template>

    <xsl:template match="lojbanization">
        <informaltable class="lojbanization">
          <colgroup/>
          <xsl:call-template name="flat_table_section">       <xsl:with-param name="items" select="./*"/>       </xsl:call-template>
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

  </xsl:stylesheet>
