# File : Utils.pl

package libs::Utils;
use base 'Exporter';
our @EXPORT = ('drawAxis',
				'drawLegend',
				'drawTitle',
				'drawXYTitles',
				'fileToArray',
				'genPrettyLabels',
				'getGolden',
				'getLabels',
				'getXValues',
				'isNumeric');

use libs::Params;
use libs::TikzWriter;

sub drawAxis {
	# Hard scaling, min, max values
	my $xHardScale = getParam("_xHardScale");
	my $yHardScale = getParam("_yHardScale");
	my $xmin = getParam("_xmin") / $xHardScale;
	my $xmax = getParam("_xmax") / $xHardScale;
	my $ymin = getParam("_ymin") / $yHardScale;
	my $ymax = getParam("_ymax") / $yHardScale;

	my $dx = $xmax - $xmin;
	my $dy = $ymax - $ymin;
	
	# Global soft scaling
	my $xscale = getParam("_xSoftScale");
	my $yscale = getParam("_ySoftScale");
	
	# Distance from graph to axis
	my $axisSep = getParam("axisSep")/100;
	my $xminl = $xmin - $dx*$axisSep;
	my $xmaxl = $xmax + $dx*$axisSep;
	my $yminl = $ymin - $dy*$axisSep;
	my $ymaxl = $ymax + $dy*$axisSep;

	# Axis and Labels
	# If possible, axis will be positioned at the origin
	my $xcut = 0;
	my $ycut = 0;
	if ( $xminl*$xmaxl > 0 ) { $xcut = $xminl; }
	if ( $yminl*$ymaxl > 0 ) { $ycut = $yminl; }
	if ( getParam("_graphType") eq "histogram" ) { $xcut = 0; }

	# Tick marks on axis
	my $xTick = getParam("tickLength");
	my $yTick = $xTick / $xscale;
	$xTick /= $yscale;

	if ( getParam("xAxis")  ) {
		wComment("X-axis");
		if ($ycut == 0) {
			wArrow($xminl,$ycut,$xmaxl,$ycut);
		} else {
			wArrow($xmin,$ycut,$xmax,$ycut);
		}
	}
	if ( getParam("yAxis") ) {
		wComment("Y-axis");
		if ($xcut == 0) {
			wArrow($xcut,$yminl,$xcut,$ymaxl);
		} else {
			wArrow($xcut,$ymin,$xcut,$ymax);
		}
	}
	my @xlabels = ();
	if ( getParam("xAxisLabel") ) {
		wComment("X-axis Labels");
		if ($ycut == 0) {
			@xlabels = genPrettyLabels($xminl, $xmaxl, getParam("xAxisTicks"));
		} else {
			@xlabels = genPrettyLabels($xmin, $xmax, getParam("xAxisTicks"));
		}
		my @xlabtext = @xlabels;
		if ( $xHardScale > 1 ) { 
			for (my $i = 0; $i < scalar @xlabels; $i++) {
				$xlabtext[$i] *= $xHardScale;
			}
		}
		wXLabels(\@xlabels,$ycut,\@xlabtext,$xTick);
	}
	my @ylabels = ();
	if ( getParam("yAxisLabel") ) {
		wComment("Y-axis Labels");
		if ($xcut == 0) {
			@ylabels = genPrettyLabels($yminl, $ymaxl, getParam("yAxisTicks"));
		} else {
			@ylabels = genPrettyLabels($ymin, $ymax, getParam("yAxisTicks"));
		}
		my @ylabtext = @ylabels;
		if ( $yHardScale > 1 ) { 
			for (my $i = 0; $i < scalar @ylabels; $i++) {
				$ylabtext[$i] *= $yHardScale;
			}
		}
		wYLabels($xcut,\@ylabels,\@ylabtext,$yTick);
	}
}

sub drawXYTitles {
	my $xtitle = getParam("xTitle");
	my $ytitle = getParam("yTitle");
	if ( $xtitle ne "" ) {
		# In the middle : xmin + 1/2 dx
		my $posxx = 0.5 * ( getParam("_xmax") + getParam("_xmin") ) / getParam("_xHardScale");
		# 10% on bottom
		my $posxy = ( 0.9 * getParam("_ymin") - 0.1 * getParam("_ymax") ) / getParam("_yHardScale");
		
		wXTitle($posxx, $posxy, $xtitle);
	}
	if ( $ytitle ne "" ) {
		# 10% to the left
		my $posyx = ( 0.9 * getParam("_xmin") - 0.1 * getParam("_xmax") ) / getParam("_xHardScale");
		# In the middle : ymin + 1/2 dy
		my $posyy = 0.5 * ( getParam("_ymax") + getParam("_ymin") ) / getParam("_yHardScale");
		
		wYTitle($posyx, $posyy, $ytitle);
	}
}

sub drawLegend ($;$) { #TODO drawLegend
	my ($rstyles, $rheaders) = @_;
	my @styles = @$rstyles || die "Problem drawing legends: $!\n";
	my @headers = ();
	if (defined($rheaders)) {
		@headers = @$rheaders || die "Problem drawing legends: $!\n";;
	} else {
		for (my $i = 1; $i <= scalar @styles; $i++) {
			push(@headers, "Series".($i) );
		}
	}
	my $ymin = getParam("_ymin") / $yHardScale;
	my $ymax = getParam("_ymax") / $yHardScale;
	my $dy = $ymax - $ymin;
	my $ySoftScale = getParam("_ySoftScale");

	# Legends will be placed on the right of the graph, between $ymin and $ymax	
		
}

sub drawTitle {
	my $title = getParam("graphTitle");
	if ( $title ne "" ) {
		# In the middle : xmin + 1/2 dx
		my $posx = 0.5 * ( getParam("_xmax") + getParam("_xmin") ) / getParam("_xHardScale");
		# 10% on top
		my $posy = ( 1.1 * getParam("_ymax") - 0.1 * getParam("_ymin") ) / getParam("_yHardScale");
		
		wTitle($posx, $posy, $title);
	}
}

sub fileToArray ($) {
	my ($filename) = @_;

	my $sep = getParam("separator");

	open(FILE, '<', $filename) || die "Cannot open file: $!\n";

	my @values = ();
	my @headers = ();
	my $isLabel = getParam("isLabel");
	my $isXCol = getParam("isXCol");

	if (getParam("isHeader") == 1)
	{ # Headers line
		@headers = split($sep, <FILE>);
	}

	# First line of data, to set variables' initial values
	my $line = <FILE>;
	$line =~ s/(\n|\r)//g;
	my @columns = split($sep, $line);
	my $cols = scalar @columns;
	my $rows = 1;

	if ( getParam("isInverted") ) {
		unshift(@values, @columns);	
	} else {
		push(@values, @columns);
	}

	while ($line = <FILE>)
	{
		$line =~ s/(\n|\r)//g;
		@columns = split($sep, $line);
		(scalar @columns != $cols) && warn "Warning : lines of different lengths found ($rows).\n";

		if ( getParam("isInverted") ) {
			unshift(@values, @columns);
		} else {
			push(@values, @columns);
		}
		$rows++;
	}

	close FILE or die $!;

	if ( getParam("isAdditive") ) {
		for (my $r = 0; $r < $rows; $r++) {
			for (my $c = $isLabel+1; $c < $cols; $c++) {
				$values[$c + $r*$cols] += $values[$c-1 + $r*$cols];
			}
		}
	}

	# Tests labels column for numeric values (all values must be numeric)
	my $numericX = 1;
	if ( $isXCol != 0 ) {
		for (my $r = 0; $r < $rows; $r++) {
			$numericX = 0 if !isNumeric($values[$r*$cols+$isLabel]);
		}
	} else {
		$numericX = 0;
	}
	setParam("_isXNumeric", $numericX);

	# Find extreme x values for hard scaling (Dimension Too Large LaTeX error)
	my $xmin;
	my $xmax;
	if ( $isXCol != 0 && $numericX == 1 ) {
		# If labels, searches numeric labels for extreme x values
		$xmin = $values[$isLabel];
		$xmax = $values[$isLabel];
		
		my $tmp;
		for (my $r = 0; $r < $rows; $r++) {
			$tmp = $values[$r*$cols+$isLabel];
			$xmin = $tmp if $tmp < $xmin;
			$xmax = $tmp if $tmp > $xmax;
		}
	} else {
		# If no x col or non-numeric x col, takes number of rows
		$xmin = 1;
		$xmax = $rows;
	}

	# Find extreme y values for hard scaling (Dimension Too Large LaTeX error)
	my $ymin = $values[$cols-1];
	my $ymax = $values[$cols-1];
	for (my $r = 0; $r < $rows; $r++) {
		for (my $c = $isLabel+$isXCol; $c < $cols; $c++) {
			$tmp = $values[$c + $r*$cols];
			$ymin = $tmp if $tmp < $ymin;
			$ymax = $tmp if $tmp > $ymax;
		}
	}

	# Save min and max values, to be used when plotting
	setParam("_xmin", $xmin);
	setParam("_xmax", $xmax);
	setParam("_ymin", $ymin);
	setParam("_ymax", $ymax);

	# Find hard scaling. We only use powers of 10 for TikZ code readability
	my $xHardScale = 1;
	my $yHardScale = 1;
	my $xtop = abs($xmin);
	$xtop = abs($xmax) if abs($xmax) > abs($xmin);
	my $ytop = abs($ymin);
	$ytop = abs($ymax) if abs($ymax) > abs($ymin);

	# Take into account space used out of the graph
	$xtop *= ( 1 + getParam("axisSep")/100 );
	$ytop *= ( 1 + getParam("axisSep")/100 );
	$latex = getLatexMax();
	
	while ( $xtop/$xHardScale > $latex ) { $xHardScale *= 10; }
	while ( $ytop/$yHardScale > $latex ) { $yHardScale *= 10; }

	# Sets parameter to be used in axis and label generators
	setParam("_xHardScale", $xHardScale);
	setParam("_yHardScale", $yHardScale);

	# Hard-scaling values
	if ( $xHardScale > 1 && $isXCol != 0  && $numericX ) {
		for (my $r = 0; $r < $rows; $r++) {
			$values[$r*$cols+$isLabel] /= $xHardScale;
		}
	}
	if ( $yHardScale > 1 ) {
		for (my $r = 0; $r < $rows; $r++) {
			for (my $c = $isLabel+$isXCol; $c < $cols; $c++) {
				$values[$c + $r*$cols] /= $yHardScale;
			}
		}
	}

	# Soft-scaling values
	my $dx = ( $xmax - $xmin ) / $xHardScale;
	my $dy = ( $ymax - $ymin ) / $yHardScale;
	setParam("_xSoftScale", ( getParam("width") - 1 ) / $dx ); 
	# 1cm less for labels or text
	setParam("_ySoftScale", ( getParam("height") - 1) / $dy ); 
	# 1cm less for labels or text
		
	return ($rows, $cols, \@values, \@headers);
}

# Generates an array containing pretty ticks for labels. 
# WARNING : Ticks are unordered.
# ARG1 = minimum value in axis
# ARG2 = maximum value in axis
# ARG3 = nmaximum number of ticks wanted
sub genPrettyLabels ($$$) {
	my ($min, $max, $ticks) = @_;
	
	# Argument Validity Verification
	if ($min > $max) {
		my $tmp = $min;
		$min = $max;
		$max = $tmp;
	}
	if ($ticks < 1) { $ticks = 1; }

	my $p1 = 1;
	if ($max < 0) { $p1 = -1; }
	my $p2 = 1;
	if ($min < 0) { $p2 = -1; }

	# Gets order of magnitude
	if ($max/$p1 > 1) {
		while ( $max / $p1 > 1 ) { $p1 *= 10; } # 36 -> 10
		$p1 /= 10;
	} else {
		if ($max != 0) {
			while ( $max / $p1 < 1 ) { $p1 /= 10; } # 0.09 -> 0.01
		}
	}
	if ($min/$p2 > 1) {
		while ( $min / $p2 > 1 ) { $p2 *= 10; } # -36 -> -10
		$p2 /= 10;
	} else {
		if ($min != 0) {
			while ( $min / $p2 < 1 ) { $p2 /= 10; } # -0.09 -> -0.01
		}
	}

	# NEW
	my $tickmin = ($max - $min) / ($ticks+1);
	my $pmax = abs($p1);
	if ( abs($p2) > abs($p1) ) { $pmax = $p2; }
	my $scale_a = $tickmin / $pmax; 
	my $scale_b = roundScale( $scale_a );
	my $begin =  int( $min/($scale_b*$pmax) );
	# Imitate "ceil"
	if ( $min > 0 && ( $min/($scale_b*$pmax) != int( $min/($scale_b*$pmax) ) ) ) { $begin += 1; }

	my @labels = ();
	for (my $i = $begin; $i <= int( $max/($scale_b*$pmax) ); $i++) {
		push( @labels, $i*($scale_b*$pmax) );
	}

	return @labels;
}

# Returns array with x-axis values
sub getXValues ($$$) {
	my ($rvalues, $rows, $cols) = @_;
	my @values = @$rvalues;

	my @xaxis = ();
	my $xHardScale = getParam("_xHardScale");
	if ( !getParam("isLabel") || !getParam("_isLabelNumeric") ) {
		for (my $i = 1; $i <= $rows; $i++) {
			push(@xaxis, $i/$xHardScale);
		}
	} else {
		for (my $i = 0; $i < $rows; $i++) {
			push(@xaxis, $values[$i*$cols]);
		}
	}
	return @xaxis;
}

# Returns golden ratio
sub getGolden {
	return "1.618";
}

# Returns max value for coordinates
# Real max-value is 16 384 pt, or 575.8875 cm, but we prefer to be cautious
sub getLatexMax {
	return 500;
}

sub isNumeric ($) {
	my ($t) = @_;
	return ($t =~ /^(\d+\.?\d*|\.\d+)$/);
}

sub roundScale ($) {
	my ($s) = @_;
	my @accepted = (0.1, 0.2, 0.25, 0.5, 1);
	my $count = 0;
	my $res;

	if ($s >= 1) {
		$res = int($s)+1;
	} else {
		while ( $s >= $accepted[$count] && $count < scalar @accepted ) { 
			$count++; 
		}
		$res = $accepted[$count];
	}

	return $res;
}

return 1;
