# File : TikzWriter.pl
# All subroutines able to write TikZ code

package libs::TikzWriter;
use base 'Exporter';
our @EXPORT = ('wAddLib',
				'wAddStyle',
				'wArrow',
				'wComment',
				'wClosing',
				'wInit',
				'wLine',
				'wMark',
				'wMarkAdd',
				'wMarkEnd',
				'wPreamble',
				'wPath',
				'wPathAdd',
				'wPathEnd',
				'wRectangle',
				'wScale',
				'wTexFile',
				'wTitle',
				'wXLabels',
				'wXLabelText',
				'wXLabelTicks',
				'wXTitle',
				'wYLabels',
				'wYLabelText',
				'wYLabelTicks',
				'wYTitle'
				);

use libs::Params;

$LIBS = "";
$SCALE = "\n\n";
$STYLES = "";
$TOPRINT = ""; 

# Adds a TikZ Library to the preamble
sub wAddLib ($) {
	my ($lib) = @_;
	if ( ($LIBS =~ /usetikzlibrary{$lib}/g) eq "" )
	{
		$LIBS .= "\\usetikzlibrary{$lib}\n";
	}
}

# Adds a TikZ style (for a more readable .tex file)
# ARG 1 can be a reference or a string
sub wAddStyle ($$) {
	my ($style, $name) = @_;

	if ($STYLES eq "") { $STYLES = "% Series Styles\n"; }

	if ( ref($style) ) {
		my @styles = @$style;
		my $count = 1;
		foreach my $s (@styles) {
			$STYLES .= "\\tikzstyle{".$name.$count."}=[$s]\n";
			$count++;
		}
	} else {
		$STYLES .= "\\tikzstyle{$name}=[$style]\n";
	}
}

# Draws an arrow (for axis)
sub wArrow ($$$$;$$) {
	my ($x,$y,$xx,$yy,$thick,$color) = @_;
	$thick = defined($thick)?$thick:getParam("lineWidth");
	$color = defined($color)?", ".$color:"";
	$TOPRINT .= sprintf "\\draw[->, line width = $thick pt $color] (%f,%f) -- (%f,%f);\n", $x, $y, $xx, $yy;
}

# Writes a comment
sub wComment ($) {
	my ($c) = @_;
	$TOPRINT .= "% $c\n";
}

# Writes final lines in .tex document
sub wClosing {
	$TOPRINT .= "\\end{tikzpicture}\n";
	$TOPRINT .= "\\end{document}\n";
}

# Initializes global variable containing TikZ code
sub wInit {
	$LIBS = "";
	$TOPRINT = "";
	$SCALE = "\n\n";
}

# Draw line from (x,y) to (xx,yy)
sub wLine ($$$$;$$) {
	my ($x,$y,$xx,$yy,$thick,$color) = @_;
	$thick = defined($thick)?$thick:getParam("lineWidth");
	$color = defined($color)?", ".$color:"";
	$TOPRINT .= sprintf "\\draw[line width = $thick pt $color] (%f,%f) -- (%f,%f);\n", $x, $y, $xx, $yy;
}
 
sub wMark ($$;$$) {
	my ($x,$y,$color,$size) = @_;
	$color = defined($color)?$color:"mark = x";
	$size = defined($size)?$size:getParam("markSize");
	$TOPRINT .= sprintf "\\draw plot[only marks, $color, mark size = $size pt] coordinates{(%f,%f)\n", $x, $y;
}
sub wMarkAdd ($$) {
	my ($x,$y) = @_;
	$TOPRINT .= sprintf " (%f,%f)", $x, $y;
}
# Closes current series
sub wMarkEnd {
	$TOPRINT .= "};\n";
}

# Writes preamble in .tex document
sub wPreamble {
	
	# Packages
	$TOPRINT .= "\\documentclass{article}\n";
	$TOPRINT .= "\\usepackage{tikz}\n";
	$TOPRINT .= $LIBS;

	# Tight border
	wComment("Generates a tightly fitting border around the image");
	$TOPRINT .= "\\usepackage[active,tightpage]{preview}\n";
	$TOPRINT .= "\\PreviewEnvironment{tikzpicture}\n";
	$TOPRINT .= "\\setlength\\PreviewBorder{2mm}\n";

	# Begin Environment
	$TOPRINT .= "\\begin{document}\n";
	$TOPRINT .= "\\begin{tikzpicture}";
}

# Creates the beginning of a path
sub wPath ($$$) {
	my ($x,$y,$color) = @_;
	$TOPRINT .= sprintf "\\draw[$color] (%f,%f)", $x, $y;
}

# Adds points to current path
sub wPathAdd ($$) {
	my ($x,$y) = @_;
	$TOPRINT .= sprintf "--(%f,%f)", $x, $y;
}

# Closes path
sub wPathEnd {
	$TOPRINT .= ";\n";
}

sub wRectangle ($$$$$) {
	my ($x,$y,$w,$h,$color) = @_;
	$TOPRINT .= sprintf "\\fill[$color] (%f , %f) rectangle +(%f, %f);\n", $x, $y, $w, $h;
}

# Adds scaling to image. Must be called immediately after wPreamble.
sub wScale ($$) {
	my ($x, $y) = @_;
	$SCALE = sprintf "[xscale = %f, yscale = %f]\n\n", $x, $y;
}

# Writes .tex file
sub wTexFile ($) {
	
	my $TIKZCONTENT = $TOPRINT;
	$TOPRINT = "";
	wPreamble;
	$TOPRINT .= $SCALE; 
	$TOPRINT .= $STYLES;
	$TOPRINT .= $TIKZCONTENT;
	wClosing;

	my ($tikzname) = @_;
	
	# Opens file and erases content, or creates file
	open(TIKZ, '>', $tikzname) || die "Cannot open file $tikzname: $!\n";

	print TIKZ $TOPRINT;

	close TIKZ or die $!;
}

sub wTitle ($$$) {
	my ($x, $y, $t) = @_;
	my $w = getParam("width");
	#( getParam("_xmax") - getParam("_xmin") ) / getParam("_xHardScale");
	wComment("Graph Title");
	$TOPRINT .= sprintf "\\node[above, text centered, text width=%f cm] at (%f,%f) {\\Large{\\textbf{$t}}};\n", $w, $x, $y;
}

# X-axis labels
sub wXLabels ($$$;$) {
	my ($rxloc, $y, $rxlabels, $tick) = @_;
	wXLabelText($rxloc, $y, $rxlabels);
	if (defined($tick)) {
		wXLabelTicks($rxloc, $y, $tick);
	} else {
		wXLabelTicks($rxloc, $y);
	}
}
# X-axis labels : only text
sub wXLabelText ($$$) {
	my ($rxloc, $y, $rxlabels) = @_;
	my @loc = @$rxloc;
	my @labels = @$rxlabels;
	for (my $i = 0; $i < scalar @loc; $i++) {
		$TOPRINT .= sprintf "\\node[below] at (".$loc[$i].",%f) {".$labels[$i]."};\n", $y;
	}
}
# X-axis labels : only tick marks
sub wXLabelTicks ($$;$) {
	my ($rloc, $y, $tick) = @_;
	my @loc = @$rloc;
	if ( !defined($tick) ) { $tick = getParam("tickLength"); }

	foreach my $loc (@loc) {
		$TOPRINT .= sprintf "\\draw[shift={(%f,%f)}] (0,%f) -- (0,-%f);\n", $loc, $y, $tick, $tick;
	}
}

sub wXTitle ($$$) {
	my ($x, $y, $t) = @_;
	my $w = getParam("width");
	wComment("X-Axis Title");
	$TOPRINT .= sprintf "\\node[below, text centered, text width=%f cm] at (%f,%f) {\\large{\\textbf{$t}}};\n", $w, $x, $y;
}

# Y-axis labels
sub wYLabels ($$$;$) {
	my ($x, $ryloc, $rylabels, $tick) = @_;
	wYLabelText($x, $ryloc, $rylabels);
	if (defined($tick)) {
		wYLabelTicks($x, $ryloc, $tick);
	} else {
		wYLabelTicks($x, $ryloc);
	}
}
# Y-axis labels : only text
sub wYLabelText ($$$) {
	my ($x, $ryloc, $rylabels) = @_;
	my @loc = @$ryloc;
	my @labels = @$rylabels;
	for (my $i = 0; $i < scalar @loc; $i++) {
		$TOPRINT .= sprintf "\\node[left] at (%f,%f) {".$labels[$i]."};\n", $x, $loc[$i];
	}
}
# Y-axis labels = only tick marks
sub wYLabelTicks ($$;$) {
	my ($x, $rloc, $tick) = @_;
	my @loc = @$rloc;
	if ( !defined($tick) ) { $tick = getParam("tickLength"); }

	foreach my $loc (@loc) {
		$TOPRINT .= sprintf "\\draw[shift={(%f,%f)}] (%f,0) -- (-%f,0);\n", $x, $loc, $tick, $tick;
	}
}

sub wYTitle ($$$) {
	my ($x, $y, $t) = @_;
	my $w = getParam("height");
	wComment("Y-Axis Title");
	$TOPRINT .= sprintf "\\node[above, text centered, text width=%f cm, rotate=90] at (%f,%f) {\\large{\\textbf{$t}}};\n", $w, $x, $y;
}

return 1;
