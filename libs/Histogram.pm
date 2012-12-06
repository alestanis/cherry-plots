# File : histogram.pl
# Generates TikZ code to draw a histogram

package libs::Histogram;
use base 'Exporter';
our @EXPORT = ('histogram');

use libs::Params;
use libs::TikzWriter;
use libs::Utils;

sub histogram($$$;$) {

	my ($rvalues, $rows, $cols, $rheaders) = @_;
	my @values = @$rvalues;
	if (defined($rheaders)) {
		my @headers = @$rheaders;
	} else {
		my @headers = ();
	}

	my $histoSpace = getParam("histoSpace");
	my $histoSep = getParam("histoSep");
	my $add = getParam("isAdditive");
	my $width = getParam("width") - 1; # 1cm left for labels
	my $isLabel = getParam("isLabel");
	my $barWidth = $width / $rows;
	
	# Computes positioning of bars
	if ($add == 0) {
		$barWidth /= ( $cols-$isLabel + $histoSpace + ($cols-$isLabel-1)*$histoSep ) ;
		$histoSpace *= $barWidth;
		$histoSep *= $barWidth;
	}
	else
	{
		$barWidth /= ( 1 + $histoSpace );
		$histoSpace *= $barWidth; 
	}


	# Positioning Variables
	my $x = $histoSpace / 2;
	my $y = 0;

	# Filling of bars
	my @filling = fillGenerator($cols - $isLabel);
	wAddStyle(\@filling, "Series");

	wComment("Bars");
	
	# Histogram Data
	my $c = $cols-1;
	while ($c >= $isLabel) {
		for (my $i = 0; $i < $rows; $i++)
		{	
			$y =  $values[$i*$cols + $c];
			my $xi = $x + $i*$width/$rows;
			my $fill = "Series".($c-$isLabel+1);
			
			wRectangle($xi,0,$barWidth,$y,$fill);
		}
		$c--;
		$x += $barWidth + $histoSep if $add == 0;	
	}
	
	# Y axis
	my $xaxis = getParam("xAxis");
	setParam("xAxis", 0);
	drawAxis();
	setParam("xAxis", $xaxis);

	# For histograms, x-axis is different : tick marks and labels are not at the same place
	if (getParam("xAxis")) {
		wComment("X-axis");
		wArrow(0,0,$width,0);
	}

	if ( getParam("xAxisLabel") ) {
		wComment("X-axis Labels");
		my @locn = (); # Text location
		my @locb = (); # Tick mark location
		my @labs = (); # Labels
		for (my $i = 0; $i<$rows; $i++) {
			push(@locn, ($i+0.5)*$width/$rows);
			push(@locb, $i*$width/$rows); 
			if ($isLabel != 0) {
				push(@labs, $values[$i*$cols]);
			} else {
				push(@labs, $i);
			}
		}
		wXLabelText(\@locn,0,\@labs);
		wXLabelTicks(\@locb,0);
	}

	wScale(1, getParam("_ySoftScale") );	
}

return 1;
