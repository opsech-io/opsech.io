Title: Creating Python 3 Virtual Environments on Centos 7
Category: linux
Tags: python, linux, centos7, python3
Date: Tue Sep 6 12:21:00 EDT 2016
Status: published

### Problems

There's a bug presently in CentOS 7's python2 `virtualenv` package that breaks the ability to create python 3 virtual envs with the `python3` binary (_from package `python34` in EPEL_), making [these otherwise useful instructions](https://blog.teststation.org/centos/python/2016/05/11/installing-python-virtualenv-centos-7) no longer viable.

[This bug in the virtualenv package](https://github.com/pypa/virtualenv/issues/463) prevents you from using it with the `-p python3` switch, and ends in something like this:

    :::text
    ImportError: No module named '_collections_abc'
    ERROR: The executable fo/bin/python3 is not functioning
    ERROR: It thinks sys.prefix is '/home/centos' (should be '/home/centos/foo')
    ERROR: virtualenv is not compatible with this system or executable

While python3 does come with virtualenv-like functionaliy through `pyvenv`, you can't use this as packaged by EPEL due to `python34` package missing `setuptools` and other dependencies by default! Pyvenv's default behavior is to use the `ensurepip` module to bootstrap `pip` into the virtualenv instance, and that fails miserably with the way EPEL packaged `python34`

### Solutions

There are three possibilities:

1.  Python 3 from EPEL has `virtualenv`-like functionality built-in with `pyvenv`, but the people that packaged it didn't do so fully. Normally, `pyvenv` bootstraps itself with the `ensurepip` module, but in this instance it can't because it's missing dependencies. Instead, we use PyPa's pip bootstrap script.

        :::bash
        sudo yum install epel-release
        sudo yum install python34
        pyvenv --without-pip <folder>
        source ./<folder>/bin/activate
        curl https://bootstrap.pypa.io/get-pip.py | python3

2.  Updating the virtualenv python2 module does in fact work, too.

        :::bash
        sudo yum install epel-release
        sudo yum install python34 # still need this
        sudo pip install --upgrade virtualenv
        virtualenv -p python3 <folder>

    I prefer option #1 over #2, despite it being more complex, because it doesn't affect any system's packages.

3.  **(bonus points!)** There is a third and even more complex option that also doesn't affect the system, using a python2 virtualenv as a bridge to patch the native virtualenv to support python3 :P

        :::bash
        sudo yum install epel-release
        sudo yum install python34
        virtualenv python2-bridge
        source ./python2-bridge/bin/active
        pip install --upgrade virtualenv
        virtualenv -p python3 <folder>
        source ./<folder>/bin/activate
        python --version && pip --version
        Python 3.4.3
        pip 8.1.2 from /home/centos/<folder>/lib/python3.4/site-packages (python 3.4)


*[PyPa]: Python Packaging Authority
*[EPEL]: Extra Packages for Enterprise Linux, Provided by the Fedora Project
