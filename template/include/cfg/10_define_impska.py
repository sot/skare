ip = get_ipython()


def import_ska(self, arg):
    ip.ex('import asciitable')
    ip.ex('import Ska.engarchive.fetch_eng as fetch')
    ip.ex('from Chandra.Time import DateTime')
    ip.ex('from Ska.Matplotlib import plot_cxctime, cxctime2plotdate')
    ip.ex('from kadi import events')
    ip.ex('from astropy.table import Table')

ip.define_magic('impska', import_ska)
