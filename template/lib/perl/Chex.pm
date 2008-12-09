package Chex;

use 5.006;
use strict;
use warnings;

use English;
use POSIX qw(tmpnam);
use RDB;
use Ska::Convert qw(date2time time2date);

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Chex ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.01';

# Preloaded methods go here.

our @states;
our @state_var   = qw(date obsid simtsc simfa gratings ra dec roll dither);
our @state_format= qw(14S   5N    6N      5N  5S       10S 9S  9S   4S );
our @state_tol   = qw( 1    300    360   360  300      300 300 300  300);
our $UNDEF = "undef";

our %match;			# not sure if this should be local, so emulate
				# pre-strict behavior
our %match_tol = (obsid  => 0.001,
		  simtsc => 5,
		  simfa  => 5
		 );

our $loud = 0;

1;

####################################################################################
sub new {
####################################################################################
    my $classname = shift;
    my $self = {};
    bless ($self, $classname);
    $self->{chex_file} = shift or die "Chex - need a chex file\n";
    $self->{time} = -1.0;
    @states = ();

    return $self;
}
####################################################################################
sub print {
####################################################################################
    my $self = shift;
    
    # Optional second argument is a new date or time
    get($self, shift) if (@_);

    my %pred_state = %{$self->{chex}};
    foreach my $sv (@state_var) {
	next if ($sv eq 'date');
	printf "%-10s : ", $sv;
	foreach (@{$pred_state{$sv}}) {
	    printf " %-12s", $_;
	}
	print "\n";
    }
}

####################################################################################
sub match {
####################################################################################
    my $self = shift;
    my %par = @_;

    my $sv = $par{var} || die "Chex::match: var parameter is undefined\n";
    my $obs_val  = $par{val} || die "Chex::match:  val parameter is undefined\n";
    $par{tol} = $par{tol} || $match_tol{$sv};

    get($self, $par{date}) if ($par{date});
    get($self, $par{time}) if ($par{time});

    my %chex = %{$self->{chex}};
    my @pred_val = @{$chex{$sv}};

    foreach my $pred_val (@pred_val) {
	return 2 if ($pred_val eq 'undef');
	if ($par{tol} eq 'MATCH') {
	    return 1 if ($pred_val eq $obs_val);
	} else {
	    return 1 if (abs($pred_val - $obs_val) <= $par{tol});
	    if ($par{var} eq 'ra' || $par{var} eq 'roll') {
		return 1 if (abs($pred_val - $obs_val) >= 360 - $par{tol});
	    }
	}
    }

    return 0;
}

####################################################################################
sub get {
####################################################################################
    my $self = shift;
    my $datetime = shift;
    my %state;

    # If argument looks like a date, then convert it
    my $time = ($datetime =~ /\d\d\d\d:\d/) ? date2time($datetime) : $datetime;

    # Check if we already have the predicted state
    return %{$self->{chex}} if ($time == $self->{time});  

    #    undef @match;  ??? What was this doing?
    
    # If chex_file was already read, force a re-read if @states in memory
    # do not contain match time

    undef @states if (@states && $states[0]->{time} >= $time);
	
    # Read in chex_file up to the point just before match time.  Chex file is
    # written in reverse chronological order

    unless (@states) {
	my $rdb = new RDB $self->{chex_file}
	    or die "Couldn't open input Chandra predicted state $self->{chex_file}\n";
	while ($rdb->read(\%state)) {
	    my $state_time = date2time($state{date});
	    unshift @states, { %state,
			       time => $state_time };
	    last if ($state_time < $time);
	}
    }

    # Find first state with time greater than match time
    my $i0 = 0;
    my $i1 = $#states;
    my $i;
    while ($i1 - $i0 > 4) {
	$i = sprintf "%d", ($i0+$i1)/2;
	if ($states[$i]->{time} > $time) {  $i1 = $i; }
	else                             {  $i0 = $i; }
    }
	    
    for ($i0 .. $i1) {
	$i = $_;
	last if ($states[$i]->{time} > $time);
    }

    if ($i == 0 or $i == $#states+1) {
	print STDERR "Chandra predicted state file '$self->{chex_file}' doesn't contain search time $time (" .
	    time2date($time) . ")\n";
	return;
    }

    
    # Start accumulating matches within time tolerance for each state variable.
    # The last record with time <= search time is automatically a match for all
    # state variables

    foreach (@state_var) {
	undef %{$match{$_}};
	$match{$_}{$states[$i-1]->{$_}} = 1;
    }

    # Search forward from the current record, accumulating only matches for
    # state variables within the time tolerance for that variable.
    # Quit when no variables match
    
    my $done = 0;
    my $i_match = $i-1;
    while ($i <= $#states && ! $done) {
	$done = 1;
	foreach my $i_sv (0 .. $#state_var) {
	    my $sv = $state_var[$i_sv];
	    if ($time + $state_tol[$i_sv] > $states[$i]->{time}) {
		$match{$sv}{$states[$i]->{$sv}} = 1;
		$done = 0;
	    }
	}
	$i++;
    }
	
    # Search backwards from the current record, accumulating only matches for
    # state variables within the time tolerance for that variable.
    # Quit when no variables match
    
    $i = $i_match-1;
    $done = 0;
    while ($i >= 0 && ! $done) {
	$done = 1;
	foreach my $i_sv (0 .. $#state_var) {
	    my $sv = $state_var[$i_sv];
	    if ($time - $state_tol[$i_sv] < $states[$i+1]->{time}) {
		$match{$sv}{$states[$i]->{$sv}} = 1;
		$done = 0;
	    }
	}
	$i--;
    }


    my %m;
    $LIST_SEPARATOR = ", ";
    foreach my $sv (@state_var) {
	$m{$sv} = [ keys %{$match{$sv}} ];
    }
    $LIST_SEPARATOR = " ";

    
    $self->{time} = $time;
    %{$self->{chex}} = %m;
    return %m;
}
    

####################################################################################
sub update {
####################################################################################
    my $self = shift;
    my @evt;
    my %state;

    my %par = (continuity => 0,
	       loud       => 0,
	       @_
	      );

    # Take pointer to mech_check array, or else parse mech_check_file
    my $p_mc = $par{mech_check};
    my $p_dot = $par{dot};
    my $p_mm = $par{mman};
    my $p_or = $par{OR};
    my $p_soe = $par{soe};
    my $p_bs  = $par{backstop};
    my $p_dthr= $par{dither};

# Put the events from the mech check file into the master event list

    foreach my $mc (@{$p_mc}) {
	next if ($mc->{var} =~ /continuity/);
	push @evt, { var  => $mc->{var},
		     val  => $UNDEF,
		     time => $mc->{time} } if ($mc->{dur} > 0.0);
	
	push @evt, { var  => $mc->{var},
		     val  => $mc->{val},
		     time => $mc->{time} + $mc->{dur} };
    }
    
# Put events from MMAN file into master event list

    my %mm_format = ('ra' => '%10.6f',
		     'dec' => '%9.5f',
		     'roll' => '%9.3f');

    foreach my $mm (values %{$p_mm}) {
	foreach my $q (qw(ra dec roll)) {
	    push @evt, { var  => $q,
			 val  => $UNDEF,
			 time => $mm->{tstart} };
	    push @evt, { var  => $q,
			 val  => sprintf($mm_format{$q}, $mm->{$q}),
			 time => $mm->{tstop} };
	}
    }

# Put obsid events from backstop into master event list

    foreach my $bs (@{$p_bs}) {
	if ($bs->{cmd} eq "MP_OBSID") {
	    my %param = parse_params($bs->{params});
	    $param{ID} =~ s/ //g;
	    push @evt, { var  => "obsid",
			 val  => $param{ID},
			 time => $bs->{time} };
	}
    }

# Put dither events from parse_cm_file::dither (taken from HISTORY file and backstop)
# into master list

    foreach my $dthr (@{$p_dthr}) {
	push @evt, { var  => "dither",
		     val  => $dthr->{state},
		     time => $dthr->{time} }
	  if $dthr->{source} eq 'backstop';
    }
	    
# Put events from OR list into master event list

    foreach my $obsid (keys %{$p_or}) {
	if (exists $p_soe->{$obsid}) {
	    push @evt, { var  => "gratings",
			 val  => $p_or->{$obsid}{GRATING},
			 time => date2time($p_soe->{$obsid}{odb_obs_start_time}) };
	    push @evt, { var  => "gratings",
			 val  => $UNDEF,
			 time => date2time($p_soe->{$obsid}{odb_obs_end_time}) };

	    # DITHER enabled?  Unless specified otherwise in OR, dither should be ENAB
	    my $dither = "ENAB";  
	    $dither = "DISA" if (defined $p_or->{$obsid}{DITHER_ON}
				 and $p_or->{$obsid}{DITHER_ON} eq 'OFF');
	    push @evt, { var  => "dither",
			 val  => $dither,
			 time => date2time($p_soe->{$obsid}{odb_obs_start_time}) };
	}
    }

# Put events from DOT file into master event list

# Sort event list by time

    my @order = sort { $evt[$a]->{time} <=> $evt[$b]->{time} } (0 .. $#evt);
    @evt = @evt[@order];
    my $evt_tstart = $evt[0]->{time};
    my $evt_tstop  = $evt[-1]->{time};

# Initialize Chandra expected state

    foreach my $var (@state_var) {
	$state{$var} = "";
    }

# Read input events

    my %in_state;
    my @in_states;
    print "Reading existing state file..\n" if ($loud);
    if (-r $self->{chex_file}) {
	my $in_rdb = new RDB $self->{chex_file}
	  or die "Couldn't open input Chandra predicted state '$self->{chex_file}'\n";
	while ($in_rdb->read(\%in_state)) {
	    push @in_states, { %in_state };
	}
    }
    foreach my $in_state_p (reverse @in_states) {
	foreach my $var (@state_var) {
	    next if ($var eq 'date');
	    if ($state{$var} ne $in_state_p->{$var}) { # Change in state -> an event
		$state{$var} = $in_state_p->{$var};
		# But only add events that are outside the time window defined by current processing
		my $state_time = date2time($in_state_p->{date});
		if ($state_time lt $evt_tstart || $state_time gt $evt_tstop) {
		    push @evt, { var  => $var,
				 val  => $in_state_p->{$var},
				 time => $state_time };
		}
	    }
	}
    }

# Sort event list by time again

    print "Sorting events by time\n" if ($loud);
    @order = sort { $evt[$a]->{time} <=> $evt[$b]->{time} } (0 .. $#evt);
    @evt = @evt[@order];

# Mark events that are at a common time

    print "Marking common time events\n" if ($loud);
    for my $i (0 .. $#evt-1) {
	$evt[$i]->{common_time} = 1 if ($evt[$i]->{time} == $evt[$i+1]->{time});
    }


# Output complete history of Chandra Expected state
    my $tmp_out_file = tmpnam(); 
    my $out_rdb = new RDB;
    $out_rdb->open($tmp_out_file, ">") or die "Couldn't open $tmp_out_file\n";
    $out_rdb->init( map {$state_var[$_] => $state_format[$_]} (0..$#state_var) );
    my @new_states = ();

    print "Collecting new events..\n" if ($loud);
    # First collect all the new states in reverse order
    foreach my $evt (@evt) {
	$state{$evt->{var}} = $evt->{val};
	next if ($evt->{common_time}); # Don't output multiple transitions at common time

	$state{date} = time2date($evt->{time});
#	unshift @new_states, { %state };# collect new states in reverse order
	push @new_states, { %state };# collect new states in reverse order
    }

    # Then actually write out file
    print "Writing file..\n" if ($loud);
    foreach my $state (reverse @new_states) {
	$out_rdb->write($state) or die "Problem writing to temporary output file\n";
    }

    system("cp $self->{chex_file} $self->{chex_file}~") if (-r $self->{chex_file});
    undef $out_rdb;		# Force closure of file
    system("cp $tmp_out_file $self->{chex_file}");
    unlink $tmp_out_file;
    print STDERR "Wrote predicted state of Chandra to $self->{chex_file}\n";
}

##***************************************************************************
sub get_file {
##***************************************************************************
    my $glob = shift;
    my $name = shift;
    my $required = shift;
    my $warning = ($required ? "ERROR" : "WARNING");

    my @files = glob($glob);
    if (@files != 1) {
	print STDERR ((@files == 0) ?
		      "$warning: No $name file matching $glob\n"
		      : "$warning: Found more than one file matching $glob, using none\n");
	die "\n" if ($required);
	return undef;
    } 

    print STDERR "Using $name file $files[0]\n";
    return $files[0];
}

##***************************************************************************
sub parse_params {
##***************************************************************************
    my @fields = split '\s*,\s*', shift;
    my %param = ();
    my $pindex = 1;

    foreach (@fields) {
	if (/(.+)= ?(.+)/) {
	    $param{$1} = $2;
	} else {
	    $param{"anon_param$pindex"} = $_;
	    $pindex++;
	}
    }

    return %param;
}


1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Chex - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Chex;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Chex, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Tom Aldcroft, E<lt>aldcroft@cfa.harvard.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by Tom Aldcroft

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
