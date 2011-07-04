<?xml version="1.0" encoding="utf-8"?>
<!-- author: georg held -->
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:xlink="http://www.w3.org/1999/xlink"
 version="1.0" >
	<!-- access dataSet element of xml data -->
	<xsl:template match="LOG">
		<!-- svg root element -->
		<xsl:variable name="itol" select="total"/>
		<html><head>Daily Test Report
		</head>
		<body>
		<svg width="{($itol+1)*20}px" height="250px" onload="alert('help')" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2000/svg">
			<!-- bar chart group -->
			<g id="bar" transform="translate(0,200)">
				<!-- each bar element -->
<line x1="5" y1="0" x2="{($itol+1)*20}" y2="0" style="stroke:rgb(0,0,99);stroke-width:2"/>
<line x1="5" y1="0" x2="5" y2="-200" style="stroke:rgb(0,0,99);stroke-width:1"/>
		<text x="5" y="40" style="font-family:arial;text-anchor:right;baseline-shift:-5;font-size:12pt">
		<xsl:value-of select="title"/>
		Failed cases summary
		</text>
				<xsl:for-each select="fail_count">
					<!-- declare variable called val containing the value -->
					<xsl:variable name="val" select="count"/>
					<xsl:variable name="link" select="flink"/>	
					<!-- bar description -->
				<a xlink:href="{$link}">
				<text x="{position()*20}" y="-{$val*1}" style="font-family:arial;text-anchor:middle;baseline-shift:-5;font-size:10pt">
						<xsl:value-of select="count"/>
					</text>	
					</a>
					<!-- bar symbolized as a rectangle -->
					<rect x="{position()*20}" y="-{$val*1}" height="{$val*1}" width="2" style="fill:{@fill};"/>
				<text x="{position()*20}" y="10" classstyle="font-family:arial;text-anchor:right;baseline-shift:-5" font-size="3pt">
						<xsl:value-of select="fdate"/>
					</text>	
				</xsl:for-each>
			</g>
		</svg>

		</body>
		</html>
	</xsl:template>
</xsl:transform>
