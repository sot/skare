package Ska::ACACoordConvert;

use strict;
use warnings;
use Getopt::Long;
use Carp;
use PDL;
use PDL::NiceSlice;

use base 'Exporter';
our @EXPORT = qw ( toPixels
	       toAngle);

sub toPixels {
    my ($y, $z) = @_;
    my $ycoeffs = pdl ( 6.08840495576943, 0.000376181788609776, -0.200249577514165,
                        -2.7052897180601e-009, 9.75572638037165e-010, -2.94865155316778e-008,
                        8.31198018312775e-013, -1.96043819238097e-010, 5.14134244771463e-013,
                        -1.97282476269237e-010 );

    my $zcoeffs = pdl ( 4.92618563916467, 0.200203020554239, 0.000332284183255046,
                        -5.35702097772202e-009, 1.91073314224894e-008, -4.85766581852866e-009,
                        2.01092070428495e-010, 5.09721545876414e-016, 1.99339355492595e-010,
                        2.52739834319184e-014 );
    ($y, $z) =  calcNewCoords($y, $z, $ycoeffs, $zcoeffs);
    croak "Coordinate off of CCD" if $y > 511.5 || $y < -512.5 || $z > 511.5 || $z < -512.5;
    return ($y, $z);
}

sub toAngle {
    my ($y, $z) = @_;
    croak "Coordinate off of CCD" if $y > 511.5 || $y < -512.5 || $z > 511.5 || $z < -512.5;
    my $pi = 4.0*atan2(1,1);
    #Inversion was done in radians.  Converted to arc-seconds.
    my $ycoeffs = pdl (1.471572165932506e-04,  4.554462091388806e-08, -2.420905844425065e-05,
                       -4.989939217701764e-12, -6.116309500303049e-12, -2.793916972292602e-11,
                       2.420403450703432e-16, 5.751137659424387e-13, -9.934587837231732e-16,
                       5.807475081470944e-13 )*180/$pi*3600;

    my $zcoeffs = pdl ( -1.195271491928579e-04,  2.421478755190295e-05, 4.005224006503938e-08,
                        1.188134673090465e-11, 1.832694593246024e-11, 5.823266376976988e-12,
                        -5.923401659857833e-13, -1.666025332027183e-15, -5.847450395792513e-13,
                        -1.842673748068349e-15)*180/$pi*3600;
    return calcNewCoords($y, $z, $ycoeffs, $zcoeffs);
}

sub calcNewCoords {
    my ($y, $z, $ycoeffs, $zcoeffs) = @_;
    my $yy = $y*$y;
    my $zz = $z*$z;
    my $poly = pdl  (1.0, $z, $y, $zz, $y*$z, $yy, $zz*$z, $y*$zz, $yy*$z, $yy*$y);
    my $ypix = sprintf("%.1f", sum($ycoeffs*$poly));
    my $zpix = sprintf("%.1f", sum($zcoeffs*$poly));
    return ($ypix, $zpix);
}

