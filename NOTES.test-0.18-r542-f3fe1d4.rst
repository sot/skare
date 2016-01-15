Ska Runtime Environment 0.18-r542-f3feld4
===========================================

.. Build and install this document with:
   rst2html.py --stylesheet=/proj/sot/ska/www/ASPECT/aspect.css \
        --embed-stylesheet NOTES.test-0.18.rst NOTES.test-0.18.html
   cp NOTES.test-0.18.html /proj/sot/ska/www/ASPECT/skare-0.18.html

Summary
---------

Version 0.18-r542-f3fe1d4 of the Ska Runtime environment is a small update that includes
updated xija and chandra_models to support the dpa model with roll.  It also supports a
newer version of the conda package manager to aid in future updates.  This is intended
for installation as a full binary build (not incremental)


Changes from 0.18-r513-d20bade 
---------------------------------------------

Package Changes
^^^^^^^^^^^

(This is a diff of packages with defined versions in pkgs.manifest or pkgs.conda.  Conda
packages not in this list are also installed and may have incremented versions)

===================  =======  =======  ======================================
Package               r513     r542       Comment
===================  =======  =======  ======================================
xija                 0.4      0.7
chandra_models       0.5      0.8
chandra_aca          0.2      0.5
hopper               ---      0.1
kadi                 0.12.1   0.12.2
mica                 0.4.1dev 0.5
parse_cm             ---      0.1
ska.file             0.3      0.4
starcheck            11.4     11.5

astropy              1.0.2    1.0.3    (already at 1.0.3 in Windows build)
bsddb                ---      1.0
conda                3.12.0   3.19.0
conda_env            2.1.4    2.4.5
db                   ---      5.3.28
jpeg                 ---      8d
libtiff              ---      4.0.2
mpld3                ---      0.2
pillow               ---      2.8.1
pip                  6.0.8    7.1.2
setuptools           16.0     18.8.1

===================  =======  =======  ======================================

Review
------

Notes and testing were assembled by Jean Connelly and reviewed by Tom Aldcroft.

Build
-------

/proj/sot/ska/dev
^^^^^^^^^^^^^^^^^^

Install skare on 32-bit and 64-bit.
::

  # Get skare repository on virtual CentOS-5 machine
  cd ~/git/skare
  git fetch
  git checkout 2015_351_models_xija_update

  # Choose prefix (dev or flight) and configure
  prefix=/proj/sot/ska/dev
  ./configure --prefix=$prefix

  # Make 64 or 32-bit installation
  make all_64  # on CentOS-5 64 bit VM
  make all_32  # on CentOS-5 32 bit VM

  # Install starcheck (has python lib not included in pkgs.manifest)
  # The two python modules need to be installed on 32 and 64 bit
  source /proj/sot/ska/dev/bin/ska_envs.sh
  cd ~/git/starcheck
  git checkout 11.5
  python setup.py install
  make install

  # For rsync and installation, do something like:
  # Tar up the pieces on each VM
  cd /proj/sot/ska/dev
  tar -cvpf 32.tar arch bin data include lib build/*/*/.installed   # 32 bit VM
  tar -cvpf 64.tar arch bin data include lib build/*/*/.installed   # 64 bit VM

  # Rsync to HEAD /proj/sot/ska/tmp
  mkdir /proj/sot/ska/tmp/skadev-0.18-r542 # on HEAD
  rsync -aruvz 32.tar /proj/sot/ska/tmp/skadev-0.18-r542 # 32 bit VM
  rsync -aruvz 64.tar /proj/sot/ska/tmp/skadev-0.18-r542 # 32 bit VM

  # Rsync to from chimchim to GRETA tmp
  mkdir /proj/sot/ska/tmp/skadev-0.18-r542-f3feld4 # on GRETA
  cd /proj/sot/ska/tmp/skadev-0.18-r542-f3feld4
  rsync -aruv jeanconn@ccosmos:/proj/sot/ska/tmp/skadev-0.18-r542/*tar .
  tar -xvpf 32.tar
  tar -xvpf 64.tar

  # Move arch to /proj/sot/ska/dev/arch and rsync the other pieces as needed
  cd /proj/sot/ska/dev/arch
  mkdir skadev-0.18-r542-r3fe1d4 # I made a typo in the directory SHA, it stays for now
  rsync -aruv /proj/sot/ska/tmp/skadev-0.18-r542/arch/* skadev-0.18-r542-r3fe1d4/

  # Create arch links
  cd /proj/sot/ska/dev/arch
  rm x86_64-linux_CentOS-5
  rm x86_64-linux_CentOS-6
  rm i686-linux_CentOS-5
  ln -s skadev-0.18-r542-r3feld4/x86_64-linux_CentOS-5 .
  ln -s skadev-0.18-r542-r3feld4/i686-linux_CentOS-5 .
  ln -s x86_64-linux_CentOS-5 x86_64-linux_CentOS-6

  # Update other pieces; perl and build are sufficient for dev
  cd /proj/sot/ska/dev/lib
  mv perl perl_bak
  rsync -aruv /proj/sot/ska/tmp/skadev-0.18-r542/lib/perl .
  cd /proj/sot/ska/dev
  rm -r build
  rsync -aruvz /proj/sot/ska/tmp/skadev-0.18-r542/build .



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
  xija.__version
'0.7'
  xija.test()

==> OK: chimchim, gretasot (JC 14-Jan-2016).  Test fails on minusz.npz not writeable in
site-packages if that directory is not writeable, but that is a test defect.


Starcheck run test
^^^^^^^^^^^^^^^^^^

Test starcheck (64 bit)::

  # On chimchim only
  skadev
  cd /tmp
  starcheck -dir /home/SOT/tmp/JAN3111C -out test


==> OK: chimchim (JC 14-Jan-2016)

Kadi
^^^^
::
  cd ~/git/kadi
  git checkout 0.12.2
  # cp ltt_bads.txt and events.db3 into $SKA/data/kadi if not linked (GRETA
  # dev data is linked)
  py.test kadi
  
==> OK: chimchim, gretasot (JC 14-Jan-2016)


Eng_archive
^^^^^^^^^^^^
::

  # Do kadi tests before and copy events and ltt_bads if needed
  cd
  skadev
  export ENG_ARCHIVE=/proj/sot/ska/data/eng_archive
  python
  import Ska.engarchive
  Ska.engarchive.test(args='-s')  # skip extended regr test with args='-k "not test_fetch_regr"'

==> OK: chimchim, gretasot.  (JC 14-Jan-2016) 1/47 tests fails on test_fetch_regr on CCDM md5s.  TLA says expected.

BAD match

Regr:

{'CACALSTA         5min  ': '48d87752c3c1cb56eaad790b816d6b55',
 'CACALSTA         None  ': '2253513735233ec5c33ceb8e35b0da62',
 'CACALSTA         daily ': '33e1ae3a41aa5a77149bc64778c45e86',
 'CONLCXSM         5min  ': 'adc9d666c3ec9f1d7582faa990e602f1',
 'CONLCXSM         None  ': 'b19da98d272cba1071f127b7ce63c5f9',
 'CONLCXSM         daily ': '983ed343bf5a9f1fb69fa523fde60a4c',
 'COSBID           5min  ': '5a9d66a8e7b548446ea1edf738523314',
 'COSBID           None  ': '95ad463449c74cbcffa3c0e89fb901e9',
 'COSBID           daily ': '9198d08f141d52389639e2581b978c8e',
 'CTUSTAT0         5min  ': 'f471feba792bff77197200a241338093',
 'CTUSTAT0         None  ': '1673bd17a1aa6aca7f08f31a79146172',
 'CTUSTAT0         daily ': '6e03accdba322a3a346f96b7a3613524'}

Test:

{'CACALSTA         5min  ': '48d87752c3c1cb56eaad790b816d6b55',
 'CACALSTA         None  ': '2253513735233ec5c33ceb8e35b0da62',
 'CACALSTA         daily ': '33e1ae3a41aa5a77149bc64778c45e86',
 'COINSTTM         5min  ': '9fb95a86b826fa298c16fb5d8986fa66',
 'COINSTTM         None  ': '635c37f62d1a3611d5dbdc8bb0a9d0c4',
 'COINSTTM         daily ': 'e61815b3c5311ab5de5d44c36251dd71',
 'COSBCMRS         5min  ': '0b30daaac49f5db5538248403e427f37',
 'COSBCMRS         None  ': '65cd6598ead3383f4ce3748bceba628a',
 'COSBCMRS         daily ': '7401eeee1ff79e3c65cacf41db395ba5',
 'CTUSTAT0         5min  ': 'f471feba792bff77197200a241338093',
 'CTUSTAT0         None  ': '1673bd17a1aa6aca7f08f31a79146172',
 'CTUSTAT0         daily ': '6e03accdba322a3a346f96b7a3613524'}

F

  # Check cmd_states fetch 
  python
  >>> from Chandra.cmd_states import fetch_states
  >>> states = fetch_states('2011:100', '2011:101', vals=['obsid', 'simpos'])
  >>> print states[['obsid', 'simpos']]
  [(13255L, 75624L) (13255L, 91272L) (12878L, 91272L)]

===> OK: gretasot JC 14-Jan-2016

Other modules
^^^^^^^^^^^^^

**agasc** - ::

  # just do a does-it-run test for the agasc module
  python
  import agasc
  agasc.get_agasc_cone(10, 20, radius=1.5)

==> OK: stars retrieved.  chimchim, gretasot JC 14-Jan-2016


**Ska.Table** -  ::

  cd ~/git/Ska.Table
  git fetch origin
  python test.py

==> OK: chimchim, gretasot JC 14-Jan-2016

**Ska.DBI** -  ::

  cd ~/git/Ska.DBI
  git fetch origin
  py.test test.py

==> Not Done

**Quaternion** -  ::

  cd ~/git/Quaternion
  git fetch origin
  nosetests

==> OK: chimchim, gretasot JC 14-Jan-2016

**Ska.ftp** -  ::

  cd ~/git/Ska.ftp
  git fetch origin
  py.test

==> Not Done


**Ska.Numpy** -  ::

  cd ~/git/Ska.Numpy
  git fetch origin
  nosetests

==> OK: chimchim, gretasot JC 14-Jan-2016

**Ska.ParseCM** -  ::

  cd ~/git/Ska.ParseCM
  git fetch origin
  python test.py

==> Not Done

**Ska.quatutil** -  ::

  cd ~/git/Ska.quatutil
  git fetch origin
  nosetests

==> OK: chimchim, gretasot JC 14-Jan-2016


**Ska.Shell** -  ::

  cd ~/git/Ska.Shell
  git fetch origin
  python test.py

==> OK: chimchim, gretasot JC 14-Jan-2016

**asciitable** -  ::

  cd ~/git/asciitable
  git checkout 0.8.0
  nosetests

==> Not Done

**esa_view** - ::

  cd
  python /proj/sot/ska/share/taco/esaview.py MAR2513

==> OK: chimchim, gretasot JC 14-Jan-2016



Build and install of GRETA flight
--------------------------------------

Install skare on 32-bit and 64-bit.
::

  # Get skare repository on virtual CentOS-5 machine
  cd ~/git/skare
  git fetch
  git checkout 2015_351_models_xija_update

  # Choose prefix (dev or flight) and configure
  prefix=/proj/sot/ska
  ./configure --prefix=$prefix

  # Make 64 or 32-bit installation
  make all_64  # on CentOS-5 64 bit VM
  make all_32  # on CentOS-5 32 bit VM

  # Install starcheck (has python lib not included in pkgs.manifest)
  # The two python modules need to be installed on 32 and 64 bit
  source /proj/sot/ska/bin/ska_envs.sh
  cd ~/git/starcheck
  git checkout 11.5
  python setup.py install
  make install

  # For rsync and installation, do something like:
  # Tar up the pieces on each VM
  cd /proj/sot/ska
  tar -cvpf 32.tar arch bin data include lib build/*/*/.installed   # 32 bit VM
  tar -cvpf 64.tar arch bin data include lib build/*/*/.installed   # 64 bit VM

  # Rsync to HEAD /proj/sot/ska/tmp
  mkdir /proj/sot/ska/tmp/ska-0.18-r542 # on HEAD
  rsync -aruvz 32.tar jeanconn@fido.cfa.harvard.edu:/proj/sot/ska/tmp/ska-0.18-r542/ # 32 bit VM
  rsync -aruvz 64.tar jeanconn@fido.cfa.harvard.edu:/proj/sot/ska/tmp/ska-0.18-r542/ # 32 bit VM

  # Rsync to from chimchim to GRETA tmp
  mkdir /proj/sot/ska/tmp/ska-0.18-r542  # on GRETA
  cd /proj/sot/ska/tmp/ska-0.18-r542
  rsync -aruv "jeanconn@ccosmos:/proj/sot/ska/tmp/ska-0.18-r542/*tar" .
  tar -xvpf 32.tar
  tar -xvpf 64.tar

  # As FOT CM user (on chimchim for disk speed

  # Copy content and link as needed
  cd /proj/sot/ska/arch
  mkdir skare-0.18-r542-f3fe1d4
  rsync -aruv /proj/sot/ska/tmp/ska-0.18-r542/arch/* skare-0.18-r542-f3fe1d4

  # Create arch links
  cd /proj/sot/ska/arch
  rm x86_64-linux_CentOS-5
  rm i686-linux_CentOS-5
  ln -s skare-0.18-r542-f3fe1d4/x86_64-linux_CentOS-5 .
  ln -s skare-0.18-r542-r3fe1d4/i686-linux_CentOS-5 .

  # Update other pieces
  cd /proj/sot/ska/lib
  mv perl perl_bak
  rsync -aruv /proj/sot/ska/tmp/ska-0.18-r542/lib/perl .

  cd /proj/sot/ska
  mv build build_bak
  rsync -aruv /proj/sot/ska/tmp/ska-0.18-r542/build .

  # Update data and bin directories for starcheck 11.5
  rsync -aruv --dry-run /proj/sot/ska/tmp/ska-0.18-r542/data/* data/
  rsync -aruv /proj/sot/ska/tmp/ska-0.18-r542/data/* data/
  rsync -aruv --dry-run /proj/sot/ska/tmp/ska-0.18-r542/bin/* bin/
  rsync -aruv /proj/sot/ska/tmp/ska-0.18-r542/bin/* bin/

  # Set arch and lib directories to be not-writeable
  cd /proj/sot/ska/arch
  chmod -w -R ska-0.18-r542-f3fe1d4
  cd /proj/sot/ska
  chmod -w -R lib


Test on GRETA network (flight)
--------------------------------------

Test xija as SOT (32 and 64 bit)::

  ska
  cd
  ipython
  import xija
  xija.test()
  xija.__version__
  '0.7'



Check chandra_models version
::

  python
  >>> import chandra_models
  >>> chandra_models.__version__
  '0.8'



Smoke tests on chimchim::

  source /proj/sot/ska/bin/ska_envs.csh
  ipython --pylab
  >>> import Ska.engarchive.fetch as fetch
  >>> fetch.__version__
  >>> dat = fetch.Msid('tephin', '2012:001', stat='5min')
  >>> dat.plot()

  >>> from kadi import events
  >>> print events.safe_suns.all()



Smoke test on snowman::

  source /proj/sot/ska/bin/ska_envs.csh
  ipython --pylab
  >>> import Ska.engarchive.fetch as fetch
  >>> fetch.__version__
  >>> dat = fetch.Msid('tephin', '2012:001', stat='5min')
  >>> dat.plot()

  >>> from kadi import events
  >>> print events.safe_suns.all()


Test kadi (32 and 64 bit)
::

  cd ~/git/kadi
  # checkout at version 0.12.2 which corresponds to this sha
  git checkout bb5b93f
  py.test kadi


Run models
::

  cd ~/git/chandra_models
  git checkout 0.8
  ipython --matplotlib
  > import matplotlib.pyplot as plt
  > cd chandra_models/xija/acisfp
  > run calc_model.py
  > plt.show() # close figure after viewing
  > cd ../psmc
  > run calc_model.py
  > plt.show()



Run starcheck on chimchim and confirm successful run
::

  cd ~/tmp
  starcheck -dir JAN3111C -out 0.18_r542_starcheck


Check plotting for qt
::

  cd
  ipython --pylab=qt
  >>> plot()
  >>> savefig('/tmp/junk.png')


