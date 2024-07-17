<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <toc version="1.0">
            <xsl:apply-templates/>
        </toc>
    </xsl:template>
    <xsl:template match="ul/li">
        <tocitem target="{a/@href}">
            <xsl:value-of select="a/text()"/>
            <xsl:apply-templates/>
        </tocitem>
    </xsl:template>
    <xsl:template match="ol/li">
        <tocitem target="{a/@href}">
            <xsl:value-of select="a/text()"/>
            <xsl:apply-templates/>
        </tocitem>
    </xsl:template>
    <xsl:template match="text()"/>
    <xsl:strip-space elements="*" />
</xsl:stylesheet>