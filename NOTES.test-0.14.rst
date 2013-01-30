Ska Runtime Environment 0.14
===========================================

.. Build and install this document with:
   rst2html.py --stylesheet=/proj/sot/ska/www/ASPECT/aspect.css \
        --embed-stylesheet NOTES.skare-0.14.rst NOTES.skare-0.14.html
   cp NOTES.skare-0.14.html /proj/sot/ska/www/ASPECT/skare-0.14.html

Review
------

Notes and testing were reviewed by Jean Connelly.  Command states and module
testing were run independently by Jean.

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

Pre-install testing in development area
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

==> 

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

==> 

psmc_check
^^^^^^^^^^
::

  skatest
  cd ~/hg/psmc
  export ENG_ARCHIVE=/proj/sot/ska/data/eng_archive
  make install
  python ./psmc_check.py --run_start_time='2011:001' --outdir regress_skatest

  # NEW WINDOW
  ska
  python ./psmc_check.py --run_start_time='2011:001' --outdir regress_ska

  diff regress_ska{,test}/validation_quant.csv

==> 

Other modules
^^^^^^^^^^^^^

**Ska.Table** - ::

  cd ~/git/Ska.Table
  python test.py

**Ska.DBI** - ::   

  su -l aca
  ln -s $ska/data/aspect_authorization $ska/test/data/
  cd ~/hg/Ska.DBI
  hg pull
  source /proj/sot/ska/test/bin/ska_envs.csh
  
**Quaternion** - : 

  cd ~/hg/Quaternion
  nosetests

**Ska.ftp** - : 

  cd ~/git/Ska.ftp
  nosetests

**Ska.Numpy** - ::

  cd ~/git/Ska.Numpy
  nosetests

**Ska.ParseCM** - ::

  cd ~/hg/Ska.ParseCM
  python test.py

**Ska.quatutil** - ::

  cd ~/hg/Ska.quatutil
  nosetests

**Ska.Shell** - ::

  cd ~/hg/Ska.Shell
  python test.py

**asciitable** - ::

  cd ~/git/asciitable
  git checkout 0.8.0
  py.test asciitable/tests

Installation on GRETA network (test)
-------------------------------------

On ccosmos::

  skatest
  ska_version  # 0.14-r272-ebf9f03

On quango (32-bit)::

  skatest
  ska_version  # 0.14-r272-ebf9f03

On chimchim as SOT::

  set version=0.14-r272-ebf9f03
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


Installation on GRETA network (flight)
--------------------------------------

Ensure that the HEAD flight distribution has been installed and tested.

On ccosmos::

  ska
  version=`ska_version`  
  cd /proj/sot/ska/dist
  mkdir skare-${version}
  cd skare-${version}
  cp -rp ../arch/x86_64-linux_CentOS-5 ../arch/i686-linux_CentOS-5 ./

On chimchim as SOT::

  set version= ??
  rysnc -azv aldcroft@ccosmos:/proj/sot/ska/dist/skare-${version} /proj/sot/ska/tmp/

On chimchim as FOT CM::

  cd /proj/sot/ska/arch
  set version= ??
  cp -rp /proj/sot/ska/tmp/skare-?? ./
  rm i686-linux_CentOS-5
  rm x86_64-linux_CentOS-5
  ln -s skare-??/i686-linux_CentOS-5 ./
  ln -s skare-??/x86_64-linux_CentOS-5 ./

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

One-time cleanup for a change in directory structure convention.  (Note that
the "r100" and "r200" are fictitious, the code that generated these SVN-like
revision numbers didn't exist for these earlier versions)::

  cd /proj/sot/ska/arch

  mkdir skare-0.11-r100-c0195da
  mv x86_64-linux_CentOS-5-0.11  skare-0.11-r100-c0195da/x86_64-linux_CentOS-5
  mv i686-linux_CentOS-5-0.11  skare-0.11-r100-c0195da/i686-linux_CentOS-5

  mkdir skare-0.12-r200-0512af5
  mv x86_64-linux_CentOS-5-0.12  skare-0.12-r200-0512af5/x86_64-linux_CentOS-5
  mv i686-linux_CentOS-5-0.12  skare-0.12-r200-0512af5/i686-linux_CentOS-5

Fallback::

  cd /proj/sot/ska/arch
  rm i686-linux_CentOS-5
  rm x86_64-linux_CentOS-5
  ln -s skare-0.12-r200-0512af5/i686-linux_CentOS-5 ./
  ln -s skare-0.12-r200-0512af5/x86_64-linux_CentOS-5 ./
  
Install eng_archive 0.19.1 executable scripts on chimchim as SOT::

  ska
  cd ~/git/eng_archive
  git pull origin master
  git checkout 0.19.1
  make install


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


Installation on GRETA network (test)
-------------------------------------

On ccosmos::

  # Create tarfile output for distribution to GRETA (after local testing)
  cd ~/git/skare
  version=`./ska_version.py`
  cd /proj/sot/ska/test
  tar zcf skare-${version}-test.tar.gz bin lib
  tar zcf skare-${version}-test-build.tar.gz build/*/*/.installed
  tar zcf skare-${version}-test-32.tar.gz arch/i686-linux_CentOS-5 
  tar zcf skare-${version}-test-64.tar.gz arch/x86_64-linux_CentOS-5
  mv skare-${version}*.tar.gz /proj/sot/ska/dist/

On chimchim::

  set version=??
  cd /proj/sot/ska/tmp
  scp -p aldcroft@ccosmos:/proj/sot/ska/dist/skare-${version}-test* ./
  # then install

Installation on HEAD network (flight)
-------------------------------------

Copy the skare tar distribution binary to /proj/sot/ska/dist.
::

  # Do everything as aca
  su -l aca
  ska

  # Make copy of current arch dirs
  cd /proj/sot/ska/arch
  set version=`ska_version`
  mkdir -p skare-${version}
  cp -rp x86_64-linux_CentOS-5 skare-${version}/
  # Normally do this for i686, but it doesn't exist yet for skare-0.12
  cp -rp i686-linux_CentOS-5 skare-${version}/

  # Prepare for in-place installation
  cd ~/git/skare
  git pull
  git log  

  # Stop all cron jobs
  touch /proj/sot/ska/data/task_schedule/master_heart_attack
  # Wait at least a minute

  # Build updated skare on ccosmos
  ./configure --prefix=/proj/sot/ska
  make all_64

  # For skare-0.13 ONLY:  (CHECK THIS for 0.14!)
  # Need to install an update to the eng_archive "update_archive.py" script
  # in $ska/share/eng_archive.
  cd ~/git/eng_archive
  make install

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

==> 

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

