# File : Params.pm
# Parameters used when creating TikZ images

package libs::Params;
use base 'Exporter';
our @EXPORT = ('init',
				'getParam',
				'setParam',
				'fillGenerator',
				'lineStyleGenerator',
				'markStyleGenerator',);

# TODO error checking here.
%TikzParameters = do 'libs/parameters.pl';

# Gets the selected parameter
sub getParam ($) {
	my ($param) = @_;
	return $TikzParameters{$param} if defined $param;
}
# Sets the selected parameter
sub setParam ($$) {
	my ($param, $value) = @_;
	$TikzParameters{$param} = $value if defined $value;
}

@Colors = (	"blue",
		"red",
		"green",
		"orange",
		"violet",
		"cyan",
		"yellow",
		"magenta"
);

@Fills = (	"horizontal lines",
		"vertical lines",
		"north east lines",
		"north west lines",
		"grid",
		"crosshatch",
		"dots",
		"crosshatch dots",
		"fivepointed stars",
		"sixpointed stars",
		"bricks"
);

# Path dashing (when usePaths selected)
@Paths = (	"solid",
		"dotted",
		"dashed",
		"densely dotted",
		"densely dashed",
		"loosely dotted",
		"loosely dashed"
);

# For shatter plots
@Marks = ( 	"mark=*", "mark=x", "mark=+", 
			"mark=-", "mark=|", "mark=o",
			"mark=asterisk",
			"mark=star",
			#"mark=oplus",
			"mark=oplus*",
			#"mark=otimes",
			"mark=otimes*",
			#"mark=square",
			"mark=square*",
			#"mark=triangle",
			"mark=triangle*",
			#"mark=diamond",
			"mark=diamond*",
			#"mark=pentagon",
			"mark=pentagon*",
);

# PRIVATE Generates an array containing ARG colors
sub colorGenerator ($) {
	my ($nb) = @_;
	my @tmp = ();
	my @vars = ( 	"",
			"black!50!",
			"white!50!",
			"black!20!",
			"white!20!"
	);
	my $which = 0;
	while (scalar @tmp < $nb && $which < scalar @vars) 
	{
		foreach $col (@Colors) {
			push(@tmp, $vars[$which].$col);
		}
		$which++;
	}

	while (scalar @tmp < $nb) {
		push(@tmp, @tmp);
	}

	@col = splice(@tmp, 0, $nb);
	return @col;
}

# PRIVATE Creates a color array from base colors (intermediate function)
# ARG1 = number of colors
# ARG2 = reference to an array containing base colors. All inner colors must be pure.
sub gradient ($$) {
	my ($nb, $rbase) = @_;
	my @base = @$rbase;

	my @col = ($base[0]);
	for (my $i = 1; $i < $nb-1; $i++) {
		my $where = ( $i / ($nb-1) )*( scalar @base - 1 );	
		my $percent = 100 - int( ($where - int($where))*100 );
		my $firstcol = $base[int($where)];
		my $seccol = $base[int($where)+1];
		my $final = $firstcol."!".$percent."!".$seccol;
		if ( int($where) + 2 == scalar @base ) {
			$percent = 100 - $percent;
			$final = $seccol."!".$percent."!".$firstcol;
		}
		if ($percent == 0) { $final = $firstcol; }

		push(@col, $final);
	}
	push(@col, $base[scalar @base - 1]);
	return @col;
}

# General Filling Generator
sub fillGenerator ($) {
	my ($nb) = @_;

	my @tmp = ();
	my @fill = ();
	my $f = 0;
	
	my $useColor = getParam("useColor");
	my $useFillShapes = getParam("useFillShapes");
	my $border = getParam("useBorder");
	my $draw = "";

	if ( $useColor != 0 && $useFillShapes == 0 ) { 
		# Shading or plain colors
		
		my @tmp = ();
		if ($useColor == 2) {
			@tmp = rainbowColorGenerator($nb);
		} elsif ($useColor == 3) {
			@tmp = heatColorGenerator($nb);
		} else {
			@tmp = colorGenerator($nb);
		}
	
		# Use shading?
		my $shade = getParam("useShade");
		if ($shade < -100) { $shade = -100; }
		if ($shade > 100) { $shade = 100; }

		# Rotate shading?
		my $rot = getParam("shadeRotation");
		if ($rot < 0) {$rot = 0;}
		if ($rot > 90) {$rot = 90;}

		# Add shading to colors
		if ($shade != 0) {
			my $mix = "";
			if ($shade < 0) { 
				$shade = (-1)*$shade;
				$mix = "!$shade!black";
			} else {
				$mix = "!$shade!white";
			}
			foreach my $col (@tmp) {
				my $draw = "";
				if ($border == 1) { $draw = "draw=$col,"; }
				$bottomcol = $col.$mix;
				push(@fill, "$draw top color = $col, bottom color=$bottomcol, shading angle=$rot");
			}
		} else {
			@fill = @tmp;
		}
	} elsif ($useColor == 0) {
		# Only shapes
		if ($border == 1) { $draw = "draw, "; }
		foreach my $f (@Fills) {
			push(@tmp, $draw."pattern = ".$f);
		}
		while (scalar @tmp < $nb) {
			push(@tmp, @tmp);
		}
		@fill = splice(@tmp, 0, $nb);
	} else {
		# Shapes and Color
		if ($useColor == 2) { @colList = rainbowColorGenerator($nb); }
		elsif ($useColor == 3) { @colList = heatColorGenerator($nb); }
		else { @colList = colorGenerator($nb); }

		my $i = 0;
		while ($i < $nb) {
			if ($border == 1) { $draw = "draw = ".$colList[$i].", "; }
			push(@tmp, $draw."pattern = ".$Fills[$f].", pattern color = ".$colList[$i]);
			$i++;
			$f = $i % (scalar @Fills);
		}
		@fill = @tmp;
	}

	return @fill;
}

# PRIVATE Heat Colors Array Generator
sub heatColorGenerator ($) {
	my ($nb) = @_;
	my @base = (	"white!70!yellow",
			"yellow",
			"orange",
			"red",
			"black!40!red");
	my @col = gradient($nb, \@base);
	return @col;
}

# (Colored) Path/Node Generator
sub pathGenerator ($$) {
	my ($nb, $ref) = @_;

	my @tmp = ();
	my @type = @$ref;
	my $p = 0;

	my $useColor = getParam("useColor");

	if ($useColor == 0) {
		while (scalar @tmp < $nb) {
			push(@tmp, @type);
		}
		@path = splice(@tmp, 0, $nb);
	} else {
		if ($useColor == 2) { @colList = rainbowColorGenerator($nb); }
		elsif ($useColor == 3) { @colList = heatColorGenerator($nb); }
		else { @colList = colorGenerator($nb); }
		
		my $i = 0;
		while ($i < $nb) {
			push(@tmp, $colList[$i].", ".$type[$p] );
			$i++;
			$p = $i % (scalar @type);
		}
		@path = @tmp;
	}
	return @path;
}

# PRIVATE Rainbow Colors Array Generator
sub rainbowColorGenerator ($) {
	my ($nb) = @_;
	my @base = (	"black!40!red",
			"orange",
			"yellow",
			"green",
			"cyan",
			"blue",
			"violet",
			"black!40!violet");
	my @col = gradient($nb, \@base);
	return @col;
}

# General Style Generator for lines
sub lineStyleGenerator ($) {
	my ($nb) = @_;
	my $usePaths = getParam("usePaths");
	my $useColor = getParam("useColor");

	my @style = ();

 	if ($usePaths == 1 || $useColor == 0) {
		@style = pathGenerator($nb, \@Paths);
	} elsif ($useColor == 2) {
		@style = rainbowColorGenerator($nb);
	} elsif ($useColor == 3) {
		@style = heatColorGenerator($nb);
	} else {
		@style = colorGenerator($nb);
	}

	# Set line width
	my $lineWidth = getParam("lineWidth");
	if ($lineWidth != 0.4) {
		$lineWidth = "line width = ".$lineWidth."pt, ";
		@tmp = ();
		foreach my $pa (@style) {
			push(@tmp, $lineWidth.$pa);
		}
		@style = @tmp;
	}

	return @style;
}

sub markStyleGenerator ($) {
	my ($nb) = @_;
	my $useMarks = getParam("useMarks");
	my $useColor = getParam("useColor");

	my @style = ();

 	if ($useMarks == 1 || $useColor == 0) {
		@style = pathGenerator($nb, \@Marks);
	} else {
		if ($useColor == 2) {
			@style = rainbowColorGenerator($nb);
		} elsif ($useColor == 3) {
			@style = heatColorGenerator($nb);
		} else {
			@style = colorGenerator($nb);
		}
		for (my $n = 0; $n < $nb; $n++) { $style[$n] .= ", mark = x"; }
	}
	for (my $n = 0; $n < $nb; $n++) { 
		$style[$n] = "mark options = ".$style[$n]; 
	}
	return @style;
}


return 1;
