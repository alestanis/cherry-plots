# File : parameters.pl

#-----------------#
# Data Parameters #
#-----------------#

	# Add series values?
	isAdditive => 0, 

	# Are there headers in the csv file?
	isHeader => 1, 

	# Plot inverted data (when first line must be placed last)
	# Financial data is exported this way
	isInverted => 1,

	# Are there labels (1st column) in the csv file?
	isLabel => 1, 

	# Csv file separator
	separator => ';',

	# Force min axis value
	# TODO Take xMin/xMax hard values into account?
	xMin => "",

	# Force max axis value
	xMax => "",

	# Force min axis value
	# TODO Take yMin/yMax hard values into account?
	yMin => "",

	# Force max axis value
	yMax => "",

#-----------------#
# Drawing Options #
#-----------------#

	# Draw legends ?
	isLegend => 0,

	# Line thickness in pt (for Graphs)
	lineWidth => 0.8,

	# Mark size for scatter plots (in pt)
	markSize => 10,

	# Shade rotation, between 0 (horizontal) and 90 (vertical) degrees
	# Used for filling
	shadeRotation => 90,

	# Draw a border around filled areas?
	# TODO only border and no fill ?
	useBorder => 1,

	# 0 = Black and White
	# 1 = Regular Colors
	# 2 = Rainbow Colors
	# 3 = Heat Colors
	useColor => 1,

	# Fill with shapes instead of plain color
	useFillShapes => 0,

	# Lines or dashed paths?
	# Used in line graphs
	usePaths => 0, 

	# Fill with shaded colors? Bottom color is : -100 = black, 100 = white, 0 = no shading, anything in between mixed with base color. 
	useShade => -50, 

	# Different point shapes
	# Used in scatter plot
	useMarks => 1,

	# Draw horizontal axis?
	xAxis => 1,

	# Put labels on horizontal axis?
	xAxisLabel => 1,

	# Maximum number of ticks in horizontal axis (when using labels)
	xAxisTicks => 10, 

	# Draw vertical axis?
	yAxis => 1,

	# Put labels on vertical axis?
	yAxisLabel => 1,

	# Maximum number of ticks in vertical axis (when using labels)
	yAxisTicks => 10,

#------------------#
# Graph Parameters #
#------------------#

	# Space between axis and graph, in % of total graph width/height
	axisSep => 5,

	# Image height in cm
	height => 10, 

	# Length of tick marks on axis (in cm)
	tickLength => 0.1,

	# Graph title, "" gives no title
	title => "", 

	# Image width in cm
	width => 15,

	# x-Axis title, "" gives no title
	xLegend => "",

	# y-Axis title, "" gives no title
	yLegend => "",

#----------------------#
# Histogram Parameters #
#----------------------#

	# Space between bars, in bar width
	histoSep => 0.5, 

	 # Space between series, in bar width
	histoSpace => 1,

#--------------------#
# Implied Parameters #
#--------------------#

	# Are labels numeric values?
	# Computed in "fileToArray" function
	# _isLabelNumeric => 1,

	# Hard scaling on x values. See "Dimension Too Large" LaTex error
	# Computed in "fileToArray" function
	# _xHardScale => 1,

	# Hard scaling on y values. See "Dimension Too Large" LaTex error
	# Computed in "fileToArray" function
	# _yHardScale => 1,

	# Soft scaling on x values
	# _xSoftScale => 1,

	# Soft scaling on y values
	# _ySoftScale => 1,
	
	# Data limits
	# Computed in "fileToArray" function
	# _xmin,
	# _xmax,
	# _ymin,
	# _ymax,
