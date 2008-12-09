package Ska::RunAsp;

use 5.006;
# use strict;   # Sorry this is old code, no strict
use warnings;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Ska::RunAsp ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
				   go
				  ) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';


# Preloaded methods go here.
use File::Basename;
use File::Spec::Functions qw(rel2abs);
use Text::ParseWords;
use Getopt::Long;
use IO::All;

use Ska::IO qw(read_param_file cfitsio_read_header);
use Ska::Process qw(get_archive_files);
use Cwd;

1;

sub go {

    %par = (clean => 0,
	    range => '0:',
	    inter => 0,
	    version => 'last',
	    punlearn => 1,
	    @_);
    $par{run} = ! $par{inter} unless (exists $par{run});

# Definitions

    $PIPES_HOME = '/proj/rad1/ska/dev/run_pipe';
    $CWD0 = cwd;
    $log = $par{log} ? " 2>&1 >> ".rel2abs($par{log}) : "";
    $workdir = "$CWD0/ASP_L1_STD";
    $indir   = "in";
    $pcad0_files = 'pcad0/pcad*_3_*fits* pcad0/pcad*_5_*fits* pcad0/pcad*_7_*fits*' .
	' pcad0/pcad*_8_*fits* pcad0/pcad*_14_*fits* pcad0/pcad*_15_*fits*';


# Create the necessary directories

    system("mkdir $workdir") unless (-e $workdir);

    @indirs = <$workdir/in*>;
    $rev = @indirs+1;
    $indir = "in$rev";
    die "Bad in directory sequence ($indir exists)\n"
	if (-e "$workdir/$indir");
    system("mkdir $workdir/$indir");

    @outdirs = <$workdir/out*>;
    $rev = @outdirs+1;
    $outdir = "out$rev";
    die "Bad out directory sequence ($outdir exists)\n"
	if (-e "$workdir/$outdir");
    system("mkdir $workdir/$outdir");

# Set up pipeline file requirements

    @pipe_ped =     ('asp_l1_std.ped',
		     "asp_l1_psf.ped",
#		 "$PIPES_HOME/asp_l1_props_egauss.ped",
		     'asp_l1_std.ped -s get_calibration_data',
		     "$PIPES_HOME/asp_l1_data.ped",
		     "$PIPES_HOME/asp_l1_data_egauss.ped",
		     );

# Define files that get linked into "in" directory, corresponding to above pipeline profiles

    @pipe_infiles = ("asp05/pcad*aipr0a.fits* $pcad0_files aca0/* sim05/sim*coor0a* obspar/axaf*obs0a.par*",
		     "asp05/pcad*aipr0a.fits* $pcad0_files aca0/* sim05/sim*coor0a* obspar/axaf*obs0a.par*",
		     "asp05/pcad*aipr0a.fits* $pcad0_files aca0/* sim05/sim*coor0a* obspar/axaf*obs0a.par*",
		     "obspar/axaf*obs0a.par*",
		     "obspar/axaf*obs0a.par*",
		     );

# Define files that get linked into "out" directory

    @pipe_outfiles = ('',
		      '',
		      'asp1/*gspr* asp1/*fidpr*',
		      'asp1/*gspr* asp1/*fidpr* asp1/*acal* asp1/*adat* asp1/*osol* asp1/*gcal* asp1/*gdat*',
		      'asp1/*gspr* asp1/*fidpr* asp1/*acal* asp1/*adat* asp1/*osol* asp1/*gcal* asp1/*gdat*',
		      );

    @pipe_archfiles = ('aca0 pcad0 sim05 asp05 obspar',
		       'aca0 pcad0 sim05 asp05 obspar',
		       'aca0 pcad0 sim05 asp05 obspar asp1',
		       'asp1',
		       'asp1'
		       );

    my %arch_glob = (aca0 => 'aca*img0.fits*',
		     pcad0 => 'pcad*eng0.fits*',
		     sim05 => 'sim*coor0*fits*',
		     asp05 => 'pcad*aipr0a.fits*',
		     obspar => 'axaf*obs0a.par*',
		    );

    # Find level of reprocessing 

    if (!$par{inter} || exists $par{pipe}) {
	$pipe_num = $par{pipe} || 0;
    } else {
	print "What pipeline do you want:\n";
	print " 0. asp_l1_std (Standard pipe from L0 L0.5 products, star.txt if available)\n";
	print " 1. asp_l1_psf (Custom pipe with PSF centroiding)\n";
	print " 2. asp_l1_props_egauss (Use existing PROPS files, but re-read data)\n";
	print " 3. asp_l1_data (Use existing PROPS and ACADATA files)\n";
	print " 4. asp_l1_data_egauss (Use existing PROPS and ACADATA files and EGAUSS)\n";
	print "Enter option: ";
	$pipe_num = <STDIN>;
	die "Enter 0 - 4 numskull\n" unless ($pipe_num >= 0 and $pipe_num <=4);
    }

    $pipe_ped = $par{ped} || $pipe_ped[$pipe_num];
    @infiles = split(' ', $pipe_infiles[$pipe_num]);
    @outfiles = split(' ', $pipe_outfiles[$pipe_num]);

# Get files from archive if needed

    if ($par{obsid} || $par{archive}) {
	foreach (split ' ',$pipe_archfiles[$pipe_num]) {
	    my $dir = "$CWD0/$_";
	    mkdir $dir or die "Couldn't make directory $dir\n" 
		unless (-e $dir);
	    chdir $dir;
	    @files =  get_archive_files(obsid => $par{obsid} || $par{archive},  # For back-compatibility
					prod      => $_,
					file_glob => $arch_glob{$_} || "*",
					dir       => $dir,
					loud      => 1,
					version   => [5,4,3,2,1]
				       );
	}
	chdir $CWD0;
    }

# Check for necessary directories

    print "Checking input files...\n";
    foreach (@infiles, @outfiles) {
	@files = glob($_);		# Try to glob some files
	die "Did not find required files $_\n" # Die if none were found
	    unless (@files);

	foreach $file (@files) {
	    if ($file =~ /.g?z$/) {
		print "Gunzipping $file\n";
		system ("gunzip -f $file");
	    }
	}

    }
    print "Input files OK.\n\n";

# Read obspar file

    ($obspar) = <obspar/axaf*obs0a.par*>;
    system("gunzip -f $obspar") if ($obspar =~ /.gz/);
    %obspar = read_param_file ($obspar);
    $obsid=$obspar{obs_id};

    ($obiroot) = ($obspar =~ /axaf(.+)_obs0a.par/);

# Read asp05 (AIPROPS) files

    $start = 0;
    $stop  = 0;
    @aipr = ();
    @tstart = ();
    @tstop = ();
    FILES: foreach (<asp05/pcad*aipr0a.fits*>) {
	$dm_cmd = "dmlist \"$_\[cols start_time,stop_time,aspect_mode,pcad_mode,obsid,sim_mode\]\" data verbose=1";
	print "$dm_cmd\n";
	@all_aipr = `$dm_cmd`;
	foreach $aipr (@all_aipr) {
	    next unless ($aipr =~ /\s+\d+\s+\d+/);
	    if ($aipr =~ /KALMAN.*NPNT.*\b$obsid\b.*STOPPED/) {
		my (undef, $start_time, $stop_time) = split ' ', $aipr;
		# Require that interval be at least 5 secs long.  Recent data have a second or two
		# of KALMAN just as the obsid is changed
		if ($stop_time - $start_time > 5) {
		    $start = 1;
		    push @aipr, $aipr;
		}
	    } else {
		$stop = 1 if ($start);

	    }
	    last FILES if ($stop); # Abort as soon as non-KALMAN interval reached
	}
    }

    $n = 0;
    map { (undef, $tstart[$n++]) = split } @aipr;
    @aipr = @aipr[ sort {$tstart[$a] <=> $tstart[$b]} (0 .. $#tstart) ];

    $n = 0;
    map { (undef, $tstart[$n], $tstop[$n++]) = split } @aipr;

# Determine processing interval and tstart tstop

    if ($par{interactive}) {
	$i = 0;
	foreach (@aipr) {
	    print $i++, " : ", $_;
	}

	if ($n > 1) {
	    print "\nEnter interval number (or range) to process: ";
	    $intvl = <STDIN>;
	    ($intvl0, $intvl1) = split(' ', $intvl);
	    $intvl1 = $intvl1 || $intvl0;
	} else {
	    $intvl0 = $intvl1 = 0;
	}
	
	$tstart = $tstart[$intvl0];
	$tstop =  $tstop[$intvl1];
    } else {
	$_ = $par{range};
	s/\s//g;
	if (/^(\d+)$/) {
	    $tstart = $tstart[$1];
	    $tstop = $tstop[$1];
	} elsif (/^(\d+):$/) {
	    $tstart = $tstart[$1];
	    $tstop = $tstop[$#tstop];
	} elsif (/^(\d+):(\d+)$/) {
	    $tstart = $tstart[$1];
	    $tstop = $tstop[$2];
	} elsif (/^(\d+):\+(\d+)$/) {
	    $tstart = $tstart[$1];
	    $tstop = $tstart[$1]+$2;
	} elsif (/^([\d\.]+)-([\d\.]+)$/) {
	    $tstart = $1;
	    $tstop = $2;
	    $dont_check_tstop = 1;
	} else {
	    die "Error - Couldn't parse range: $par{range}\n";
	}
	$tstop = $tstop[$#tstop] if (! $dont_check_tstop && $tstop > $tstop[$#tstop]);
    }

    $root = sprintf ("f0%07dN001", $tstart);

# Put SIM, ACA, and PCAD files in indir

# foreach (<$CWD0/pcad0/pcad*_3_*fits $CWD0/pcad0/pcad*_5_*fits $CWD0/pcad0/pcad*_8_*fits $CWD0/pcad0/pcad*_14_*fits $CWD0/pcad0/pcad*_15_*fits $CWD0/aca0/aca*fits $CWD0/sim05/sim*coor0a*fits>) {

    print "Linking files in time range $tstart : $tstop to indir...\n";
    chdir "$workdir/$indir";

    # Make a hash of the slots to skip in processing
    my %skip_slot = map {$_ => 1} defined $par{skip_slot} ? split(',', $par{skip_slot}) : ();

    foreach $infile (@infiles) {
	@files = glob("$CWD0/$infile");
      FILE: foreach (@files) {
	    my ($file) = m|/([^/]+)$|;
	    unless (-e "$file") {
		if ($file =~ /.fits/) {
		    $fitskeys = cfitsio_read_header($_, 2);
		    next if ($tstart >= $fitskeys->{TSTOP} || $tstop <= $fitskeys->{TSTART});
		}
		# Don't like aca0 data files for a particular slot.  Useful for generating
		# an aspect solution without a slot, or for the asp_get_calib bug for ERs
		next FILE if m!aca0/aca.+_(\d)_img0! and $skip_slot{$1} and print("** Skipping slot $1\n");

		print "ln -s $_ ./$file\n";
		system ("ln -s $_ ./$file");
	    }
	}
    }

    system ("rm *.lis") if (glob("*.lis"));
    system ("pwd; ls -1 sim*coor0a*fits > ${root}_sim.lis");
    for (3..7, 0..2) {
	@a = glob("aca*_$_*0.fits");
	if (@a) {
	    system ("ls -1 aca*_$_*0.fits");
	    system ("ls -1 aca*_$_*0.fits >> ${root}_tel.lis");
	}
    }
    system ("ls -1 pcad*eng0*fits > ${root}_pcad.lis");

# Go into out directory

    chdir "$workdir/$outdir";

    print "Linking files to outdir...\n";
    foreach $outfile (@outfiles) {
	@files = glob("$CWD0/$outfile");
	foreach (@files) {
	    my ($file) = m|/([^/]+)$|;
	    unless (-e "$file") {
		$fitskeys = cfitsio_read_header($_, 2);
		next if ($tstart >= $fitskeys->{TSTOP} || $tstop <= $fitskeys->{TSTART});
		print "cp $_ ./$file\n";
		system ("cp $_ ./$file");
	    }
	}
    }

    system ("ls -1 pcad*adat*fits > ${root}_dat.lis") if (glob("pcad*adat*fits"));

# Rename gsprops and fidprops in out directory to match the root
# for current processing run

    if ($pipe_outfiles[$pipe_num] =~ /gspr/) {
	@props = glob("*gspr*");
	rename $props[0], "pcad${root}_gspr1.fits";
    }
    if ($pipe_outfiles[$pipe_num] =~ /fidpr/) {
	@props = glob("*fidpr*");
	rename $props[0], "pcad${root}_fidpr1.fits";
    }

    chdir $workdir;

# Print command to run the pipe

    if ($par{run}) {
	if ($par{punlearn}) {
	    print STDERR "punlearn asp_l1_std\n";
	    system("punlearn asp_l1_std");
	}
	if ($par{param}) {
	    print STDERR "pset asp_l1_std $par{param}\n";
	    system("pset asp_l1_std $par{param}");
	}
	my $stop_par = $par{stop} ? "-S $par{stop}" : "";
	$cmd = "flt_run_pipe -i $indir -o $outdir -r $root -t $pipe_ped " . $stop_par .
	    " -a \"INTERVAL_START=$tstart\" -a \"INTERVAL_STOP=$tstop\" -a obiroot=$obiroot $log";

	print STDERR "$cmd\n";
	$cmd > io("$indir/pipe_command");
	system($cmd);		# Run the pipe!

	# Run vv_asp if requested
	if ($par{qual}) {
	    system("cp $CWD0/obspar/* $workdir/$outdir") if (-e "$CWD0/obspar" and $par{archive});
	    print STDERR "vv_asp -cp -noclean $log\n";
	    chdir "$workdir/$outdir";
	    system("vv_asp -cp -noclean $log");
	    chdir $CWD0;
	    system("mv $workdir/$outdir/obs*_asp_*.ps* $par{qual}");
	}

	# Clean up
	if ($par{clean}) {
	    chdir $CWD0;
	    print STDERR "Cleaning files $workdir $pipe_archfiles[$pipe_num]\n";
	    system("rm -rf $workdir $pipe_archfiles[$pipe_num]");
	}
    } else {
	print "Remember to pset asp_l1_std kalman_alg=EGAUSS (or whatever)\n\n";
	print "cd ASP_L1_STD\n";
	print "flt_run_pipe -i $indir -o $outdir -r $root -t $pipe_ped \\\n";
	print "  -a \"INTERVAL_START=$tstart\" -a \"INTERVAL_STOP=$tstop\" -a obiroot=$obiroot\n";
    }

    chdir $CWD0;
    return ( indir => $indir,
	     outdir => $outdir,
	     root => $root,
	     pipe_ped => $pipe_ped,
	     tstart => $tstart,
	     tstop => $tstop,
	     obiroot => $obiroot
	   );
}

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Ska::RunAsp - Perl extension for running aspect pipeline

=head1 SYNOPSIS

  use Ska::RunAsp;

=head1 DESCRIPTION

See run_pipe.pl for an example of how to use it.

=head2 EXPORT

None by default.

=head1 AUTHOR

Tom Aldcroft, E<lt>aldcroft@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Tom Aldcroft

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
