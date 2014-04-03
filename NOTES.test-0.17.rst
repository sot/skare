Ska Runtime Environment 0.17
===========================================

.. Build and install this document with:
   rst2html.py --stylesheet=/proj/sot/ska/www/ASPECT/aspect.css \
        --embed-stylesheet NOTES.test-0.17.rst NOTES.test-0.17.html
   cp NOTES.test-0.17.html /proj/sot/ska/www/ASPECT/skare-0.17.html

Summary
---------

Version 0.17 of the Ska Runtime environment is a significant upgrade for the GRETA
Ska-flight environment (64, 32 bit) and GRETA Ska-test 32-bit.  There were last updated
around April 2013.

Highlights include version 0.7 of Kadi (first production release) and version 0.28 of the
engineering archive (many improvements since the previous 0.22.1).

For the other targets (HEAD Ska-flight-64, GRETA Ska-test-64) there is no update provided
since they have been incrementally updated and tested to correspond to verison 0.17.

Testing overview
^^^^^^^^^^^^^^^^^

Pre-install testing is focused on GRETA Ska-test-32.  This is the test version of the
flight image that will be installed for GRETA / MCC operations.  In addition the
HEAD Ska-flight-32 image that will be directly rsynced to GRETA Ska-flight is also
tested.

Changes from 0.15 (current GRETA Ska flight)
---------------------------------------------

Python
^^^^^^^^^^^

===================  =======  =======  ======================================
Package               0.15     0.17       Comment
===================  =======  =======  ======================================
agasc                   -      0.2
astropy                0.2.1   0.3
chandra_models          -      0.2
Chandra.cmd_states    0.08.1   0.09      Lucky sftp
Chandra.Time          1.15.1   1.16.1    Add plotdate format
Django                1.4.3    1.6.1
ecdsa                   -      0.10      Lucky sftp
kadi                    -      0.7       First production release
paramiko                -      1.12.0    Lucky sftp
pip                     -      1.4.1
pycrypto                -      2.6.1     Lucky sftp
pyyaks                 0.2.1   0.3.1
setuptools              -      2.0.2     Formerly distribute
six                     -      1.5.2     Python 3 compatibility
Ska.engarchive        0.22.1   0.28
Ska.DBI                0.07    0.08
Ska.ftp                0.02    0.04      Lucky sftp
Ska.Matplotlib         0.10    0.11
Ska.Shell              0.01    0.03
Ska.tdb                0.1     0.2       P010 and all previous
stevedore               -      0.13
xija                   0.3.2   0.3.4     Minor fixes, better testing
===================  =======  =======  ======================================

Review
------

Notes and testing were reviewed by Jean Connelly.

Build
-------

/proj/sot/ska/test
^^^^^^^^^^^^^^^^^^

Install skare on 32-bit or 64-bit HEAD CentOS-5 machine.
::

  # Get skare repository on virtual CentOS-5 machine
  cd ~/git/skare
  git fetch
  git checkout 0.17-rc1

  # Choose prefix (dev or flight) and configure
  prefix=/proj/sot/ska/test
  ./configure --prefix=$prefix

  # Make 64 or 32-bit installation
  make all_64  # on CentOS-5 machine
  make all_32  # on quango

  # Create arch link for CentOS-6
  cd /proj/sot/ska/test/arch
  ln -s x86_64-linux_CentOS-5 x86_64-linux_CentOS-6

/proj/sot/ska (32-bit)
^^^^^^^^^^^^^^^^^^^^^^
On quango as aca::

  # Get skare repository on virtual CentOS-5 machine
  cd ~/git/skare
  git fetch
  git checkout 0.17-rc1

  # Choose prefix (dev or flight) and configure
  prefix=/proj/sot/ska
  ./configure --prefix=$prefix

  # Make 32-bit flight installation
  make all_32  # on quango

Installation on GRETA network (test)
-------------------------------------

On HEAD ccosmos::

  skatest
  ska_version  # 0.17-r390-f1e6c5e

Note that 64-bit version is incrementally updated so that the link is actually
from the previous binary install 0.15-r293::

  x86_64-linux_CentOS-5 -> skare-0.15-r293-e754375/x86_64-linux_CentOS-5

On HEAD quango (32-bit)::

  skatest
  ska_version  # 0.17-r390-f1e6c5e

On GRETA chimchim as SOT install new 32-bit binary::

  set version=0.17-r390-f1e6c5e
  mkdir /proj/sot/ska/test/arch/skare-${version}
  rysnc -av aldcroft@ccosmos:/proj/sot/ska/test/arch/i686-linux_CentOS-5 \
                             /proj/sot/ska/test/arch/skare-${version}/

  cd /proj/sot/ska/test/arch
  ls -l  # make sure everything looks good
  ls -l skare-${version}
  rm i686-linux_CentOS-5
  ln -s skare-${version}/i686-linux_CentOS-5 ./

Stub out perl, perldoc::

  cd skare-${version}/i686-linux_CentOS-5/bin
  rm perl*
  ln -s /usr/bin/perl* ./

Confirm that /proj/sot/ska/test/bin/perl and perldoc both point to /usr/bin/ versions.

OK: Mar-6 TLA, JC; Mar-30 TLA

Esa_view
^^^^^^^^

Check that ESA view tool passes basic functional checkout on chimchim (64).
Not supported on 32-bit::

  skatest
  cd
  python /proj/sot/ska/share/taco/esaview.py MAR2513

OK: Mar-28 TLA

Pre-install testing on GRETA in Ska test 32-bit
-----------------------------------------------

Xija
^^^^^^^^
::

  source /proj/sot/ska/test/bin/ska_envs.csh
  cd
  python
  import os
  os.environ['ENG_ARCHIVE'] = '/proj/sot/ska/data/eng_archive'
  import xija
  xija.test()

4 passed, 1 skipped in 4.54 seconds
==> OK: Mar-30 TLA

Starcheck
^^^^^^^^^^^^
Skare 0.17 does not affect starcheck, but for completeness::

  /proj/sot/ska/bin/starcheck -dir /home/SOT/tmp/JAN3111C

==> OK: Mar-30 TLA

Eng_archive
^^^^^^^^^^^^
::

  cd
  skatest
  python
  import Ska.engarchive
  Ska.engarchive.test()

==> OK: Mar-30 TLA with usual regression miscompare for DP_SUN_XZ_ANGLE

Kadi
^^^^^^
::

  cd ~/git/kadi
  git checkout 0.07
  py.test kadi

==> OK: Mar-30 TLA

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
==> OK: Mar-30 TLA

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

==> OK: Mar-30 TLA (regression fully passes)

Kadi
^^^^^^
::

  cd ~/git/kadi
  git checkout 0.07
  py.test kadi

==> OK: Mar-30 TLA


Installation on GRETA network (flight)
--------------------------------------

Ensure that the HEAD flight distribution has been installed and tested.

On GRETA chimchim as SOT::

  set version=0.17-r390-f1e6c5e
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

==> OK: Mar-30 TLA

On chimchim as FOT CM::

  cd /proj/sot/ska/arch
  set version=0.17-r390-f1e6c5e
  mkdir skare-${version}
  ls /proj/sot/ska/dist/skare-${version}
  rsync -av /proj/sot/ska/dist/skare-${version}/ skare-${version}/

  rm i686-linux_CentOS-5
  rm x86_64-linux_CentOS-5
  ln -s skare-${version}/i686-linux_CentOS-5 ./
  ln -s skare-${version}/x86_64-linux_CentOS-5 ./

==> OK: Apr-3 TLA and Brad Bissell

Smoke test on chimchim::

  source /proj/sot/ska/bin/ska_envs.csh
  ska_version  # 0.17-r390-f1e6c5e
  ipython --pylab
  >>> import Ska.engarchive.fetch as fetch
  >>> fetch.__version__
  >>> dat = fetch.Msid('tephin', '2012:001', stat='5min')
  >>> dat.plot()

  >>> from kadi import events
  >>> print events.safe_suns.all()

  >>> import xija
  >>> xija.__version__

==> OK: Apr-3 TLA

Smoke test on snowman::

  source /proj/sot/ska/bin/ska_envs.csh
  ska_version  # 0.17-r390-f1e6c5e
  ipython --pylab
  >>> import Ska.engarchive.fetch as fetch
  >>> fetch.__version__
  >>> dat = fetch.Msid('tephin', '2012:001', stat='5min')
  >>> dat.plot()

  >>> from kadi import events
  >>> print events.safe_suns.all()

  >>> import xija
  >>> xija.__version__

==> OK: Apr-3 TLA

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

==> OK: Apr-3 TLA

Test eng_archive (32 and 64 bit)::

  ska
  ipython
  import Ska.engarchive
  Ska.engarchive.test()


==> OK: Apr-3 TLA

Test kadi (32 and 64 bit)
::

  cd ~/git/kadi
  git checkout 0.07
  py.test kadi

==> OK: Apr-3 TLA


ESA view tool (basic functional checkout)::

  # On chimchim only
  ska
  cd
  python /proj/sot/ska/share/taco/esaview.py MAR2513

==> OK: Apr-3 TLA
