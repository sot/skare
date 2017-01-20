Ska Runtime Environment 2.18
===========================================

.. Build and install this document with:
   rst2html.py --stylesheet=/proj/sot/ska/www/ASPECT/aspect.css \
        --embed-stylesheet NOTES.test-2.18.rst NOTES.test-2.18.html
   cp NOTES.test-2.18.html /proj/sot/ska/www/ASPECT/skare-2.18.html

Summary
---------

Version 2.18 of the Ska Runtime environment is a significant infrastructure
upgrade for the HEAD Ska flight and GRETA Ska test environments (64 bit).
Later this will be the basis for the next GRETA flight (Matlab) Ska
environment.

This update includes the upgrade of 27 packages to versions that are source-code
compliant with both Python 2.7 and Python 3.5+.  In most cases the code changes
are small and logically insignificant.  This include issues like changing print
statements into print functions, or putting a ``list()`` around an iterable.  In
a few cases (for instance ``Ska.engarchive`` or ``kadi``) the changes are more
substantial because of issues largely related to unicode handling.  For
``kadi``, the Python 3 version uses version 1.10 of Django (vs. 1.6 for Python
2.7), so this forced significant changes.

In addition, in order to verify that the package updates do not introduce
regressions, automated unit testing capability was added to many packages.


Interface changes
^^^^^^^^^^^^^^^^^

This update does not change any interfaces and no impact to existing code
is anticipated.

Testing overview
^^^^^^^^^^^^^^^^^

As mentioned, improved unit and regression testing is a major component
of this update.  To this end work was done on the ``ska_testr`` package:

- http://cxc.cfa.harvard.edu/mta/ASPECT/tool_doc/testr
- https://github.com/sot/ska_testr

Note that ``ska_testr`` is not actually part of Ska, but rather is a separate
repository of package test specifications that thoroughly test an installation
of Ska.  For this release `https://github.com/sot/ska_testr/tree/0.1.1 <version
0.1.1>`_ of ``ska_testr`` was used.

The following packages now have automated tests, with coverage ranging from
minimal to decent::

  ====================
       Package
  ====================
   acisfp_check
   agasc
   chandra_aca
   Chandra.cmd_states
   Chandra.Maneuver
   Chandra.Time
   cxotime
   dea_check
   dpa_check
   kadi
   maude
   mica
   parse_cm
   pyyaks
   Quaternion
   Ska.DBI
   Ska.engarchive
   Ska.ftp
   Ska.Numpy
   Ska.ParseCM
   Ska.quatutil
   Ska.Shell
   Ska.Table
   Ska.tdb
   starcheck
   timelines
   xija
  ====================

Initial testing was done on HEAD and GRETA with a pre-install version installed
to ``/proj/sot/ska/dev``.  After installation to ``/proj/sot/ska`` (HEAD) and
``/proj/sot/ska/test`` (GRETA), post-install testing will be done.

Changes from 0.18-r630-bc4d24f (current HEAD Ska flight)
--------------------------------------------------------

Packages
^^^^^^^^^^^

===================  =======  =======  ===============================================
Package               0.18     2.18      Pull Request
===================  =======  =======  ===============================================
agasc                 0.4      3.4     https://github.com/sot/agasc/pull/8
Chandra.cmd_states    0.10     3.10    https://github.com/sot/cmd_states/pull/26
Chandra.Maneuver      0.6      3.6     https://github.com/sot/Chandra.Maneuver/pull/5
Chandra.Time          3.20     3.20.1  https://github.com/sot/Chandra.Time/pull/25
chandra_aca           0.8      3.9     https://github.com/sot/chandra_aca/pull/21
chandra_models        0.11     3.11    https://github.com/sot/chandra_models/pull/27
cxotime               0.1      3.1     https://github.com/sot/cxotime/pull/1
kadi                  0.12.2   3.12.2  https://github.com/sot/kadi/pull/88
maude                 1.0      3.0     https://github.com/sot/maude/pull/6
mica                  0.5.4    3.5.4   https://github.com/sot/mica/pull/91
parse_cm              0.3      3.3     https://github.com/sot/parse_cm/pull/14
pyyaks                3.3.3    3.3.4   https://github.com/sot/pyyaks/pull/4
Quaternion            0.4.1    3.4.1   https://github.com/sot/Quaternion/pull/6
Ska.arc5gl            0.1.1    3.1.1   https://github.com/sot/Ska.arc5gl/pull/1
Ska.astro             0.2.1    3.2.1   https://github.com/sot/Ska.astro/pull/3
Ska.DBI               0.8.1    3.8.2   https://github.com/sot/Ska.DBI/pull/3
Ska.engarchive        0.41     3.41.2  https://github.com/sot/eng_archive/pull/132
Ska.File              0.4.1    3.4.1   https://github.com/sot/Ska.File/pull/4
Ska.ftp               0.4.2    3.4.2   https://github.com/sot/Ska.ftp/pull/10
Ska.Matplotlib        0.11.2   3.11.2  https://github.com/sot/Ska.Matplotlib/pull/7
Ska.Numpy             0.8.1    3.8.1   https://github.com/sot/Ska.Numpy/pull/1
Ska.ParseCM           0.3.1    3.3.1   https://github.com/sot/Ska.ParseCM/pull/3
Ska.quatutil          0.3.1    3.3.1   https://github.com/sot/Ska.quatutil/pull/2
Ska.Shell             0.3.1    3.3.1   https://github.com/sot/Ska.Shell/pull/7
Ska.Sun               0.5      3.5     https://github.com/sot/Ska.Sun/pull/4
Ska.tdb               0.5.1    3.5.1   https://github.com/sot/Ska.tdb/pull/7
ska_path              0.1      3.1     https://github.com/sot/ska_path/pull/1
===================  =======  =======  ===============================================

Review
------

Pull requests, notes, and testing were reviewed by Jean Connelly.

Build
-------

/proj/sot/ska/dev
^^^^^^^^^^^^^^^^^^

Install skare on 64-bit HEAD CentOS-5 machine.
::

  # Get skare repository on CentOS-5 machine
  ssh aca@unagi
  cd ~/git/skare
  git fetch origin
  git checkout py2-3

  # Choose prefix (dev or flight) and configure
  set prefix=/proj/sot/ska/dev
  ./configure --prefix=$prefix

  # Make 64-bit installation
  make all_64 >& make.log  # on CentOS-5 machine

  # Create arch link for CentOS-6
  cd /proj/sot/ska/dev/arch
  ln -s x86_64-linux_CentOS-5 x86_64-linux_CentOS-6

  # Create data and share links
  cd /proj/sot/ska/dev
  ln -s /proj/sot/ska/data ./
  ln -s /proj/sot/ska/share ./

  # BUILD on 32-bit, skipping perl  make python_32 on aca@quango

  # Install applications that are not included in skare
  source ${prefix}/bin/ska_envs.sh

  # Install starcheck files to $SKA/bin and /lib.
  cd ~/git/starcheck
  git checkout modularize-install
  make install_bin install_lib

  # Cmd_states - NOT REQUIRED NOW
  # All share are wrappers, data is static.
  # cd ~/git/cmd_states
  # git checkout master
  # make install

  # IGNORE this for now.  Share scripts need to be bundled into module
  # and bin/esaview should be fixed to not be hardwired to flight Ska.
  #   cd ~/git/taco
  #   git checkout master
  #   make install # doc build broken, so commented out in local install
  # Also note that the esaview wrapper is hard-coded to flight skare

Testing of /proj/sot/ska/dev
----------------------------
::

  cd ~/git/ska_testr
  git checkout master
  git pull origin master
  git checkout 0.1

  # If flight baseline regression data if not already available
  ska
  run_testr --include='*regress*' --exclude=Ska.engarchive

  # Unit and regression testing. Includes long tests, takes ~20 minutes on kadi.
  unska
  source ${prefix}/bin/ska_envs.sh
  run_testr

  # Confirm all "pass"
  cat outputs/2.18/

  # Diff regression outputs, confirm diffs only in package manifest
  (ska17; meld regress/0.18 regress/2.18)

  # ESA view tool (basic functional checkout, chimchim only)::
  cd
  python /proj/sot/ska/share/taco/esaview.py MAR2513


Installation on GRETA network (dev)
-------------------------------------

On HEAD ccosmos::

  skadev
  ska_version  #  2.18-r633-8a7e0b8

On GRETA chimchim as SOT install new 64-bit binary::

  set version=2.18-r633-8a7e0b8
  set arch=x86_64-linux_CentOS-5
      -- OR --
  set arch=i686-linux_CentOS-5

  mkdir /proj/sot/ska/dev/arch/${version}
  rsync -azv aldcroft@ccosmos:/proj/sot/ska/dev/arch/${arch} \
                              /proj/sot/ska/dev/arch/${version}/
      (Probably want to ignore pkgs though)


  cd /proj/sot/ska/dev/arch
  ls -l  # make sure everything looks good
  ls -l ${version}
  rm ${arch}
  ln -s ${version}/${arch} ./

Testing on GRETA 64-bit::

  # Make sure all repos with ``*git*`` tests are up to date.

  cd ~/git/ska_testr
  git pull origin master
  git checkout fddff8d

  # long tests are all related to data product creation
  # which does not happen on GRETA.  They also tend to require
  # resources or interfaces that are not available on GRETA.
  run_testr --exclude='*long*' --packages-repo=/home/SOT/git

  # ESA view tool (basic functional checkout, chimchim only)::
  cd
  python /proj/sot/ska/share/taco/esaview.py MAR2513

All tests from above pass except following, which are all
acceptable / expected:

==================   =============================================
  Package              Failure
==================   =============================================
Chandra.cmd_states     3 pass, 1 xfail: No sybase
           Ska.DBI     23 pass, 22 xfail: No sybase
       Ska.ParseCM     0 pass, 4 xfail: No MP archive data
         Ska.Shell     18 pass, 1 xfail: No CIAO
      acisfp_check     No sybase
         dea_check     No sybase
         dpa_check     No sybase
              mica     3 pass, 8 xfail: No /data/aca
         timelines     0 pass, 1 xfail: No sybase
==================   =============================================

Installation on HEAD network (flight)
-------------------------------------

Installation and test overview:

- Make a backup copy of the 64-bit SKA_ARCH_OS directory as aca@kadi
- Log in to aca@unagi
- cd ~/git/skare
- Check out release commit for py2-3, effectively same as r633-8a7e0b8 before rebase
  - git checkout fb2811a
- ./configure --prefix=/proj/sot/ska
- Perform an in-place update with ``make python_modules``
- Run full ska_testr unit and regression tests
- After one-week soak delete the backup copy

Fallback:

- Move the backup directory back into place as prime


Installation on GRETA network (test)
------------------------------------

Build (on HEAD):

- Move the existing /proj/sot/ska/test to test-bak
- Following the build instructions for /proj/sot/ska/dev, but use
  prefix=/proj/sot/ska/test and commit fb2811a instead

Install and test on GRETA (test)::

  set version=2.18-r639-fb2811a
  set arch=x86_64-linux_CentOS-5

  mkdir /proj/sot/ska/test/arch/${version}
  rsync -azv aldcroft@ccosmos:/proj/sot/ska/test/arch/${arch} \
                              /proj/sot/ska/test/arch/${version}/
      (Probably want to ignore pkgs though)

  cd /proj/sot/ska/test/arch
  ls -l  # make sure everything looks good
  ls -l ${version}
  rm ${arch}
  ln -s ${version}/${arch} ./

Testing on GRETA 64-bit::

  # Make sure all repos with ``*git*`` tests are up to date.

  cd ~/git/ska_testr
  git pull origin master
  git checkout fddff8d

  # long tests are all related to data product creation
  # which does not happen on GRETA.  They also tend to require
  # resources or interfaces that are not available on GRETA.
  run_testr --exclude='*long*' --packages-repo=/home/SOT/git

  # ESA view tool (basic functional checkout, chimchim only)::
  cd
  python /proj/sot/ska/share/taco/esaview.py MAR2513

Fallback:

- Move the backup directory back into place as prime

