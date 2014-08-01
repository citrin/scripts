
##  Settings

$anti_alias       = "YES";                # YES, NO
$contrast_mode    = "MIN_MAX";            # NONE, PERCENTAGE, MIN_MAX
$contrast_shared  = "NO";                 # YES, NO
$color_intensity  = "256";                # 0 - 512

$compression      = 4;
#$spatial_res      = "10.0,10.0";

#$proj = "PROJ_EPSG_CODE=3395";           # PROJ_EPSG_CODE=<code> or FILENAME=<file>


##  Action

opendir DIR, ".";
@maps = grep { /\.map$/ && -f $_ } readdir DIR;
closedir DIR;

open OUT, ">", "run.gms";

print OUT "
GLOBAL_MAPPER_SCRIPT VERSION=1.00 ENABLE_PROGRESS=YES
UNLOAD_ALL

SET_BG_COLOR COLOR=RGB(255,255,255)

";

print OUT "LOAD_PROJECTION $proj\n\n"           if ($proj);

for $map (@maps) {
    ($minlat, $minlon, $maxlat, $maxlon) = (10000,10000,-10000,-10000);

    open MAP, $map;
    while (<MAP>) {
        if (/MMPLL,.,\s*(\-?\d+\.\d+),\s*(\-?\d+\.\d+)/) {
            $minlat = sprintf("%d",$2*12+0.5)/12        if ($2<$minlat);
            $maxlat = sprintf("%d",$2*12+0.5)/12        if ($2>$maxlat);
            $minlon = sprintf("%d",$1*12+0.5)/12        if ($1<$minlon);
            $maxlon = sprintf("%d",$1*12+0.5)/12        if ($1>$maxlon);
        }
    }

    print OUT "IMPORT FILENAME=\"$map\" ANTI_ALIAS=$anti_alias CLIP_COLLAR=LAT_LON CLIP_COLLAR_BOUNDS=$minlon,$minlat,$maxlon,$maxlat CONTRAST_MODE=$contrast_mode CONTRAST_SHARED=$contrast_shared COLOR_INTENSITY_FULL=$color_intensity\n"
}

print OUT "\nEXPORT_RASTER FORCE_SQUARE_PIXELS=YES TYPE=ECW FILENAME=\"export.ecw\" TARGET_COMPRESSION=$compression " 
           . ($spatial_res ? "SPATIAL_RES=$spatial_res" : "") . "\n\n";
