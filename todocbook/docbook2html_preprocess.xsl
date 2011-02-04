<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  extension-element-prefixes="exsl str"
  version="1.0">

  <!-- Import the identity transformation. -->
  <xsl:import href="identity.xsl"/>

  <xsl:output method="xml" doctype-system="dtd/docbook-5.0.dtd" doctype-public="-//OASIS//DTD DocBook XML V5.0//EN" />

  <xsl:template name="counted_table">
    <xsl:param name="maximal" select="''"/>
    <xsl:param name="items" select="''"/>
    <informaltable>
      <tgroup>
        <xsl:attribute name="cols">
          <xsl:value-of select="count(str:tokenize($maximal))"/>
        </xsl:attribute>
        <xsl:for-each select="str:tokenize($maximal)">
          <colspec>
            <xsl:attribute name="colname">
              <xsl:value-of select="concat('col',position())"/>
            </xsl:attribute>
          </colspec>
        </xsl:for-each>
        <tbody>
          <xsl:for-each select="$items/jbo">
            <row>
              <xsl:for-each select="str:tokenize(.)">
                <entry><xsl:value-of select="."/></entry>
              </xsl:for-each>
            </row>
          </xsl:for-each>
          <xsl:for-each select="$items/gloss">
            <row>
              <xsl:for-each select="str:tokenize(.)">
                <entry><xsl:value-of select="."/></entry>
              </xsl:for-each>
            </row>
          </xsl:for-each>
          <xsl:for-each select="$items/en">
            <xsl:variable name="startcol" select="concat('col',1)" />
            <xsl:variable name="endcol" select="concat('col',count(str:tokenize($maximal)))" />
            <row>
              <entry namest="{$startcol}" nameend="{$endcol}"><xsl:value-of select="."/></entry>
            </row>
          </xsl:for-each>
        </tbody>
      </tgroup>
    </informaltable>
  </xsl:template>

  <!-- Turn cmavo-list nodes into tables. -->
  <xsl:template match="cmavo-list">
    <informaltable>
      <tgroup cols="3">
        <xsl:apply-templates select="cmavo-list-head"/>  
        <tbody>
          <xsl:for-each select=".//cmavo-entry">
            <row>
              <xsl:for-each select="cmavo|selmaho|description|gismu|rafsi|attitudinal-scale|modal-place">
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

        Such a node must have at least one jbo entry and at least one en entry.
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
      <xsl:when test="count(.//en) &lt; 1">
        <xsl:message>interlinear-gloss needs at least one en line; look for "ERROR" in the output</xsl:message>
        <xsl:text>
          ERROR: The following interlinear-gloss needs at least one en line:
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
              <xsl:with-param name="maximal" select="."/>
              <xsl:with-param name="items" select="$items"/>
            </xsl:call-template>
          </xsl:if>
        </xsl:for-each>

        <!-- END actual table conversion -->
      </xsl:otherwise>
    </xsl:choose>
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
      <xsl:when test="count(.//en) &lt; 1">
        <xsl:message>interlinear-gloss needs at least one en line; look for "ERROR" in the output</xsl:message>
        <xsl:text>
          ERROR: The following interlinear-gloss needs at least one en line:
        </xsl:text>
        <xsl:copy/>
      </xsl:when>
      -->
      <xsl:otherwise>
        <itemizedlist role="pronunciation">
        <xsl:for-each select=".//jbo">
          <listitem role="pronunciation-jbo">
            <para>
              <xsl:value-of select=".//text()"/>
            </para>
          </listitem>
        </xsl:for-each>
        <xsl:for-each select=".//ipa">
          <listitem role="pronunciation-ipa">
            <para>
              <xsl:value-of select=".//text()"/>
            </para>
          </listitem>
        </xsl:for-each>
        </itemizedlist>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- <en> tags that arn't in <interlinear-gloss> tags -->
  <xsl:template match="example/en[not(boolean(ancestor::interlinear-gloss))]">
    <para>
      <xsl:value-of select='.//text()'/>
    </para>
  </xsl:template>

  <!-- <compound-cmavo> tags; placeholder -->
  <xsl:template match="compound-cmavo">
    <simplelist>
      <xsl:for-each select=".//jbo">
        <member>
          <xsl:value-of select=".//text()"/>
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

  <!-- turn <jbophrase> elements with single lojban words into
       glossary and indexed elements
       -->
  <!-- If you change the match here, also change it in
       generate_glossary.xsl ; search for LOJBAN WORDS MATCH
       -->
  <xsl:template match="jbophrase[count(str:tokenize(text())) = 1 and ( not(@glossary) or @glossary != 'false')
    and ( not(@role) or ( @role != 'morphology' and @role != 'rafsi' and @role != 'diphthong' and @role != 'letteral' ) ) ]"
    priority="2">
    <xsl:variable name="wordsnum">
      <xsl:value-of select="count(str:tokenize(text()))"/>
    </xsl:variable>
    <xsl:variable name="slug">
      <xsl:call-template name="make_slug">
        <xsl:with-param name="input" select="text()"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- FIXME: the role is currently only used by the chapter2
         markup stuff, which still needs to be implemented
    -->
    <glossterm linkend='jbogloss-{$slug}'>
      <foreignphrase xml:lang="jbo">
        <xsl:if test="boolean(@role)">
          <xsl:attribute name="role">
            <xsl:value-of select="@role"/>
          </xsl:attribute>
        </xsl:if>
        <indexterm>
          <xsl:attribute name="type">lojban-words</xsl:attribute>
          <primary><xsl:value-of select="text()"/></primary>
        </indexterm>
        <xsl:value-of select="text()"/>
      </foreignphrase>
    </glossterm>
  </xsl:template>

  <!-- lojban phrases and/or unglossed words -->
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
    <!-- FIXME: the role is currently only used by the chapter2
         markup stuff, which still needs to be implemented
    -->
    <foreignphrase xml:lang="jbo">
      <xsl:if test="boolean(@role)">
        <xsl:attribute name="role">
          <xsl:value-of select="@role"/>
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

</xsl:stylesheet>
