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

# Make sure we have all the necessary locales, to prevent Perl from being
# confused.
sudo dpkg-reconfigure locales

# Install OS packages that we want.  ttyrec is for recording the screen.
# git is for generating patches.  Calibre is for 'ebook-convert'.  The
# others are dependencies of various tools we install from source.
sudo apt-get install -y ttyrec git python-numpy recode openjdk-7-jre-headless \
    calibre

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
if [ ! -f packages/melt-2.0b4.tar.gz ]; then
    # We don't even try to check this into git; it's about 350MB.
    url=https://gforge.inria.fr/frs/download.php/file/33238/melt-2.0b4.tar.gz
    (cd packages && curl -O "$url")
fi
standard_install /usr/local/bin/MElt melt-2.0b4
# MElt's -L option insists on this being readable for some reason.  We
# don't care; we're in a VM anyway.
sudo chown -R vagrant:vagrant /usr/local/share/melt/fr/lemmatization_data.db
# Install our custom tools for interfacing with MElt.
sudo install extra/melt2conllx /usr/local/bin/
sudo install extra/tag /usr/local/bin/

# Install maltparser, which was never really meant to be installed.
if [ ! -d /vagrant/maltparser-1.7.2 ]; then
    cd /vagrant
    tar xzf packages/maltparser-1.7.2.tar.gz
    cp packages/fremalt-1.7.mco maltparser-1.7.2/
fi
sudo install extra/parse /usr/local/bin/

# Install alexina (needed by LEFFF).
standard_install /usr/local/share/alexina alexina-tools-1.6

# Install the LEFFF lexicon.
standard_install /usr/local/share/lefff lefff-3.2

