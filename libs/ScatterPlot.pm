# File : ScatterPlot.pm

package libs::ScatterPlot;
use base 'Exporter';
our @EXPORT = ('scatterPlot');

use strict;
use warnings;
use libs::Params;
use libs::TikzWriter;
use libs::Utils;

sub scatterPlot ($$$$;$) {

	wAddLib("plotmarks");

	my ($rvalues, $rows, $cols, $rheaders) = @_;
	my @values = @$rvalues;
	my @headers = @$rheaders;
	my $isLabel = getParam("isLabel");

	# Colors, dashing
	my @nodetypes = markStyleGenerator($cols - $isLabel);

	# Graph Data
	wComment("Lines");

	my $c = $isLabel;

	# Get x-Axis Values
	my @xaxis = getXValues(\@values, $rows, $cols);
	
	# Draw Scatter Plot
	while ($c < $cols) {
		my $node = $nodetypes[$c-$isLabel];
		wMark($xaxis[0],$values[$c],$node);
		for (my $i = 1; $i < $rows; $i++)
		{				
			wMarkAdd($xaxis[$i], $values[$i*$cols + $c]);
		}
		wMarkEnd();
		$c++;
	}

	# Scaling
	wScale( getParam("_xSoftScale"), getParam("_ySoftScale") );	

	# Axis and Labels
	drawAxis();
}

return 1;
