Ska runtime environment
========================

Directory structure
--------------------

**Arch dependent installation**
::

  arch/
    +-- i686-linux_CentOS-5/
    +-- x86_64-linux_CentOS-5/
    |   +-- bin/
    |   +-- doc/
    |   +-- etc/
    |   +-- include/
    |   +-- lib/
    |   |   +-- python2.7/
    |   +-- lib64/
    |   +-- libexec/
    |   +-- pgplot/
    |   +-- pkgs.manifest
    |   +-- sbin/
    |   +-- share/
    |   +-- var/

**Arch independent scripts**
::

  bin/  
    +-- flt_envs
    +-- ipython
    +-- perl
    +-- perldoc
    +-- python
    +-- ska_envs.csh
    +-- ska_envs.sh
    +-- sysarch
    +-- syspathsubst
    +-- ... many Ska application scripts and launchers

**Build Ska runtime environment (mostly) from source**
::

  build/  
    +-- i686-linux_CentOS-5/
    +-- x86_64-linux_CentOS-5/

**Project or task data**
::

  data/  
    +-- aca_bgd_mon/
    +-- aca_dark_cal/
    +-- aca_dark_cal_checker/
    +-- aca_egse/
    +--   ...
    +-- eng_archive/
    +--   ...
    +-- psmc/
    +--   ...
    +-- taco/
    +-- telem_archive/

**Complete Ska runtime environment for development**
::

  dev/  
    +-- arch/
    +-- bin/
    +-- build/
    +-- data/
    +-- doc/
    +-- idl/
    +-- include/
    +-- lib/
    +-- ops/
    +-- pkgs@ -> ../pkgs
    +-- share/
    +-- www/

**Project documentation**
::

  doc/  
    +-- cmd_states/
    +-- eng_archive/
    +--  ...

**Global includes**
::

  include/
    +-- Makefile.FLIGHT
    +-- SKA_MAKE_DEFAULTS
    +-- Task_template/

**Global libraries but in reality just perl**
::

  lib/
    +-- perl/
        +--  ... <arch independent perl libraries>
        +-- i386-linux-thread-multi/
        +-- x86_64-linux-gnu-thread-multi/
        +-- x86_64-linux-thread-multi/

**Source / binary tarballs for entire Ska runtime environment**
::

  pkgs/
    +-- ActivePython-2.7.1.4-linux-x86.tar.gz
    +-- ActivePython-2.7.1.4-linux-x86_64.tar.gz
    +-- Alien-SVN-1.6.12.0.tar.gz
    +-- App-Env-0.25.tar.gz
    +-- App-Env-ASCDS-0.01.tar.gz
    +-- ...  

**Project scripts and files**
::

  share/
    +-- aca_bgd_mon/
    +-- aca_dark_cal/
    +-- aca_egse/
    +--  ...

