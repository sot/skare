package Ska::Archive;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

use Carp;

require Exporter;
require AutoLoader;

use Expect;
use Cwd;

use Data::Password::Entry qw/:all/;

@ISA = qw(Exporter AutoLoader Expect);
# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.
@EXPORT = qw(
	
);
$VERSION = '1.0.2';


# Preloaded methods go here.

sub new {
  my $proto = shift;
  my $class = ref($proto) || $proto;
  my $arc  = {
	      Server => undef,
	      User => $ENV{USER},
	      Password => undef,
	      PasswordFile => undef,
	      Auto_cd_Reconnect => 1,
	      ifGuestUser => 0,
	      Timeout => 1000,
	      arc4gl => '/home/ascds/DS.release/bin/arc4gl',
	      lib_path => '/home/ascds/DS.release/lib',
	      sybase => $ENV{SYBASE} || '/soft/sybase',
	      config_db_data => $ENV{ASCDS_CONFIG_DB_DATA}
	                        || '/home/ascds/DS.release/data',
	      local_arcsrv => $ENV{DB_LOCAL_ARCSRV} || 'arcocc',
	      remote_arcsrv => $ENV{DB_REMOTE_ARCSRV} || 'arcocc',
	      telem_arcsrv => $ENV{DB_TELEM_ARCSRV} || 'arcocc',
	      prop_arcsrv => $ENV{DB_PROP_ARCSRV} || 'arcsao',
	      ocat_arcsrv => $ENV{DB_OCAT_ARCSRV} || 'ocatarcsrv',
	      Verbose => 0,
	      RemoteHost => undef,
	      RemoteUser => undef,
	      RemotePassword => undef,
	      Directory => undef
	     };

  bless ($arc, $class);

  my $attr = shift;

  if ( $attr )
  {
    while( my ( $attr, $val ) = each %{$attr} )
    {
      croak( __PACKAGE__, ": attribute error : `$attr' is not recognized \n" )
	unless exists $arc->{$attr};

      $arc->{$attr} = $val;
      if ( $attr eq 'Server' )
      {
	$arc->{local_arcsrv} = $val;
	$arc->{remote_arcsrv} = $val;
	$arc->{telem_arcsrv} = $val;
	$arc->{prop_arcsrv} = $val;
	$arc->{ocat_arcsrv} = $val;
      }
    }
  }


  if (not $arc->{ifGuestUser}){  
      $arc->{Password} ||= 
	  get_passwd_simplefile( $arc->{PasswordFile} ) 
	  || get_passwd_tty( "Enter arc4gl password for " . $arc->{User} );
  }

  $arc->{RemoteUser} ||= getpwuid($>);

  $arc->_need_ssh_password
    if defined $arc->{RemoteHost} ;

  my $curdir = getcwd;

  eval {
    chdir( $arc->{Directory} )
      || die( "unable to cd to $arc->{Directory}\n" )
	if defined $arc->{Directory};
    $arc->_connect;
  };
  my $error = $@;

  chdir $curdir or croak( __PACKAGE__, "unable to cd to $curdir\n");

  croak __PACKAGE__, ": $error" if $error;

  # turn on verbose *after* sending password.
  $arc->verbosity( $arc->{Verbose} );

  return $arc;
}

# _connect - start up arc4gl process
#
# creates an Expect object which talks to arc4gl.  It dies with
# an appropriate message upon error.

sub _connect
{
  my $arc = shift;

  $arc->{startup_dir} = getcwd;

  # save old environment
  my %oENV = %ENV;
  $ENV{LD_LIBRARY_PATH} = $arc->{lib_path};
  $ENV{SYBASE} = $arc->{sybase};
  $ENV{ASCDS_CONFIG_DB_DATA} = $arc->{config_db_data};
  $ENV{DB_LOCAL_ARCSRV} = $arc->{local_arcsrv};
  $ENV{DB_REMOTE_ARCSRV} = $arc->{remote_arcsrv};
  $ENV{DB_TELEM_ARCSRV} = $arc->{telem_arcsrv};
  $ENV{DB_PROP_ARCSRV} = $arc->{prop_arcsrv};
  $ENV{DB_OCAT_ARCSRV} = $arc->{ocat_arcsrv};

  # this acts a little strangely.  If there's an error in connection,
  # it doesn't get noticed until we look for the Password prompt
  # later on.  Thus all real error checking gets done if we fail
  # to get the Password prompt

  my $rhost = defined $arc->{RemoteHost} ? 
    sprintf( ' via SSH to %s as user %s',
	     $arc->{RemoteHost}, $arc->{RemoteUser} ) : '';
  
  if (not $arc->{ifGuestUser}){ 
      print STDERR "Connecting as archive user $arc->{User}$rhost\n"
	  if $arc->{Verbose};
  }
  else{
      print STDERR "Connecting to archive without username\n"
	  if $arc->{Verbose};
  }


  my $cmd;

  # Null user and no -U if guest user
  my $arc4gl_user = $arc->{ifGuestUser} ? '' : "-U$arc->{User}";

  $cmd = "$arc->{arc4gl} -v $arc4gl_user";
                                           
  if ( defined $arc->{RemoteHost} )
  {
    my $envs = join(' ', map { "$_='$ENV{$_}'" } 
		    qw/ LD_LIBRARY_PATH
			SYBASE
			ASCDS_CONFIG_DB_DATA
			DB_LOCAL_ARCSRV
			DB_REMOTE_ARCSRV
			DB_TELEM_ARCSRV
			DB_PROP_ARCSRV
			DB_OCAT_ARCSRV
			/
		);


    $cmd = sprintf ( 'ssh -t %s@%s "cd %s;  /usr/bin/env %s %s"',
		     $arc->{RemoteUser},
		     $arc->{RemoteHost}, $arc->{startup_dir}, $envs, $cmd);

    print STDERR "Remote SSH command:\n $cmd\n"
      if $arc->{Verbose};
  }

  $arc->{conn} = Expect->new;

  $arc->{conn}->spawn( $cmd ) || die( "connection error\n" );

  $arc->{conn}->log_stdout( 0 );

  # restore old environment
  %ENV = %oENV;

  # if remote host and need to send password, do that now.
  if ( $arc->{NeedRemotePassword} )
  {
    eval {
      $arc->{conn}->raw_pty(1);
      $arc->{conn}->expect( $arc->{Timeout}, -re => '[pP]assword:' )
	or die("error waiting for ssh password prompt\n" );
      $arc->{conn}->print( $arc->{RemotePassword}, "\n");
    };
    my $error = $@;
    $arc->{conn}->raw_pty(0);
    croak( __PACKAGE__, $error )
      if $error;
  }

  if (not $arc->{ifGuestUser}){ 
      $arc->_expect( 'Password: ' ) 
	  || die( "connection error: $arc->{res}{error}: $arc->{res}{before}\n" );

      $arc->_send_passwd;
  }
  else{
      $arc->_expect( 'arc4gl>' ) || return undef;  
  }
      

  if ( $arc->{res}{error} )
  {
    # remove password from before string; if the tty stuff in _send_passwd
    # really worked, wouldn't need this...
    {
      my $pwd = $arc->{Password};
      $arc->{res}{before} =~ s/$pwd/<PASSWD>/;
    }

    # didn't get authenticated.  Check for invalid password
    if ( $arc->{res}{before} =~ /assword invalid/ )
    {
      die( "authentication error for user `$arc->{User}': invalid password \n" );
    }

    # or maybe invalid user
    elsif ( $arc->{res}{before} =~ /has no account/ )
    {
      die( "authentication error for user `$arc->{User}': no such user \n" );
    }

    # or maybe invalid server
    elsif ( $arc->{res}{before} =~ /server name not found/ )
    {
      die( "connection error to server `$arc->{Server}': no such server\n" );
    }

    # or maybe who knows what
    else
    {
      die( "connection error: $arc->{res}{error}\n$arc->{res}{before}\n");
    }
  }

  print STDERR "Connected.\n"
    if $arc->{Verbose};

}

sub _disconnect
{
  my $arc = shift;

  return unless $arc->{conn};

  print STDERR "Disconnecting.\n"
    if $arc->{Verbose};

  $arc->{conn}->print( "exit\n");
  $arc->_expect( 'the unexpected' );
  croak( "disconnection error\n" )
    unless $arc->{res}{error_orig} =~ /^(2|3)/;

  $arc->{conn} = undef;
}

sub browse
{
  my $arc = shift;
  my $attr = shift;

  my %attr = %$attr;

  $attr{ operation } = 'browse';

  $arc->_send( ( map { "$_ = $attr{$_}" } keys %attr), 'go' ) ||
    croak( __PACKAGE__, "::browse: connection error: $arc->{res}{error}: $arc->{res}{before}\n" );

  croak( __PACKAGE__, "::browse: bad server name error" )
    if $arc->{res}{before} =~ /Requested server name not found/i;
  croak( __PACKAGE__, "::browse: bad user name or password" )
    if $arc->{res}{before} =~ /The attempt to connect to the server failed/i;
  croak( __PACKAGE__, "::browse: syntax error" )
    if $arc->{res}{before} =~ /4GL Command does not exist/i;

  _parse_browse( $arc->{res}{before} );
}

# _parse_browse( $res )
#
# splits the output of a browse command into an array containing
# the file information.  each element of the array is a hash
# with keys name, size, and time

sub _parse_browse
{
  # clean up output of arc4gl (has carriage returns in it)
  local($_) = shift;
  tr/\r//d;
  my @lines = split( "\n" );

  # we're looking for filenames.
  while ( @lines )
  {
    last if ( shift @lines ) =~ /^\s*filename\s+fileSize/i;
  }

  return [] unless @lines;

  my @files;
  my $records;
  my ( $name, $size, $time );

  while( defined( $_ = shift @lines ) )
  {
    if ( /^(\d+) record/ )
    {
      $records = $1;
      last;
    }
    elsif ( ( $name, $size, $time ) = /\s*(\S+)\s+(\d+)\s+(.*)/ )
    {
      push @files, { name => $name,
		     size => $size,
		     time => $time };
    }
  }

  croak( __PACKAGE__, "::browse: arc4gl error: no. of records ($records) != no. of files (", scalar @files, ")\n" )
    if ( $records != @files );

  return \@files;
}


sub retrieve
{
  my $arc = shift;
  my $attr = shift;

  my %attr = %$attr;

  my $dir = delete $attr{directory} || $arc->{Directory};
  my $curdir = getcwd;

  eval {

    chdir $dir or die( "unable to cd to $dir\n" )
      if defined $dir;

    if ( $arc->{Auto_cd_Reconnect} && $arc->{startup_dir} ne getcwd() )
    {
      $arc->_disconnect;
      $arc->_connect;
    }

    $attr{ operation } = 'retrieve';

    $arc->_send( ( map { "$_ = $attr{$_}" } keys %attr), 'go' ) ||
      die( "connection error: $arc->{res}{error}: $arc->{res}{before}\n" );;

    die( "bad server name error" )
      if $arc->{res}{before} =~ /Requested server name not found/;
    die( "bad user name or password" )
      if $arc->{res}{before} =~ /The attempt to connect to the server failed/;
    die( "syntax error" )
      if $arc->{res}{before} =~ /4GL Command does not exist/;
  };

  my $error = $@;

  chdir $curdir or 
    croak( __PACKAGE__, "::retrieve: unable to cd to $curdir\n");

  croak( __PACKAGE__, "::retrieve: ", $error ) if $error;

  _parse_retrieve( $arc->{res}{before} );
}

sub verbosity
{
  my $arc = shift;
  my $verbosity = shift;

  my $overbosity = $arc->{Verbose};

  if ( defined $verbosity )
  {
    $arc->{Verbose} = $verbosity;
    $arc->{conn}->log_stdout( $arc->{Verbose} > 3 ? 1 : 0 );
  }

  $overbosity;
}


# _parse_retrieve( $res )
#
# splits the output of a browse command into an array containing
# the names of the files retrieved.
sub _parse_retrieve
{
  # clean up output of arc4gl (has carriage returns in it)
  local($_) = shift;
  tr/\r//d;
  my @lines = split( "\n" );

  # everything between the 'Retrieving...' and the final tally is a
  # file name
  1 while( ( shift @lines ) !~ /Retrieving/ );
  
  my @files;
  my $records;

  while( defined( $_ = shift @lines ) )
  {
    if ( /^(\d+) file/ )
    {
      $records = $1;
      last;
    }
    push @files, $_;
  }

  croak( __PACKAGE__, "::retrieve: arc4gl error: no. of files specified ($records) != no. of files retrieved (", scalar @files, ")\n" )
    if ( $records != @files );

  # if there are no files, there might be an error message at the end..
  if ( 0 == @files && @lines )
  {
    croak( __PACKAGE__, "::retrieve: ", join ("\n", @lines ) );
  }


  return \@files;
}



# _send( @commands )
#
# send commands to the server. each command is sent independently.
# it waits for the 'arc4gl>' prompt to indicate success.
#
# it returns 1 upon success. if there was an error, it returns undef.
# $arc->{res} contains the results of the communication to
# the server which caused the error.

sub _send
{
  my $arc = shift;

  foreach ( @_ )
  {
    print STDERR "Sending `$_'\n"
      if $arc->{Verbose} && ! $arc->{conn}->log_stdout;
    $arc->{conn}->print( $_, "\n");

    $arc->_expect( 'arc4gl>' ) || return undef;
  }

  1;
}

# _send_passwd( )
#

sub _send_passwd
{
  my $arc = shift;

#  my $mstty = $arc->{conn}->manual_stty(1);
#  my $old_mode = $arc->{conn}->exp_stty('-g');
#  $arc->{conn}->exp_stty('raw -echo');

  $arc->{conn}->raw_pty( 1 );
  $arc->{conn}->print( $arc->{Password}, "\n");
  $arc->{conn}->raw_pty( 0 );

#  $arc->{conn}->exp_stty($old_mode);
#  $arc->{conn}->manual_stty($mstty);

  $arc->_expect( 'arc4gl>' ) || return undef;

  1;
}


# _expect( @match_patterns )
#
# match output of the server.  this is a simple wrapper around
# the Expect::expect call.  It stores the results in the 
# $arc->{res} hash, with the elements C<idx>, C<error>, C<string>,
# C<before>, and C<after>.  The error message is massaged to
# make it more obvious.
#
# it returns 1 upon success, undef if there was an error.

sub _expect
{
  my $arc = shift;

  $arc->{res} = ();
  @{$arc->{res}}{ qw( idx error_orig string before after ) } = 
    $arc->{conn}->expect( $arc->{Timeout}, @_ ); 

  if ( defined $arc->{res}{error_orig} )
  {
    local $_ = $arc->{res}{error_orig};

    if ( /^1/ )
    {
      $arc->{res}{error} = 'connection to archive timed out';
    }
    elsif ( /^(2|3)/ )
    {
      $arc->{res}{error} = 'connection to archive unexpectedly terminated';
    }
    else
    {
      my ( $errno, $errmsg) = /(\d):(.*)/;

      $arc->{res}{error} = "error in communications to archive: $errmsg";
    }

    return undef;
  }

  1;
}

# _need_ssh_password
#
# check if an ssh connection requires a password.  this is REALLY CRUDE.
sub _need_ssh_password
{
  my $self = shift;
  my $ruser = sprintf( "%s@%s", $self->{RemoteUser}, $self->{RemoteHost} );

  my $exp = Expect->new;
  $exp->log_stdout( 0 );
  $exp->spawn( "/usr/bin/ssh $ruser /bin/true" ) or
    die( "error spawning ssh password connect test\n" );

  my @results = $exp->expect( $self->{Timeout}, -re => '[pP]assword:' );

  $self->{NeedRemotePassword} = 0;

  # if it prompts...
  if ( defined  $results[2] )
  {
    $self->{NeedRemotePassword} = 1;

    $exp->raw_pty(1);

    # if a password was specified, try that
    if ( defined $self->{RemotePassword} )
    {
      $exp->print($self->{RemotePassword}, "\n");
      @results = $exp->expect( $self->{Timeout}, -re => '[pP]assword:' );

      die( __PACKAGE__, ":: incorrect SSH password for $ruser\n" )
	unless '2:EOF' eq $results[1];
    }

    # no password, ask for one
    else
    {
      my $tries = 0;
      until ( !defined  $results[2] )
      {

	print STDERR "Incorrect SSH Password.  Try Again\n"
	  if $tries;

	last if ++$tries > 3;

	# try sending the password if one was specified, else ask for one
	$self->{RemotePassword} = 
	  get_passwd_tty("Enter SSH password for $ruser");

	# try sending the password
	$exp->print($self->{RemotePassword}, "\n");

	@results = $exp->expect( $self->{Timeout}, -re => '[pP]assword:' );

	die( __PACKAGE__,
	     ":: incorrect SSH password for $ruser: too many guesses\n" )
	  if $results[3] =~ /denied/;
      }
    }
    $exp->raw_pty(0);
  }

}


sub DESTROY
{
  my $arc = shift;
  $arc->_disconnect;
}


# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

CXC::Archive - wrapper around the DS arc4gl interface to the archive.

=head1 SYNOPSIS

  use CXC::Archive;

  my $arc = new CXC::Archive;

  my %req = ( 
	     dataset     => 'flight',
	     detector    => 'obi',
	     subdetector => 'obspar',
	     level       => 0.5,
	     filetype    => 'actual',
	     filename    => '62979',
	     version     => 1,
	    );

  $files = $arc->browse( \%req );
  $files = $arc->retrieve( \%req );

=head1 DESCRIPTION

B<CXC::Archive> is a class which implements a connection to the CXC
data archive, using the B<arc4gl> program as the communications layer.
It abstracts the connection, browsing, and retrieval processes.
It works outside of the ASCDS environment (see below for specific
paths which may need to be changed).

At the time of this writing, B<arc4gl> only runs on computers with 
Sparc CPUs running the Solaris OS.  To get around this, this module
allows one to B<ssh> into a remote machine and run B<arc4gl> there.
See L</Remote Use> below for more details.

The constructor and methods throw exceptions using C<croak()> if there
is an error.  Use C<eval{}> to catch the exceptions.  The resultant
message begins with the string C<CXC::Archive::method: > and is
followed by an error message.  C<method> will be the name of the
method which failed.  Classes of exceptions are identified by the
first word in the error message.

=head2 Remote Use

By default the B<arc4gl> program is run locally.  To run it on another
machine (if for instance the local machine is not supported), specify
the C<RemoteHost> attribute.  An SSH connection will be made to that
machine, and B<arc4gl> will be started there.  By default the
connection is made as the current user; this may be changed with the
C<RemoteUser> attribute.  Note that if you haven't set up public key
authentication, you will be prompted for a password to connect to the
remote machine.


=head1 CONSTRUCTOR

=over 8

=item B<new>

  $arc = new CXC::Archive \%attr;

Creates a new connection to the CXC Archive server.  Connection
parameters are passed via the hash reference.  The following keys will
be recognized:

=over 8

=item C<Server>

This option is B<DEPRECATED> in the newest release of C<arc4gl>.  The various B<*_arcsrv> options now take its place.

The archive server to which to connect.  If not specified, the
content of the C<ASCDS_ARCHIVE_SERVER> environmental variable is used.

=item C<User>

The archive user account name.  If not specified, the value of the
C<USER> environmental variable is used.

=item C<ifGuestUser>

Flag to be set if arc4gl should be run in guest/non-priviledged mode.
If not set, defaults to user/password authentication for user mode.

=item C<Password>

The password for the archive account.  If this is not specified, and
C<PasswordFile> is not specified, the user will be prompted for it.

=item C<PasswordFile>

A file which contains the user's archive account password.  The
file shall not have read or write permissions to anyone but the owner.

=item C<RemoteHost>

A remote machine on which to run B<arc4gl>.  If not set, it will be
run locally.

=item C<RemoteUser>

The user name with which to connect to the remote host which will run
B<arc4gl>.  It defaults to the current user.

=item C<Directory>

The directory to which retrieved files will be written.  Usually
B<CXC::Archive> will retrieve files into the current directory.

When C<Directory> is specified, B<CXC::Archive> will retrieve files
into that directory unless an alternative is specified via the
C<directory> attribute to the retrieve request (see below).  It will
not track the current directory.

=item C<Auto_cd_Reconnect>

This is a boolean flag which indicates whether or not the connection
to the archive should be closed and restarted if a browse request is
performed in a different directory than where the connection was
created.  B<arc4gl> doesn't allow one to switch directories, so it
can only retrieve files into the directory in which it was executed.

This defaults to true.

=item C<Timeout>

The amount of time, in seconds, to wait for a reply from the archive
before timing out.  This defaults to 1000 seconds.

=item C<Verbose>

The verbosity level.  Change the level to change the amount of verbosity.
Currently only three levels exist: 

=over 8

=item C<0>

quiet

=item C<1>

say a few high level things

=item C<5>

dump the full interaction with C<arc4gl>.

=back

=item C<arc4gl>

The path to the C<arc4gl> binary.  This defaults to
C</home/ascds/DS.release/bin/arc4gl>.

=item C<lib_path>

The library path containing the shared libraries required by C<arc4gl>.
It defaults to C</home/ascds/DS.release/lib>.

=item C<sybase>

The Sybase home (set via the environmental variable B<SYBASE>).
Defaults to the environmental variable B<SYBASE> if set, otherwise, it defaults to C</soft/sybase>.

=item C<config_db_data>

Look up table for C<arc4gl>.  It provides C<arc4gl> with a mapping of which servers to use for which kinds of queries.  Defaults to the environmental variable B<ASCDS_CONFIG_DB_DATA> if set, otherwise, it defaults to C</home/ascds/DS.release/data>.

=item C<local_arcsrv>

Local archive server.  Defaults to the environmental variable B<DB_LOCAL_ARCSRV> if set, otherwise, it defaults to C<arcocc>.

=item C<remote_arcsrv>

Local archive server.  Defaults to the environmental variable B<DB_REMOTE_ARCSRV> if set, otherwise, it defaults to C<arcocc>.

=item C<telem_arcsrv>

Local archive server.  Defaults to the environmental variable B<DB_TELEM_ARCSRV> if set, otherwise, it defaults to C<arcocc>.

=item C<prop_arcsrv>

Local archive server.  Defaults to the environmental variable B<DB_PROP_ARCSRV> if set, otherwise, it defaults to C<arcsao>.

=item C<ocat_arcsrv>

Local archive server.  Defaults to the environmental variable B<DB_OCAT_ARCSRV> if set, otherwise, it defaults to C<ocatarcsrv>.

=back

Exceptions that may be thrown:

=over 8

=item C<attribute>

One of the attributes specified to the constructor wasn't recognized.

=item C<connection>

There was an error while creating the connection to C<arc4gl>.

=item C<authentication>

Authentication of the user failed.

=back

=head1 METHODS

=over 8

=item B<browse>

  $files = $arc->browse( \%req );

Browse the archive for data which match the passed keyword value
pairs.  See the C<arc4gl> documentation for valid keywords and values.
It returns a reference to an array of hashes containing the file
information.  Each hash has the elements C<name>, C<size>, and
C<time>.  If C<arc4gl> returns conflicting information about the files
(it shouldn't), B<browse()> will croak,

Exceptions that may be thrown are:

=over 8

=item C<syntax>

B<arc4gl> griped about the syntax of the command sent it.

=item C<arc4gl>

B<arc4gl> returned inconsistent or wrong results.

=item C<connection>

something went wrong while communicating with C<arc4gl>

=back

=item B<retrieve>

  $files = $arc->retrieve( \%req );

Retrieve files from the archive which match the passed keyword value pairs.
See the C<arc4gl> documentation for valid keywords and values.  It
returns a reference to an array with the filenames of the retrieved files.

These additional keywords are available:

=over

=item directory

This specifies the directory to which the data should be written.
This overrides 1) the C<Directory> attribute in the constructor; and
2) the current directory, which is where the data would normally be
written.

=back

Exceptions that may be thrown are:

=over 8

=item C<syntax>

B<arc4gl> griped about the syntax of the command sent it.

=item C<arc4gl>.

B<arc4gl> returned inconsistent or wrong results.

=item C<connection>

something went wrong while communicating with C<arc4gl>

=item B<verbosity>

  $old_verbosity = $arc->verbosity( 3 );

Sets the verbosity of the connection.  See the C<Verbosity> attribute
for the constructor.

=back

=back


=head1 AUTHOR

Diab Jerius ( djerius@cfa.harvard.edu )  based upon ideas and code
from Tom Aldcroft.

=cut
