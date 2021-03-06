#
# This is a script which will repackage Mailpile for distribution on
# Windows.  Tested on Ubuntu 14.04, YMMV.
#
set -e
cd "$(dirname "$0")"
SCRIPTDIR="$(pwd)"
PYBINARIES="https://www.mailpile.is/files/build/"
WORKDIR="/tmp/mailpile-winbuild/"

OUTPUT="Mailpile-Beta-Installer.exe"
if [ "$1" = "--output" -a "$2" != "" ]; then
    OUTPUT="$2"
    shift
    shift
fi
echo "=== Target file is: $OUTPUT"

echo '=== Install apps we depend on'
which makensis >/dev/null || sudo apt-get install nsis

echo '=== Fetch / update Mailpile itself'
mkdir -p $WORKDIR && cd $WORKDIR
[ -d Mailpile ] || git clone https://github.com/pagekite/Mailpile
(cd Mailpile && git pull)


echo '=== Download and extract binary packages'
rm -rf $WORKDIR/Buildroot && mkdir $WORKDIR/Buildroot
mkdir -p $WORKDIR/Downloads && cd $WORKDIR/Downloads
# Maybe later: pywin32-219.win32-py2.7.exe \
#              Jinja2-2.7.3.win32-py2.7.exe \
for package in python-2.7.8-win32.zip \
               openssl-1.0.1h-win32.zip \
               gnupg-1.4.18-win32.zip \
               MailpileLauncher.zip \
               lxml-3.3.5.win32-py2.7.exe \
               Pillow-2.5.3.win32-py2.7.exe \
               setuptools-5.4.2.win32-py2.7.exe \
               pip-1.5.6.win32-py2.7.exe \
               pyreadline-2.0.win32-py2.7.exe \
               pydns-2.3.6-win32-py2.7.zip \
               jinja2-2.7.3-win32-py2.7.zip \
               markdown-2.4.1-win32-py2.7.zip \
               pgpdump-1.5-win32-py2.7.zip \
; do
    wget -q -c $PYBINARIES/$package
    (cd ../Buildroot; unzip -q -o ../Downloads/$package || true)
done
cd ../Buildroot
mkdir -p Python27/Scripts Python27/Lib/site-packages/
mv -f PLATLIB/* PURELIB/* Python27/Lib/site-packages/ && rmdir PLATLIB PURELIB
mv -f SCRIPTS/* Python27/Scripts && rmdir SCRIPTS

rm -rf ../Mailpile/{OpenSSL,GnuPG,Python27,Mailpile.exe,Mailpile.exe.config,img}
mv OpenSSL GnuPG Python27 MailpileLauncher/MailpileLauncher/* ../Mailpile

