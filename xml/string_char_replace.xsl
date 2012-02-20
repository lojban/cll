<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!--  (c) David Carlisle
      replace all occurences of the character(s) `from'
      by the string `to' in the string `string'.

      Modified by RLP to use copy-of for $to so it could take whole structures

      http://home.online.no/~pjacklam/latex/textcomp.pdf is likely to be helpful here
  -->
  <xsl:template name="string-char-replace" >
    <xsl:param name="string"/>
    <xsl:param name="from"/>
    <xsl:param name="to"/>
    <xsl:choose>
      <xsl:when test="contains($string,$from)">
        <xsl:value-of select="substring-before($string,$from)"/>
        <xsl:copy-of select="$to"/>
        <xsl:call-template name="string-char-replace">
          <xsl:with-param name="string" select="substring-after($string,$from)"/>
          <xsl:with-param name="from" select="$from"/>
          <xsl:with-param name="to" select="$to"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
