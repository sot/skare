Ska Runtime Environment 2.18-r561-5120035
===========================================


Summary
---------

Version 2.18-r561-5120035 of the Ska Runtime environment is an update to the Ska runtime environment.


PR
--
https://github.com/sot/skare/pull/165/files


Changes from 0.18-r555
---------------------------------------------

Package Changes
^^^^^^^^^^^

(This is a diff of packages with defined versions in pkgs.manifest or pkgs.conda.  Conda
packages not in this list are also installed and may have incremented versions.  Efforts
were made to pin/freeze packages at their current versions to avoid version or build creep.)

===================  =======  =======  ======================================
Package               r555     r561       Comment
===================  =======  =======  ======================================
agasc                 0.3.1    3.5.2
chandra_aca           0.7      3.20
chandra_models        0.8      3.11
Chandra.acis_esa      0.01     ---
Chandra.cmd_states    0.09.1   3.14
Chandra.ECF           0.02     0.2.1
Chandra.Maneuver      0.05     3.7
Chandra.taco          0.2      0.2.1
Chandra.Time          3.20     3.20.1
cxotime               ---      3.1
find_attitude         0.1      0.2
hopper                0.1      0.3
kadi                  0.12.2   3.15.3
maude                 ---      3.1
mica                  0.5      3.14.0
nb2to3                ---      3.1
parse_cm              0.1      3.3.2
pyger                 0.6      1.1.0
pyyaks                3.3.3    3.3.4
Quaternion            0.03.2   3.4.1
tables3_api           ---      0.1
testr                 0.1      3.2
xija                  3.8      3.9      required for new xija models
ska_path              0.1      3.1
Ska.arc5gl            0.01     3.1.1
Ska.astro             0.02     3.2.1
Ska.engarchive        0.36.2   3.43.1
Ska.CIAO              0.02     0.2.1
Ska.DBI               0.08     3.8.2
Ska.File              0.4      3.4.1
Ska.ftp               0.04     3.5
Ska.Matplotlib        0.11.1   3.11.2
Ska.Numpy             0.08     3.8.1
Ska.ParseCM           0.03     3.3.1
Ska.Shell             0.03     3.3.2
Ska.Sun               0.04     3.5
Ska.Table             0.05     0.5.1
Ska.tdb               0.3      3.5.1
Ska.TelemArchive      0.08     0.8.1
Ska.quatutil          0.03     3.3.1
Ska.report_ranges     0.2      0.2.1

starcheck             ---      11.25    (not functional)
d2to1                 ---      0.2.12
stsci.distutils       ---      0.3.7
backstop_history      ---      1.1.0
acis_thermal_check    ---      2.5.0
psmc_check            ---      1.1.0
dpa_check             ---      2.2.0
dea_check             ---      2.1.0
acisfp_check          ---      2.2.0
===================  =======  =======  ======================================


Review
------

Notes and testing were assembled by Jean Connelly (to be reviewed by Tom Aldcroft).

Build
-------

/proj/sot/ska/dev
^^^^^^^^^^^^^^^^^^

Install skare on 32-bit and 64-bit.
::

  # Get skare repository on virtual CentOS-5 machine
  cd ~/git/skare
  git fetch
  git checkout greta_catchup_may2018

  # Choose prefix (dev or flight) and configure
  prefix=/proj/sot/ska/dev
  ./configure --prefix=$prefix

  # Make 64 or 32-bit installation
  make all_64  # on CentOS-5 64 bit VM
  make all_32  # on CentOS-5 32 bit VM

  # For rsync and installation, do something like:
  # Tar up the pieces on each VM
  cd /proj/sot/ska/dev
  tar -cvpf 32dev.tar arch bin include lib build/*/*/.installed   # 32 bit VM
  tar -cvpf 64dev.tar arch bin include lib build/*/*/.installed   # 64 bit VM

  # Rsync to HEAD /proj/sot/ska/tmp
  mkdir /proj/sot/ska/tmp/skadev-2.18-r561 # on HEAD
  rsync -aruvz 32dev.tar jeanconn@fido:/proj/sot/ska/tmp/skadev-2.18-r561 # 32 bit VM
  rsync -aruvz 64dev.tar jeanconn@fido:/proj/sot/ska/tmp/skadev-2.18-r561 # 64 bit VM

  # Rsync from ccosmos to GRETA tmp on machine chimchim
  mkdir /proj/sot/ska/tmp/skadev-2.18-r561 # on GRETA
  cd /proj/sot/ska/tmp/skadev-2.18-r561
  rsync -aruv jeanconn@ccosmos:/proj/sot/ska/tmp/skadev-2.18-r561/\*dev.tar .
  tar -xvpf 32dev.tar
  tar -xvpf 64dev.tar
  # remove no-longer needed tarballs
  rm 32dev.tar
  rm 64dev.tar

  # Rsync arch into /proj/sot/ska/dev/arch, link, and rsync the other pieces as needed
  cd /proj/sot/ska/dev/arch
  mkdir skadev-2.18-r561-5120035
  rsync -aruv /proj/sot/ska/tmp/skadev-2.18-r561/arch/\* skadev-2.18-r561-5120035

  # Create arch links
  cd /proj/sot/ska/dev/arch
  rm x86_64-linux_CentOS-5
  rm i686-linux_CentOS-5
  ln -s skadev-2.18-r561-5120035/x86_64-linux_CentOS-5 .
  ln -s skadev-2.18-r561-5120035/i686-linux_CentOS-5 .

  # Update other pieces; perl and build are sufficient for dev
  cd /proj/sot/ska/dev/lib
  mv perl perl_bak
  rsync -aruv /proj/sot/ska/tmp/skadev-2.18-r561/lib/perl .
  cd /proj/sot/ska/dev
  rm -r build
  rsync -aruvz /proj/sot/ska/tmp/skadev-2.18-r561/build .



Testing in GRETA dev
----------------------------------------

Chandra.Time
^^^^^^^^^^^^
::

  skadev
  cd
  python
  import Chandra.Time
  Chandra.Time.__version__
  '3.20.1'
  Chandra.Time.test()

==> OK: chimchim,  tiny numeric diff running test on gretasot.  OK

E       AssertionError: 441763266.184 != 441763266.18399996


Xija
^^^^^^^^
::

  skadev
  cd
  python
  import xija
  xija.__version__
  '3.9'
  xija.test()

==> OK: chimchim, gretasot


chandra_aca
^^^^^^^^^^^
::

  skadev
  cd
  python
  import chandra_aca
  chandra_aca.__version__
  '3.20'
  chandra_aca.test()

==> OK: chimchim, gretasot


Kadi
^^^^
::

  import kadi
  kadi.__version__
  '3.15.3'
  kadi.test()


==> OK on chimchim.  kadi.commands fails test_quick, test_states_2017, test_reduce_states_cmd_states
on gretasot.  kadi.commands is not required operationally and not presently supported for 32-bit.


Eng_archive
^^^^^^^^^^^^
::

  cd
  skadev
  python
  import Ska.engarchive
  Ska.engarchive.__version
  '3.43.1'
  Ska.engarchive.test()

==> OK: chimchim, gretasot


Cmd_states
^^^^^^^^^^
::

  # Check cmd_states fetch
  python
  >>> import Chandra.cmd_states
  >>> Chandra.cmd_states.test()

===> OK: chimchim, gretasot


**Ska.DBI** -  ::

  >>> import Ska.DBI
  >>> Ska.DBI.test()

==> sqlite tests appear to pass.  Errors on the Sybase tests (somewhat expected) chimchim, gretasot

**Quaternion** -  ::

   >>> import Quaternion
   >>> Quaternion.test

==> OK: chimchim, gretasot

**Ska.Numpy** -  ::

  >>> import Ska.Numpy
  >>> Ska.Numpy.test()

==> OK: chimchim, gretasot

**Ska.quatutil** -  ::

  cd ~/git/Ska.quatutil
  nosetests

==> OK: chimchim, gretasot


**Ska.Shell** -  ::

   >>> import Ska.Shell
   >>> Ska.Shell.test()

==> OK: (fails ciao.sh test, OK) chimchim, gretasot

**esa_view** - ::

  cd
  python /proj/sot/ska/share/taco/esaview.py MAR2513

==> OK: chimchim, gretasot


Run models
::

  cd ~/git/chandra_models
  git checkout 3.14
  ipython --matplotlib
  >>> import matplotlib.pyplot as plt
  >>> cd chandra_models/xija/acisfp
  >>> run calc_model.py
  >>> plt.show()
  >>> cd ../psmc
  >>> plt.figure()
  >>> run calc_model.py
  >>> plt.show()

==> Not done


Check plotting for qt
::

  cd
  ipython --pylab=qt
  >>> plot()
  >>> savefig('/tmp/junk.png')

  display /tmp/junk.png

==> OK chimchim, gretasot



Build of /proj/sot/ska
----------------------

Install skare on 32-bit and 64-bit.
::

  # Get skare repository on virtual CentOS-5 machine
  cd ~/git/skare
  git fetch
  git checkout greta_catchup_may2018

  # Choose prefix (dev or flight) and configure
  prefix=/proj/sot/ska
  ./configure --prefix=$prefix

  # Make 64 or 32-bit installation
  make all_64  # on CentOS-5 64 bit VM
  make all_32  # on CentOS-5 32 bit VM

  # For rsync and installation, do something like:
  # Tar up the pieces on each VM
  cd /proj/sot/ska
  tar -cvpf 32.tar arch bin include lib build/*/*/.installed   # 32 bit VM
  tar -cvpf 64.tar arch bin include lib build/*/*/.installed   # 64 bit VM

  # Rsync to HEAD /proj/sot/ska/tmp
  rsync -aruvz 32.tar jeanconn@fido:/proj/sot/ska/tmp/skadev-2.18-r561 # 32 bit VM
  rsync -aruvz 64.tar jeanconn@fido:/proj/sot/ska/tmp/skadev-2.18-r561 # 64 bit VM

  # Rsync from ccosmos to GRETA tmp on machine chimchim
  mkdir /proj/sot/ska/tmp/ska-2.18-r561 # on GRETA
  cd /proj/sot/ska/tmp/ska-2.18-r561
  rsync -aruv jeanconn@ccosmos:/proj/sot/ska/tmp/skadev-2.18-r561/\*tar .
  tar -xvpf 32.tar
  tar -xvpf 64.tar
  # remove no-longer needed tarballs
  rm *.tar


  # As FOT CM user (on chimchim for disk speed)


  # Rsync arch into /proj/sot/ska/arch, link, and rsync the other pieces as needed
  cd /proj/sot/ska/arch
  mkdir skare-2.18-r561-5120035
  rsync -aruv /proj/sot/ska/tmp/ska-2.18-r561/arch/\* skare-2.18-r561-5120035

  # Create arch links
  cd /proj/sot/ska/arch
  rm x86_64-linux_CentOS-5
  rm i686-linux_CentOS-5
  ln -s skare-0.18-r561-5120035/x86_64-linux_CentOS-5 .
  ln -s skare-0.18-r561-5120035/i686-linux_CentOS-5 .


  # Update other pieces
  cd /proj/sot/ska/lib
  mv perl perl_bak
  rsync -aruv /proj/sot/ska/tmp/ska-2.18-r561/lib/perl .
  cd /proj/sot/ska
  rm -r build
  rsync -aruv /proj/sot/ska/tmp/ska-2.18-r561/build .

  # Set arch and lib directories to be not-writeable
  cd /proj/sot/ska/arch
  chmod a-w -R skare-0.18-r561-5120035
  cd /proj/sot/ska
  chmod a-w -R lib/perl

  #logout as FOT CM user



Testing in GRETA flight
----------------------------------------

64 bit tests were run from chimchim.  32 bit tests were run from gretasot

Chandra.Time
^^^^^^^^^^^^
::

  ipython
  >>> import Chandra.Time
  >>> Chandra.Time.__version__


==> OK at version 3.20: chimchim, gretasot (17-Apr-2017)


Eng archive and kadi smoke tests
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
::

  ska
  ipython --pylab
  >>> import Ska.engarchive.fetch as fetch
  >>> fetch.__version__
  >>> dat = fetch.Msid('tephin', '2012:001', stat='5min')
  >>> dat.plot()

  >>> from kadi import events
  >>> print events.safe_suns.all()

===> OK chimchim, gretasot (17-Apr-2017)


Xija
^^^^^^^^
::

  cd
  ipython
  import os
  import xija
  xija.__version__
  '0.7'
  xija.test()

==> minusz.npz fail but good besides that chimchim, gretasot (17-Apr-2017)

chandra_aca
^^^^^^^^^^^
::

  ipython
  import chandra_aca
  chandra_aca.__version__
  '0.7'
  chandra_aca.test()

===> OK chimchim, gretasot (17-Apr-2017)

Kadi
^^^^
::

  cd ~/git/kadi
  git checkout 0.12.2
  py.test kadi

===> OK chimchim, gretasot (17-Apr-2017)


Eng_archive
^^^^^^^^^^^^
::

  # Do kadi tests before and copy events and ltt_bads if needed
  ipython
  import Ska.engarchive
  Ska.engarchive.test(args='-k "not test_fetch_regr"')

==> expected test_get_fetch_size_accuracy fail.  otherwise OK chimchim, gretaso (17-Apr-2017)


Check plotting for qt
^^^^^^^^^^^^^^^^^^^^^
::

  ipython --pylab=qt
  >>> plot()
  >>> savefig('/tmp/junk.png')

  display /tmp/junk.png

===> OK chimchim, gretasot (17-Apr-2017)

