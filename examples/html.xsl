<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:import href="../charts.xsl" />
	<xsl:output method="html" indent="yes" omit-xml-declaration="yes" />
	<xsl:template match="/">
	    <xsl:text disable-output-escaping="yes">&lt;!doctype html&gt;</xsl:text>
		<html>
			<body>

					<p>
						<xsl:call-template name="lineChart">
							<xsl:with-param name="xData" select="/data/x" />
							<xsl:with-param name="yData" select="/data/y" />
							<xsl:with-param name="width" select="'640px'" />
							<xsl:with-param name="height" select="'250px'" />
							<xsl:with-param name="viewBoxWidth" select="325" />
                            <xsl:with-param name="viewBoxHeight" select="150" />
						</xsl:call-template>
					</p>
					<p>
						<xsl:call-template name="barChart">
							<xsl:with-param name="xData" select="/data/x" />
							<xsl:with-param name="yData" select="/data/y" />
							<xsl:with-param name="width" select="'640px'" />
							<xsl:with-param name="height" select="'250px'" />
							<xsl:with-param name="viewBoxWidth" select="325" />
                            <xsl:with-param name="viewBoxHeight" select="150" />
						</xsl:call-template>
					</p>
					<p>
						<xsl:call-template name="pieChart">
							<xsl:with-param name="xData" select="/data/x" />
							<xsl:with-param name="yData" select="/data/y" />
							<xsl:with-param name="width" select="'640px'" />
							<xsl:with-param name="height" select="'250px'" />
							<xsl:with-param name="viewBoxWidth" select="325" />
                            <xsl:with-param name="viewBoxHeight" select="150" />
						</xsl:call-template>
					</p>

			</body>
		</html>
	</xsl:template>
</xsl:stylesheet>
