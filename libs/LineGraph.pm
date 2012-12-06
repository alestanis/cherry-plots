# File : LineGraph.pl

package libs::LineGraph;
use base 'Exporter';
our @EXPORT = ('lineGraph');

use strict;
use warnings;
use libs::Params;
use libs::TikzWriter;
use libs::Utils;

sub lineGraph ($$$$;$) {

	my ($rvalues, $rows, $cols, $rheaders) = @_;
	my @values = @$rvalues;
	my @headers = @$rheaders;
	my $isLabel = getParam("isLabel");

	# Colors, dashing
	my @paths = lineStyleGenerator($cols - $isLabel);

	# Graph Data
	wComment("Lines");

	my $c = $isLabel;

	# Get x-Axis Values
	my @xaxis = getXValues(\@values, $rows, $cols);
	
	# Draw Graph
	while ($c < $cols) {
		my $path = $paths[$c-$isLabel];
		wPath($xaxis[0] ,$values[$c] ,$path);
		for (my $i = 1; $i < $rows; $i++)
		{				
			wPathAdd($xaxis[$i], $values[$i*$cols + $c]);
		}
		wPathEnd();
		$c++;
	}

	# Scaling
	wScale( getParam("_xSoftScale"), getParam("_ySoftScale") );	

	# Axis and Labels
	drawAxis();
}

return 1;
