<?xml version="1.0" encoding="UTF-8"?>
<!-- Copyright 2020 The MathWorks, Inc. -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:output method="html" indent="yes"/>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" />
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@href">
        <xsl:attribute name="href">
            <xsl:choose>
                <xsl:when test="contains(.,'.md')">
                    <xsl:value-of select="substring-before(.,'.md')"/>
                    <xsl:text>.html</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
</xsl:stylesheet>