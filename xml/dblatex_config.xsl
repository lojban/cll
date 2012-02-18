<?xml version='1.0' encoding="iso-8859-1"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

  <!-- FIXME: Options pages we should review:

       http://dblatex.sourceforge.net/doc/manual/apas18.html

       http://dblatex.sourceforge.net/doc/manual/apas15.html

       http://dblatex.sourceforge.net/doc/manual/apas10.html

       http://dblatex.sourceforge.net/doc/manual/apas08.html

       http://dblatex.sourceforge.net/doc/manual/apas05.html

       -->


<!-- trying to avoid the BS front thing; actually handeled by
     options below; defaults to
<xsl:param name="doc.layout">coverpage toc frontmatter mainmatter index </xsl:param>
 -->

<!-- drop the dblatex logo -->
<xsl:param name="doc.publisher.show">0</xsl:param>

<!-- drop the revision history -->
<xsl:param name="latex.output.revhistory">0</xsl:param>

<!-- drop the collaboraters list -->
<xsl:param name="doc.collab.show">0</xsl:param>

<!-- default is:
  <xsl:param name="doc.lot.show">figure,table</xsl:param>
  to show examples add ,examples, but we almost certainly don't want that
-->

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
