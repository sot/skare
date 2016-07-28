Ska Runtime Environment 0.18-r546-ca170c6
===========================================

.. Build and install this document with:
   rst2html.py --stylesheet=/proj/sot/ska/www/ASPECT/aspect.css \
        --embed-stylesheet NOTES.test-0.18.rst NOTES.test-0.18.html
   cp NOTES.test-0.18.html /proj/sot/ska/www/ASPECT/skare-0.18.html

Summary
---------

Version 0.18-r546-ca170c6 of the Ska Runtime environment is a small update that includes
an updated version of the chandra_aca package to support the dynamic aimpoint process.  It
also includes an update to Python and small required updates to support that. This is intended
for installation as a full binary build (not incremental)


Changes from 0.18-r542
---------------------------------------------

Package Changes
^^^^^^^^^^^

(This is a diff of packages with defined versions in pkgs.manifest or pkgs.conda.  Conda
packages not in this list are also installed and may have incremented versions.  Efforts
were made to pin/freeze packages at their current versions to avoid version or build creep.)

===================  =======  =======  ======================================
Package               r542     r546       Comment
===================  =======  =======  ======================================
python               2.7.9    2.7.12
openssl              1.0.1k   1.0.2h
sqlite3              3.8.4.1  3.13.0

chandra_aca          0.5      0.7
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
  git checkout greta_aimpoint_update

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
  mkdir /proj/sot/ska/tmp/skadev-0.18-r546 # on HEAD
  rsync -aruvz 32.tar jeanconn@fido:/proj/sot/ska/tmp/skadev-0.18-r546 # 32 bit VM
  rsync -aruvz 64.tar jeanconn@fido:/proj/sot/ska/tmp/skadev-0.18-r546 # 32 bit VM

  # Rsync from ccosmos to GRETA tmp on machine chimchim
  mkdir /proj/sot/ska/tmp/skadev-0.18-r546 # on GRETA
  cd /proj/sot/ska/tmp/skadev-0.18-r546
  rsync -aruv jeanconn@ccosmos:/proj/sot/ska/tmp/skadev-0.18-r546/*tar .
  tar -xvpf 32.tar
  tar -xvpf 64.tar
  # remove no-longer needed tarballs
  rm 32.tar
  rm 64.tar

  # Rsync arch into /proj/sot/ska/dev/arch, link, and rsync the other pieces as needed
  cd /proj/sot/ska/dev/arch
  mkdir skadev-0.18-r546-ca170c6
  rsync -aruv /proj/sot/ska/tmp/skadev-0.18-r546/arch/* skadev-0.18-r546-ca170c6

  # Create arch links
  cd /proj/sot/ska/dev/arch
  rm x86_64-linux_CentOS-5
  rm x86_64-linux_CentOS-6
  rm i686-linux_CentOS-5
  ln -s skadev-0.18-r546-ca170c6/x86_64-linux_CentOS-5 .
  ln -s skadev-0.18-r546-ca170c6/i686-linux_CentOS-5 .
  ln -s x86_64-linux_CentOS-5 x86_64-linux_CentOS-6

  # Update other pieces; perl and build are sufficient for dev
  cd /proj/sot/ska/dev/lib
  mv perl perl_bak
  rsync -aruv /proj/sot/ska/tmp/skadev-0.18-r546/lib/perl .
  cd /proj/sot/ska/dev
  rm -r build
  rsync -aruvz /proj/sot/ska/tmp/skadev-0.18-r546/build .



Testing in GRETA dev
----------------------------------------

Xija
^^^^^^^^
::

  skadev
  cd
  python
  import os
  os.environ['ENG_ARCHIVE'] = '/proj/sot/ska/data/eng_archive'
  import xija
  xija.__version__
'0.7'
  xija.test()

==> OK: chimchim, gretasot (JC 15-Jul-2016).


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

==> OK: chimchim, gretasot (JC 15-Jul-2016)

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

==> OK: chimchim, gretasot (JC 15-Jul-2016)


Eng_archive
^^^^^^^^^^^^
::

  # Do kadi tests before and copy events and ltt_bads if needed
  cd
  skadev
  setenv ENG_ARCHIVE /proj/sot/ska/data/eng_archive
  python
  import Ska.engarchive
  Ska.engarchive.test(args='-s')  # skip extended regr test with args='-k "not test_fetch_regr"'

==> OK: chimchim, gretasot.  (JC 15-Jul-2016) 1/47 tests fails on test_fetch_regr.  JC
assumes expected (TLA to confirm)

Cmd_states
^^^^^^^^^^
::

  # Check cmd_states fetch 
  python
  >>> from Chandra.cmd_states import fetch_states
  >>> states = fetch_states('2011:100', '2011:101', vals=['obsid', 'simpos'])
  >>> print states[['obsid', 'simpos']]
  [(13255L, 75624L) (13255L, 91272L) (12878L, 91272L)]

===> OK with deprecation warning: gretasot JC 15-Jul-2016
/proj/sot/ska/dev/arch/i686-linux_CentOS-5/lib/python2.7/site-packages/tables/conditions.py:419:
DeprecationWarning: using `oa_ndim == 0` when `op_axes` is NULL is deprecated. Use
`oa_ndim == -1` or the MultiNew iterator for NumPy <1.8 compatibility return func(*args



Other modules
^^^^^^^^^^^^^

**agasc** - ::

  # just do a does-it-run test for the agasc module
  python
  import agasc
  agasc.get_agasc_cone(10, 20, radius=1.5)

==> OK with deprecation warning seen above.  chimcim, gretasot JC 15-Jul-2016


**Ska.Table** -  ::

  cd ~/git/Ska.Table
  python test.py

==> OK: chimchim, gretasot JC 15-Jul-2016

**Ska.DBI** -  ::

  cd ~/git/Ska.DBI
  py.test test.py

==> sqlite tests appear to pass.  Errors on the Sybase tests (expected) JC 28-Jul-2016

**Quaternion** -  ::

  cd ~/git/Quaternion
  nosetests

==> OK: chimchim, gretasot JC 15-Jul-2016

**Ska.ftp** -  ::

  cd ~/git/Ska.ftp
  py.test

==> Not Done


**Ska.Numpy** -  ::

  cd ~/git/Ska.Numpy
  nosetests

==> OK: chimchim, gretasot JC 15-Jul-2016

**Ska.ParseCM** -  ::

  cd ~/git/Ska.ParseCM
  python test.py

==> Not Done

**Ska.quatutil** -  ::

  cd ~/git/Ska.quatutil
  nosetests

==> OK: chimchim, gretasot JC 15-Jul-2016


**Ska.Shell** -  ::

  cd ~/git/Ska.Shell
  python test.py

==> OK: chimchim, gretasot JC 15-Jul-2016

**asciitable** -  ::

  cd ~/git/asciitable
  git checkout 0.8.0
  nosetests

==> Not Done

**esa_view** - ::

  cd
  python /proj/sot/ska/share/taco/esaview.py MAR2513

==> OK: chimchim, gretasot JC 15-Jul-2016


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

==> OK chimchim, gretasot JC 15-Jul-2016


Check plotting for qt
::

  cd
  ipython --pylab=qt
  >>> plot()
  >>> savefig('/tmp/junk.png')

  display /tmp/junk.png

==> OK chimchim, gretasot JC 15-Jul-2016



Build of /proj/sot/ska
----------------------

/proj/sot/ska
^^^^^^^^^^^^^

Build 32 and 64 bit flight skare
::

  # Get skare repository on virtual CentOS-5 machine
  cd ~/git/skare
  git fetch
  git checkout greta_aimpoint_update

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
  mkdir /proj/sot/ska/tmp/ska-0.18-r546 # on HEAD
  rsync -aruvz 32.tar jeanconn@fido:/proj/sot/ska/tmp/ska-0.18-r546 # 32 bit VM
  rsync -aruvz 64.tar jeanconn@fido:/proj/sot/ska/tmp/ska-0.18-r546 # 32 bit VM


Install 32 and 64 bit flight
::
  # Rsync from ccosmos to GRETA tmp on machine chimchim
  mkdir /proj/sot/ska/tmp/ska-0.18-r546 # on GRETA
  cd /proj/sot/ska/tmp/ska-0.18-r546
  rsync -aruv jeanconn@ccosmos:/proj/sot/ska/tmp/ska-0.18-r546/*tar .
  tar -xvpf 32.tar
  tar -xvpf 64.tar
  # remove no-longer needed tarballs
  rm 32.tar
  rm 64.tar

  # Verify outputs
  # Confirm arch has correct directories
  cd /proj/sot/ska/tmp/ska-0.18-r546
  ls arch
  ls bin
  ls build

  # As FOT CM user (on chimchim for disk speed)

  # Rsync arch into /proj/sot/ska/arch, link, and rsync the other pieces as needed
  cd /proj/sot/ska/dev/arch
  mkdir skare-0.18-r546-ca170c6
  rsync -aruv /proj/sot/ska/tmp/ska-0.18-r546/arch/* skare-0.18-r546-ca170c6

  # Create arch links
  cd /proj/sot/ska/arch
  rm x86_64-linux_CentOS-5
  rm x86_64-linux_CentOS-6
  rm i686-linux_CentOS-5
  ln -s skare-0.18-r546-ca170c6/x86_64-linux_CentOS-5 .
  ln -s skare-0.18-r546-ca170c6/i686-linux_CentOS-5 .
  ln -s x86_64-linux_CentOS-5 x86_64-linux_CentOS-6

  # Update other pieces; perl and build are sufficient for dev
  cd /proj/sot/ska/lib
  mv perl perl_bak
  rsync -aruv /proj/sot/ska/tmp/ska-0.18-r546/lib/perl .
  cd /proj/sot/ska
  mv build build_bak
  rsync -aruvz /proj/sot/ska/tmp/ska-0.18-r546/build .

  # Set arch and lib directories to be not-writeable
  cd /proj/sot/ska/arch
  chmod a-w -R skare-0.18-r546-ca170c6
  cd /proj/sot/ska
  chmod a-w -R lib/perl

  #logout as FOT CM user

  # Remove starcheck in GRETA flight
  rm /proj/sot/ska/bin/starcheck
  rm /proj/sot/ska/bin/starcheck.pl
