# SvgCharts4Xsl

SVG or Scalable Vector Graphics is a powerful way to render vector graphics on screen and print media.
Propelled by its adoption and availability of editors, it has become the de-facto standard for creating and publishing vector graphics.

SvgCharts4Xsl is a set of utility XSL templates, written in XSLT 2.0, for SVG charting.

Currently SvgCharts4Xsl supports the following types of charts:

*  Line Chart: Plots both positive and negative values.
*  Bar Chart: Plots both positive and negative values.
*  Pie Chart: Plots only positive values, negative values are discarded.

## Usage

Import/include the respective chart XSL file in your stylesheet and call the appropriate method with required arguments (some are optional).
For generating standalone SVG files, use appropriate DOCTYPE tag as shown in the examples.

## Download

You can download the latest [charts.xsl here](https://raw.githubusercontent.com/speedata/SvgCharts4Xsl/master/charts.xsl).


## Sample Outputs

![linechart example](examples/lineChartExample1.svg)

![barchart example](examples/barChartExample1.svg)

![piechart example](examples/pieChartExample1.svg)

## Other

Get the source code on GitHub: [https://github.com/speedata/SvgCharts4Xsl](https://github.com/speedata/SvgCharts4Xsl)

This charting module is forked from https://github.com/franklinefrancis/SvgCharts4Xsl so all the credits should go there, not here. The license is a BSD-license, see the file charts.xsl for details.