Ska Runtime Environment 0.18
===========================================

.. Build and install this document with:
   rst2html.py --stylesheet=/proj/sot/ska/www/ASPECT/aspect.css \
        --embed-stylesheet NOTES.test-0.18.rst NOTES.test-0.18.html
   cp NOTES.test-0.18.html /proj/sot/ska/www/ASPECT/skare-0.18.html

Summary
---------

Version 0.18-r513 of the Ska Runtime environment is an incremental update to 0.18

Highlights include updates to xija and chandra_models to support acis_fp model changes.



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
Review
------

Notes and testing were reviewed by Jean Connelly.

Build
-------



Installation on GRETA network (flight)
--------------------------------------

On or before live-install day as SOT user::

  # Copy flight installation
  rsync -aruvz  skare-0.18-r460-06aafd2 skare-0.18-r460-06aafd2-copy

On chimchim as FOT CM (chimchim required for local disk access for copy)::

  set version=0.18-r513-d20bade
  cd /proj/sot/ska/arch
  mv skare-0.18-r460-06aafd2-copy skare-${version}
  mkdir skare-${version}

  # do the actual linking
  rm i686-linux_CentOS-5
  rm x86_64-linux_CentOS-5
  ln -s skare-${version}/i686-linux_CentOS-5 ./
  ln -s skare-${version}/x86_64-linux_CentOS-5 ./

  # do the actual update in 32 and 64 bit
  cd ~/git/skare
  git checkout 0.18-r513-d20bade
  ./configure --prefix=$prefix
  make python_modules



Test on GRETA network (flight)
--------------------------------------

Test xija as SOT (32 and 64 bit)::

  ska
  cd
  ipython
  import xija
  xija.test()


Test kadi (32 and 64 bit)
::

  cd ~/git/kadi
  git checkout 0.12.2
  py.test kadi


Check chandra_models version
::

  python
  >>> import chandra_models
  >>> chandra_models.__version__
  '0.7'
