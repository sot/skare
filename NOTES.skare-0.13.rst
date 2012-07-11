Ska Runtime Environment 0.13
===========================================

.. Build and install this document with:
   rst2html.py --stylesheet=/proj/sot/ska/www/ASPECT/aspect.css \
        --embed-stylesheet NOTES.skare-0.13.rst NOTES.skare-0.13.html
   cp NOTES.skare-0.13.html /proj/sot/ska/www/ASPECT/skare-0.13.html

Content changes overview
------------------------

- NumPy 1.5.0 to 1.6.2

- Xija 0.2 to 0.2.2: provides ACIS FP model

- Ska.engarchive 0.19 to 0.19.1:

  - Add ``MSID.interpolate()`` method which is like ``MSIDset.interpolate()``
  - Speed up ``interpolate()`` methods using the new ``Ska.Numpy.interpolate``.
  - Add ``MSIDset.filter_bad_times()`` method that applies the bad
    times filter to all MSIDs in a set.
  - Speed up `filter_bad_times()` by using a single mask array over 
    all bad time filters.
  - Add some unit / regression tests.

- Ska.Numpy 0.06 to 0.08: speed and lower memory usage with Cython:

  - New function ``search_both_sorted()`` that is like ``np.searchsorted()``
    but up to 15 times faster for both input arrays already sorted.
  - Updated function ``interpolate()`` that is up to 8 times faster for
    both input X arrays already sorted.

- PyFITS 2.4.0 to 3.0.7

- IPython 0.12 to 0.12.1: bug fix release

- PyTables 2.2b1 to 2.3.1: efficient table indexing

- Add new module numexpr 2.0.1: allows compiling NumPy expressions
  down to multi-threaded C for very fast execution.

- Other upgrades: argparse, distribute, docutils, Jinja2,
  mpi4py, pep8, pytest, Pygments, Ska.Table, Sphinx, and virtualenv. 

- 32-bit version of NumPy and SciPy built from source (as for  64-bit)

- Minor improvements in build process

- Update install.py to set LD_RUN_PATH globally to reduce (eliminate?) need for
  LD_LIBRARY_PATH in Python.  Rebuild mpi4py, matplotlib, numpy, scipy,
  ipython, tables.

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

==> OK

Eng_archive
^^^^^^^^^^^^
::

  cd ~/git/eng_archive

Follow the steps for "Regression test for new skare (..) in $ska/dev" in NOTES.test.

==> OK

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

==> OK

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

==> OK

Other modules
^^^^^^^^^^^^^

**Ska.Table** - OK::

  cd ~/git/Ska.Table
  python test.py

**Ska.DBI** - OK::   

  su -l aca
  ln -s $ska/data/aspect_authorization $ska/test/data/
  cd ~/hg/Ska.DBI
  hg pull
  source /proj/sot/ska/test/bin/ska_envs.csh
  
**Quaternion** - OK: 

  cd ~/hg/Quaternion
  nosetests

**Ska.ftp** - OK: 

  cd ~/git/Ska.ftp
  nosetests

**Ska.Numpy** - OK::

  cd ~/git/Ska.Numpy
  nosetests

**Ska.ParseCM** - OK::

  cd ~/hg/Ska.ParseCM
  python test.py

**Ska.quatutil** - OK::

  cd ~/hg/Ska.quatutil
  nosetests

**Ska.Shell** - OK::

  cd ~/hg/Ska.Shell
  python test.py

**asciitable** - OK::

  cd ~/git/asciitable
  git checkout 0.8.0
  py.test asciitable/tests

Installation on GRETA network (flight)
--------------------------------------

Ensure that the HEAD flight distribution has been installed and tested.

On ccosmos::

  ska
  version=`ska_version`  # 0.13-r241-427bb9c
  cd /proj/sot/ska/dist
  mkdir skare-${version}
  cd skare-${version}
  cp -rp ../arch/x86_64-linux_CentOS-5 ../arch/i686-linux_CentOS-5 ./

On chimchim as SOT::

  set version=0.13-r241-427bb9c
  rysnc -azv aldcroft@ccosmos:/proj/sot/ska/dist/skare-${version} /proj/sot/ska/tmp/

On chimchim as FOT CM::

  cd /proj/sot/ska/arch
  set version=0.13-r241-427bb9c
  cp -rp /proj/sot/ska/tmp/skare-0.13-r241-427bb9c ./
  rm i686-linux_CentOS-5
  rm x86_64-linux_CentOS-5
  ln -s skare-0.13-r241-427bb9c/i686-linux_CentOS-5 ./
  ln -s skare-0.13-r241-427bb9c/x86_64-linux_CentOS-5 ./

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

  set version=0.13-r241-427bb9c
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

  # For skare-0.13 ONLY:
  # Force re-build of these packages in order to set internal RPATH (see
  # email from Mark search "mbaski rpath")
  cd /proj/sot/ska/build/x86_64-linux_CentOS-5
  rm mpi4py-1.*/.installed numpy-1.*/.installed scipy-0.*/.installed
  rm matplotlib-1.1.0/.installed ipython-0.1*/.installed tables-2.*/.installed

  # Prepare for in-place installation
  cd ~/git/skare
  git pull
  git log  

  # Stop all cron jobs
  touch /proj/sot/ska/data/task_schedule/master_heart_attack
  # Wait at least a minute

  # Build updated skare 0.13 on ccosmos
  ./configure --prefix=/proj/sot/ska
  make all_64
  
  # For skare-0.13 ONLY:
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

==> OK

Eng_archive
^^^^^^^^^^^^
::

  cd ~/git/eng_archive

Follow the steps for "Regression test for new skare in /proj/sot/ska" in NOTES.test.

==> OK

Commanded states
^^^^^^^^^^^^^^^^^^^
::

  cd ~/git/timelines
  nosetests

==> OK

Other modules
^^^^^^^^^^^^^

- Ska.Table: OK
- Ska.DBI: OK
- Quaternion (nose): OK
- Ska.ftp (nose): OK
- Ska.Numpy: OK
- Ska.ParseCM: OK
- Ska.quatutil: OK
- Ska.Shell: OK
- asciitable: OK


Notes
-----

REMEMBER to "make install" eng archive!

