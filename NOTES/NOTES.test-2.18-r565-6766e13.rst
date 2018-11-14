Ska Runtime Environment 2.18-r565-6766e13
===========================================


Summary
---------

Version 2.18-r565-6766e13 of the Ska Runtime environment is an update to the Ska runtime environment.


PR
--
https://github.com/sot/skare/pull/184/files


Changes from 0.18-r561
---------------------------------------------

Package Changes
^^^^^^^^^^^

===================  =======  =======  ======================================
Package               r561     r565       Comment
===================  =======  =======  ======================================
chandra_aca           3.20     3.24
chandra_models        3.11     3.21    
xija                  3.9      3.12    required for newest ACA model
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
  git checkout safe_mode_fixes

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
  mkdir /proj/sot/ska/tmp/skadev-2.18-r565 # on HEAD
  rsync -aruvz 32dev.tar jeanconn@fido:/proj/sot/ska/tmp/skadev-2.18-r565 # 32 bit VM
  rsync -aruvz 64dev.tar jeanconn@fido:/proj/sot/ska/tmp/skadev-2.18-r565 # 64 bit VM

  # Rsync from ccosmos to GRETA tmp on machine chimchim
  mkdir /proj/sot/ska/tmp/skadev-2.18-r565 # on GRETA
  cd /proj/sot/ska/tmp/skadev-2.18-r565
  rsync -aruv jeanconn@ccosmos:/proj/sot/ska/tmp/skadev-2.18-r565/\*dev.tar .
  tar -xvpf 32dev.tar
  tar -xvpf 64dev.tar
  # remove no-longer needed tarballs
  rm 32dev.tar
  rm 64dev.tar

  # Rsync arch into /proj/sot/ska/dev/arch, link, and rsync the other pieces as needed
  cd /proj/sot/ska/dev/arch
  mkdir skadev-2.18-r565-6766e13
  rsync -aruv /proj/sot/ska/tmp/skadev-2.18-r565/arch/\* skadev-2.18-r565-6766e13

  # Create arch links
  cd /proj/sot/ska/dev/arch
  rm x86_64-linux_CentOS-5
  rm i686-linux_CentOS-5
  ln -s skadev-2.18-r565-6766e13/x86_64-linux_CentOS-5 .
  ln -s skadev-2.18-r565-6766e13/i686-linux_CentOS-5 .

  # Update other pieces; perl and build are sufficient for dev
  cd /proj/sot/ska/dev/lib
  mv perl perl_bak
  rsync -aruv /proj/sot/ska/tmp/skadev-2.18-r565/lib/perl .
  cd /proj/sot/ska/dev
  rm -r build
  rsync -aruvz /proj/sot/ska/tmp/skadev-2.18-r565/build .



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
   >>> Quaternion.test()

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
  rsync -aruvz 32.tar jeanconn@fido:/proj/sot/ska/tmp/skadev-2.18-r565 # 32 bit VM
  rsync -aruvz 64.tar jeanconn@fido:/proj/sot/ska/tmp/skadev-2.18-r565 # 64 bit VM

  # Rsync from ccosmos to GRETA tmp on machine chimchim
  mkdir /proj/sot/ska/tmp/ska-2.18-r565 # on GRETA
  cd /proj/sot/ska/tmp/ska-2.18-r565
  rsync -aruv jeanconn@ccosmos:/proj/sot/ska/tmp/skadev-2.18-r565/\*tar .
  tar -xvpf 32.tar
  tar -xvpf 64.tar
  # remove no-longer needed tarballs
  rm *.tar


  # As jrose / FOT CM user (on chimchim for disk speed)


  # Rsync arch into /proj/sot/ska/arch, link, and rsync the other pieces as needed
  cd /proj/sot/ska/arch
  mkdir skare-2.18-r565-6766e13
  rsync -av /proj/sot/ska/tmp/ska-2.18-r565/arch/* skare-2.18-r565-6766e13

  # Create arch links
  cd /proj/sot/ska/arch
  rm x86_64-linux_CentOS-5
  rm i686-linux_CentOS-5
  ln -s skare-2.18-r565-6766e13/x86_64-linux_CentOS-5 .
  ln -s skare-2.18-r565-6766e13/i686-linux_CentOS-5 .


  # Update other pieces
  cd /proj/sot/ska/lib
  mv perl_bak perl_bak1
  chmod +w -R perl_bak1
  rm -rf perl_back1
  mv perl perl_bak
  rsync -aruv /proj/sot/ska/tmp/ska-2.18-r565/lib/perl .
  cd /proj/sot/ska
  rm -rf build
  rsync -aruv /proj/sot/ska/tmp/ska-2.18-r565/build .

  # Set arch and lib directories to be not-writeable
  cd /proj/sot/ska/arch
  chmod a-w -R skare-2.18-r565-6766e13
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


==> OK at version 3.20.1: chimchim, gretasot (03-Aug-2018)


Eng archive and kadi smoke tests
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
::

  ska
  ipython --pylab
  >>> import Ska.engarchive.fetch as fetch
  >>> fetch.__version__
  '3.43.1'
  >>> dat = fetch.Msid('tephin', '2012:001', stat='5min')
  >>> dat.plot()

  >>> from kadi import events
  >>> print events.safe_suns.all()

===> OK chimchim, gretasot (03-Aug-2018)


Xija
^^^^^^^^
::

  cd
  ipython
  import os
  import xija
  xija.__version__
  '3.9'
  xija.test()

==> OK chimchim, gretasot (03-Aug-2018)

chandra_aca
^^^^^^^^^^^
::

  ipython
  import chandra_aca
  chandra_aca.__version__
  '3.20'
  chandra_aca.test()

===> OK chimchim, gretasot (03-Aug-2018)

Kadi
^^^^
::

  import kadi
  kadi.test()

==> OK on chimchim.  kadi.commands fails test_quick, test_states_2017, test_reduce_states_cmd_states
on gretasot.  kadi.commands is not required operationally and not presently supported for
32-bit. (03-Aug-2018)


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

==> Four data_source tests fail.  MAUDE tests.  This is due to MAUDE
1.0 change since environment was created. otherwise OK chimchim, gretasot (03-Aug-2018)


Chandra.Maneuver
^^^^^^^^^^^^^^^^^
::

  import Chandra.Maneuver
  Chandra.Maneuver.test()

==> Small numeric diffs on gretasot.  OK chimchim (03-Aug-2018)


Check plotting for qt
^^^^^^^^^^^^^^^^^^^^^
::

  ipython --pylab=qt
  >>> plot()
  >>> savefig('/tmp/junk.png')

  display /tmp/junk.png

===> OK chimchim, gretasot (03-Aug-2018)

