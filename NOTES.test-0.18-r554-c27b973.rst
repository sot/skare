Ska Runtime Environment 0.18-r554-c27b973
===========================================


Summary
---------

Version 0.18-r554-c27b973 of the Ska Runtime environment is a small update that includes
updates to the Perl and Python modules that handle time. It is intended to support the
leap second at the end of 2016.  It also includes a small change in the Python module
install process, as "pip" is now used instead of "python setup.py install".

PR
--
https://github.com/sot/skare/pull/92/files


Changes from 0.18-r546
---------------------------------------------

Package Changes
^^^^^^^^^^^

(This is a diff of packages with defined versions in pkgs.manifest or pkgs.conda.  Conda
packages not in this list are also installed and may have incremented versions.  Efforts
were made to pin/freeze packages at their current versions to avoid version or build creep.)

===================  =======  =======  ======================================
Package               r546     r554       Comment
===================  =======  =======  ======================================
Chandra.Time          3.19     3.20
Chandra-Time          0.09.1   0.9.2
XTime                 1.2.1    1.2.2

testr                 ---      0.1
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
  git checkout greta_2016_322

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
  mkdir /proj/sot/ska/tmp/skadev-0.18-r554 # on HEAD
  rsync -aruvz 32.tar jeanconn@fido:/proj/sot/ska/tmp/skadev-0.18-r554 # 32 bit VM
  rsync -aruvz 64.tar jeanconn@fido:/proj/sot/ska/tmp/skadev-0.18-r554 # 32 bit VM

  # Rsync from ccosmos to GRETA tmp on machine chimchim
  mkdir /proj/sot/ska/tmp/skadev-0.18-r554 # on GRETA
  cd /proj/sot/ska/tmp/skadev-0.18-r554
  rsync -aruv jeanconn@ccosmos:/proj/sot/ska/tmp/skadev-0.18-r554/\*tar .
  tar -xvpf 32.tar
  tar -xvpf 64.tar
  # remove no-longer needed tarballs
  rm 32.tar
  rm 64.tar

  # Rsync arch into /proj/sot/ska/dev/arch, link, and rsync the other pieces as needed
  cd /proj/sot/ska/dev/arch
  mkdir skadev-0.18-r554-c27b973
  rsync -aruv /proj/sot/ska/tmp/skadev-0.18-r554/arch/\* skadev-0.18-r554-c27b973

  # Create arch links
  cd /proj/sot/ska/dev/arch
  rm x86_64-linux_CentOS-5
  rm x86_64-linux_CentOS-6
  rm i686-linux_CentOS-5
  ln -s skadev-0.18-r554-c27b973/x86_64-linux_CentOS-5 .
  ln -s skadev-0.18-r554-c27b973/i686-linux_CentOS-5 .
  ln -s x86_64-linux_CentOS-5 x86_64-linux_CentOS-6

  # Update other pieces; perl and build are sufficient for dev
  cd /proj/sot/ska/dev/lib
  mv perl perl_bak
  rsync -aruv /proj/sot/ska/tmp/skadev-0.18-r554/lib/perl .
  cd /proj/sot/ska/dev
  rm -r build
  rsync -aruvz /proj/sot/ska/tmp/skadev-0.18-r554/build .



Testing in GRETA dev
----------------------------------------

Chandra.Time
^^^^^^^^^^^^
::

  skadev
  cd
  python
  import Chandra.Time
  Chandra.Time__version__
  '3.20'


==> OK: chimchim, gretasot

