<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright 2020 The MathWorks, Inc. -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:output method="html" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:element name="html">
            <xsl:attribute name="xml:lang">en</xsl:attribute>
            <xsl:attribute name="lang">en</xsl:attribute>
            <xsl:element name="head">
                <xsl:element name="title">Title</xsl:element>
            </xsl:element>
            <xsl:element name="body">
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>