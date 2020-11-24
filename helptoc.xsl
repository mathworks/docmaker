<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright 2020 The MathWorks, Inc. -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:output indent="yes"/>
    
    <xsl:template match="/">
        <xsl:text>&#xA;</xsl:text>    
        <xsl:comment> Copyright 2009-2020 The MathWorks, Inc. </xsl:comment>
        <xsl:text>&#xA;</xsl:text>
        <xsl:element name="toc">
            <xsl:attribute name="version">1.0</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="ul">
        <xsl:apply-templates select="li"/>  
    </xsl:template>
    
    <xsl:template match="li">
        <xsl:element name="tocitem">
            <xsl:apply-templates select="a"/>
            <xsl:apply-templates select="ul"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="a">
        <xsl:attribute name="target">
            <xsl:apply-templates select="@href"/>
        </xsl:attribute>
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="@href">
        <xsl:choose>
            <xsl:when test="contains(.,'.')">
                <xsl:value-of select="substring-before(.,'.')"/>
                <xsl:text>.html</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>