﻿<?xml version="1.0" encoding="UTF-8"?>
<!--

Maintained by Patrick Gundlach, speedata. See git log for changes.

https://github.com/speedata/SvgCharts4Xsl

Original copyright notice follows:

Original Author: Frankline Francis

Copyright (c) 2012, Imaginea. All rights reserved.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND DEVELOPERS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT OWNER OR DEVELOPERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Redistribution and use, with or without modification, are permitted provided that the following conditions are met:
    # Redistribution of source code must retain the above copyright notice, this list of conditions and the disclaimer.
    # Neither the name of Imaginea nor the names of the developers may be used to endorse or promote products derived from
      this software without specific prior written permission.
-->
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/2005/xpath-functions/math"
	xmlns:sd="urn:speedata-functions"
	xmlns="http://www.w3.org/2000/svg"
	exclude-result-prefixes="#all">

	<!-- Constants -->
	<xsl:variable name="COLOURS" select="('violet','orangered', 'navajowhite', 'teal', 'limegreen', 'hotpink', 'maroon', 'steelblue', 'olive', 'gold', 'yellow', 'yellowgreen', 'red', 'wheat', 'darkgreen', 'brown', 'olivedrab', 'darkblue', 'firebrick', 'gray') "/>
	<xsl:variable name="FONT" select="'Arial'" />
	<xsl:variable name="FONT_SIZE" select="5" />

	<xsl:function name="sd:color" as="xs:string">
		<xsl:param name="index" as="xs:integer"/>
		<xsl:value-of select="$COLOURS[( ($index - 1)  mod count($COLOURS) ) + 1]"/>
	</xsl:function>

	<!-- Helper template to print x-axis -->
	<xsl:template name="printXAxis">
		<xsl:param name="xData" />
		<xsl:param name="step" />
		<xsl:param name="xMin" />
		<xsl:param name="xMax" />

		<xsl:for-each select="$xData">
			<xsl:if test="position() &lt;= $xMax">
				<text writing-mode="tb" dy="5" fill="black" font-weight="bold" >
					<xsl:attribute name="x" select="$xMin+(position() - 1)*$step"/>
					<xsl:attribute name="font-family" select="$FONT"/>
					<xsl:attribute name="font-size" select="$FONT_SIZE"/>
					<xsl:value-of select="." />
				</text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Helper template to print y-axis -->
	<xsl:template name="printYAxis">
		<xsl:param name="index" />
		<xsl:param name="step" />
		<xsl:param name="xMin" />
		<xsl:param name="xMax" />
		<xsl:param name="yMin" />
		<xsl:param name="yMax" />
		<xsl:param name="yScale" />

		<xsl:variable name="labelDelta" select="$FONT_SIZE div 2" />
		<xsl:if test="$index &lt; $yMax">
			<xsl:variable name="y" select="if ($yMin &lt; 0) then floor($yScale*($yMax - $index + $step div 2)) else floor($yScale*($yMax - $index))"/>
			<text x="{($xMin - 5)}" y="{($y + $labelDelta)}" text-anchor="end" fill="black" font-family="{$FONT}" font-weight="bold" font-size="{$FONT_SIZE}" >
				<xsl:value-of select="$index" />
			</text>
			<line x1="{$xMin}" y1="{$y}" x2="{$xMax}" y2="{$y}" stroke="grey" stroke-width="0.25"  />

			<xsl:call-template name="printYAxis">
				<xsl:with-param name="index" select="$index+$step" />
				<xsl:with-param name="step" select="$step" />
				<xsl:with-param name="xMin" select="$xMin" />
				<xsl:with-param name="xMax" select="$xMax" />
				<xsl:with-param name="yMin" select="$yMin" />
				<xsl:with-param name="yMax" select="$yMax" />
				<xsl:with-param name="yScale" select="$yScale" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!--
		************************************************
		***************    linechart     ***************
		************************************************
	-->
	<!-- Constants -->

	<xsl:variable name="POINT_RADIUS" select="1.5" />

	<!-- Prints a simple line chart with grid -->
	<xsl:template name="lineChart">
		<xsl:param name="xData" />
		<xsl:param name="yData" />
		<xsl:param name="lineColour" select="'black'" />
		<xsl:param name="pointColour" select="'red'" />
		<xsl:param name="width" select="'100%'" />
		<xsl:param name="height" select="'100%'" />
		<xsl:param name="viewBoxWidth" select="300" />
		<xsl:param name="viewBoxHeight" select="300" />
		<xsl:param name="xDelta" select="15" />
		<xsl:param name="leftPadding" select="20" />
		<xsl:param name="rightPadding" select="10" />
		<xsl:param name="verticalSpan" select="100" />

		<xsl:variable name="xCount" select="count($xData)" />
		<xsl:variable name="yCount" select="count($yData)" />
		<xsl:variable name="_verticalSpan" select="if ($verticalSpan &lt; $MIN_VERTICAL_SPAN) then $MIN_VERTICAL_SPAN else $verticalSpan"/>

		<svg version="1.1" preserveAspectRatio="xMinYMin" >
			<xsl:attribute name="width" select="$width"/>
			<xsl:attribute name="height" select="$height"/>
			<xsl:attribute name="viewBox" select="concat('0 0 ', $viewBoxWidth, ' ', $viewBoxHeight)"/>

			<xsl:if test="$xCount &gt; 0 and $yCount &gt; 0">
				<xsl:variable name="yDataMin" select="min($yData)"/>
				<xsl:variable name="yDataMax" select="max($yData)"/>
				<xsl:variable name="yScale" select="$_verticalSpan div ($yDataMax - $yDataMin)" />
				<xsl:variable name="yDelta" select="round(($yDataMax - $yDataMin) div $yCount)*2" />
				<xsl:variable name="xMin" select="$leftPadding" />
				<xsl:variable name="xMax" select="$xMin+count($yData)*$xDelta+$rightPadding" />
				<xsl:variable name="xStart" select="$xMin+$xDelta div 2" />
				<xsl:variable name="yMin" select="if ($yDataMin &lt; 0) then $yDataMin - $yDelta else 0"/>
				<xsl:variable name="yMax" select="$yDataMax+$yDelta" />
				<xsl:variable name="bottom" select="if ($yDataMin &lt; 0) then - $_verticalSpan else 0"/>
				<xsl:variable name="yStep" select="$yDelta*$yScale" />
				<xsl:variable name="totalHeight" select="round($_verticalSpan+$bottom+2*$yStep)" />
				<xsl:variable name="yStart" select="if ($yDataMin &lt; 0) then $bottom - $yStep else $bottom" />
				<xsl:variable name="yCentre" select="if ($yMin &lt; 0) then floor($yScale*($yMax + $yDelta div 2)) else floor($yScale*$yMax)"/>

				<!-- Print centre -->
				<circle cx="{$xMin}" cy="{$yCentre}" r="1" />

				<!-- Print y-axis -->
				<xsl:call-template name="printYAxis">
					<xsl:with-param name="index" select="$yMin" />
					<xsl:with-param name="step" select="$yDelta" />
					<xsl:with-param name="xMin" select="$xMin" />
					<xsl:with-param name="xMax" select="$xMax" />
					<xsl:with-param name="yMin" select="$yMin" />
					<xsl:with-param name="yMax" select="$yMax" />
					<xsl:with-param name="yScale" select="$yScale" />
				</xsl:call-template>
				<g transform="translate(0 {$totalHeight}) scale(1 -1)">
					<line x1="{$xMin}" y1="{$yStart}" x2="{$xMin}" y2="{$totalHeight}" stroke="black" stroke-width="2" />
				</g>

				<!-- Print points -->
				<g transform="translate(0 {$yCentre}) scale(1 -1)">
					<xsl:call-template name="_printPoints">
						<xsl:with-param name="yData" select="$yData" />
						<xsl:with-param name="xMin" select="$xStart" />
						<xsl:with-param name="xDelta" select="$xDelta" />
						<xsl:with-param name="yScale" select="$yScale" />
						<xsl:with-param name="lineColour" select="$lineColour" />
						<xsl:with-param name="pointColour" select="$pointColour" />
					</xsl:call-template>
				</g>

				<!-- Print x-axis -->
				<g transform="translate(0 {$yCentre})">
					<xsl:call-template name="printXAxis">
						<xsl:with-param name="xData" select="$xData" />
						<xsl:with-param name="step" select="$xDelta" />
						<xsl:with-param name="xMin" select="$xStart" />
						<xsl:with-param name="xMax" select="$yCount" />
					</xsl:call-template>
					<line x1="{$xMin}" y1="0" x2="{$xMax}" y2="0" stroke="black" stroke-width="2" />
				</g>
			</xsl:if>
		</svg>
	</xsl:template>

	<!-- Prints points and joins them -->
	<xsl:template name="_printPoints">
		<xsl:param name="yData" />
		<xsl:param name="index" select="1" />
		<xsl:param name="xMin" />
		<xsl:param name="xDelta" />
		<xsl:param name="yScale" />
		<xsl:param name="lineColour" />
		<xsl:param name="pointColour" />

		<xsl:variable name="x" select="$xMin+($index - 1)*$xDelta" />
		<xsl:variable name="y" select="$yData[$index]*$yScale" />
		<xsl:if test="$yData[$index+1]">
			<line x1="{$x}" y1="{$y}" x2="{$xMin+($index)*$xDelta}" y2="{$yData[$index+1]*$yScale}" stroke="{$lineColour}" stroke-width="1"  />
		</xsl:if>
		<circle cx="{$x}" cy="{$y}" r="{$POINT_RADIUS}" fill="white" stroke="{$pointColour}" stroke-width="1"  />

		<xsl:if test="$index &lt; count($yData)">
			<xsl:call-template name="_printPoints">
				<xsl:with-param name="yData" select="$yData" />
				<xsl:with-param name="index" select="$index+1" />
				<xsl:with-param name="xMin" select="$xMin" />
				<xsl:with-param name="xDelta" select="$xDelta" />
				<xsl:with-param name="yScale" select="$yScale" />
				<xsl:with-param name="lineColour" select="$lineColour" />
				<xsl:with-param name="pointColour" select="$pointColour" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!--
		************************************************
		***************    barchart      ***************
		************************************************
	-->
	<!-- Constants -->

	<!-- Prints a simple bar chart with grid -->
	<xsl:template name="barChart">
		<xsl:param name="xData" />
		<xsl:param name="yData" />
		<xsl:param name="width" select="'100%'" />
		<xsl:param name="height" select="'100%'" />
		<xsl:param name="viewBoxWidth" select="300" />
		<xsl:param name="viewBoxHeight" select="300" />
		<xsl:param name="barWidth" select="15" />
		<xsl:param name="leftPadding" select="20" />
		<xsl:param name="rightPadding" select="10" />
		<xsl:param name="verticalSpan" select="100" />

		<xsl:variable name="xCount" select="count($xData)" />
		<xsl:variable name="yCount" select="count($yData)" />
		<xsl:variable name="_verticalSpan" select="if ($verticalSpan &lt; $MIN_VERTICAL_SPAN) then $MIN_VERTICAL_SPAN else $verticalSpan"/>

		<svg version="1.1" preserveAspectRatio="xMinYMin" >
			<xsl:attribute name="width" select="$width"/>
			<xsl:attribute name="height" select="$height"/>
			<xsl:attribute name="viewBox" select="concat('0 0 ', $viewBoxWidth, ' ', $viewBoxHeight)"/>
			<xsl:if test="$xCount &gt; 0 and $yCount &gt; 0">
				<xsl:variable name="yDataMin" select="min($yData)"/>
				<xsl:variable name="yDataMax" select="max($yData)"/>
				<xsl:variable name="yScale"	select="$_verticalSpan div ($yDataMax - $yDataMin)" />
				<xsl:variable name="yDelta"	select="round(($yDataMax - $yDataMin) div $yCount)*2" />
				<xsl:variable name="xMin" select="$leftPadding" />
				<xsl:variable name="xMax" select="$xMin+count($yData)*$barWidth+$rightPadding" />
				<xsl:variable name="yMin" select="if ($yDataMin &lt; 0) then $yDataMin - $yDelta else 0"/>
				<xsl:variable name="yMax" select="$yDataMax+$yDelta" />
				<xsl:variable name="bottom" select="if ($yDataMin &lt; 0) then - $_verticalSpan else 0"/>
				<xsl:variable name="yStep" select="$yDelta*$yScale" />
				<xsl:variable name="totalHeight" select="floor($_verticalSpan+$bottom+2*$yStep)" />
				<xsl:variable name="yStart" select="if ($yDataMin &lt; 0) then $bottom - $yStep else $bottom" />
				<xsl:variable name="yCentre" select="if ($yMin &lt; 0) then floor($yScale*($yMax + $yDelta div 2)) else floor($yScale*$yMax)"/>


				<!-- Print centre -->
				<circle cx="{$xMin}" cy="{$yCentre}" r="1" />

				<!-- Print y-axis -->
				<xsl:call-template name="printYAxis">
					<xsl:with-param name="index" select="$yMin" />
					<xsl:with-param name="step" select="$yDelta" />
					<xsl:with-param name="xMin" select="$xMin" />
					<xsl:with-param name="xMax" select="$xMax" />
					<xsl:with-param name="yMin" select="$yMin" />
					<xsl:with-param name="yMax" select="$yMax" />
					<xsl:with-param name="yScale" select="$yScale" />
				</xsl:call-template>
				<g transform="translate(0 {$totalHeight}) scale(1 -1)">
					<line x1="{$xMin}" y1="{$yStart}" x2="{$xMin}" y2="{$totalHeight}" stroke="black" stroke-width="2" />
				</g>

				<!-- Print bars -->
				<g transform="translate(0 {$yCentre}) scale(1 -1)">
					<xsl:for-each select="$yData">
						<xsl:variable name="colour" select="sd:color(position())"/>
						<xsl:variable name="height" select=".*$yScale" />
						<xsl:variable name="absoluteHeight" select="abs(floor($height))"/>
						<xsl:variable name="y" select="if ($height >= 0) then 0 else $height"/>

						<rect x="{$xMin+(position() - 1)*$barWidth}" y="{$y}" rx="2" ry="2" width="{$barWidth}" height="{$absoluteHeight}" fill="{$colour}" stroke="black" stroke-width="1" />
					</xsl:for-each>
				</g>

				<!-- Print x-axis -->
				<g transform="translate(0 {$yCentre})">
					<xsl:call-template name="printXAxis">
						<xsl:with-param name="xData" select="$xData" />
						<xsl:with-param name="step" select="$barWidth" />
						<xsl:with-param name="xMin" select="$xMin+$barWidth div 2" />
						<xsl:with-param name="xMax" select="$yCount" />
					</xsl:call-template>
					<line x1="{$xMin}" y1="0" x2="{$xMax}" y2="0" stroke="black" stroke-width="2" />
				</g>
			</xsl:if>
		</svg>
	</xsl:template>

	<!--
		************************************************
		***************    piechart      ***************
		************************************************
	-->

	<!-- Constants -->
	<xsl:variable name="MIN_VERTICAL_SPAN" select="100" />
	<xsl:variable name="CUT_OFF_PERCENTAGE" select="0.05" />
	<xsl:variable name="DEGREE_RADIAN_RATIO" select="0.0175" /> <!-- 1 degree = 0.0175 radians -->
	<xsl:variable name="HALF_CIRCLE_ANGLE" select="3.1415" /> <!-- 180 degrees = 3.14 radians -->
	<xsl:variable name="FULL_CIRCLE_ANGLE" select="$HALF_CIRCLE_ANGLE*2" /> <!-- 360 degrees = 6.29 radians -->

	<!--
	Prints a simple pie chart with legend
	   Percentages may not be accurate
	-->
	<xsl:template name="pieChart">
		<xsl:param name="xData" />
		<xsl:param name="yData" />
		<xsl:param name="width" select="'100%'" />
		<xsl:param name="height" select="'100%'" />
		<xsl:param name="viewBoxWidth" select="300" />
		<xsl:param name="viewBoxHeight" select="300" />
		<xsl:param name="padding" select="10" />
		<xsl:param name="verticalSpan" select="100" />
		<xsl:param name="othersLabel" select="'Others'" />

		<xsl:variable name="xCount" select="count($xData)" />
		<xsl:variable name="yCount" select="count($yData)" />
		<xsl:variable name="_verticalSpan" select="if ($verticalSpan &lt; $MIN_VERTICAL_SPAN) then $MIN_VERTICAL_SPAN else $verticalSpan"/>


		<svg version="1.1" preserveAspectRatio="xMinYMin" >
			<xsl:attribute name="width" select="$width"/>
			<xsl:attribute name="height" select="$height"/>
			<xsl:attribute name="viewBox" select="concat('0 0 ', $viewBoxWidth, ' ', $viewBoxHeight)"/>
			<xsl:if test="$xCount &gt; 0 and $yCount &gt; 0">
				<xsl:variable name="_aggregatedData">
					<xsl:call-template name="_aggregate">
						<xsl:with-param name="xData" select="$xData" />
						<xsl:with-param name="yData" select="$yData" />
						<xsl:with-param name="othersLabel" select="$othersLabel" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="aggregatedData" select="$_aggregatedData/*" />

				<xsl:call-template name="_printPies">
					<xsl:with-param name="data" select="$aggregatedData" />
					<xsl:with-param name="padding" select="$padding" />
					<xsl:with-param name="radius" select="$verticalSpan div 2" />
				</xsl:call-template>
				<xsl:call-template name="_printLegend">
					<xsl:with-param name="data" select="$aggregatedData" />
					<xsl:with-param name="xStart" select="$padding*2.5+$_verticalSpan" />
					<xsl:with-param name="yStart" select="$padding" />
				</xsl:call-template>
			</xsl:if>
		</svg>
	</xsl:template>

	<!-- Aggregates data to be printed; merges small values under 'Others' -->
	<xsl:template name="_aggregate">
		<xsl:param name="xData" />
		<xsl:param name="yData" />
		<xsl:param name="othersLabel" />

		<xsl:variable name="_transformedData">
			<xsl:call-template name="_transform">
				<xsl:with-param name="xData" select="$xData" />
				<xsl:with-param name="yData" select="$yData" />
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="transformedData" select="$_transformedData/*" />

		<!-- filter 'other' items -->
		<xsl:for-each select="$transformedData">
			<xsl:sort select="." order="descending" data-type="number" />
			<xsl:if test="name()='item'">
				<xsl:copy-of select="." />
			</xsl:if>
		</xsl:for-each>

		<!-- add 'Others' with summed up value of 'other' items -->
		<xsl:variable name="sumOfOthers" select="sum($transformedData[name()='other'])" />
		<xsl:if test="$sumOfOthers &gt; 0">
			<xsl:element name="item">
				<xsl:attribute name="name" select="$othersLabel"/>
				<xsl:value-of select="$sumOfOthers" />
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<!-- Converts raw data to a unified result-tree for ease of processing -->
	<xsl:template name="_transform">
		<xsl:param name="xData" />
		<xsl:param name="yData" />

		<xsl:variable name="total" select="sum($yData[. &gt; 0])" />
		<xsl:for-each select="$yData">
			<xsl:variable name="index" select="position()" />

			<xsl:choose>
				<xsl:when test=". &lt;= 0">
					<!-- ignore negative values -->
				</xsl:when>
				<!-- collect insignificant values (< cut-off) as 'other' -->
				<xsl:when test="(. div $total) &lt; $CUT_OFF_PERCENTAGE">
					<xsl:element name="other">
						<xsl:value-of select="." />
					</xsl:element>
				</xsl:when>
				<!-- collect significant values (> cut-off%) as 'item' -->
				<xsl:otherwise>
					<xsl:element name="item">
						<xsl:attribute name="name" select="$xData[$index]" />
						<xsl:value-of select="." />
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>

	<!-- Prints each pie recursively -->
	<xsl:template name="_printPies">
		<xsl:param name="data" />
		<xsl:param name="total" select="sum($data)" />
		<xsl:param name="padding" />
		<xsl:param name="radius" />
		<xsl:param name="index" select="1" />

		<xsl:variable name="rotationInDegrees" select="270+(360*(sum($data[position()&lt;$index]) div $total))" />
		<xsl:variable name="angleInRadians" select="($data[$index] div $total)*$FULL_CIRCLE_ANGLE" />

		<xsl:call-template name="_printPie">
			<xsl:with-param name="index" select="$index" />
			<xsl:with-param name="rotationInDegrees" select="$rotationInDegrees" />
			<xsl:with-param name="angleInRadians" select="$angleInRadians" />
			<xsl:with-param name="padding" select="$padding" />
			<xsl:with-param name="radius" select="$radius" />
		</xsl:call-template>

		<xsl:call-template name="_printLabel">
			<xsl:with-param name="data" select="$data" />
			<xsl:with-param name="total" select="$total" />
			<xsl:with-param name="index" select="$index" />
			<xsl:with-param name="rotationInRadians" select="$rotationInDegrees*$DEGREE_RADIAN_RATIO" />
			<xsl:with-param name="angleInRadians" select="$angleInRadians div 2" />
			<xsl:with-param name="padding" select="$padding" />
			<xsl:with-param name="radius" select="$radius" />
		</xsl:call-template>

		<xsl:if test="$index &lt; count($data)">
			<xsl:call-template name="_printPies">
				<xsl:with-param name="data" select="$data" />
				<xsl:with-param name="total" select="$total" />
				<xsl:with-param name="padding" select="$padding" />
				<xsl:with-param name="index" select="$index+1" />
				<xsl:with-param name="radius" select="$radius" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- Prints pie -->
	<xsl:template name="_printPie">
		<xsl:param name="index" />
		<xsl:param name="rotationInDegrees" />
		<xsl:param name="angleInRadians" />
		<xsl:param name="padding" />
		<xsl:param name="radius" />

		<xsl:variable name="colour" select="sd:color($index)"/>
		<xsl:variable name="largeArcFlag" select="if ($angleInRadians &gt; $HALF_CIRCLE_ANGLE) then 1 else 0"/>
		<xsl:variable name="centre" select="$padding+$radius" />

		<path stroke="white" stroke-width="1" >
			<xsl:attribute name="fill" select="$colour"/>
			<xsl:attribute name="transform" select="concat('translate(',$centre,' ',$centre,') rotate(',$rotationInDegrees,')')"/>
			<xsl:attribute name="d" select="string-join(
				(
				'M', $radius, '0',
				'A', $radius, $radius,'0', $largeArcFlag, '1', $radius * math:cos($angleInRadians), $radius * math:sin($angleInRadians),
				'L 0 0 Z'
				)
				, ' ')"/>
		</path>
	</xsl:template>

	<!-- Prints label inside the pie -->
	<xsl:template name="_printLabel">
		<xsl:param name="data" />
		<xsl:param name="total" />
		<xsl:param name="index" />
		<xsl:param name="rotationInRadians" />
		<xsl:param name="angleInRadians" />
		<xsl:param name="padding" />
		<xsl:param name="radius" />

		<xsl:variable name="labelRadius" select="$radius*0.7" />
		<xsl:variable name="cosine" select="math:cos($rotationInRadians)" />
		<xsl:variable name="sine" select="math:sin($rotationInRadians)" />
		<xsl:variable name="x" select="math:cos($angleInRadians)*$labelRadius" />
		<xsl:variable name="y" select="math:sin($angleInRadians)*$labelRadius" />
		<xsl:variable name="centre" select="$padding+$radius" />

		<text text-anchor="middle" fill="black" transform="translate({$centre} {$centre})" >
			<xsl:attribute name="x" select="($x*$cosine)-($y*$sine)" />
			<xsl:attribute name="y" select="($x*$sine)+($y*$cosine)" />
			<xsl:attribute name="font-family" select="$FONT"/>
			<xsl:attribute name="font-size" select="$FONT_SIZE"/>
			<xsl:value-of select="round(100*($data[$index] div $total))" />
			<xsl:text>%</xsl:text>
		</text>
	</xsl:template>

	<!-- Prints legend -->
	<xsl:template name="_printLegend">
		<xsl:param name="data" />
		<xsl:param name="xStart" />
		<xsl:param name="yStart" />

		<xsl:for-each select="$data">
			<xsl:variable name="y" select="$yStart+(position()-1)*8" />
			<xsl:variable name="colour" select="sd:color(position())"/>
			<rect rx="1" ry="1" width="10" height="5" stroke="black" stroke-width="0.5"  >
				<xsl:attribute name="x" select="$xStart"/>
				<xsl:attribute name="y" select="$y"/>
				<xsl:attribute name="fill" select="$colour"/>
			</rect>

			<text text-anchor="start" >
				<xsl:attribute name="x" select="$xStart+15"/>
				<xsl:attribute name="y" select="$y + 4"/>
				<xsl:attribute name="font-family" select="$FONT"/>
				<xsl:attribute name="font-size" select="$FONT_SIZE"/>
				<xsl:value-of select="@name" />
				<xsl:text> (</xsl:text><xsl:value-of select="." /><xsl:text>)</xsl:text>
			</text>
		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>