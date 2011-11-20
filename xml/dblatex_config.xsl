<?xml version='1.0' encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

<!-- trying to avoid the BS front thing; defaults to
<xsl:param name="doc.layout">coverpage toc frontmatter mainmatter index </xsl:param>
 -->
<xsl:param name="doc.layout">coverpage toc frontmatter mainmatter index</xsl:param>

<!-- drop the dblatex logo -->
<xsl:param name="doc.publisher.show">0</xsl:param>

<!-- Show the list of examples too, default is:
  <xsl:param name="doc.lot.show">figure,table</xsl:param>
-->
<xsl:param name="doc.lot.show">figure,table,example</xsl:param>

<!-- The way this works is that xml/docbook2html_preprocess.xsl
     wraps things in <latex-verbatim> tags for special latex stuff,
     and we unwrap them into their raw text here
     -->
<xsl:template match="latex-verbatim">
  <xsl:value-of select="text()">
    <xsl:apply-templates mode="latex.verbatim"/>
  </xsl:value-of>
</xsl:template>

</xsl:stylesheet>
