<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <toc version="1.0">
            <xsl:apply-templates/>
        </toc>
    </xsl:template>
    <xsl:template match="ul">
        <xsl:for-each select="li">
            <tocitem target="{a/@href}">
                <xsl:apply-templates/>
            </tocitem>
        </xsl:for-each>
    </xsl:template>
    <!-- TODO match ol -->
    <xsl:template match="h1"/>
    <xsl:template match="p"/>
    <xsl:strip-space elements="*" />
</xsl:stylesheet>