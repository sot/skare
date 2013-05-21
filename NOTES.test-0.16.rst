Ska Runtime Environment 0.16
===========================================

THIS IS THE CURRENTLY-INCOMPLETE version of test / install procedures
for skare-0.16, based on a copy of the 0.15 version.


.. Build and install this document with:
   rst2html.py --stylesheet=/proj/sot/ska/www/ASPECT/aspect.css \
        --embed-stylesheet NOTES.skare-0.14.rst NOTES.skare-0.14.html
   cp NOTES.skare-0.14.html /proj/sot/ska/www/ASPECT/skare-0.14.html

Review
------

Notes and testing were reviewed by Jean Connelly.

Build
-------

/data/fido/reds10
^^^^^^^^^^^^^^^^^^

Install (or git pull) skare on 32-bit or 64-bit virtual CentOS-5 machine.
::

  # Get skare repository on virtual CentOS-5 machine
  cd ~/git/skare
  git fetch
  git checkout centos_rc1

  # Choose prefix (dev or flight) and configure
  prefix=/data/fido/reds10
  ./configure --prefix=$prefix

  # Make 64 or 32-bit installation
  make all_64  # on CentOS-5 machine
  make all_32  # on quango

  # Create arch link for CentOS-6
  cd /data/fido/reds10/arch
  ln -s x86_64-linux_CentOS-5 x86_64-linux_CentOS-6


Additional setup detail:

This release hits how the runtime environment works with the ASCDS
environment.  As Ska.arc5gl is hard-coded to run
/proj/sot/ska/bin/arc5gl, which is, in turn, hard-coded to call
/proj/sot/ska/bin/perl, a local path edit was performed in the test
skare to call arc5gl from the test perl.  The test copy of Ska.arc5gl
was edited to call "arc5gl" instead of "/proj/sot/ska/bin/arc5gl", and
/proj/sot/ska/bin/arc5gl was copied into $SKA/bin with an edited
top-line to use whatever perl is in the path.


Pre-install testing in Ska test
----------------------------------------

Scientific Python
^^^^^^^^^^^^^^^^^
::

  python -c "import numpy; numpy.test()"
  OK (KNOWNFAIL=5)

  python -c "import numpy; import scipy; scipy.test()"
  OK (KNOWNFAIL=13, SKIP=41)

Perl Plotting
^^^^^^^^^^^^^
Manually ran PGPLOT and PDL "make test" in those build directories.


Xija
^^^^^^^^
::

  source /data/fido/reds10/bin/ska_envs.csh
  cd
  python
  import os
  os.environ['ENG_ARCHIVE'] = '/proj/sot/ska/data/eng_archive'
  import xija
  xija.test()

4 passed, 1 skipped in 4.54 seconds
==> OK

Starcheck
^^^^^^^^^^^^
::

  # on c3po-v, testing CentOS 6
  source /data/fido/reds10/bin/ska_envs.csh
  cd ~/git/starcheck
  git checkout 10.0
  setenv APP_ENV_ASCDS_STR \
  "/proj/cm/Release/install.linux64.DS10/config/system/.ascrc \
  -r /proj/cm/Release/install.linux64.DS10"
  make regress
  mv regress/90ece962c9f598078f62b6d1c0ef74b35680dc95 regress/c3po-v_ds10
  unsetenv APP_ENV_ASCDS_STR
  make regress
  mv regress/90ece962c9f598078f62b6d1c0ef74b35680dc95 regress/c3po-v_ds85

  # on fido, confirming back-compatible CentOS 5
  make regress
  mv regress/90ece962c9f598078f62b6d1c0ef74b35680dc95 regress/fido_ds85

==> OK 

In this testing, starcheck's calls to mp_get_agasc have been tested on
the expected platforms and DS releases:

   * CentOS-6 DS10
   * CentOS-6 DS8.5
   * CentOS-5 DS8.5

The regression outputs for each reveal no regressions.

(The "release" products needed to be present for these tests work
(starcheck/regress/release at the time), as the
from-scratch method of regression testing calls
/proj/sot/ska/bin/starcheck.pl to run the "flight" code from the same
machine as the test code.  Since the flight code needed to be run from
CentOS 5 and the test code was running from CentOS 6, I used a
pre-existing copy of the release outputs and checked the diffs. JMC)

arc5gl
^^^^^^^
::

  # on c3po-v
  echo $APP_ENV_ASCDS_STR
  /proj/cm/Release/install.linux64.DS10/config/system/.ascrc -r
  /proj/cm/Release/install.linux64.DS10

  perl /proj/sot/ska/bin/arc5gl

  ARC5GL> obsid = 2121
  ARC5GL> get asp1{fidprops}
  Retrieved files:
  pcadf090549491N003_fidpr1.fits.gz

  unsetenv APP_ENV_ASCDS_STR
  perl /proj/sot/ska/bin/arc5gl

  ARC5GL> obsid=1426
  ARC5GL> get asp1{fidprops}
  Retrieved files:
  pcadf057297145N004_fidpr1.fits.gz


  # on fido
  echo $SKA

  /data/fido/reds10

  perl /proj/sot/ska/bin/arc5gl

  ARC5GL> obsid=14206
  ARC5GL> get asp1{gsprops}
  Retrieved files:
  pcadf485360268N002_gspr1.fits.gz

==> OK (JC)

Aspect Pipeline
^^^^^^^^^^^^^^^^

Ran the DS10 CentOS-6 aspect pipeline on one obsid (14206) to confirm
that it runs::

  flt_run_pipe -i ./ASP_L1_STD_485360268/in1 \
    -o ./ASP_L1_STD_485360268/out1 \
    -r f485360268 -t asp_l1_std.ped \
    -a "INTERVAL_START"=485360268.701222 \
    -a "INTERVAL_STOP"=485422452.37959 \
    -a obiroot=f14206_000N001 -a revision=1

==> OK (JC)


Eng_archive
^^^^^^^^^^^^
::

  cd
  skatest
  python
  import Ska.engarchive
  Ska.engarchive.test()


OK

Haven't done: "Follow the steps for "Regression test for new skare (..) in $ska/dev" in NOTES.test."



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
  cd ~/git/starcheck
  make install
  # timelines needed Ska::Parse_CM_File from starcheck
 
  nosetests timelines_test.py

==> OK (JC)
(ran this in both sqlite and sybase modes)


ACIS thermal load review
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Test for for dpa_check, dea_check, acisfp_check, and psmc_check

==> OK (

DPA
~~~~~~~~

Window 1 (FLIGHT on fido)::

  % source /proj/sot/ska/bin/ska_envs.csh
  % cd ~/git/skare/tests/0.16/acis_regression  # Use your own area here
  Run the tool, e.g.
  % python /proj/sot/ska/share/dpa/dpa_check.py \
   --outdir=dpa-feb0413a-flight \
   --oflsdir=/data/mpcrit1/mplogs/2013/FEB0413/oflsa \
   --run-start=2013:031

Window 2 (TEST on c3po-v)::

  % cd ~/git/skare/tests/0.16/acis_regression  # Use your own area here
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

Window 1 (FLIGHT on fido)::

  % python /proj/sot/ska/share/dea/dea_check.py \
   --outdir=dea-feb0413a-flight \
   --oflsdir=/data/mpcrit1/mplogs/2013/FEB0413/oflsa \
   --run-start=2013:031

Window 2 (TEST on c3po-v)::

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

Window 1 (FLIGHT on fido)::

  % python /proj/sot/ska/share/psmc_check/psmc_check.py \
   --outdir=psmc-feb0413a-flight \
   --oflsdir=/data/mpcrit1/mplogs/2013/FEB0413/oflsa \
   --run-start=2013:031

Window 2 (TEST on c3po-v)::

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

Window 1 (FLIGHT on fido)::

  % python /proj/sot/ska/share/acisfp/acisfp_check.py \
   --outdir=acisfp-feb0413a-flight \
   --oflsdir=/data/mpcrit1/mplogs/2013/FEB0413/oflsa \
   --run-start=2013:031

Window 2 (TEST on c3po-v)::

  % python /proj/sot/ska/share/acisfp/acisfp_check.py \
   --outdir=acisfp-feb0413a-test \
   --oflsdir=/data/mpcrit1/mplogs/2013/FEB0413/oflsa \
   --run-start=2013:031

DIFFS::

  % diff acisfp-feb0413a-flight/index.rst acisfp-feb0413a-test/index.rst
  % diff acisfp-feb0413a-flight/temperatures.dat \
         acisfp-feb0413a-test/temperatures.dat



Other modules
^^^^^^^^^^^^^

**Ska.Table** -  ::

  cd ~/git/Ska.Table
  python test.py

Ran 4 tests in 2.280s
==> OK (JC)

**Ska.DBI** -  ::

  cd ~/git/Ska.DBI
  python test.py

Ran 56 tests in 3.858s
==> OK (JC)

**Quaternion** -  ::

  cd ~/git/Quaternion
  git fetch origin
  nosetests

Ran 8 tests in 0.971s
==> OK (NC)

**Ska.ftp** -  ::

  cd ~/git/Ska.ftp
  git fetch origin
  nosetests

Ran 2 tests in 1.355s
FAILED (errors=2)
==> NOT OK (JC)

**Ska.Numpy** -  ::

  cd ~/git/Ska.Numpy
  git fetch origin
  nosetests

NameError: global name 'fastss' is not defined
Ran 6 tests in 1.071s
FAILED (errors=2)
==> NOT OK (JC)

**Ska.ParseCM** -  ::

  cd ~/hg/Ska.ParseCM
  hg incoming
  python test.py

Ran 4 tests in 25.038s
==> OK (JC)

**Ska.quatutil** -  ::

  cd ~/hg/Ska.quatutil
  hg incoming
  nosetests

Ran 4 tests in 0.497s
==> OK (JC)

**Ska.Shell** -  ::

  cd ~/hg/Ska.Shell
  hg incoming
  python test.py

Ran 6 tests in 1.404s
==> OK (JC)

**asciitable** -  ::

  cd ~/git/asciitable
  git checkout 0.8.0
  nosetests

Ran 106 tests in 3.868s
==> OK (JC)

**esa_view** - ::

  cd
  python /proj/sot/ska/share/taco/esaview.py MAR2513

==> Doesn't crash. (JC)

