

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
flight image that will be installed for GRETA / MCC operations.


Changes from 0.18 (current GRETA Ska flight)
---------------------------------------------

Packages
^^^^^^^^^^^

===================  =======  ==========  ======================================
Package               0.18     0.18-r513       Comment
===================  =======  ==========  ======================================
chandra_models       0.5      0.7
Chandra.Time         3.18     3.19
kadi                 0.12.1   0.12.2
Ska.report_ranges    0.01     0.2
xija                 0.4      0.6

Chandra-Time         0.09     0.09.1

XTime                1.2.0    1.2.1
===================  =======  ==========  ======================================


Review
------

Notes and testing were reviewed by Tom Aldcroft and Jean Connelly.

Build
-------



Installation on GRETA network (flight)
--------------------------------------

On or before live-install day as SOT user::

On chimchim as FOT CM (chimchim required for local disk access for copy)::

  set version=0.18-r513-d20bade
  cd /proj/sot/ska/arch
  rsync -aruv skare-0.18-r460-06aafd2/ skare-${version}

  # do the actual linking
  rm i686-linux_CentOS-5
  rm x86_64-linux_CentOS-5
  ln -s skare-${version}/i686-linux_CentOS-5 ./
  ln -s skare-${version}/x86_64-linux_CentOS-5 ./

  # do the actual update in 32 and 64 bit
  cd ~/git/skare
  git checkout ${version}
  ./configure --prefix=$prefix
  make xtime
  make python_modules
  make perl_modules


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

Run models
::

  cd ~/git/chandra_models
  git checkout 0.7
  ipython --matplotlib
  > run xija/acisfp/calc_model.py
  > run xija/psmc/calc_model.py
