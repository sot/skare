import sys

names = [name for name, mod in sys.modules.items() if 'site-packages' in str(mod)]

comps_list = [name.split('.') for name in sorted(names)]
mods = ['.'.join(comps[:2] if (comps[0] in ('Ska', 'Chandra', 'IPython')) else comps[:1])
        for comps in comps_list]

print(sorted(set(mods)))
