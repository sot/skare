Ska Runtime Environment 0.15
===========================================

THIS IS THE CURRENTLY-INCOMPLETE version of test / install procedures
for skare-0.15, based on a copy of the 0.14 version.


.. Build and install this document with:
   rst2html.py --stylesheet=/proj/sot/ska/www/ASPECT/aspect.css \
        --embed-stylesheet NOTES.skare-0.14.rst NOTES.skare-0.14.html
   cp NOTES.skare-0.14.html /proj/sot/ska/www/ASPECT/skare-0.14.html

Review
------

Notes and testing were reviewed by Jean Connelly.

Build
-------

/proj/sot/ska/test
^^^^^^^^^^^^^^^^^^^

Install (or git pull) skare on 32-bit or 64-bit virtual CentOS-5 machine.
::

  # Get skare repository on virtual CentOS-5 machine
  cd ~/git/skare
  git checkout master
  git pull origin master

  # Choose prefix (dev or flight) and configure
  prefix=/proj/sot/ska/test
  ./configure --prefix=$prefix

  # Make 64 or 32-bit installation
  make all_64
  make all_32  # on quango

Pre-install testing in Ska test 
----------------------------------------

Starcheck
^^^^^^^^^^^^
::

  skatest
  cd ~/git/starcheck
  git checkout master
  git pull origin master
  (unska; /proj/sot/ska/bin/starcheck -dir AUG0104A -fid_char fid_CHARACTERIS_JUL01 -out test-flight)
  make test
  diff test-flight.txt test.txt

==> 

Eng_archive
^^^^^^^^^^^^
::

  cd ~/git/eng_archive

Follow the steps for "Regression test for new skare (..) in $ska/dev" in NOTES.test.

==> SKIP (No changes to modules that affect eng_archive)

Commanded states
^^^^^^^^^^^^^^^^^^
::

  skatest
  cd ~/git/Chandra.cmd_states
  python setup.py install
  cd ~/git/cmd_states
  make install
  cd ~/git/timelines
  make install

  nosetests

==> SKIP (No changes to modules that affect cmd_states)


ACIS thermal load review
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Tested by TLA for dpa_check, dea_check, acisfp_check, and psmc_check (2013 April 16)

DPA
~~~~~~~~

Window 1 (FLIGHT)::

  % source /proj/sot/ska/bin/ska_envs.csh
  % cd /pool14/aldcroft/acis_regression  # Use your own area here
  Run the tool, e.g.
  % python /proj/sot/ska/share/dpa/dpa_check.py \
   --outdir=dpa-feb0413a-flight \
   --oflsdir=/data/mpcrit1/mplogs/2013/FEB0413/oflsa \
   --run-start=2013:031

Window 2 (TEST)::

  % cd /pool14/aldcroft/acis_regression  # Use your own area here
  % source /proj/sot/ska/test/bin/ska_envs.csh
  % setenv ENG_ARCHIVE /proj/sot/ska/data/eng_archive
  % python /proj/sot/ska/share/dpa/dpa_check.py \
   --outdir=dpa-feb0413a-test \
   --oflsdir=/data/mpcrit1/mplogs/2013/FEB0413/oflsa \
   --run-start=2013:031

DIFFS::

  % diff dpa-feb0413a-flight/index.rst dpa-feb0413a-test/index.rst
  % diff dpa-feb0413a-flight/temperatures.dat \
         dpa-feb0413a-test/temperatures.dat

DEA
~~~~~~~~

Window 1 (FLIGHT)::

  % python /proj/sot/ska/share/dea/dea_check.py \
   --outdir=dea-feb0413a-flight \
   --oflsdir=/data/mpcrit1/mplogs/2013/FEB0413/oflsa \
   --run-start=2013:031

Window 2 (TEST)::

  % python /proj/sot/ska/share/dea/dea_check.py \
   --outdir=dea-feb0413a-test \
   --oflsdir=/data/mpcrit1/mplogs/2013/FEB0413/oflsa \
   --run-start=2013:031

DIFFS::

  % diff dea-feb0413a-flight/index.rst dea-feb0413a-test/index.rst
  % diff dea-feb0413a-flight/temperatures.dat \
         dea-feb0413a-test/temperatures.dat

PSMC
~~~~~~~~

Window 1 (FLIGHT)::

  % python /proj/sot/ska/share/psmc_check/psmc_check.py \
   --outdir=psmc-feb0413a-flight \
   --oflsdir=/data/mpcrit1/mplogs/2013/FEB0413/oflsa \
   --run-start=2013:031

Window 2 (TEST)::

  % python /proj/sot/ska/share/psmc_check/psmc_check.py \
   --outdir=psmc-feb0413a-test \
   --oflsdir=/data/mpcrit1/mplogs/2013/FEB0413/oflsa \
   --run-start=2013:031

DIFFS::

  % diff psmc-feb0413a-flight/index.rst psmc-feb0413a-test/index.rst
  % diff psmc-feb0413a-flight/temperatures.dat \
         psmc-feb0413a-test/temperatures.dat

ACIS_FP
~~~~~~~~

Window 1 (FLIGHT)::

  % python /proj/sot/ska/share/acisfp/acisfp_check.py \
   --outdir=acisfp-feb0413a-flight \
   --oflsdir=/data/mpcrit1/mplogs/2013/FEB0413/oflsa \
   --run-start=2013:031

Window 2 (TEST)::

  % python /proj/sot/ska/share/acisfp/acisfp_check.py \
   --outdir=acisfp-feb0413a-test \
   --oflsdir=/data/mpcrit1/mplogs/2013/FEB0413/oflsa \
   --run-start=2013:031

DIFFS::

  ## There are small expected diffs in both cases because of the random
  ## sampling in the flight Earth solid angle code.  This is changed
  ## in Skare 0.15, so subsequent regression testing will match.

  % diff acisfp-feb0413a-flight/index.rst acisfp-feb0413a-test/index.rst
  % diff acisfp-feb0413a-flight/temperatures.dat \
         acisfp-feb0413a-test/temperatures.dat


Other modules
^^^^^^^^^^^^^

**Ska.Table** -  ::

  cd ~/git/Ska.Table
  git fetch origin
  python test.py

**Ska.DBI** -  ::

  cd ~/git/Ska.DBI
  git fetch origin
  python test.py

**Quaternion** -  ::

  cd ~/git/Quaternion
  git fetch origin
  nosetests

**Ska.ftp** -  ::

  cd ~/git/Ska.ftp
  git fetch origin
  nosetests

**Ska.Numpy** -  ::

  cd ~/git/Ska.Numpy
  git fetch origin
  nosetests

**Ska.ParseCM** -  ::

  cd ~/hg/Ska.ParseCM
  hg incoming
  python test.py

**Ska.quatutil** -  ::

  cd ~/hg/Ska.quatutil
  hg incoming
  nosetests

**Ska.Shell** -  ::

  cd ~/hg/Ska.Shell
  hg incoming
  python test.py

**asciitable** -  ::

  cd ~/git/asciitable
  git checkout 0.8.0
  nosetests

Installation on GRETA network (test)
-------------------------------------

On ccosmos::

  skatest
  ska_version  # 0.15-r293-e754375

On quango (32-bit)::

  skatest
  ska_version  # 0.15-r293-e754375

On chimchim as SOT::

  set version=0.15-r293-e754375
  mkdir /proj/sot/ska/test/arch/skare-${version}
  rysnc -av aldcroft@ccosmos:/proj/sot/ska/test/arch/x86_64-linux_CentOS-5 \
                             /proj/sot/ska/test/arch/skare-${version}/
  rysnc -av aldcroft@ccosmos:/proj/sot/ska/test/arch/i686-linux_CentOS-5 \
                             /proj/sot/ska/test/arch/skare-${version}/

  cd /proj/sot/ska/test/arch
  ls -l  # make sure everything looks good
  ls -l $skare-${version}
  rm i686-linux_CentOS-5
  rm x86_64-linux_CentOS-5
  ln -s skare-${version}/i686-linux_CentOS-5 ./
  ln -s skare-${version}/x86_64-linux_CentOS-5 ./


Esa_view
^^^^^^^^

TBD but don't forget this.



Installation on HEAD network (flight)
-------------------------------------
The updates from the currently running flight Ska on HEAD are minor::

  * ebf9f03 (tag: refs/tags/0.14) Update Skare version from 0.13 to 0.14
  * d07ffa6 Add virtualenvwrapper 3.6
  * 9cf1fb8 Update psycopg2 2.0.8 to 2.4.6 and add psycopg2.cfg and Makefile entry
  * cd1d2ee Update ipython 0.12.1 to 0.13.1
  * b2a9524 Update matplotlib 1.1.0 to 1.2.0
  * 99ab4b2 Add BeautifulSoup4 4.1.3 (BeautifulSoup3 is still also available)
  * 3d370c2 Update xija from 0.2.4 to 0.2.7
  * 06d40f1 (refs/remotes/origin/master, refs/remotes/origin/HEAD, refs/heads/master) Update Django

Installation::

  # Do everything as aca
  su -l aca
  ska

  # SKIP this for 0.14 because it is a small delta from the current Ska
  #   # Make copy of current arch dirs
  #   cd /proj/sot/ska/arch
  #   set version=`ska_version`
  #   mkdir -p skare-${version}
  #   cp -rp x86_64-linux_CentOS-5 skare-${version}/
  #   # Normally do this for i686, but it doesn't exist yet for skare-0.12
  #   cp -rp i686-linux_CentOS-5 skare-${version}/

  # Prepare for in-place installation
  cd ~/git/skare
  git checkout 0.14  # Note: skare-0.14 branch has post-install updates vs. 0.14 tag
  git log

  # SKIP this for 0.14
  #   # Stop all cron jobs
  #   touch /proj/sot/ska/data/task_schedule/master_heart_attack
  #   # Wait at least a minute

  # Build updated skare on ccosmos
  ./configure --prefix=/proj/sot/ska
  make python_modules  # Could be "make all_64" for a bigger update

  # Build 32-bit version on quango
  ssh aca@quango
  cd ~/git/skare
  make all_32

  # TEST per instructions below

  # Allow all cron jobs to resume
  rm /proj/sot/ska/data/task_schedule/master_heart_attack


Post-install testing on HEAD
-----------------------------

Starcheck
^^^^^^^^^^^^
::

  cd ~/git/starcheck
  /proj/sot/ska/bin/starcheck -dir AUG0104A -fid_char fid_CHARACTERIS_JUL01 -out test.new
  diff test.7cb31b.txt test.new.txt

==> 

Eng_archive
^^^^^^^^^^^^
::

  cd ~/git/eng_archive

Follow the steps for "Regression test for new skare in /proj/sot/ska" in NOTES.test.

==> SKIP (no impact from update)

Commanded states
^^^^^^^^^^^^^^^^^^^
::

  cd ~/git/timelines
  nosetests

==> 

Other modules
^^^^^^^^^^^^^

- Ska.Table: 
- Ska.DBI: 
- Quaternion (nose): 
- Ska.ftp (nose): 
- Ska.Numpy: 
- Ska.ParseCM: 
- Ska.quatutil: 
- Ska.Shell: 
- asciitable: 


Notes
-----

REMEMBER to "make install" eng archive!

psmc_check
^^^^^^^^^^
::

  ska
  /proj/sot/ska/psmc_check_xija --run-start='2013:003' --oflsdir=/data/mpcrit1/mplogs/2013/JAN0713/ofls \
         --outdir=regress_flight-0.14


Esa_view
^^^^^^^^

TBD but don't forget this.


Installation on GRETA network (flight)
--------------------------------------

Ensure that the HEAD flight distribution has been installed and tested.


  cp -rp ../arch/x86_64-linux_CentOS-5 ../arch/i686-linux_CentOS-5 ./

On chimchim as SOT::

  set version=0.14-r272-ebf9f03
  cd /proj/sot/ska/dist
  mkdir skare-${version}
  rysnc -azv aldcroft@ccosmos:/proj/sot/ska/arch/x86_64-linux_CentOS-5/ \
        skare-${version}/x86_64-linux_CentOS-5/
  rysnc -azv aldcroft@ccosmos:/proj/sot/ska/arch/i686-linux_CentOS-5/ \
        skare-${version}/i686-linux_CentOS-5/

On chimchim as FOT CM::

  cd /proj/sot/ska/arch
  set version=0.14-r272-ebf9f03
  mkdir skare-${version}
  ls /proj/sot/ska/dist/skare-${version}
  rsync -av /proj/sot/ska/dist/skare-${version}/ skare-${version}/

  rm i686-linux_CentOS-5
  rm x86_64-linux_CentOS-5
  ln -s skare-${version}/i686-linux_CentOS-5 ./
  ln -s skare-${version}/x86_64-linux_CentOS-5 ./

Smoke test on chimchim::

  source /proj/sot/ska/arch/x86_64-linux_CentOS-5/bin/ska_envs.csh
  ipython --pylab
  import Ska.engarchive.fetch as fetch
  dat = fetch.Msid('tephin', '2012:001', stat='5min')
  dat.plot()

Smoke test on snowman::

  source /proj/sot/ska/arch/i686-linux_CentOS-5/bin/ska_envs.csh
  ipython --pylab
  import Ska.engarchive.fetch as fetch
  dat = fetch.Msid('tephin', '2012:001', stat='5min')
  dat.plot()

Fallback::

  set version=0.13-r241-427bb9c
  cd /proj/sot/ska/arch
  rm i686-linux_CentOS-5
  rm x86_64-linux_CentOS-5
  ln -s skare-${version}/i686-linux_CentOS-5 ./
  ln -s skare-${version}/x86_64-linux_CentOS-5 ./


Test on GRETA network (flight)
--------------------------------------

Test xija as SOT::

  ska
  cd ~/git/xija
  py.test xija/tests/

Test eng_archive::

  ska
  cd ~/git/eng_archive
  py.test tests/

Test esa_view::

  TBD but don't forget this.


