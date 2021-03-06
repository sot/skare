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

Packages
^^^^^^^^^^^

===================  =======  =======  ======================================
Package               0.17     0.18       Comment
===================  =======  =======  ======================================
astropy              0.3      1.0.2
atk                  1.28.0   ---      gtk support removed
atlas                3.8.2    ---      local numerical libraries not needed
autopep8             0.8.7    1.1.1
beautiful soup       3.2.1    4.3.2
cairo                1.8.8    1.12.18
configobj            4.7.2    5.0.6
cython               0.16     0.22
dateutil             1.5      2.1
decorator            ---      3.4.0
fftw                 3.2.1    ---      local numerical libraries not needed
fontconfig           2.7.3    2.11.1
glib                 2.22.2   ---      gtk support removed
gtk+                 2.18.3   ---      gtk support removed
h5py                 ---      2.4.0
ipython              0.13.1   3.1.0
jinja2               2.6      2.7.3
lapack               3.1.1    ---      local numerical libraries not needed
libpng               1.2.5    1.5.13   libpng 1.2.5 was from CentOS not skare
matplotlib           1.2.1    1.4.3
meld                 1.5.1    ---
mpich2               1.4      1.4.1p1
nose                 1.1.2    1.3.4
numexpr              2.0.1    2.2.2
numpy                1.6.2    1.9.2
pandas               ---      0.15.2
pango                1.26.0   ---      gtk support removed
paramiko             1.12.0   1.15.2
pep8                 1.3.3    1.6.2
pexpect              2.4      3.3
pip                  1.4.1    6.0.8
ply                  ---      3.4
psutil               ---      2.2.1
pycairo              1.8.8    ---      gtk support removed
pyds9                1.0      ---
pyfits               3.0.7    3.3
pyflakes             0.5.0    0.8.1
pygments             1.5      2.0.2
pygobject            2.20.0   ---      gtk support removed
pygtk                2.16.0   ---      gtk support removed
pylint               0.25     ---
pyparsing            1.5.5    2.0.3
python               2.7.1    2.7.9
pyyaml               3.10     3.11
pyzmq                2.1.11   14.5.0
requests             1.0.3    2.6.0
runipy               ---      0.1.3
scipy                0.10.1   0.15.1
sherpa               4.4      4.7
stevedore            0.13     ---
six                  1.5.2    1.9.0
sphinx               1.1.3    1.2.3
swig                 1.3.40   ---
virtualenv           1.7.1.2  ---
virtualenvwrapper    3.6      ---
zeromq               2.1.11   4.0.4

Chandra.cmd_states   0.09     0.09.1
Chandra.Maneuver     0.04     0.05
Chandra.Time         1.16.1   3.18
Ska.engarchive       0.28     0.36.2
Ska.Matplotlib       0.11     0.11.1
Ska.quatutil         0.02     0.03
Ska.tdb              0.2      0.3
agasc                0.20     0.30
chandra_models       0.2      0.5
kadi                 0.7      0.12.1
pyyaks               0.3.1    3.3.3
ska_path             ---      0.1
xija                 0.3.4    0.4

CXC::Envs::Flight    1.99     2.01
Ska::AGASC           3.4      3.4.1
Inline::Python       0.43     0.48dev



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

  # Fix libg2c linking as needed
  # Remove libg2c.so link and relink to Ska libg2c.so.0

  # Install applications that are not included in skare
  # The two python modules need to be installed on 32 and 64 bit
  source /proj/sot/ska/dev/bin/ska_envs.sh
  cd ~/git/starcheck
  git checkout 11.4
  python setup.py install
  make install

  cd ~/git/cmd_states
  git checkout master
  make install

  cd ~/git/mica
  git checkout master
  python setup.py install

  cd ~/git/taco
  git checkout master
  make install # doc build broken, so commented out in local install
  # Also note that the esaview wrapper is hard-coded to flight skare

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

==> OK: 64-bit kadi, chimchim and 32-bit quango, gretasot (2015-May-3, TLA)

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

==> OK (64 bit on fido, 5-May JC)
==> OK (32 bit on quango, flight ska fails to load mica.aca_dark or Sybase,
       dev ska fails to load Sybase, which is acceptable, 5-May JC)


Eng_archive
^^^^^^^^^^^^
::

  cd
  skadev
  export ENG_ARCHIVE=/proj/sot/ska/data/eng_archive
  python
  import Ska.engarchive
  Ska.engarchive.test(args='-s')  # skip extended regr test with args='-k "not test_fetch_regr"'

==> OK: (64-bit on kadi, 32-bit on quango, 2015-May-03 TLA)

Note: regression tests originally failed due to (1) np.mean output differences
      and (2) latent failures due to addition of new MSIDs.  Separate tests
      confirmed np.mean diff of O(0.01) for 100000 samples of 32-bit value.  The
      numpy 1.9 behavior is correct, numpy 1.6 had problems.

==> OK: (64-bit on chimchim, 32-bit on gretasot, 2015-May-03 TLA)

Note: Usual GRETA test_fetch_regr for DP_SUN_XZ_ANGLE was seen.

Archive update (ingest) testing::

  cd ~/git/eng_archive

Follow the steps for "Regression test for new skare (..) in $ska/dev" in NOTES.test.

==>  OK: 64-bit on kadi 2015-May-03 TLA

Note: saw a few failures in 5min and daily stats due to np.mean diff.

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

==> OK: (Ran sybase version of tests on fido, 5-May JC)

  # Check cmd_states fetch on quango 32 bit
  python
  >>> from Chandra.cmd_states import fetch_states
  >>> states = fetch_states('2011:100', '2011:101', vals=['obsid', 'simpos'])
  >>> print states[['obsid', 'simpos']]
  [(13255L, 75624L) (13255L, 91272L) (12878L, 91272L)]

===> OK: (5-May JC. A little surprised that obsid displays as a Long,
          but this is also true on 32 bit current ska, so not a regression)

Kadi
^^^^
::
  cd ~/git/kadi
  git checkout master
  cd kadi/tests
  py.test .
  
==> OK: kadi, quango, chimchim, gretasot (TLA 2015-May-3)

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

==> OK: (5-May JC, quango and fido)

**Ska.DBI** -  ::

  cd ~/git/Ska.DBI
  git fetch origin
  py.test test.py

==> OK: (5-May JC, fido.  quango fails with "ImportError: No module named Sybase")

**Quaternion** -  ::

  cd ~/git/Quaternion
  git fetch origin
  nosetests

==> OK: (5-May JC, quango and fido)

**Ska.ftp** -  ::

  cd ~/git/Ska.ftp
  git fetch origin
  py.test

==> OK: (5-May JC, quango and fido.  Doesn't pass tests/test_tar.py
        which is still set up for plain ftp. The test is correctly
        skipped by py.test.)

**Ska.Numpy** -  ::

  cd ~/git/Ska.Numpy
  git fetch origin
  nosetests

==> OK: (5-May JC, quango and fido)

**Ska.ParseCM** -  ::

  cd ~/git/Ska.ParseCM
  git fetch origin
  python test.py

==> OK: (5-May JC, quango and fido)

**Ska.quatutil** -  ::

  cd ~/git/Ska.quatutil
  git fetch origin
  nosetests

==> OK: (5-May JC, quango and fido after Ska.quatutil 0.03 update)

**Ska.Shell** -  ::

  cd ~/git/Ska.Shell
  git fetch origin
  python test.py

==> OK: (5-May JC, quango and fido)

**asciitable** -  ::

  cd ~/git/asciitable
  git checkout 0.8.0
  nosetests

==> Fails on quango: OK on fido (5-May JC)

**esa_view** - ::

  cd
  python /proj/sot/ska/share/taco/esaview.py MAR2513

==> OK: (works quango and fido after Ska.quatutil 0.03 update, 5-May JC)



Post install testing in HEAD /proj/sot/ska
-------------------------------------------

Xija
^^^^^^^^
::

  ska
  cd
  python
  import os
  import xija
  xija.test()

==> OK: 64-bit fido (2015-Jun-3, JC)
==> OK: minusz.npz failure on 32-bit quango, problem with test not xija
        Test needed a local xija checkout.  Worked on 64 bit because of 
        incorrectly-writeable arch site-packages dir on 64-bit arch
        (2015-Jun-3, JC and TLA)

Starcheck
^^^^^^^^^^^^
::

  ska
  /proj/sot/ska/bin/starcheck -dir /data/mpcrit1/mplogs/2015/APR2015/oflsa/ -out new_flight_apr2015a

DIFFS::

  # diff the test version we made in dev testing
  diff test_apr2015a.txt new_flight_apr2015a.txt
  # and diff the flight version that was actually used
  diff /data/mpcrit1/mplogs/2015/APR2015/oflsa/starcheck.txt new_flight_apr2015a.txt
  # And check that plots have been made

==> OK (64 bit on fido, 3-Jun JC)
==> OK (32 bit on quango, fails to load Sybase which is acceptable, 3-Jun JC)


Eng_archive
^^^^^^^^^^^^
::

  cd
  ska
  python
  import Ska.engarchive
  Ska.engarchive.test(args='-s')  # skip extended regr test with args='-k "not test_fetch_regr"'

==> OK: (64-bit on fido 2015-Jun-3 JC)


Timelines/cmd_states
^^^^^^^^^^^^^^^^^^^^^^^
::
  ska
  # Command states scripts and module already installed in skadev
  # cd ~/git/Chandra.cmd_states
  # python setup.py install
  # cd ~/git/cmd_states
  # make install
  cd ~/git/timelines
  # And no need to install to test
  # make install

  nosetests timelines_test.py

==> OK: (Ran sybase version of tests on fido, 3-Jun JC)

  # Check cmd_states fetch on quango 32 bit
  python
  >>> from Chandra.cmd_states import fetch_states
  >>> states = fetch_states('2011:100', '2011:101', vals=['obsid', 'simpos'])
  >>> print states[['obsid', 'simpos']]
  [(13255L, 75624L) (13255L, 91272L) (12878L, 91272L)]

===> OK: (3-Jun JC. A little surprised that obsid displays as a Long,
          but this is also true on 32 bit current ska, so not a regression)

Kadi
^^^^
::
  cd ~/git/kadi
  git checkout master
  cd kadi/tests
  py.test .

==> OK: fido, quango (3-Jun JC)

ACIS thermal load review
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

These were basically run as "run" tests, not diff/regression tests for dpa_check, dea_check, acisfp_check, and
psmc_check.  I did diff against TLA's "test" output from DEV testing in his working skare directory.
Confirmed no errors and plots made for each tool.

==> OK: JC 2015-Jun-03

DPA
~~~~~~~~


  % ska
  % cd ~/git/skare/tests/0.18_install/acis_regression  # Use your own area here
  Run the tool, e.g.
  % python /proj/sot/ska/share/dpa/dpa_check.py \
   --outdir=dpa-feb0413a-flight \
   --oflsdir=/data/mpcrit1/mplogs/2013/FEB0413/oflsa \
   --run-start=2013:031

DEA
~~~~~~~~

  % python /proj/sot/ska/share/dea/dea_check.py \
   --outdir=dea-feb0413a-flight \
   --oflsdir=/data/mpcrit1/mplogs/2013/FEB0413/oflsa \
   --run-start=2013:031


PSMC
~~~~~~~~

  % python /proj/sot/ska/share/psmc_check/psmc_check.py \
   --outdir=psmc-feb0413a-flight \
   --oflsdir=/data/mpcrit1/mplogs/2013/FEB0413/oflsa \
   --run-start=2013:031

ACIS_FP
~~~~~~~~

  % python /proj/sot/ska/share/acisfp/acisfp_check.py \
   --outdir=acisfp-feb0413a-flight \
   --oflsdir=/data/mpcrit1/mplogs/2013/FEB0413/oflsa \
   --run-start=2013:031



Other modules
^^^^^^^^^^^^^

**Ska.Table** -  ::

  cd ~/git/Ska.Table
  git fetch origin
  python test.py

==> OK: (3-Jun JC, quango and fido)

**Ska.DBI** -  ::

  cd ~/git/Ska.DBI
  git fetch origin
  py.test test.py

==> OK: (3-Jun JC, fido.  quango fails with "ImportError: No module named Sybase")

**Quaternion** -  ::

  cd ~/git/Quaternion
  git fetch origin
  nosetests

==> OK: (3-Jun JC, quango and fido)

**Ska.ftp** -  ::

  cd ~/git/Ska.ftp
  git fetch origin
  py.test

==> OK: (3-Jun JC, quango and fido.  Doesn't pass tests/test_tar.py
        which is still set up for plain ftp. The test is correctly
        skipped by py.test.)

**Ska.Numpy** -  ::

  cd ~/git/Ska.Numpy
  git fetch origin
  nosetests

==> OK: (3-Jun JC, quango and fido)

**Ska.ParseCM** -  ::

  cd ~/git/Ska.ParseCM
  git fetch origin
  python test.py

==> OK: (3-Jun JC, quango and fido)

**Ska.quatutil** -  ::

  cd ~/git/Ska.quatutil
  git fetch origin
  nosetests

==> OK: (3-Jun JC, quango and fido after Ska.quatutil 0.03 update)

**Ska.Shell** -  ::

  cd ~/git/Ska.Shell
  git fetch origin
  python test.py

==> OK: (3-Jun JC, quango and fido)

**asciitable** -  ::

  cd ~/git/asciitable
  git checkout 0.8.0
  nosetests

==> Fails on quango: OK on fido (3-Jun JC)

**esa_view** - ::

  cd
  python /proj/sot/ska/share/taco/esaview.py MAR2513

==> OK: (works quango and fido after Ska.quatutil 0.03 update, 3-Jun-2015 JC)



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

Installation on GRETA network (flight)
--------------------------------------

Ensure that the HEAD flight distribution has been installed and tested.

On or before live-install day as SOT user::

  # copy virtual-box built "candidate" directory into a temp directory on chimchim disk
  cd /proj/sot/ska/tmp
  rsync -av jeanconn@ccosmos:/proj/sot/ska/ska_0.18_candidate .
  # this has previously been done in /proj/sot/ska/dist and that would be fine as well


On chimchim as FOT CM (chimchim required for local disk access for copy)::

  set version=0.18-r460-06aafd2
  cd /proj/sot/ska/arch
  mkdir skare-${version}

  rsync -av /proj/sot/ska/tmp/ska_0.18_candidate/arch skare-${version}
  # change these from 'pegasus' group
  chgrp -R fotcm skare-${version}
  chmod g+w -R skare-${version}

  # do the actual linking
  rm i686-linux_CentOS-5
  rm x86_64-linux_CentOS-5
  ln -s skare-${version}/i686-linux_CentOS-5 ./
  ln -s skare-${version}/x86_64-linux_CentOS-5 ./


On GRETA chimchim as SOT

Complete non-arch install::

  cd /proj/sot/ska/lib
  mv perl perl_pre_0.18
  cd /proj/sot/ska/tmp/ska_0.18_candidate
  rsync -av --dry-run lib/perl /proj/sot/ska/lib/
  rsync -av lib/perl /proj/sot/ska/lib/
  rsync -av --dry-run bin/ /proj/sot/ska/bin/
  rsync -av bin/ /proj/sot/ska/bin/
  rsync -av build/ /proj/sot/ska/build/

  # Remove data directories that would be no-ops
  rm -r data/cmd_states
  rm -r data/eng_archive
  rm dir data/pyger

  # Remove kadi data directory as we don't want to update task schedule now
  rm -r data/kadi/

  # Double check remaining data to sync

   SOT@chimchim% tree data
   data
   |-- starcheck
   |   |-- A.tlr
   |   |-- ACABadPixels
   |   |-- B.tlr
   |   |-- aca_spec.json
   |   |-- agasc.bad
   |   |-- bad_acq_stars.rdb
   |   |-- bad_gui_stars.rdb
   |   |-- characteristics.yaml
   |   |-- down.gif
   |   |-- fid_CHARACTERISTICS
   |   |-- fid_CHARACTERIS_FEB07
   |   |-- fid_CHARACTERIS_JAN07
   |   |-- fid_CHARACTERIS_JUL01
   |   |-- overlib.js
   |   |-- tlr.cfg
   |   `-- up.gif
   `-- taco
       |-- task_schedule.cfg
       `-- task_schedule_occ.cfg

  # Sync data
  rsync -av data/ /proj/sot/ska/data/

  # Skip no-op include files
  rm -r include

  # Syncing share, but while this updated files
  # it is also basically a no-op as the running cron task
  # versions of the tasks are being called from /proj/sot/ska/test/share
  rsync -av share/ /proj/sot/ska/share/


==> OK: TLA/JC 2015-Jun-29

Smoke test on chimchim::

  source /proj/sot/ska/bin/ska_envs.csh
  ipython --pylab
  >>> import Ska.engarchive.fetch as fetch
  >>> fetch.__version__
  >>> dat = fetch.Msid('tephin', '2012:001', stat='5min')
  >>> dat.plot()

  >>> from kadi import events
  >>> print events.safe_suns.all()

  >>> import xija
  >>> xija.__version__

==> OK: TLA/JC 2015-Jun-29

Smoke test on snowman::

  source /proj/sot/ska/bin/ska_envs.csh
  ipython --pylab
  >>> import Ska.engarchive.fetch as fetch
  >>> fetch.__version__
  >>> dat = fetch.Msid('tephin', '2012:001', stat='5min')
  >>> dat.plot()

  >>> from kadi import events
  >>> print events.safe_suns.all()

  >>> import xija
  >>> xija.__version__

==> OK: TLA/JC 2015-Jun-29



Test on GRETA network (flight)
--------------------------------------

Test xija as SOT (32 and 64 bit)::

  ska
  cd
  ipython
  import xija
  xija.test()

==> OK: TLA/JC 64 bit, 32 bit  2015-Jun-29

Test eng_archive (32 and 64 bit)::

  ska
  ipython
  import Ska.engarchive
  Ska.engarchive.test()


==> OK: TLA/JC 64 bit, 32 bit but with usual fail on DP_SUN_XZ_ANGLE daily 2015-Jun-29

Test kadi (32 and 64 bit)
::

  cd ~/git/kadi
  git checkout 0.12.2
  py.test kadi

==> OK: TLA/JC 64 bit, 32 bit  2015-Jun-29

ESA view tool (basic functional checkout)::

  # On chimchim only
  ska
  cd
  python /proj/sot/ska/share/taco/esaview.py MAR2513

==> OK: TLA/JC 64 bit 2015-Jun-29

Test starcheck (64 bit)::

  # On chimchim only
  ska
  cd /tmp
  starcheck -dir /home/SOT/tmp/JAN3111C -out test

