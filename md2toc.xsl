<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <toc version="1.0">
    <xsl:apply-templates/>  
  </toc>
</xsl:template>

<xsl:template match="ul">
    <xsl:apply-templates select="li"/>  
</xsl:template>

<xsl:template match="li">
  <xsl:text disable-output-escaping="yes">&lt;</xsl:text>tocitem<xsl:apply-templates select="a"/><xsl:apply-templates select="ul"/><xsl:text disable-output-escaping="yes">&lt;</xsl:text>/tocitem<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
</xsl:template>

<xsl:template match="a">
  target="<xsl:apply-templates select="@href"/>.html"<xsl:text disable-output-escaping="yes">&gt;</xsl:text><xsl:value-of select="."/>
</xsl:template>

<xsl:template match="@href">
  <xsl:value-of select="substring-before(.,'.md')"/>
</xsl:template>

</xsl:stylesheet>