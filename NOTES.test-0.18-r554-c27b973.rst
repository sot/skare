Ska Runtime Environment 0.18-r554-c27b973
===========================================


Summary
---------

Version 0.18-r554-c27b973 of the Ska Runtime environment is a small update that includes
updates to the Perl and Python modules that handle time. It is intended to support the
leap second at the end of 2016.  It also includes a small change in the Python module
install process, as "pip" is now used instead of "python setup.py install".

PR
--
https://github.com/sot/skare/pull/92/files


Changes from 0.18-r546
---------------------------------------------

Package Changes
^^^^^^^^^^^

(This is a diff of packages with defined versions in pkgs.manifest or pkgs.conda.  Conda
packages not in this list are also installed and may have incremented versions.  Efforts
were made to pin/freeze packages at their current versions to avoid version or build creep.)

===================  =======  =======  ======================================
Package               r546     r554       Comment
===================  =======  =======  ======================================
Chandra.Time          3.19     3.20
Chandra-Time          0.09.1   0.9.2
XTime                 1.2.1    1.2.2

testr                 ---      0.1
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
  git checkout greta_2016_322

  # Choose prefix (dev or flight) and configure
  prefix=/proj/sot/ska/dev
  ./configure --prefix=$prefix

  # Make 64 or 32-bit installation
  make all_64  # on CentOS-5 64 bit VM
  make all_32  # on CentOS-5 32 bit VM

  # For rsync and installation, do something like:
  # Tar up the pieces on each VM
  cd /proj/sot/ska/dev
  tar -cvpf 32.tar arch bin include lib build/*/*/.installed   # 32 bit VM
  tar -cvpf 64.tar arch bin include lib build/*/*/.installed   # 64 bit VM

  # Rsync to HEAD /proj/sot/ska/tmp
  mkdir /proj/sot/ska/tmp/skadev-0.18-r554 # on HEAD
  rsync -aruvz 32.tar jeanconn@fido:/proj/sot/ska/tmp/skadev-0.18-r554 # 32 bit VM
  rsync -aruvz 64.tar jeanconn@fido:/proj/sot/ska/tmp/skadev-0.18-r554 # 32 bit VM

  # Rsync from ccosmos to GRETA tmp on machine chimchim
  mkdir /proj/sot/ska/tmp/skadev-0.18-r554 # on GRETA
  cd /proj/sot/ska/tmp/skadev-0.18-r554
  rsync -aruv jeanconn@ccosmos:/proj/sot/ska/tmp/skadev-0.18-r554/\*tar .
  tar -xvpf 32.tar
  tar -xvpf 64.tar
  # remove no-longer needed tarballs
  rm 32.tar
  rm 64.tar

  # Rsync arch into /proj/sot/ska/dev/arch, link, and rsync the other pieces as needed
  cd /proj/sot/ska/dev/arch
  mkdir skadev-0.18-r554-c27b973
  rsync -aruv /proj/sot/ska/tmp/skadev-0.18-r554/arch/\* skadev-0.18-r554-c27b973

  # Create arch links
  cd /proj/sot/ska/dev/arch
  rm x86_64-linux_CentOS-5
  rm x86_64-linux_CentOS-6
  rm i686-linux_CentOS-5
  ln -s skadev-0.18-r554-c27b973/x86_64-linux_CentOS-5 .
  ln -s skadev-0.18-r554-c27b973/i686-linux_CentOS-5 .
  ln -s x86_64-linux_CentOS-5 x86_64-linux_CentOS-6

  # Update other pieces; perl and build are sufficient for dev
  cd /proj/sot/ska/dev/lib
  mv perl perl_bak
  rsync -aruv /proj/sot/ska/tmp/skadev-0.18-r554/lib/perl .
  cd /proj/sot/ska/dev
  rm -r build
  rsync -aruvz /proj/sot/ska/tmp/skadev-0.18-r554/build .



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
  '3.20'


==> OK: chimchim, gretasot


Xija
^^^^^^^^
::

  skadev
  cd
  python
  import xija
  xija.__version__
  '0.7'
  xija.test()

==> OK-ish: chimchim, gretasot (fails on write of minusz.npz, fixed in 0.7.1)


chandra_aca
^^^^^^^^^^^
::

  skadev
  cd
  python
  import chandra_aca
  chandra_aca.__version__
  '0.7'
  chandra_aca.test()

==> OK: chimchim, gretasot

Starcheck run test
^^^^^^^^^^^^^^^^^^

No longer supported in GRETA flight/dev.  Only in GRETA test.

==> NA

Kadi
^^^^
::

  cd ~/git/kadi
  git checkout 0.12.2
  # cp ltt_bads.txt and events.db3 into $SKA/data/kadi if not linked (GRETA
  # dev data is linked)
  py.test kadi

==> OK: chimchim, gretasot


Eng_archive
^^^^^^^^^^^^
::

  # Do kadi tests before and copy events and ltt_bads if needed
  cd
  skadev
  python
  import Ska.engarchive
  Ska.engarchive.test(args='-k "not test_fetch_regr"')  # skip extended regr test with args='-k "not test_fetch_regr"'

==> chimchim and gretasot test fail in test_get_fetch_size_accuracy (test has since been changed)
>       assert fetch_mb == round(fetch_bytes / 1e6, 2)
E       assert 4.61 == 4.62
E        +  where 4.62 = round((4615056 / 1000000.0), 2)


Cmd_states
^^^^^^^^^^
::

  # Check cmd_states fetch 
  python
  >>> from Chandra.cmd_states import fetch_states
  >>> states = fetch_states('2011:100', '2011:101', vals=['obsid', 'simpos'])
  >>> print states[['obsid', 'simpos']]
  [(13255L, 75624L) (13255L, 91272L) (12878L, 91272L)]

===> chimchim is back to printing this without the "L"s, gretasot has the "L"s

>>> print states[['obsid', 'simpos']]
[(13255, 75624) (13255, 91272) (12878, 91272)]



^^^^^^^^^^^^^

**agasc** - ::

  # just do a does-it-run test for the agasc module
  python
  import agasc
  agasc.get_agasc_cone(10, 20, radius=1.5)

==> OK chimchim, gretasot


**Ska.Table** -  ::

  cd ~/git/Ska.Table
  python test_read.py

==> OK: chimchim, gretasot

**Ska.DBI** -  ::

  cd ~/git/Ska.DBI
  py.test test.py

==> sqlite tests appear to pass.  Errors on the Sybase tests (expected) chimchim, gretasot

**Quaternion** -  ::

  cd ~/git/Quaternion
  nosetests

==> OK: chimchim, gretasot

**Ska.ftp** -  ::

  cd ~/git/Ska.ftp
  py.test

==> Not Done


**Ska.Numpy** -  ::

  cd ~/git/Ska.Numpy
  nosetests

==> OK: chimchim, gretasot

**Ska.ParseCM** -  ::

  cd ~/git/Ska.ParseCM
  python test.py

==> Not Done

**Ska.quatutil** -  ::

  cd ~/git/Ska.quatutil
  nosetests

==> OK: chimchim, gretasot


**Ska.Shell** -  ::

  cd ~/git/Ska.Shell
  python test.py

==> OK: chimchim, gretasot

**asciitable** -  ::

  cd ~/git/asciitable
  git checkout 0.8.0
  nosetests

==> Not Done

**esa_view** - ::

  cd
  python /proj/sot/ska/share/taco/esaview.py MAR2513

==> OK: chimchim, gretasot


Run models
::

  cd ~/git/chandra_models
  git checkout 0.8
  ipython --matplotlib
  >>> import matplotlib.pyplot as plt
  >>> cd chandra_models/xija/acisfp
  >>> run calc_model.py
  >>> plt.show()
  >>> cd ../psmc
  >>> plt.figure()
  >>> run calc_model.py
  >>> plt.show()

==> OK chimchim, gretasot


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
  git checkout greta_2016_322

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
  mkdir /proj/sot/ska/tmp/ska-0.18-r554 # on HEAD
  rsync -aruvz 32.tar jeanconn@fido:/proj/sot/ska/tmp/ska-0.18-r554 # 32 bit VM
  rsync -aruvz 64.tar jeanconn@fido:/proj/sot/ska/tmp/ska-0.18-r554 # 32 bit VM

  # Rsync from ccosmos to GRETA tmp on machine chimchim
  mkdir /proj/sot/ska/tmp/ska-0.18-r554 # on GRETA
  cd /proj/sot/ska/tmp/ska-0.18-r554
  rsync -aruv jeanconn@ccosmos:/proj/sot/ska/tmp/ska-0.18-r554/\*tar .
  tar -xvpf 32.tar
  tar -xvpf 64.tar
  # remove no-longer needed tarballs
  rm 32.tar
  rm 64.tar

  # Optional non-arch cleanup items
  cd /proj/sot/ska/lib
  rm -rf perl_bak
  rm -rf perl_bak2
  rm -rf perl_pre_0.18
  cd /proj/sot/ska
  rm -rf build_bak
  rm -rf build_bak2
  rm -rf dev-bak
  rm -rf dev-bak2

  # As FOT CM user (on chimchim for disk speed)

  # Rsync arch into /proj/sot/ska/arch, link, and rsync the other pieces as needed
  cd /proj/sot/ska/arch
  mkdir skare-0.18-r554-c27b973
  rsync -aruv /proj/sot/ska/tmp/ska-0.18-r554/arch/\* skare-0.18-r554-c27b973

  # Create arch links
  cd /proj/sot/ska/arch
  rm x86_64-linux_CentOS-5
  rm i686-linux_CentOS-5
  ln -s skare-0.18-r554-c27b973/x86_64-linux_CentOS-5 .
  ln -s skare-0.18-r554-c27b973/i686-linux_CentOS-5 .
  ln -s x86_64-linux_CentOS-5 x86_64-linux_CentOS-6

  # Update other pieces
  cd /proj/sot/ska/lib
  mv perl perl_bak
  rsync -aruv /proj/sot/ska/tmp/ska-0.18-r554/lib/perl .
  cd /proj/sot/ska
  rm -r build
  rsync -aruv /proj/sot/ska/tmp/ska-0.18-r554/build .

  # Set arch and lib directories to be not-writeable
  cd /proj/sot/ska/arch
  chmod a-w -R skare-0.18-r554-c27b973
  cd /proj/sot/ska
  chmod a-w -R lib/perl

  #logout as FOT CM user



Testing in GRETA flight
----------------------------------------

64 bit tests were run from chimchim.  32 bit tests were run from greta7b

Eng archive and kadi smoke tests
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
::

  ipython --pylab
  >>> import Ska.engarchive.fetch as fetch
  >>> fetch.__version__
  >>> dat = fetch.Msid('tephin', '2012:001', stat='5min')
  >>> dat.plot()

  >>> from kadi import events
  >>> print events.safe_suns.all()

===> 


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

==> 

chandra_aca
^^^^^^^^^^^
::

  ipython
  import chandra_aca
  chandra_aca.__version__
  '0.7'
  chandra_aca.test()

==> 

Kadi
^^^^
::

  cd ~/git/kadi
  git checkout 0.12.2
  py.test kadi

==> 


Eng_archive
^^^^^^^^^^^^
::

  # Do kadi tests before and copy events and ltt_bads if needed
  ipython
  import Ska.engarchive
  Ska.engarchive.test(args='-k "not test_fetch_regr"')

==> 


Check plotting for qt
^^^^^^^^^^^^^^^^^^^^^
::

  ipython --pylab=qt
  >>> plot()
  >>> savefig('/tmp/junk.png')

  display /tmp/junk.png

==> 
