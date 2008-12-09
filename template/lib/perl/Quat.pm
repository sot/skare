package Quat;

use 5.006;
use strict;
use warnings;
use POSIX;
#use Math::Trig qw( acos );

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Quat ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

# Preloaded methods go here.

our $r2d = 180/3.14159265358979;
our $d2r = 1.0 / $r2d;

1;

sub new {
    my $classname = shift;
    my $self = {};
    bless ($self, $classname);

    $self->set(@_);
    return $self;
}

sub set {
    my $self = shift;

    if (@_ == 3) {  # List of (ra, dec, roll)
	($self->{q}, $self->{T}) = radecroll2quat_transform(@_);
	$self->{ra} = $_[0];
	$self->{dec} = $_[1];
	$self->{roll} = $_[2];
    } elsif (@_ == 4) {  # List of (q1, q2, q3, q4)
	@{$self->{q}} = @_;
	($self->{ra}, $self->{dec}, $self->{roll}) = quat2radecroll(\@_);
	$self->{T} = quat2transform(\@_);
    }

    #define versions of RA and Roll that go from -180 to 180
    $self->{ra0} = ($self->{ra} <= 180.0) ? $self->{ra} : $self->{ra} - 360.0;
    $self->{roll0} = ($self->{roll} <= 180.0) ? $self->{roll} : $self->{roll} - 360.0;
}


sub ra {
    return $_[0]->{ra};
}

sub dec {
    return $_[0]->{dec};
}

sub roll {
    return $_[0]->{roll};
}

sub ra0 {
    return $_[0]->{ra0};
}

sub roll0 {
    return $_[0]->{roll0};
}

sub q {
    return $_[0]->{'q'};
}

sub T {
    return $_[0]->{T};
}

#***************************************************************************
sub divide {
# Rotation 'bb^-1' followed by 'q'  (q * bb^-1)
#//***************************************************************************
    my $self = shift;
    my $bb = shift;

    my @qq = ();
    my @q = @{$self->{q}};
    my @b = @{$bb->{q}};

    $qq[0] =  $q[3]*$b[0] + $q[2]*$b[1] - $q[1]*$b[2] - $q[0]*$b[3];
    $qq[1] = -$q[2]*$b[0] + $q[3]*$b[1] + $q[0]*$b[2] - $q[1]*$b[3];
    $qq[2] =  $q[1]*$b[0] - $q[0]*$b[1] + $q[3]*$b[2] - $q[2]*$b[3];
    $qq[3] = -$q[0]*$b[0] - $q[1]*$b[1] - $q[2]*$b[2] - $q[3]*$b[3];

    my $d = Quat->new(@qq);
    return ($d);
}

#***************************************************************************
sub multiply {
# Rotation 'bb' followed by 'q'  (q * bb)
#//***************************************************************************
    my $self = shift;
    my $bb = shift;

    my @qq = ();
    my @q = @{$self->{q}};
    my @b = @{$bb->{q}};

    $qq[0] =  $q[3]*$b[0] + $q[2]*$b[1] - $q[1]*$b[2] + $q[0]*$b[3];
    $qq[1] = -$q[2]*$b[0] + $q[3]*$b[1] + $q[0]*$b[2] + $q[1]*$b[3];
    $qq[2] =  $q[1]*$b[0] - $q[0]*$b[1] + $q[3]*$b[2] + $q[2]*$b[3];
    $qq[3] = -$q[0]*$b[0] - $q[1]*$b[1] - $q[2]*$b[2] + $q[3]*$b[3];

    my $d = Quat->new(@qq);
    return ($d);
}

sub quat2radecroll {
    my $q = shift;		# Array ref with 4-element quaternion
    my @q = @{$q};
    my @q2;
    for (0..3) { $q2[$_] = $q[$_]**2; }

# calculate direction cosine matrix elements from $quaternions

    my $xa = $q2[0] - $q2[1] - $q2[2] + $q2[3] ;
    my $xb = 2 * ($q[0] * $q[1] + $q[2] * $q[3]) ;
    my $xn = 2 * ($q[0] * $q[2] - $q[1] * $q[3]) ;
    my $yn = 2 * ($q[1] * $q[2] + $q[0] * $q[3]) ;
    my $zn = $q2[3] + $q2[2] - $q2[0] - $q2[1] ;

#; calculate RA, Dec, Roll from cosine matrix elements

    my $ra   = atan2($xb , $xa) * $r2d  ;
    my $dec  = atan2($xn , sqrt(1 - $xn**2)) * $r2d ;
    my $roll = atan2($yn , $zn) * $r2d  ;
    $ra += 360.0 if ($ra < 0.0);
    $roll += 360 if ($roll < 0);

    return ($ra, $dec, $roll);
}

sub quat2transform {
    my $q = shift;

    my $q1 = $q->[0];
    my $q2 = $q->[1];
    my $q3 = $q->[2];
    my $q4 = $q->[3];

    my $q12 = 2.0 * $q1 * $q1;
    my $q22 = 2.0 * $q2 * $q2;
    my $q32 = 2.0 * $q3 * $q3;

    my @T = ([]);
    $T[0][0] = 1.0 - $q22 - $q32;
    $T[1][0] = 2.0 * ($q1 * $q2 - $q3 * $q4);
    $T[2][0] = 2.0 * ($q3 * $q1 + $q2 * $q4);
    $T[0][1] = 2.0 * ($q1 * $q2 + $q3 * $q4);
    $T[1][1] = 1.0 - $q32 - $q12;
    $T[2][1] = 2.0 * ($q2 * $q3 - $q1 * $q4);
    $T[0][2] = 2.0 * ($q3 * $q1 - $q2 * $q4);
    $T[1][2] = 2.0 * ($q2 * $q3 + $q1 * $q4);
    $T[2][2] = 1.0 - $q12 - $q22;

    return (\@T);
}

sub radecroll2quat_transform {
    my ($a, $d, $r) = @_;

    $a *= $d2r;
    $d *= $d2r;
    $r *= $d2r;

    my $ca = cos($a);
    my $sa = sin($a);
    my $cd = cos($d);
    my $sd = sin($d);
    my $cr = cos($r);
    my $sr = sin($r);

    my @T = ([]);

    $T[0][0] = $ca * $cd;
    $T[0][1] = $sa * $cd;
    $T[0][2] = $sd;
    $T[1][0] = -$ca * $sd * $sr - $sa * $cr;
    $T[1][1] = -$sa * $sd * $sr + $ca * $cr;
    $T[1][2] = $cd * $sr;
    $T[2][0] = -$ca * $sd * $cr + $sa * $sr;
    $T[2][1] = -$sa * $sd * $cr - $ca * $sr;
    $T[2][2] = $cd * $cr;

    return (transform2quat(\@T), \@T);
}


sub transform2quat {
    my $T = shift;			# Reference to T[3][3]
    my @den = (0,0,0,0);
    my @q = (0,0,0,0);

    $den[0] = 1.0 + $T->[0][0] - $T->[1][1] - $T->[2][2];
    $den[1] = 1.0 - $T->[0][0] + $T->[1][1] - $T->[2][2];
    $den[2] = 1.0 - $T->[0][0] - $T->[1][1] + $T->[2][2];
    $den[3] = 1.0 + $T->[0][0] + $T->[1][1] + $T->[2][2];

    my $max_den = -1.0;
    my $index;
    for my $i (0 .. 3) {
	if ($den[$i] > $max_den) {
	    $max_den = $den[$i]        ;
	    $index = $i               ;
	}
    }

    $q[$index] = 0.5 * sqrt ($max_den) ;
    my $denom = (4.0 * $q[$index])        ;

    if ($index == 0) {
	$q[1] = ($T->[1][0] + $T->[0][1]) / $denom ;
	$q[2] = ($T->[2][0] + $T->[0][2]) / $denom ;
	$q[3] = -($T->[2][1] - $T->[1][2]) / $denom ;
    }

    if ($index == 1) {
	$q[0] = ($T->[1][0] + $T->[0][1]) / $denom ;
	$q[2] = ($T->[2][1] + $T->[1][2]) / $denom ;
	$q[3] = -($T->[0][2] - $T->[2][0]) / $denom ;
    }

    if ($index == 2) {
	$q[0] = ($T->[2][0] + $T->[0][2]) / $denom ;
	$q[1] = ($T->[2][1] + $T->[1][2]) / $denom ;
	$q[3] = -($T->[1][0] - $T->[0][1]) / $denom ;
    }

    if ($index == 3) {
	$q[0] = -($T->[2][1] - $T->[1][2]) / $denom ;
	$q[1] = -($T->[0][2] - $T->[2][0]) / $denom ;
	$q[2] = -($T->[1][0] - $T->[0][1]) / $denom ;
    }

    
    if ($q[3] < 0.0) {
	for (0 .. 3) {
	    $q[$_] = -$q[$_];
	}
    }

    return (\@q);
}


##***************************************************************************
sub mult {
##***************************************************************************
    my ($m, $x) = @_;
    my @y = (0., 0., 0.);
    for my $i (0 .. 2) {
	for my $j (0 .. 2) {
	    $y[$i] += $m->[$i][$j] * $x->[$j];
	}
    }
    return (@y);
}

##***************************************************************************
sub radec2eci {
##***************************************************************************
    my ($ra, $dec) = @_;
    my @eci = (0,0,0);
    $eci[0] = cos($d2r*$ra) * cos($d2r*$dec);
    $eci[1] = sin($d2r*$ra) * cos($d2r*$dec); 
    $eci[2] = sin($d2r*$dec);
    return (@eci);
}

##***************************************************************************
sub eci2radec {
##***************************************************************************
    my @eci = @_;
    my $ra  = atan2 ($eci[1], $eci[0]) * $r2d;
    my $dec = atan2 ($eci[2], sqrt($eci[1]**2 + $eci[0]**2)) * $r2d;
    $ra += 360.0 if ($ra < 0.0);
    return ($ra, $dec);
}

##***************************************************************************
sub radec2yagzag {
##***************************************************************************
    my ($ra, $dec, $q) = @_;
    my @eci = radec2eci($ra, $dec);
    my @d_aca = mult($q->{T}, \@eci);
    my $yag = atan2 ($d_aca[1], $d_aca[0]);
    my $zag = atan2 ($d_aca[2], $d_aca[0]);
    return ($yag, $zag);
}

##***************************************************************************
sub yagzag2radec {
##***************************************************************************
    # Input args: Y angle, Z angle, target quaternion
    my ($yag, $zag, $q) = @_;

    my @d_aca = (1.0, tan($yag*$d2r), tan($zag*$d2r));

    # Normalize
    my $norm = 1.0 / ($d_aca[0]**2+$d_aca[1]**2+$d_aca[2]**2);
    map {$_ *= $norm} @d_aca;

    # Transpose
    my $Tt = transp($q->{T});
    
    my @eci = mult($Tt, \@d_aca);
    
    return eci2radec(@eci);

}

##***************************************************************************
sub transp {
##***************************************************************************
    my $m = shift;
    my $mt;
    my ($i, $j);

    for $i (0 .. $#{$m}) {
	for $j (0 .. $#{$m->[0]}) {
	    $mt->[$j][$i] = $m->[$i][$j];
	}
    }
    return $mt;
}

##***************************************************************************
sub radial_dist{	    
##***************************************************************************
# intended to find the "length" of a delta quaternion
# return type is arcseconds

    my $delta = shift;
    my ($d_pitch, $d_yaw) = ($delta->{q}[1]*2, $delta->{q}[2]*2);

    my $dist = (sph_dist( 0, 0,$d_pitch, $d_yaw))*$r2d*60*60;

    return $dist;

}    


##***************************************************************************
sub sph_dist{
##***************************************************************************
# generic formula for spherical distance between two points
# in radians
    my ($a1, $d1, $a2, $d2)= @_;

    return(0.0) if ($a1==$a2 && $d1==$d2);

    return acos( cos($d1)*cos($d2) * cos(($a1-$a2)) +
		 sin($d1)*sin($d2));
}

	    


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Quat - Perl extension for manipulating quaternions and attitude representations

=head1 SYNOPSIS

  use Quat;

  $q  = Quat->new($ra, $dec, $roll);   # Init from RA, Dec, Roll
  $q2 = Quat->new($q1, $q2, $q3, $q4); # Init from quaternion components

  $dq = $q2->divide($q);	# Rotation $q^{-1} followed by $q2
  $qm = $q2->multiply($q);	# Rotation $q followed by $q2

  @eci = Quat::radec2eci($ra, $dec);  # RA, Dec as a 3-vector
  ($y, $z) = Quat::radec2yagzag($ra, $dec, $q2);  # RA,Dec as offset in $q2 frame

=head1 DESCRIPTION

This module provides an object-oriented method of manipulating quaternions and transforming
between different representations of attitude or sky position.

=head1 OBJECT METHODS

=over 4

=item ra(), dec(), roll(), ra0(), roll0()

Returns the celestial coordinates associated with the quaternion object.  The ra0() and 
roll0() methods return values in the -180 to +180 range, instead of 0 to 360. 

=item T()

Returns the 3x3 transformation matrix corresponding to the quaternion.

=item q()

Returns a reference to four element list of the quaternion components

=head1 CLASS METHODS

=item @eci = radec2eci($ra, $dec)

Returns the Earth Centered Inertial 3-vector corresponding to ($ra, $dec)

=item ($ra,$dec) = eci2radec(@eci)

Returns the RA, Dec corresponding to the input Earth Centered Inertial 3-vector

=item ($ra,$dec) = yagzag2radec($y_ang, $z_ang, $q)

Returns the RA, Dec corresponding to the specified Y-angle and Z-angle offset from
the attitude $q

=item ($y_ang,$z_ang) = radec2yagzag($ra, $dec, $q)

Returns the Y-angle, Z-angle offset from the center of the attitude frame $q to
the specified RA, Dec position

=head1 EXPORT

None by default.

=head1 AUTHOR

Tom Aldcroft, E<lt>aldcroft@cfa.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Tom Aldcroft

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
