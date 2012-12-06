#! /usr/bin/perl
# ARGV[0] = input file name
# ARGV[1] = output file name (without extension)

package main;

#use strict; # Gives an error if variables are not declared explicitly

use libs::Histogram;
use libs::LineGraph;
use libs::Params;
use libs::ScatterPlot;
use libs::TikzWriter;
use libs::Utils;
use Getopt::Long;    

my $filename = $ARGV[0] || die "Error: First argument must be data file.\n";
my $texoutput = $ARGV[1] || die "Error: Second argument must be output filename for LaTeX file.\n";
my $graphtype = $ARGV[2] || die "Error: Third argument must be type of graph. Allowed values are \"graph\", \"scatter\" and \"histogram\".\n";

setParam("_graphType", $graphtype);

# Read flags and other arguments
GetOptions( 'isAdditive|additive|add!' => \&setParam,
			'isHeader|header|headers!' => \&setParam,
			'isInverted|inverted|invert!' => \&setParam,
			'isLabel|label|labels!' => \&setParam,
			'isXCol|xcol!' => \&setParam,
			'separator|sep=s' => \&setParam,
			'xMin=s' => \&setParam,
			'xMax=s' => \&setParam,
			'yMin=s' => \&setParam,
			'yMax=s' => \&setParam,
			'isLegend|legend|legends!' => \&setParam,
			'lineWidth|line=f' => \&setParam,
			'markSize=f' => \&setParam,
			'shadeRotation=i' => \&setParam,
			'useBorder|border!' => \&setParam,
			'useColor|color=i' => \&setParam,
			'useFillShapes|fillShapes!' => \&setParam,
			'usePaths|path|paths!' => \&setParam,
			'useShade|shade=i' => \&setParam,
			'useMarks|marks|mark!' => \&setParam,
			'xAxis!' => \&setParam,
			'xAxisLabel|xLabel!' => \&setParam,
			'xTicks|xtick=i' => \&setParam,
			'yAxis!' => \&setParam,
			'yAxisLabel|yLabel!' => \&setParam,
			'yTicks|ytick=i' => \&setParam,
			'axisSep|asep=f' => \&setParam,
			'height|h=f' => \&setParam,
			'width|w=f' => \&setParam,
			'tickLength|tick|ticks=f' => \&setParam,
			'graphTitle|title=s' => \&setParam,
			'xTitle=s' => \&setParam,
			'yTitle=s' => \&setParam,
			'histoSep|hsep=f' => \&setParam,
			'histoSpace|hspace=f' => \&setParam,
			'configfile|parameters|config=s' => \$myconfig); 

# Read personal configuration file
if ( defined($myconfig) ) {
	open(PARAMS, '<', $myconfig) || die "Error: Sorry, I cannot open your configuration file.\n";

	while ($line = <PARAMS>)
	{ 
		# Remove white spaces from the beginning of the line
		$line =~ s/^\s*//g;

		# Line matches a hash declaration
		if ($line =~ m/^((\'|\")*\w*(\'|\")*)\s*\=\>\s*((\'|\")*[^\']*(\'|\")*)\s*\,/) {
			$key = $1;
			$value = $4;
			$value =~ s/(^\'|\'$)//g; # Remove simple quotes from declaration
			setParam($key,$value);
			print "Set $key to $value from $myconfig file.\n";
		}
	}

	close PARAMS or die $!;
}

# Clean extension of output filename
$texoutput =~ s/\.[a-zA-Z]*//g;

my ($rows, $cols, $rvalues, $rheaders) = fileToArray($filename);

wInit();

wAddLib("patterns"); # Fills
wAddLib("shapes"); # Points

# Graph
if ( $graphtype eq "graph" ) {
	lineGraph($rvalues, $rows, $cols, $rheaders);
} elsif ( $graphtype eq "scatter" ) {
	scatterPlot($rvalues, $rows, $cols, $rheaders);
} elsif ( $graphtype eq "histogram" ) {
	histogram($rvalues, $rows, $cols, $rheaders);
} else {
	die "Error: I don't recognize the graph type. Allowed values are \"graph\", \"scatter\" and \"histogram\".\n";
}

drawTitle();
drawXYTitles();

wTexFile($texoutput.".tex");

# Create PDF File
#system("pdflatex -halt-on-error $texoutput.tex");
# Clean auxiliary files
#system("rm $texoutput.aux $texoutput.log");
# Open pdf file
#system("open $texoutput.pdf");
