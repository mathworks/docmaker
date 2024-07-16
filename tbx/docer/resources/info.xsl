<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" indent="yes" omit-xml-declaration="yes"/>
    <xsl:template match="/">
        <productinfo xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="optional">
            <xsl:apply-templates/>
            <type>toolbox</type>
            <icon>$toolbox/matlab/icons/bookicon.gif</icon>
            <help_location>.</help_location>
        </productinfo>
    </xsl:template>
    <xsl:template match="release">
        <matlabrelease><xsl:value-of select="."/></matlabrelease>
    </xsl:template>
    <xsl:template match="name">
        <name><xsl:value-of select="."/></name>
    </xsl:template>
<xsl:strip-space elements="*" />
</xsl:stylesheet>