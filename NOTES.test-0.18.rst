Ska Runtime Environment 0.18
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

Changes from 0.17 (current GRETA Ska flight)
---------------------------------------------

Python
^^^^^^^^^^^

===================  =======  =======  ======================================
Package               0.17     0.18       Comment
===================  =======  =======  ======================================
  ...                  ...     ...        ....
===================  =======  =======  ======================================

Review
------

Notes and testing were reviewed by Jean Connelly.

Build
-------

/proj/sot/ska/dev
^^^^^^^^^^^^^^^^^^

Install skare on 32-bit or 64-bit HEAD CentOS-5 machine.
::

  # Get skare repository on virtual CentOS-5 machine
  cd ~/git/skare
  git fetch
  git checkout skare-0.18

  # Choose prefix (dev or flight) and configure
  prefix=/proj/sot/ska/dev
  ./configure --prefix=$prefix

  # Make 64 or 32-bit installation
  make all_64  # on CentOS-5 machine
  make all_32  # on quango

  # Create arch link for CentOS-6
  cd /proj/sot/ska/dev/arch
  ln -s x86_64-linux_CentOS-5 x86_64-linux_CentOS-6

/proj/sot/ska (32-bit)
^^^^^^^^^^^^^^^^^^^^^^
On quango as aca::

  # Get skare repository on virtual CentOS-5 machine
  cd ~/git/skare
  git fetch
  git checkout skare-0.18

  # Choose prefix (dev or flight) and configure
  prefix=/proj/sot/ska
  ./configure --prefix=$prefix

  # Make 32-bit flight installation
  make all_32  # on quango

Pre-install testing in Ska dev
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
  xija.test()

==> OK:

Starcheck
^^^^^^^^^^^^
::

Window 1 (DEV)::

  skadev
  cd ~/git/starcheck
  git checkout 11.4
  setenv ENG_ARCHIVE /proj/sot/ska/data/eng_archive
  cp /proj/sot/ska/data/cmd_states/cmd_states.h5 /proj/sot/ska/dev/data/cmd_states/
  # Run the tool, e.g.
  ./sandbox_starcheck -dir /data/mpcrit1/mplogs/2015/APR2015/oflsa/ -out test_apr2015a

Window 2 (FLIGHT)::

  ska
  /proj/sot/ska/bin/starcheck -dir /data/mpcrit1/mplogs/2015/APR2015/oflsa/ -out flight_apr2015a

DIFFS::

  diff flight_apr2015a.txt test_apr2015a.txt
  # And check that plots have been made

==> OK (64 bit on fido, 1-May JC)
==> OK (32 bit on quango, flight ska fails to load mica.aca_dark or Sybase,
       dev ska fails to load Sybase, which is acceptable, 1-May JC)


Eng_archive
^^^^^^^^^^^^
::

  cd
  skadev
  python
  import Ska.engarchive
  Ska.engarchive.test()

  cd ~/git/eng_archive

Follow the steps for "Regression test for new skare (..) in $ska/dev" in NOTES.test.

==>  OK:

Timelines/cmd_states
^^^^^^^^^^^^^^^^^^^^^^^
::
  skadev
  # Command states scripts and module already installed in skadev
  # cd ~/git/Chandra.cmd_states
  # python setup.py install
  # cd ~/git/cmd_states
  # make install
  cd ~/git/timelines
  # And no need to install to test
  # make install

  nosetests timelines_test.py

==> OK: (Ran sybase version of tests on fido, 1-May JC)

  # Check cmd_states fetch on quango 32 bit
  python
  >>> from Chandra.cmd_states import fetch_states
  >>> states = fetch_states('2011:100', '2011:101', vals=['obsid', 'simpos'])
  >>> print states[['obsid', 'simpos']]
  [(13255L, 75624L) (13255L, 91272L) (12878L, 91272L)]

===> OK: (1-May JC. A little surprised that obsid displays as a Long)


ACIS thermal load review
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Test for for dpa_check, dea_check, acisfp_check, and psmc_check

==> OK: TLA 2015-Apr-30

DPA
~~~~~~~~

Window 1 (FLIGHT)::

  % source /proj/sot/ska/bin/ska_envs.csh
  % cd ~/git/skare/tests/0.15/acis_regression  # Use your own area here
  Run the tool, e.g.
  % python /proj/sot/ska/share/dpa/dpa_check.py \
   --outdir=dpa-feb0413a-flight \
   --oflsdir=/data/mpcrit1/mplogs/2013/FEB0413/oflsa \
   --run-start=2013:031

Window 2 (TEST)::

  % cd ~/git/skare/tests/0.15/acis_regression  # Use your own area here
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

Window 2 (DEV)::

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

Window 2 (DEV)::

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

Window 2 (DEV)::

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

==> OK: (1-May JC, quango and fido)

**Ska.DBI** -  ::

  cd ~/git/Ska.DBI
  git fetch origin
  py.test test.py

==> OK: (1-May JC, fido.  quango fails with "ImportError: No module named Sybase")

**Quaternion** -  ::

  cd ~/git/Quaternion
  git fetch origin
  nosetests

==> OK: (1-May JC, quango and fido)

**Ska.ftp** -  ::

  cd ~/git/Ska.ftp
  git fetch origin
  nosetests

==> Not OK:

**Ska.Numpy** -  ::

  cd ~/git/Ska.Numpy
  git fetch origin
  nosetests

==> OK: (1-May JC, quango and fido)

**Ska.ParseCM** -  ::

  cd ~/git/Ska.ParseCM
  git fetch origin
  python test.py

==> OK: (1-May JC, quango and fido)

**Ska.quatutil** -  ::

  cd ~/git/Ska.quatutil
  git fetch origin
  nosetests

==> Not OK:

**Ska.Shell** -  ::

  cd ~/git/Ska.Shell
  git fetch origin
  python test.py

==> OK: (1-May JC, quango and fido)

**asciitable** -  ::

  cd ~/git/asciitable
  git checkout 0.8.0
  nosetests

==> Fails on quango: OK on fido (1-May JC)

**esa_view** - ::

  cd
  python /proj/sot/ska/share/taco/esaview.py MAR2513

==> Not OK (due to Ska.quatutil errors, 1-May JC)

Installation on GRETA network (dev)
-------------------------------------

On HEAD ccosmos::

  skadev
  ska_version  # 0.18-r442-7a8c037

Note that 64-bit version is incrementally updated so that the link is actually
from the previous binary install 0.15-r293::

  x86_64-linux_CentOS-5 -> skare-0.15-r293-e754375/x86_64-linux_CentOS-5

On HEAD quango (32-bit)::

  skadev
  ska_version  # 0.18-r442-7a8c037

On GRETA chimchim as SOT install new 32-bit binary::

  set version=0.18-r442-7a8c037
  mkdir /proj/sot/ska/dev/arch/skare-${version}
  rysnc -av aldcroft@ccosmos:/proj/sot/ska/dev/arch/i686-linux_CentOS-5 \
                             /proj/sot/ska/dev/arch/skare-${version}/

  cd /proj/sot/ska/dev/arch
  ls -l  # make sure everything looks good
  ls -l skare-${version}
  rm i686-linux_CentOS-5
  ln -s skare-${version}/i686-linux_CentOS-5 ./

Stub out perl, perldoc::

  cd skare-${version}/i686-linux_CentOS-5/bin
  rm perl*
  ln -s /usr/bin/perl* ./

Confirm that /proj/sot/ska/dev/bin/perl and perldoc both point to /usr/bin/ versions.

OK:

Esa_view
^^^^^^^^

Check that ESA view tool passes basic functional checkout on chimchim (64).
Not supported on 32-bit::

  skadev
  cd
  python /proj/sot/ska/share/taco/esaview.py MAR2513

OK:

Pre-install testing on GRETA in Ska dev 32-bit
-----------------------------------------------

Xija
^^^^^^^^
::

  source /proj/sot/ska/dev/bin/ska_envs.csh
  cd
  python
  import os
  os.environ['ENG_ARCHIVE'] = '/proj/sot/ska/data/eng_archive'
  import xija
  xija.test()

4 passed, 1 skipped in 4.54 seconds
==> OK:

Starcheck
^^^^^^^^^^^^
Skare 0.18 does not affect starcheck, but for completeness::

  /proj/sot/ska/bin/starcheck -dir /home/SOT/tmp/JAN3111C

==> OK:

Eng_archive
^^^^^^^^^^^^
::

  cd
  skadev
  python
  import Ska.engarchive
  Ska.engarchive.test()

==> OK:

Kadi
^^^^^^
::

  cd ~/git/kadi
  git checkout 0.07
  py.test kadi

==> OK:

Pre-install testing on HEAD in Ska flight 32-bit
------------------------------------------------

Xija
^^^^^^^^
::

  source /proj/sot/ska/bin/ska_envs.csh
  cd
  python
  import os
  os.environ['ENG_ARCHIVE'] = '/proj/sot/ska/data/eng_archive'
  import xija
  xija.__version__  # 0.3.4
  xija.test()

4 passed, 1 skipped in 4.54 seconds
==> OK:

Eng_archive
^^^^^^^^^^^^
::

  source /proj/sot/ska/bin/ska_envs.csh
  cd
  python
  import Ska.engarchive
  import Ska.engarchive.fetch
  Ska.engarchive.__version__  # 0.28
  Ska.engarchive.test()

==> OK:

Kadi
^^^^^^
::

  cd ~/git/kadi
  git checkout 0.07
  py.test kadi

==> OK:


Installation on GRETA network (flight)
--------------------------------------

Ensure that the HEAD flight distribution has been installed and tested.

On GRETA chimchim as SOT::

  set version=0.18-r442-7a8c037
  cd /proj/sot/ska/dist
  mkdir skare-${version}
  rsync -azv aldcroft@ccosmos:/proj/sot/ska/arch/x86_64-linux_CentOS-5/ \
        skare-${version}/x86_64-linux_CentOS-5/
  rsync -azv aldcroft@ccosmos:/proj/sot/ska/arch/i686-linux_CentOS-5/ \
        skare-${version}/i686-linux_CentOS-5/

Stub out perl, perldoc::

  cd /proj/sot/ska/dist/skare-${version}/i686-linux_CentOS-5/bin
  rm perl*
  ln -s /usr/bin/perl* ./

  cd /proj/sot/ska/dist/skare-${version}/x86_64-linux_CentOS-5/bin
  rm perl*
  ln -s /usr/bin/perl* ./

 - Confirm that /proj/sot/ska/bin/perl and perldoc both point to /usr/bin/ versions.

==> OK:

On chimchim as FOT CM::

  cd /proj/sot/ska/arch
  set version=0.18-r442-7a8c037
  mkdir skare-${version}
  ls /proj/sot/ska/dist/skare-${version}
  rsync -av /proj/sot/ska/dist/skare-${version}/ skare-${version}/

  rm i686-linux_CentOS-5
  rm x86_64-linux_CentOS-5
  ln -s skare-${version}/i686-linux_CentOS-5 ./
  ln -s skare-${version}/x86_64-linux_CentOS-5 ./

==> OK:

Smoke test on chimchim::

  source /proj/sot/ska/bin/ska_envs.csh
  ska_version  # 0.18-r442-7a8c037
  ipython --pylab
  >>> import Ska.engarchive.fetch as fetch
  >>> fetch.__version__
  >>> dat = fetch.Msid('tephin', '2012:001', stat='5min')
  >>> dat.plot()

  >>> from kadi import events
  >>> print events.safe_suns.all()

  >>> import xija
  >>> xija.__version__

==> OK:

Smoke test on snowman::

  source /proj/sot/ska/bin/ska_envs.csh
  ska_version  # 0.18-r442-7a8c037
  ipython --pylab
  >>> import Ska.engarchive.fetch as fetch
  >>> fetch.__version__
  >>> dat = fetch.Msid('tephin', '2012:001', stat='5min')
  >>> dat.plot()

  >>> from kadi import events
  >>> print events.safe_suns.all()

  >>> import xija
  >>> xija.__version__

==> OK:

Fallback::

  set version=0.15-r293-e754375
  cd /proj/sot/ska/arch
  rm i686-linux_CentOS-5
  rm x86_64-linux_CentOS-5
  ln -s skare-${version}/i686-linux_CentOS-5 ./
  ln -s skare-${version}/x86_64-linux_CentOS-5 ./


Test on GRETA network (flight)
--------------------------------------

Test xija as SOT (32 and 64 bit)::

  ska
  cd
  ipython
  import xija
  xija.test()

==> OK:

Test eng_archive (32 and 64 bit)::

  ska
  ipython
  import Ska.engarchive
  Ska.engarchive.test()


==> OK:

Test kadi (32 and 64 bit)
::

  cd ~/git/kadi
  git checkout 0.07
  py.test kadi

==> OK:


ESA view tool (basic functional checkout)::

  # On chimchim only
  ska
  cd
  python /proj/sot/ska/share/taco/esaview.py MAR2513

==> OK: Apr-3 TLA
