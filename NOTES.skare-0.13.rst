Ska Runtime Environment 0.13
===========================================

.. Build and install this document with:
   rst2html.py --stylesheet=/proj/sot/ska/www/ASPECT/aspect.css \
        --embed-stylesheet NOTES.skare-0.13 NOTES.skare-0.13.html
   cp NOTES.skare-0.13.html /proj/sot/ska/www/ASPECT/skare-0.13.html

Content changes overview
------------------------

- NumPy 1.5.0 to 1.6.2

- Xija 0.2 to 0.2.2: provides ACIS FP model

- Ska.engarchive 0.19 to 0.19.1:

  - Add ``MSID.interpolate()`` method which is like ``MSIDset.interpolate()``
  - Speed up ``interpolate()`` methods using the new ``Ska.Numpy.interpolate``.
  - Add a standard bad times file (taken from values provided by 
    A. Arvai) so that all bad times can be filtered out with
    ``dat.filter_bad_times()``
  - Add ``MSIDset.filter_bad_times()`` method that applies the bad
    times filter to all MSIDs in a set.
  - Speed up `filter_bad_times()` by using a single mask array over 
    all bad time filters.
  - Add some unit / regression tests

- Ska.Numpy 0.06 to 0.08: speed and lower memory usage with Cython:
  - New function search_both_sorted() that is like np.searchsorted 
    but up to 15 times faster for both input arrays already sorted.
  - Updated function interpolate() that is up to 8 times faster for
    both input X arrays already sorted.

- PyFITS 2.4.0 to 3.0.7

- PyTables 2.2b1 to 2.3.1: efficient table indexing

- Add new module numexpr 2.0.1: allows compiling NumPy expressions
  down to multi-threaded C for very fast execution.

- Other upgrades: argparse, distribute, docutils, Jinja2,
  mpi4py, pep8, pytest, Pygments, Ska.Table, Sphinx, and virtualenv, 

- 32-bit version of NumPy and SciPy built from source (as for  64-bit)

- Minor improvements in build process

Review
------

Notes and testing were reviewed by Jean Connelly.  Command states and module
testing were run independently by Jean.

Build 
-----

REMEMBER to "make install" eng archive!

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

**Ska.quatutil** - ::

  cd ~/hg/Ska.quatutil
  nosetests

**Ska.Shell** - OK::

  cd ~/hg/Ska.Shell
  python test.py

**asciitable** - OK::

  cd ~/git/asciitable
  git checkout 0.8.0
  py.test asciitable/tests

Installation on GRETA network
-------------------------------------

On ccosmos::

  # Create tarfile output for distribution to GRETA (after local testing)
  cd ~/git/skare
  version=`./ska_version.py`
  cd /proj/sot/ska/test
  tar zcf skare-${version}-test.tar.gz bin lib build/*/*/.installed
  tar zcf skare-${version}-test-32.tar.gz arch/i686-linux_CentOS-5 
  tar zcf skare-${version}-test-64.tar.gz arch/x86_64-linux_CentOS-5
  mv skare-${version}*.tar.gz /proj/sot/ska/dist/


Installation on HEAD network
------------------------------------

Copy the skare tar distribution skare-0.11-64.tar.gz to /proj/sot/ska/dist.
::

  # Do everything as aca
  su -l aca

  # Stop all cron jobs
  touch /proj/sot/ska/data/task_schedule/master_heart_attack

  cd /proj/sot/ska/dist
  mkdir skare-0.11-64
  cd skare-0.11-64
  tar xf ../skare-0.11-64.tar.gz

  # preview updates in key areas
  rsync --size-only --dry-run -av bin/ /proj/sot/ska/bin/
  rsync --size-only --dry-run -av lib/ /proj/sot/ska/lib/
  # NO CHANGES

  ls        /proj/sot/ska/dist/skare-0.11-64/
  mv /proj/sot/ska/build/x86_64-linux_CentOS-5{,.bak}
  mv /proj/sot/ska/arch/x86_64-linux_CentOS-5{,.bak}

  cd /proj/sot/ska/dist
  rsync -av /proj/sot/ska/dist/skare-0.11-64/ /proj/sot/ska/ >& install-0.11-64.log 

  # Make modules that cannot be made on virtual machine, e.g. Sybase, and
  # ensure completeness.
  # First clone the skare installer repo, then
  cd /proj/sot/ska/dist
  (ska; git clone ~aldcroft/git/skare)
  cd skare
  git branch # confirm correct branch  
  ./configure --prefix=/proj/sot/ska
  make python_modules

  # TEST per instructions below

  # Allow all cron jobs to resume
  rm /proj/sot/ska/data/task_schedule/master_heart_attack

Installation on GRETA network
------------------------------------

Perform GRETA network installation after a soak period of about one week on the
HEAD network.  Start by copying the skare tar distribution skare-0.11-32.tar.gz
to /proj/sot/ska/dist on the GRETA network.  Then do the installation steps::

  # Do everything as aca
  su -l aca

  # Stop all cron jobs
  crontab -e

  cd /proj/sot/ska/dist
  mkdir skare-0.11-32
  cd skare-0.11-32
  tar xf ../skare-0.11-32.tar.gz

  # preview updates in key areas
  rsync --size-only --dry-run -av bin/ /proj/sot/ska/bin/
  rsync --size-only --dry-run -av lib/ /proj/sot/ska/lib/

  mv /proj/sot/ska/build{,.bak}
  ls /proj/sot/ska/dist/skare-0.11-32/

  # DO THE INSTALL
  rsync -av /proj/sot/ska/dist/skare-0.11-32/ /proj/sot/ska/ >& install.log 

  # Make modules that cannot be made on virtual machine, e.g. Sybase, and
  # ensure completeness.
  make python_modules

  # TEST per instructions below (as applicable for GRETA)

  # Allow all cron jobs to resume
  crontab -e

TEST that shared object python libs are there!!!

Fallback
--------

Only three files are expected to changed (the rest go in a new arch directory): 

- bin/sysarch 
- bin/syspathsubst 
- lib/perl/CXC/Envs/Flight.pm.

Confirm with::

  rsync --dry-run -av /proj/sot/.snapshot/nightly.0/ska/bin/ /proj/sot/ska/bin/
  rsync --dry-run -av /proj/sot/.snapshot/nightly.0/ska/lib/ /proj/sot/ska/lib/

Restore with::

  cp -p /proj/sot/.snapshot/nightly.0/ska/bin/sysarch /proj/sot/ska/bin/
  cp -p /proj/sot/.snapshot/nightly.0/ska/bin/syspathsubst /proj/sot/ska/bin/
  cp -p /proj/sot/.snapshot/nightly.0/ska/lib/perl/CXC/Envs/Flight.pm /proj/sot/ska/lib/perl/CXC/Envs/
  rm -rf /proj/sot/ska/build
  mv /proj/sot/ska/build{.bak,}

Post-install testing 
--------------------

Starcheck
^^^^^^^^^^^^
::

  cd ~/hg/starcheck
  /proj/sot/ska/bin/starcheck -dir AUG0104A -fid_char fid_CHARACTERIS_JUL01 -out test.new
  diff test.7cb31b.txt test.new.txt

==> OK

Eng_archive
^^^^^^^^^^^^
::

  cd ~/hg
  hg clone /proj/sot/ska/hg/eng_archive
  cd eng_archive

Follow the steps for "Regression test for new skare in /proj/sot/ska" in NOTES.test.

==> OK

Commanded states
^^^^^^^^^^^^^^^^^^^
::

  cd ~/hg/timelines
  nosetests

==> PENDING...

psmc_check
^^^^^^^^^^
::

  ska
  cd ~/hg/psmc
  python ./psmc_check.py --run_start_time='2011:001' --outdir regress_ska.new

  diff regress_ska{.new,.7cb31b}/validation_quant.csv

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



