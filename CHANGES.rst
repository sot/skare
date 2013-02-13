Ska Runtime Environment Changes
===========================================

0.14 - 2013-Jan-13
------------------

- Xija 0.2.2 to 0.2.7

  - Provides ACIS PSMC model
  - Uses the new HDF5 cmd states when available
  - Pitch class filters out-of-bounds pitch values

- Ska.engarchive 0.19.1 to 0.21

  - Add three new content types: SIM SEA, EPHIN housekeeping, CPE
  - Numerous infrastructure improvements in ingest and update process.
  - Use weighted mean and stddev for calculating stats.
  - Use float64 to accumulate sum for computing stats mean.
  - Rebuild stats files for the full mission.
  - Fix bug that number of samples for daily stats was incorrect.
  - Add notes and regression testing code for re-building stats files.

- Pyger 0.1.1 to 0.2.1

  - Include the Xija DPA and IPS fuel tank models

- Sherpa installation is 4.4.1 and now includes the full X-ray fitting
  capability

- Add mica 0.1

- Chandra.Time 0.13 to 0.14

  - Add conversion routines that are 4 to 12 times faster when the inputs
    are known to be in a single format.

- IPython 0.12.1 to 0.13.1: major improvements to IPython notebook

- Matplotlib 1.1 to 1.2: http://matplotlib.org/users/whats_new.html

- Other additions / upgrades: Django, BeautifulSoup4, psycopg2,
  virtualenvwrapper, Ska.Matplotlib, requests


0.13 - 2012-Jul-12
------------------

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
