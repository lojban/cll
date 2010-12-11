<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  extension-element-prefixes="exsl str"
  version="1.0">

  <!-- Import the identity transformation. -->
  <xsl:import href="identity.xsl"/>

  <!-- eats whitespace from the left 
    from http://dpawson.co.uk/xsl/sect2/N8321.html#d11328e833
  -->
  <xsl:template name="remove-ws-left">
    <xsl:param name="astr"/>

    <xsl:choose>
      <xsl:when test="starts-with($astr,'&#xA;') or
        starts-with($astr,'&#x20;') or
        starts-with($astr,'&#x9;') or
        starts-with($astr,'&#xD;')">
        <xsl:call-template name="remove-ws-left">
          <xsl:with-param name="astr" select="substring($astr, 2)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$astr"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- eats whitespace from the right
    from http://dpawson.co.uk/xsl/sect2/N8321.html#d11328e833
  -->
  <xsl:template name="remove-ws-right">
    <xsl:param name="astr"/>

    <xsl:variable name="last-char">
      <xsl:value-of select="substring($astr, string-length($astr), 1)"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="($last-char = '&#xA;') or
        ($last-char = '&#xD;') or
        ($last-char = '&#x20;') or
        ($last-char = '&#x9;')">
        <xsl:call-template name="remove-ws-right">
          <xsl:with-param name="astr"
            select="substring($astr, 1, string-length($astr) - 1)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$astr"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- matches items with example-type anchor elements that don't contain phrase or foreignphrase -->
  <xsl:template match="programlisting[boolean(./anchor[contains(@xml:id, 'example')]) and not(boolean(child::foreignphrase)) and not(boolean(child::phrase))]">
    <example role="interlinear-gloss-example" xml:id="RANDOM">
      <title>
        <xsl:for-each select="anchor">
          <xsl:copy>
            <!-- Including any attributes it has and any child nodes -->
            <xsl:apply-templates select="@*|node()"/>
          </xsl:copy>
        </xsl:for-each>
      </title>
      <interlinear-gloss>
        <xsl:for-each select=".//text()">
          <xsl:variable name="tmpstring">
            <xsl:call-template name="remove-ws-left">
              <xsl:with-param name="astr" select="."/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="newstring">
            <xsl:call-template name="remove-ws-right">
              <xsl:with-param name="astr" select="$tmpstring"/>
            </xsl:call-template>
          </xsl:variable>

          <xsl:if test="contains($newstring,')')">
            <xsl:for-each select="str:tokenize($newstring,'&#10;')">
              <xsl:choose>
                <xsl:when test="position() = 1">
                  <jbo><xsl:value-of select="."/></jbo>
                </xsl:when>
                <xsl:when test="position() = last()">
                  <en><xsl:value-of select="."/></en>
                </xsl:when>
                <xsl:otherwise>
                  <gloss><xsl:value-of select="."/></gloss>
                </xsl:otherwise>
                <xsl:value-of select="."/>
                <xsl:text>foo</xsl:text>
              </xsl:choose>
            </xsl:for-each>
          </xsl:if>
        </xsl:for-each>
      </interlinear-gloss>
    </example>
  </xsl:template>

</xsl:stylesheet>
