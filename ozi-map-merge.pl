#!/usr/bin/perl
#

use warnings;
use strict;

use autodie;

##  Settings

# CONTRAST_MODE (raster only) - specifies the type of contrast adjustment to apply to the data.
# * NONE - no contrast adjustment applied (this is the default)
# * PERCENTAGE - apply a percentage contrast adjustment. The
#  CONTRAST_STRETCH_SIZE parameter can be used to override the number of standard
#  deviations from the mean to stretch to.
# * MIN_MAX - apply a min/max contrast stretch, stretching the available range of
#  values in each color band to the full range of 0-255. For imagery which
#  contains both black and white, this will have no affect.
my $contrast_mode    = 'MIN_MAX';

# specified whether or not the contrast adjustment for this layer will share
# the adjustment with other contrast-adjusted layers in order to ensure a
# consistent modification across layers.
my $contrast_shared  = 'NO';                 # YES, NO

# specifies the color intensity to use when adjusting the brightness of pixels
# in the overlay. Valid values range from 0 to 512, with 0 being completely
# white, 256 being no alteration, and 512 being completely black. For example, to
# make an image slightly darker, you could use COLOR_INTENSITY=300.
my $color_intensity  = '270';                # 0 - 512

my $compression      = 4;
my $spatial_res;
#my $spatial_res      = "10.0,10.0";

my $proj;
#my $proj = "PROJ_EPSG_CODE=3395";           # PROJ_EPSG_CODE=<code> or FILENAME=<file>


##  Action

my @maps = sort glob('*.map');

open my $out_fh, '>', 'run.gms';
print $out_fh <<'END';
GLOBAL_MAPPER_SCRIPT VERSION=1.00
// See Global Mapper Scripting Language Reference
// http://www.globalmapper.com/helpv14/ScriptReference.html
UNLOAD_ALL

SET_BG_COLOR COLOR=RGB(255,255,255)

END

print $out_fh "LOAD_PROJECTION $proj\n\n"           if ($proj);

FILE:
foreach my $file (@maps) {
    my ($minlat, $minlon, $maxlat, $maxlon) = (10000,10000,-10000,-10000);

	# OziExplorer Map File Format
	#  http://www.oziexplorer3.com/eng/help/map_file_format.html
    open my $map_fh, '<', $file;
	my $header = <$map_fh>;
	if ($header !~ /^OziExplorer Map Data File Version \d/) {
		warn "$file is not OziExplorer map file\n";
		close $map_fh;
		next FILE;
	}
	warn "processing $file\n";
    while (<$map_fh>) {
		# MMPLL,1,  58.000000,  62.000000
        if (/MMPLL,\d,\s*(\-?\d+\.\d+),\s*(\-?\d+\.\d+)/) {
			# round to 5' net; not (for scale up to 1:50_000)
            $minlat = int($2*12+0.5)/12 if $2 < $minlat;
            $maxlat = int($2*12+0.5)/12 if $2 > $maxlat;
            $minlon = int($1*12+0.5)/12 if $1 < $minlon;
            $maxlon = int($1*12+0.5)/12 if $1 > $maxlon;
        }
    }
	close $map_fh;
	warn sprintf "crop to bounds: latitude: %2.5f .. %2.5f, longitude: %2.5f .. %2.5f\n",
		$minlat, $maxlat, $minlon, $maxlon;

    print $out_fh "IMPORT FILENAME=\"$file\" CLIP_COLLAR=LAT_LON CLIP_COLLAR_BOUNDS=$minlon,$minlat,$maxlon,$maxlat CONTRAST_MODE=$contrast_mode CONTRAST_SHARED=$contrast_shared COLOR_INTENSITY_FULL=$color_intensity\n"
}

#print $out_fh "\nEXPORT_RASTER FORCE_SQUARE_PIXELS=YES TYPE=ECW FILENAME=\"export.ecw\" TARGET_COMPRESSION=$compression "
#           . ($spatial_res ? "SPATIAL_RES=$spatial_res" : "") . "\n\n";
