#!/bin/bash

# Die on error.
set -e

# Set up our environment.
. /vagrant/extra/env.sh

# Make sure our environment gets set up on login, too.
if ! grep -q local.sh /home/vagrant/.bashrc; then
    echo "# Local customizations." >> /home/vagrant/.bashrc
    echo ". ~/local.sh" >> /home/vagrant/.bashrc
fi
cp /vagrant/extra/env.sh /home/vagrant/local.sh

# Set up some variables we only need during provisioning.
export DEBIAN_FRONTEND=noninteractive

# Make sure we have all the necessary locales.
sudo dpkg-reconfigure locales

# Install OS packages that we want.  ttyrec is for recording the screen and
# git is for generating patches.
sudo apt-get install -y ttyrec git python-numpy recode

# Install Perl packages that we want.  We use cpanminus instead of cpan,
# because cpan wants to have a long conversation with us about defaults.
if ! type cpanm >/dev/null 2>&1; then
    curl -L http://cpanmin.us | sudo perl - --self-upgrade
fi
sudo cpanm install DBI DBD::SQLite

# Our install routine.
function standard_install() {
    if [ ! -e "$1" ]; then
        cd /vagrant
        tar xzf packages/"$2".tar.gz
        cd "$2"
        if [ -f ../packages/"$2".diff ]; then
            cat ../packages/"$2".diff | patch -p1
        fi
        $3 ./configure
        make
        sudo make install
    fi
}

# Install MElt tokenizer.
standard_install /usr/local/bin/MElt melt-0.6

# Install alexina (needed by LEFFF and sxpipe).
standard_install /usr/local/share/alexina alexina-tools-1.6

# Install the LEFFF lexicon (needed by sxpipe, but also pretty awesome just
# by itself).
standard_install /usr/local/share/lefff lefff-3.2

# Enable this code if you want to try to make sxpipe work.  It can be made
# build (perhaps with a few tweaks I didn't record here), but I don't think
# it likes UTF-8 much, judging from its output.  And it's not clear that it
# produces the input format we need, in any case.  To get things working,
# start with our patches to melt-0.6.
if false; then
    # Install the support packages we want.
    sudo apt-get install -y g++
    sudo cpanm install AppConfig

    # Install syntax parser utilities (needed by sxpipe).
    standard_install /usr/local/share/syntax syntax-6.0b7

    # Install sxpipe (smart tokenizer).
    standard_install /usr/local/bin/sxpipe sxpipe-2.0b3 "LDFLAGS=-lm"
fi
