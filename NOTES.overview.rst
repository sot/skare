Ska runtime environment
========================

The Ska runtime environment provides the full runtime resources used for all
Chandra "Ska" operations tools.  This includes the all aspect related
processing, ACA load review tools, the Ska engineering archive, the commanded
states database, ESAview tool, etc.

The Ska name was coined in a trailer at TRW during pre-launch integration and
test activities.  It was originally a lame acronym for Spacekraft und Aspect,
but now is just a word that might also refer to an under-appreciated form of
music.

Directory structure
--------------------

For historical reasons, the flight installation has the root path
`/proj/sot/ska/`.  The actual root for a Ska runtime environment is determined
by the `SKA` environment variable.  The whole environment can be built in a
different root, but an existing Ska runtime environment is not movable.

**Arch dependent files**

This tree holds everything that is architecture and OS-specific, with the
exception of Perl, which lives in `lib/perl`.
::

  arch/
    +-- i686-linux_CentOS-5/
    +-- x86_64-linux_CentOS-5/
    |   +-- bin/
    |   +-- doc/
    |   +-- etc/
    |   +-- include/
    |   +-- lib/
    |   |   +-- python2.7/
    |   +-- lib64/
    |   +-- libexec/
    |   +-- pgplot/
    |   +-- pkgs.manifest
    |   +-- sbin/
    |   +-- share/
    |   +-- var/

**Arch independent scripts**

The `ipython`, `perl` and `python` files are just shell launcher scripts that
use `flt_envs` to set the Ska environment and launch the correct arch-specific
binary.  The `flt_envs` script depends on the Ska `perl` to run.
::

  bin/  
    +-- flt_envs
    +-- ipython
    +-- perl  
    +-- python  # Launcher script (set environment and launch arch bin python)
    +-- ska_envs.csh
    +-- ska_envs.sh
    +-- sysarch
    +-- syspathsubst
    +-- ... global Ska application scripts and launchers

**Build Ska runtime environment (mostly) from source**
::

  build/  
    +-- i686-linux_CentOS-5/
    +-- x86_64-linux_CentOS-5/

**Source / binary tarballs for entire Ska runtime environment**
::

  pkgs/
    +-- ActivePython-2.7.1.4-linux-x86.tar.gz
    +-- ActivePython-2.7.1.4-linux-x86_64.tar.gz
    +-- Alien-SVN-1.6.12.0.tar.gz
    +-- App-Env-0.25.tar.gz
    +-- App-Env-ASCDS-0.01.tar.gz
    +-- ...  

**Global includes**
::

  include/
    +-- Makefile.FLIGHT
    +-- SKA_MAKE_DEFAULTS
    +-- Task_template/

**Global libraries**

In reality this only holds Perl 5.8.8, which internally chooses the right
architecture where needed.  ::

  lib/
    +-- perl/
        +--  ... <arch independent perl libraries>
        +-- i386-linux-thread-multi/
        +-- x86_64-linux-gnu-thread-multi/
        +-- x86_64-linux-thread-multi/

**Project documentation**
::

  doc/  
    +-- cmd_states/
    +-- eng_archive/
    +--  ...

**Project or task data**
::

  data/  
    +-- aca_bgd_mon/
    +-- aca_dark_cal/
    +-- aca_dark_cal_checker/
    +-- aca_egse/
    +--   ...
    +-- eng_archive/
    +--   ...
    +-- psmc/
    +--   ...
    +-- taco/
    +-- telem_archive/

**Project scripts and files**
::

  share/
    +-- aca_bgd_mon/
    +-- aca_dark_cal/
    +-- aca_egse/
    +--  ...

**Complete Ska runtime environment for development**
::

  dev/  
    +-- arch/
    +-- bin/
    +-- build/
    +-- data/
    +-- doc/
    +-- idl/
    +-- include/
    +-- lib/
    +-- ops/
    +-- pkgs@ -> ../pkgs
    +-- share/
    +-- www/

Environment setup
-----------------
Environment setup can be done by eval'ing the `$SKA/bin/flt_envs` script.  This
uses `sysarch` to determine the system architecture.

::

  SKA = /proj/sot/ska
  PATH = $SKA/bin : $SKA_ARCH_OS/bin : $PATH
  LD_LIBRARY_PATH = $SKA_ARCH_OS/lib : $SKA_ARCH_OS/pgplot : /soft/SYBASE_OCS15/OCS-15_0/lib
  PERL5LIB = $SKA/lib/perl : $SKA/lib/perl/lib

Configuration management
-------------------------

The Ska runtime environment is maintained via the `skare` project.  This
project consists of a main installer script and a number of configuration files
that specify build instructions for each package within Ska.  The entire Ska
runtime environment can be built from scratch within this project.  It requires
Python version 2.4 or later to run.

The `skare` project is maintained under git revision control.

Most regular updates to the HEAD network runtime environment (e.g. updating a
component package) are done by placing the new source tarball in
`/proj/sot/ska/pkgs` and updating the skare `pkgs.manifest` file to reflect the
new package.  Typically testing is done by first installing to the dev
environment `/proj/sot/ska/dev` with the `skare` package installer.  Once testing
is complete the new package is installed to the flight environment with the
package installer.  The `arch`, `bin`, and `lib` directories are owned and only
writable by a management group account `aca`.

For major updates to the runtime environment, the build is done on a CentOS-5
VM (currently with VMware on Mac).  Then the arch-specific directory
(e.g. `arch/x86_64-linux_CentOS-5`) is moved into place after renaming the
original.  This allows for easy install and quick backout.  Note that at this
time the Perl part of the environment is largely static and is not part of this
process.

The current GRETA network installation follows the same pattern: small updates
are done in-place on a per-package basis where possible, large updates are done
with a binary install.  Many of the compiled packages cannot be built on the
standard GRETA network because of the lack of `dev` RPMs.

GRETA Ska going forward
^^^^^^^^^^^^^^^^^^^^^^^^^^
Proposal:

* SOT (currently TLA , JC) will maintain primary responsibilty for the
  `skare` project and for updates to the content of the Ska runtime environment.

* FOT CM will assume ownership and sole write-access for `/proj/sot/ska/arch`.
  This directory and contents are henceforth referred to as FOT Ska.  All
  other files in the `/proj/sot/ska` root will be owned and maintained by SOT.

* Changes to FOT Ska are controlled through the FOT Matlab tools control board
  and will follow all procedures required of actual Matlab code.

* FOT CM will track the Ska runtime environment by maintaining a version of 
  the `skare` project within the FOT version control.  Presumably there is
  no advantage to versioning the actual binary package tarballs.

* SOT will maintain a duplicate of the `x86_64` HEAD network runtime
  environment on GRETA in the `/proj/sot/ska/sot` root (the SOT Ska).  This
  will allow FOT personnel access to the latest versions of SOT tools on
  chimchim.

* SOT will maintain a clone of the `skare` git repository in
  `/proj/sot/ska/git/skare`.  The `master` (aka trunk) branch will reflect the
  current installation on the HEAD network and the installation in
  `/proj/sot/ska/sot`.

* On an as-needed basis the SOT Ska will be promoted to the FOT Ska under
  control of the FOT Matlab tools CCB.  Typically this would be driven be a
  change needed for FOT Matlab tools.  

  Can FOT Matlab tools be easily configured to use SOT Ska for testing?  Or is
  there a better strategy?

  * Option A: SOT provides "binary installs" for x86_64 and i686 platforms.
  * Option B: FOT builds binary installs using `skare` installer on
    their own CentOS-5 VMs.
  * Option C: Suggestions?
  
