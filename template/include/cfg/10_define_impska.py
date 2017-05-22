from IPython.core.magic import Magics, magics_class, line_magic
from IPython import get_ipython

ip = get_ipython()


@magics_class
class MyMagics(Magics):
    @line_magic
    def impska(self, line):
        ip.ex('import Ska.engarchive.fetch_eng as fetch')
        ip.ex('from Chandra.Time import DateTime')
        ip.ex('from Ska.Matplotlib import plot_cxctime, cxctime2plotdate')
        ip.ex('from kadi import events')
        ip.ex('from astropy.table import Table')
        ip.ex('import numpy as np')
        ip.ex('import matplotlib.pyplot as plt')
        ip.ex('from Ska.tdb import msids')

ip.register_magics(MyMagics)
