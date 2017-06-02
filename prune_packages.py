import re
import glob
import shutil
from collections import defaultdict
from distutils.version import LooseVersion

# Max number of versions to keep
N_KEEP = 2

pkgs = defaultdict(list)

files = glob.glob('/proj/sot/ska/pkgs/*.tar.gz')
for f in files:
    m = re.search(r'(.+)-([0-9.]+).tar.gz', f)
    if m:
        name, version = m.groups()
        pkgs[name].append((version, f))


for name, versions in pkgs.items():
    versions = sorted(versions, key=lambda x: LooseVersion(x[0]))
    for version, f in versions[:-N_KEEP]:
        print('Moving {}'.format(f))
        shutil.move(f, '/proj/sot/ska/pkgs/OLD/')
