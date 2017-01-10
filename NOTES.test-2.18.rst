Ska Runtime Environment 2.18
===========================================

.. Build and install this document with:
   rst2html.py --stylesheet=/proj/sot/ska/www/ASPECT/aspect.css \
        --embed-stylesheet NOTES.test-0.18.rst NOTES.test-0.18.html
   cp NOTES.test-0.18.html /proj/sot/ska/www/ASPECT/skare-0.18.html

Summary
---------

Version 0.18 of the Ska Runtime environment is a significant upgrade for the HEAD and GRETA
Ska-flight environment (64, 32 bit) and GRETA Ska-test 32-bit.

Highlights include ...


Testing overview
^^^^^^^^^^^^^^^^^

Pre-install testing is focused on GRETA Ska-test-32.  This is the test version of the
flight image that will be installed for GRETA / MCC operations.  In addition the
HEAD Ska-flight-32 image that will be directly rsynced to GRETA Ska-flight is also
tested.

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
   package_manifest
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


Installation on GRETA network (flight)
--------------------------------------

Ensure that the HEAD flight distribution has been installed and tested.

On or before live-install day as SOT user::

  # copy virtual-box built "candidate" directory into a temp directory on chimchim disk
  cd /proj/sot/ska/tmp
  rsync -av jeanconn@ccosmos:/proj/sot/ska/ska_0.18_candidate .
  # this has previously been done in /proj/sot/ska/dist and that would be fine as well


On chimchim as FOT CM (chimchim required for local disk access for copy)::

  set version=0.18-r460-06aafd2
  cd /proj/sot/ska/arch
  mkdir skare-${version}

  rsync -av /proj/sot/ska/tmp/ska_0.18_candidate/arch skare-${version}
  # change these from 'pegasus' group
  chgrp -R fotcm skare-${version}
  chmod g+w -R skare-${version}

  # do the actual linking
  rm i686-linux_CentOS-5
  rm x86_64-linux_CentOS-5
  ln -s skare-${version}/i686-linux_CentOS-5 ./
  ln -s skare-${version}/x86_64-linux_CentOS-5 ./


On GRETA chimchim as SOT

Complete non-arch install::

  cd /proj/sot/ska/lib
  mv perl perl_pre_0.18
  cd /proj/sot/ska/tmp/ska_0.18_candidate
  rsync -av lib/perl /proj/sot/ska/lib/
  rsync -av --dry-run bin/ /proj/sot/ska/bin/
  rsync -av bin/ /proj/sot/ska/bin/

  # Remove data directories that would be no-ops
  rm -r data/cmd_states
  rm -r data/eng_archive
  rm dir data/pyger

  # Remove kadi data directory as we don't want to update task schedule now
  rm -r data/kadi/

  # Double check remaining data to sync

   SOT@chimchim% tree data
   data
   |-- starcheck
   |   |-- A.tlr
   |   |-- ACABadPixels
   |   |-- B.tlr
   |   |-- aca_spec.json
   |   |-- agasc.bad
   |   |-- bad_acq_stars.rdb
   |   |-- bad_gui_stars.rdb
   |   |-- characteristics.yaml
   |   |-- down.gif
   |   |-- fid_CHARACTERISTICS
   |   |-- fid_CHARACTERIS_FEB07
   |   |-- fid_CHARACTERIS_JAN07
   |   |-- fid_CHARACTERIS_JUL01
   |   |-- overlib.js
   |   |-- tlr.cfg
   |   `-- up.gif
   `-- taco
       |-- task_schedule.cfg
       `-- task_schedule_occ.cfg

  # Sync data
  rsync -av data/ /proj/sot/ska/data/

  # Skip no-op include files
  rm -r include

  # Syncing share, but while this updated files
  # it is also basically a no-op as the running cron task
  # versions of the tasks are being called from /proj/sot/ska/test/share
  rsync -av share/ /proj/sot/ska/share/


==> OK: TLA/JC 2015-Jun-29

Smoke test on chimchim::

  source /proj/sot/ska/bin/ska_envs.csh
  ipython --pylab
  >>> import Ska.engarchive.fetch as fetch
  >>> fetch.__version__
  >>> dat = fetch.Msid('tephin', '2012:001', stat='5min')
  >>> dat.plot()

  >>> from kadi import events
  >>> print events.safe_suns.all()

  >>> import xija
  >>> xija.__version__

==> OK: TLA/JC 2015-Jun-29

Smoke test on snowman::

  source /proj/sot/ska/bin/ska_envs.csh
  ipython --pylab
  >>> import Ska.engarchive.fetch as fetch
  >>> fetch.__version__
  >>> dat = fetch.Msid('tephin', '2012:001', stat='5min')
  >>> dat.plot()

  >>> from kadi import events
  >>> print events.safe_suns.all()

  >>> import xija
  >>> xija.__version__

==> OK: TLA/JC 2015-Jun-29



Test on GRETA network (flight)
--------------------------------------

Test xija as SOT (32 and 64 bit)::

  ska
  cd
  ipython
  import xija
  xija.test()

==> OK: TLA/JC 64 bit, 32 bit  2015-Jun-29

Test eng_archive (32 and 64 bit)::

  ska
  ipython
  import Ska.engarchive
  Ska.engarchive.test()


==> OK: TLA/JC 64 bit, 32 bit but with usual fail on DP_SUN_XZ_ANGLE daily 2015-Jun-29

Test kadi (32 and 64 bit)
::

  cd ~/git/kadi
  git checkout 0.12.2
  py.test kadi

==> OK: TLA/JC 64 bit, 32 bit  2015-Jun-29

ESA view tool (basic functional checkout)::

  # On chimchim only
  ska
  cd
  python /proj/sot/ska/share/taco/esaview.py MAR2513

==> OK: TLA/JC 64 bit 2015-Jun-29

Test starcheck (64 bit)::

  # On chimchim only
  ska
  cd /tmp
  starcheck -dir /home/SOT/tmp/JAN3111C -out test
