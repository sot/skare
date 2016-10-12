"""
One-off code for removing duplicate egg-info files that accrued as a
result of installing with --ignore-installed (which does not remove
previous versions.

Usage:

- Get in the relevant Ska environment

$ python clean_egg_info.py

Then follow the prompts, choosing which egg-info file to KEEP in each case.  All
others will be removed (which each removal requiring confirmation).
"""

from __future__ import print_function

import os
import re
from glob import glob
from collections import defaultdict
import site
import shutil


def get_packages(filenames, as_list=False):
    if as_list:
        pkgs = defaultdict(list)
    else:
        pkgs = {}

    for filename in filenames:
        m = re.match(r'(.+)-\d+\.\d+', filename)
        if not m:
            print('HEJ!', filename)
            continue
        pkg = m.group(1)
        if as_list:
            pkgs[pkg].append(filename)
        else:
            pkgs[pkg] = filename

    return pkgs

pkgs = [fn.strip() for fn in open('pkgs.manifest').readlines()]
pkgs = [pkg for pkg in pkgs if pkg and not pkg.startswith('#')]
pkgs = get_packages(pkgs)

site_dir = site.getsitepackages()[0]
print('site-packages directory: {}'.format(site_dir))

eggs = sorted(glob(os.path.join(site_dir, '*.egg-info')))
eggs = [os.path.basename(egg) for egg in eggs]
eggs = get_packages(eggs, as_list=True)

print('Duplicate egg-info files for:')
for egg in sorted(eggs):
    if len(eggs[egg]) > 1:
        print('  {}'.format(egg))
print()

for egg in sorted(eggs):
    if len(eggs[egg]) > 1:
        for index, basename in enumerate(eggs[egg]):
            print('[{}]: {}'.format(index, basename))
        print('INSTALLED: ', pkgs.get(egg, '???'))
        remove = raw_input('Keep which entry? ')
        try:
            keep_index = int(remove)
        except:
            print('No action taken')
            continue

        for index, basename in enumerate(eggs[egg]):
            if index == keep_index:
                continue

            remove_name = os.path.join(site_dir, basename)
            remove = raw_input('Remove {} [y/N]? '.format(remove_name))
            if remove == 'y':
                if os.path.isfile(remove_name):
                    os.unlink(remove_name)
                else:
                    shutil.rmtree(remove_name)
            else:
                print('Not removing')

        print()
