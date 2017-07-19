import Ska.Shell
import Ska.File

script = """\
echo $PWD
git checkout master
git fetch origin
git merge origin/master
git tag -a {version} -m "Version {version} - Python 3 compatibility"
git push origin --tags
git branch -d py3"""

versions = """\
3.4     https://github.com/sot/agasc/pull/8
3.10    https://github.com/sot/cmd_states/pull/26
3.6     https://github.com/sot/Chandra.Maneuver/pull/5
3.20.1  https://github.com/sot/Chandra.Time/pull/25
3.9     https://github.com/sot/chandra_aca/pull/21
3.11    https://github.com/sot/chandra_models/pull/27
3.1     https://github.com/sot/cxotime/pull/1
3.12.2  https://github.com/sot/kadi/pull/88
3.0     https://github.com/sot/maude/pull/6
3.5.4   https://github.com/sot/mica/pull/91
3.3     https://github.com/sot/parse_cm/pull/14
3.3.4   https://github.com/sot/pyyaks/pull/4
3.4.1   https://github.com/sot/Quaternion/pull/6
3.1.1   https://github.com/sot/Ska.arc5gl/pull/1
3.2.1   https://github.com/sot/Ska.astro/pull/3
3.8.2   https://github.com/sot/Ska.DBI/pull/3
3.41.2  https://github.com/sot/eng_archive/pull/132
3.4.1   https://github.com/sot/Ska.File/pull/4
3.4.2   https://github.com/sot/Ska.ftp/pull/10
3.11.2  https://github.com/sot/Ska.Matplotlib/pull/7
3.8.1   https://github.com/sot/Ska.Numpy/pull/1
3.3.1   https://github.com/sot/Ska.ParseCM/pull/3
3.3.1   https://github.com/sot/Ska.quatutil/pull/2
3.3.1   https://github.com/sot/Ska.Shell/pull/7
3.5     https://github.com/sot/Ska.Sun/pull/4
3.5.1   https://github.com/sot/Ska.tdb/pull/7
3.1     https://github.com/sot/ska_path/pull/1"""

spawn = Ska.Shell.Spawn(shell=True)

for line in versions.splitlines()[5:]:
    version, url = line.split()
    repo = url.split('/')[4]
    print('*********** {} **************'.format(repo))
    dirname = '/home/aldcroft/git/{}'.format(repo)
    cmds = script.format(version=version)

    with Ska.File.chdir(dirname):
        for cmd in cmds.splitlines():
            print(cmd)
            spawn.run(cmd)
    print('******************************'.format(repo))
    print()
