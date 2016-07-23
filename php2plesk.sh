#!/bin/bash

##
## "php2plesk.sh"
##    - build new set of php binaries from (downloaded) sources and 
##    install addional PHP(-fast-cgi) version to PLESK 11.5+ environment on Ubuntu LTS 10+ or similar...
##
## usage/info: ./php2plesk.sh -h
##
## (c) dragon-projects.net, Björn Bartels, me@bjoernbartels.earth
##

## defaults/configuration
##
EXTRA_VERSION = ""
TARGETINSTPATH="/usr/local/php_PHPVERSION_-cgi/"
TARGETINIPATH="/usr/local/php_PHPVERSION_-cgi/etc/"
PHPHANDLER="/usr/local/psa/bin/php_handler"
LOGFILE="./php2plesk.log"
PLESKID="_PHPVERSION_-cgi-custom"
TMPPATH="/tmp/"
SRCHOST=de1
SRCURL="http://_PHPHOST_.php.net/get/php-_PHPVERSION_.tar.gz/from/this/mirror"
SAPI=0
APXSPATH="/usr/bin/apxs2"
##SRCURL="http://php.net/get/php-_PHPVERSION_.tar.gz/from/a/mirror"

SUHOSINAPPLY=0
SUHOSINHOST="download.suhosin.org"
SUHOSINVERSION="0.9.38"
SUHOSINURL="https://_SUHOSINHOST_/suhosin-_SUHOSINVERSION_.tar.gz"
SUHOSINPATH="_PHPPATH_/suhosin-_SUHOSINVERSION_.tar.gz"

XDEBUGAPPLY=0
XDEBUGHOST="xdebug.org"
XDEBUGVERSION="2.3.3"
XDEBUGURL="http://_XDEBUGHOST_/files/xdebug-_XDEBUGVERSION_.tgz"
XDEBUGPATH="_PHPPATH_/xdebug-_XDEBUGVERSION_.tgz"

MEMCACHEDAPPLY=0
MEMCACHEDHOST="memcached.org"
MEMCACHEDVERSION="1.4.25"
MEMCACHEDURL="http://_MEMCACHEDHOST_/files/memcached-_MEMCACHEDVERSION_.tar.gz"
MEMCACHEDPATH="_PHPPATH_/memcached-_MEMCACHEDVERSION_.tar.gz"

INIEDIT=0
NONINTERACTIVE=0
VERBOSE=0

SKIP_DEPENDENCIES=0
SKIP_FETCHPHP=0
SKIP_BUILDPHP=0
SKIP_PHPHANDLER=0
SKIP_LOG=0
CONFIGURE_MODE=default

## PHP enabled modules
PHPMODS=
# php core debug mode
#PHPMODS="--disable-debug"
# system/process
#PHPMODS=${PHPMODS}" --enable-sysvsem"
#PHPMODS=${PHPMODS}" --enable-sysvshm"
#PHPMODS=${PHPMODS}" --enable-sysvmsg"
#PHPMODS=${PHPMODS}" --enable-pcntl"
#PHPMODS=${PHPMODS}" --enable-shmop"
# text
#PHPMODS=${PHPMODS}" --enable-mbstring"
#PHPMODS=${PHPMODS}" --enable-mbregex"
#PHPMODS=${PHPMODS}" -with-pcre-regex"
#PHPMODS=${PHPMODS}" --with-gettext"
#PHPMODS=${PHPMODS}" --enable-intl"
#PHPMODS=${PHPMODS}" --with-iconv"
#PHPMODS=${PHPMODS}" --with-pspell"
# grafic
#PHPMODS=${PHPMODS}" --with-gd"
#PHPMODS=${PHPMODS}" --with-gmp"
#PHPMODS=${PHPMODS}" --enable-exif"
#PHPMODS=${PHPMODS}" --enable-gd-native-ttf"
#PHPMODS=${PHPMODS}" --with-pic"
#PHPMODS=${PHPMODS}" --without-gdbm"
# crypt
#PHPMODS=${PHPMODS}" --with-openssl"
#PHPMODS=${PHPMODS}" --with-kerberos"
#PHPMODS=${PHPMODS}" --with-mcrypt"
# db
#PHPMODS=${PHPMODS}" --with-mysql"
#PHPMODS=${PHPMODS}" --with-mysqli"
#PHPMODS=${PHPMODS}" --enable-pdo"
#PHPMODS=${PHPMODS}" --with-pdo-mysql"
#PHPMODS=${PHPMODS}" --with-pdo-pgsql"
#PHPMODS=${PHPMODS}" --without-pdo-sqlite"
#PHPMODS=${PHPMODS}" --without-sqlite3"
#PHPMODS=${PHPMODS}" --enable-dba"
#PHPMODS=${PHPMODS}" --with-unixODBC=/usr"
# connect
#PHPMODS=${PHPMODS}" --enable-sockets"
#PHPMODS=${PHPMODS}" --enable-ftp"
#PHPMODS=${PHPMODS}" --with-ssh2"
#PHPMODS=${PHPMODS}" --with-curl"
#PHPMODS=${PHPMODS}" --disable-rpath"
#PHPMODS=${PHPMODS}" --with-snmp"
#PHPMODS=${PHPMODS}" --with-xmlrpc"
#PHPMODS=${PHPMODS}" --enable-soap"
#PHPMODS=${PHPMODS}" --enable-wddx"
#PHPMODS=${PHPMODS}" --with-ldap"
#PHPMODS=${PHPMODS}" --with-ldap-sasl"
#PHPMODS=${PHPMODS}" --with-imap"
#PHPMODS=${PHPMODS}" --with-imap-ssl"
# xml
#PHPMODS=${PHPMODS}" --with-xsl"
#PHPMODS=${PHPMODS}" --enable-xmlreader"
#PHPMODS=${PHPMODS}" --enable-xmlwriter"
# compress
#PHPMODS=${PHPMODS}" --enable-zip"
#PHPMODS=${PHPMODS}" --with-zlib"
#PHPMODS=${PHPMODS}" --with-bz2"
# tools
#PHPMODS=${PHPMODS}" --enable-calendar"
#PHPMODS=${PHPMODS}" --enable-bcmath"


## dependencies lists
##

INST_DEPENDENCIES=(
    "build-essential"
    "make"
    "autoconf"
    "automake"
    "libtool"
    "gcc"
    "bison"
    "libgmp-dev"
    "libxpm-dev"
    "libssh2-1"
    "libssh2-1-dev"
    "re2c"
    "libxml2-dev"
    "libcurl4-openssl-dev"
    "pkg-config"
    "libbz2-dev"
    "libjpeg62"
    "libjpeg62-dev"
    "libpng12-0"
    "libpng12-dev"
    "libfreetype6"
    "libfreetype6-dev"
    "libgmp3-dev"
    "libc-client2007e"
    "libc-client2007e-dev"
    "libicu-dev"
    "libsasl2-2"
    "libsasl2-dev"
    "libsasl2-modules"
    "libmcrypt4"
    "libmcrypt-dev"
    "unixodbc-dev"
    "libmysqlclient15-dev"
    "libpq-dev"
    "libpspell-dev"
    "libsnmp-dev"
    "libxslt1-dev"
    "libxslt1.1"
)

INST_DEPENDENCIES_MEMCACHED=(
    "libevent"
    "libevent-dev"
    "memcached"
    "libmemcached"
    "libmemcached-devel"
)


## extensions lists
##

PHP_EXTENSIONS_SELECTIONS=(
    "none"
    "default"
    "full"
    "custom"
)

PHP_SYSCONFIG=(
    "--enable-debug"
    "--enable-maintainer-zts"
)

INST_EXTENSIONS=(
    "--enable-sysvsem"
    "--enable-sysvshm"
    "--enable-sysvmsg"
    "--enable-pcntl"
    "--enable-shmop"
    
    "--enable-mbstring"
    "--enable-mbregex"
    " -with-pcre-regex"
    "--with-gettext"
    "--enable-intl"
    "--with-iconv"
    "--with-pspell"
    
    "--with-gd"
    "--with-gmp"
    "--enable-exif"
    "--enable-gd-native-ttf"
    "--with-pic"
    "--without-gdbm"
    
    "--with-openssl"
    "--with-kerberos"
    "--with-mcrypt"
    
    "--with-mysql"
    "--with-mysqli"
    "--enable-pdo"
    "--with-pdo-mysql"
    "--with-pdo-pgsql"
    "--without-pdo-sqlite"
    "--without-sqlite3"
    "--enable-dba"
    "--with-unixODBC=/usr"
    
    "--enable-sockets"
    "--enable-ftp"
    "--with-ssh2"
    "--with-curl"
    "--disable-rpath"
    "--with-snmp"
    "--with-xmlrpc"
    "--enable-soap"
    "--enable-wddx"
    "--with-ldap"
    "--with-ldap-sasl"
    "--with-imap"
    "--with-imap-ssl"
    
    "--with-xsl"
    "--enable-xmlreader"
    "--enable-xmlwriter"
    
    "--enable-zip"
    "--with-zlib"
    "--with-bz2"
    
    "--enable-calendar"
    "--enable-bcmath"
)


## show installer config info
##
scriptinfo()
{
cat << EOF

INSTALLER CONFIGURATION:
    VERSION        = ${INST_VERSION} 
    DISPLAYNAME    = ${INST_DISPLAYNAME} 
    PATH           = ${INST_PATH} 
    INIPATH        = ${INST_INIPATH} 
    PHPHANDLER     = ${INST_PHPHANDLER} 
    PLESKID        = ${INST_PLESKID} 
    TMPPATH        = ${INST_TMPPATH}
    LOGFILE        = ${INST_LOGFILE}
    MIRRORHOST     = ${INST_SRCHOST} 
    MIRRORURL      = ${INST_SRCURL}
    SAPI           = ${INST_SAPI}
    APXSPATH       = ${INST_APXSPATH}
    SUHOSIN        = ${INST_SUHOSIN}
    SUHOSINURL     = ${INST_SUHOSINURL}
    XDEBUG         = ${INST_XDEBUG}
    XDEBUGURL      = ${INST_XDEBUGURL}
    MEMCACHED      = ${INST_MEMCACHED}
    MEMCACHEDURL   = ${INST_MEMCACHEDURL}

    BASECONF       = ${INST_PHPBASECONF}
    MODULES        = ${INST_PHPCONFIGURE}
EOF
}


## show installer vendor information
##
scriptvendor()
{
cat << EOF

DISCLAIMER:
    THIS SCRIPT COMES WITH ABSOLUTELY NO WARRANTY !!! USE AT YOUR OWN RISK !!!
     
    The script is tested involving the following components:
     OS            : Ubuntu 10.04+
     Plesk         : 11.5+
     PHP           : 5.2+
     Suhosin       : 0.9+
     xDebug        : 2.3+
     memcached     : 1.4+
    

CHANGELOG:
    2015-12-15     : (bba) make php 'configure' parameters selectable 
    2015-11-15     : (bba) simplyfied dependencies installations 
    2015-11-12     : (bba) add simple 'php-dev' support
    2015-05-21     : (bba) add support for SUHOSIN patch/extension, xDebug, memcached
    late 2014      : (bba) initial release 


INSTALLER INFO:
    homepage/        http://dragon-projects.net/projects/scripts/php2plesk.sh
    support/bugs    
    copyright        (c) 2015 [dragon-projects.net]
    licence          GPL-2.0

EOF
}


## show installer usage help
##
scriptusage()
{
cat << EOF
php-to-PLESK build and install script, v1.0

USAGE: 
    $0 {php-version} {displayname}
    OR
    $0 -p {php-version} -d {displayname} [more options] (see below)


DESCRIPTION:
    build new set of php binaries from (downloaded) sources and install addional PHP(-fast-cgi) version to PLESK 11.5+ environment on Ubuntu LTS 10+ or similar...


OPTIONS:
    -d name                      PLESK panel display name
    -p version                   php version (ex: 5.6.9)

    -t path                      target path for php installation (default '/usr/local/php_PHPVERSION_-cgi/')
    -i path                      target path for php.ini file (default '/usr/local/php_PHPVERSION_-cgi/etc/')

    -l filepath                  target path to installer logfile (default './php2plesk.log')
    -H filepath                  target path to PLESK panel 'php_handler' command (default '/usr/local/psa/bin/php_handler')
    -I plesk-id                  overwrite PLESK internal ID (default '_PHPVERSION_-custom')
    -s hostname                  overwrite php.net mirror hostname to download php source files (default 'de1')
    -u url                       overwrite url to download php source files (overranks '-H hostname' option)
    -T path                      installer path for temporary file storage (default '/tmp/')

    -e                           open php.ini file to be edited (requires vim)
    -n                           be non-interactive (overranks '-e' option)

    -h                           show this message
    -v                           verbose output

    --configure mode             build-in extension compile modes: default, none, full, custom
                                  - default: compile default minimal php extensions, this is the default setting
                                  - none: do not compile any php extensions 
                                  - full: compile all default php extensions currently available
                                  - custom: ask on every extension wether to compile or not 
	
    --sapi                       also compile apache2 module, use with caution(!)
    --apxs-path                  set path to 'apxs2' command (default: '/usr/bin/apxs2')
    
    --suhosin                    add SUHOSIN patch/extension to php configuration, must also set '--suhosin-version'
    --suhosin-version version    SUHOSIN patch/extension version (ex: '0.9.38') 
    --suhosin-host hostname      hostname for SUHOSIN patch/extension source download (optional, default: 'download.suhosin.org')
    
    --xdebug                     add xDebug extension to php configuration, must also set '--xdebug-version'
    --xdebug-version version     xDebug extension version (ex: '2.3.3') 
    --xdebug-host hostname       hostname for xDebug extension source download (optional, default: 'xdebug.org')

    --memcached                  add memcached extension to php configuration, must also set '--memcached-version'
    --memcached-version version  memcached extension version (ex: '1.4.25') 
    --memcached-host hostname    hostname for memcached extension source download (optional, default: 'memcached.org')

    
    placeholders for path and hostname/url parameters:
    _PHPVERSION_                 php version (ex: '5.6.9')
    _PHPHOST_                    php.net mirror hostname (ex: 'de1')
    _SUHOSINVERSION_             SUHOSIN patch/extension version (ex: '0.9.38')
    _SUHOSINHOST_                SUHOSIN patch/extension source download hostname (ex: 'download.suhosin.org')
    _XDEBUGVERSION_              xDebug extension version (ex: '2.3.3')
    _XDEBUGHOST_                 xDebug extension source download hostname (ex: 'xdebug.org')
    _MEMCACHEDVERSION_           xDebug extension version (ex: '1.4.25')
    _MEMCACHEDHOST_              xDebug extension source download hostname (ex: 'memcached.org')


EXAMPLES:

    - to compile php5.6.9 including suhosin patch enter...
        /root/php2plesk/php2plesk.sh -v -p 5.6.9 -d 5.6.09-suhosin -t /usr/local/php5.6.9-cgi-suhosin/ --suhosin --suhosin-version 0.9.37.1 -i /usr/local/php5.6.9-cgi-suhosin/etc/ -n
    
        ...and add it to plesk's list of php-handlers:
        /usr/local/psa/bin/php_handler --add -displayname 5.6.09-suhosin -path /usr/local/php5.6.9-cgi-suhosin/bin/php-cgi -phpini /usr/local/php5.6.9-cgi-suhosin/etc/php.ini -type fastcgi -id 5.6.9-cgi-custom-suhosin
    
        ...got to domain's hosting settings and select the new php handler, click 'Ok'
    
    
    - compile an older php version...
        /root/php2plesk/php2plesk.sh -v -p 5.3.2 -d 5.3.2 -t /usr/local/php5.3.2-cgi-suhosin/    -i /usr/local/php5.3.2-cgi-suhosin/etc/ --suhosin --suhosin-version 0.9.37.1 -n -u http://museum.php.net/php5/php-5.3.2.tar.gz


    - re-building or when a build was not completed:
     - in case, remove a corresponding 'plesk' php-handler first ('/usr/local/psa/bin/php_handler --remove {php_handler_id}')
     - (view a list of 'plesk' php-handler with '/usr/local/psa/bin/php_handler --list')
     - remove the corresponding php binaries folder (ex: '/usr/local/php5.6.9-cgi-suhosin')
     - in case, remove any remaining php source folders under the temporary file path (default: '/tmp/')


    - bulding from (git-)sources:
    when building php with a fresh checkout from its (original) git-repository some specific settings must apply:
     - the word 'dev' must be included in the php version parameter (ex: '7.x-dev')
     - use the '.tar.gz'/'.tgz' download-link as the download source parameter ('http://git.php.net/?p=php-src.git;a=snapshot;h=refs/heads/master;sf=tgz')

    
EOF
}


## >>> INSTALLER METHODS <<<
##


## detect current OS type
##
detectOS () 
{
    TYPE=$(echo "$1" | tr '[A-Z]' '[a-z]')
    OS=$(uname)
    ID="unknown"
    CODENAME="unknown"
    RELEASE="unknown"

    if [ "${OS}" == "Linux" ] ; then
        # detect centos
        grep "centos" /etc/issue -i -q
        if [ $? = '0' ]; then
            ID="centos"
            RELEASE=$(cat /etc/redhat-release | grep -o 'release [0-9]' | cut -d " " -f2)
        # could be debian or ubuntu
        elif [ $(which lsb_release) ]; then
            ID=$(lsb_release -i | cut -f2)
            CODENAME=$(lsb_release -c | cut -f2)
            RELEASE=$(lsb_release -r | cut -f2)
        elif [ -f "/etc/lsb-release" ]; then
            ID=$(cat /etc/lsb-release | grep DISTRIB_ID | cut -d "=" -f2)
            CODENAME=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d "=" -f2)
            RELEASE=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -d "=" -f2)
        elif [ -f "/etc/issue" ]; then
            ID=$(head -1 /etc/issue | cut -d " " -f1)
            if [ -f "/etc/debian_version" ]; then
                RELEASE=$(</etc/debian_version)
            else
                RELEASE=$(head -1 /etc/issue | cut -d " " -f2)
            fi
        fi

    elif [ "${OS}" == "Darwin" ]; then
        ID="osx"
        OS="Mac OS-X"
        RELEASE=""
        CODENAME="Darwin"
    fi

    ##ID=$(echo "${ID}" | tr '[A-Z]' '[a-z]')
    ##TYPE=$(echo "${TYPE}" | tr '[A-Z]' '[a-z]')
    ##OS=$(echo "${OS}" | tr '[A-Z]' '[a-z]')
    ##CODENAME=$(echo "${CODENAME}" | tr '[A-Z]' '[a-z]')
    ##RELESE=$(echo "${RELEASE}" | tr '[A-Z]' '[a-z]' '[0-9\.]')

}


## install basic system dependencies
##
install_basics () {
    logMessage ">>> begin installing basic tools and libraries needed for build process...";
    if [ "$INST_VERBOSE" == "1" ]; then 
        echo "";
        echo "================================================================================================";
        echo ">>> begin installing basic tools and libraries needed for build process...";
        echo ""; 
    fi
    
    if [ "$INST_VERBOSE" == "1" ]; then
        apt-get update;
        apt-get upgrade -y ;
        
        for dependency in ${INST_DEPENDENCIES[@]}; do
            
            if dpkg --list | grep "${dependency}" >/dev/null; then echo "'${dependency}' already installed";
            else apt-get install -y ${dependency}; fi
                
        done
            
        if [ $INST_MEMCACHED == 1 ]; then
        
            for dependency in ${INST_DEPENDENCIES_MEMCACHED[@]}; do
                if dpkg --list | grep "${dependency}" >/dev/null; then echo "'${dependency}' already installed";
                else apt-get install -y ${dependency}; fi
            done
            
        fi
        
    else ## quiet/none output...
        apt-get update >/dev/null;
        apt-get upgrade -y >/dev/null;
        
        for dependency in ${INST_DEPENDENCIES[@]}; do
            if dpkg --list | grep "${dependency}" >/dev/null; then echo "'${dependency}' already installed" >/dev/null;
            else apt-get install -y ${dependency} >/dev/null; fi
        done
            
        if [ $INST_MEMCACHED == 1 ]; then
        
            for dependency in ${INST_DEPENDENCIES_MEMCACHED[@]}; do
                if dpkg --list | grep "${dependency}" >/dev/null; then echo "'${dependency}' already installed" >/dev/null;
                else apt-get install -y ${dependency} >/dev/null; fi
            done
            
        fi
    fi
    
    ## link some libraries if still missing
    if [ ! -e "/usr/include/gmp.h" ]; then
        ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h
    fi
    if [ ! -e "/usr/lib/libXpm.a" ]; then
        ln -s /usr/lib/x86_64-linux-gnu/libXpm.a /usr/lib/libXpm.a
    fi
    if [ ! -e "/usr/lib/libXpm.so" ]; then
        ln -s /usr/lib/x86_64-linux-gnu/libXpm.so /usr/lib/libXpm.so
    fi
    if [ ! -e "/usr/lib/liblber.a" ]; then
        ln -s /usr/lib/x86_64-linux-gnu/liblber.a /usr/lib/liblber.a
    fi
    if [ ! -e "/usr/lib/libldap_r.a" ]; then
        ln -s /usr/lib/x86_64-linux-gnu/libldap_r.a /usr/lib/libldap_r.a
    fi

    if [ "$INST_VERBOSE" == "1" ]; then 
        echo "";
        echo ">>> finish installing basic tools and libraries";
        echo "================================================================================================";
        echo "";
    fi
    logMessage ">>> finish installing basic tools and libraries needed for build process...";
}


## fetch php source file(s)
##
fetch_php () {
    logMessage ">>> begin downloading new php source files...";
    if [ "$INST_VERBOSE" == "1" ]; then 
        echo "";
        echo "================================================================================================";
        echo ">>> begin downloading new php source files...";
        echo "";
    fi
        
    cd ${INST_TMPPATH};
    if [ -d "${INST_SRCURL}" ] && [ -f "${INST_SRCURL}/php5.spec.in" ]; then
        # path with source files in it is given, take sources from there...
        logMessage ">>> source path '${INST_SRCURL}' given, do not download and extract new source archive...";
        cd ${INST_SRCURL};
        if [ "$INST_VERBOSE" == "1" ]; then 
            echo ">>> source path '${INST_SRCURL}' given, do not download and extract new source archive...";
        fi
    elif [ -r ${INST_SRCURL} ] && [ -d ${INST_SRCPATH} ] && [ "${INST_SRCURL#*.}" == "tar.gz" ]; then
        # URL is an archive, extract and take sources from there...
        logMessage ">>> source archive '${INST_SRCURL}' given, do not download new source archive...";
        if [ "$INST_VERBOSE" == "1" ]; then
            echo ">>> source archive '${INST_SRCURL}' given, do not download new source archive...";
            tar xzvf ${INST_SRCURL} ${INST_SRCPATH}/.;
            if [ "$INST_KEEPARCHIVE" != "1" ]; then 
                rm -rf ${INST_SRCURL}; 
                logMessage ">>> remove source archive in '${INST_SRCURL}'..."; 
            fi
            cd php-${INST_VERSION};
        else
            tar xzvf ${INST_SRCURL} ${INST_SRCPATH}/. >/dev/null;
            if [ "$INST_KEEPARCHIVE" != "1" ]; then 
                rm -rf ${INST_SRCURL} >/dev/null; 
                logMessage ">>> remove source archive in '${INST_SRCURL}'..."; 
            fi
            cd php-${INST_VERSION};
        fi
    elif [ "${INST_SRCURL:0:4}" == "http" ]; then
        # URL seems to be really an URL, download archive, etc... 
        logMessage ">>> source URL '${INST_SRCURL}' given, download and extract new source archive...";
        if [ "$INST_VERBOSE" == "1" ]; then
            echo ">>> source URL '${INST_SRCURL}' given, download and extract new source archive...";
            wget ${INST_SRCURL} -O php-${INST_VERSION}.tar.gz;
            tar xzvf php-${INST_VERSION}.tar.gz;
            if [ "$INST_KEEPARCHIVE" != "1" ]; then 
                rm php-${INST_VERSION}.tar.gz; 
                logMessage ">>> remove source archive in 'php-${INST_VERSION}.tar.gz'..."; 
            fi
            cd php-${INST_VERSION};
        else
            wget ${INST_SRCURL} -O php-${INST_VERSION}.tar.gz >/dev/null;
            tar xzvf php-${INST_VERSION}.tar.gz >/dev/null;
            if [ "$INST_KEEPARCHIVE" != "1" ]; then 
                rm php-${INST_VERSION}.tar.gz >/dev/null; 
                logMessage ">>> remove source archive in 'php-${INST_VERSION}.tar.gz'..."; 
            fi
            cd php-${INST_VERSION};
        fi
    else
        if [ "$INST_VERBOSE" == "1" ]; then 
            echo "WARNING: no source files to build, canceling operation...";
            exit;
        fi
    fi
    INST_SRCPATH=`pwd`;
    
    if [ "$INST_VERBOSE" == "1" ]; then 
        echo "";
        echo ">>> finish downloading new php source files";
        echo "================================================================================================";
        echo "";
    fi
    logMessage ">>> finish downloading new php source files...";
}


## check and prepare git-sources
##
prepare_git_sources () {
    case "$INST_VERSION" in
        *dev*)
            logMessage ">>> build from git-source requested...";
            logMessage ">>> begin preparing git-source files...";
            if [ "$INST_VERBOSE" == "1" ]; then 
                echo "";
                echo "renaming dev-srv folder to php-${INST_VERSION}";
                echo "";
            fi

            cd ${INST_TMPPATH};
            rm -rf php-${INST_VERSION};
            mv php-src* php-${INST_VERSION};
            cd php-${INST_VERSION};
            CPWD=`pwd`;
            INST_SRCPATH=`pwd`;
            ./buildconf

            if [ "$INST_VERBOSE" == "1" ]; then 
                echo "";
                echo "current path: $CPWD";
                echo "current src-path: $INST_SRCPATH";
                echo "";
            fi
            logMessage ">>> finish preparing git-source files...";
        ;;
    esac    
}


## assemple php configure parameters and set library paths
##
configure_php ()
{
    # basic config
    INST_PHPBASECONF=
    INST_PHPBASECONF=${INST_PHPBASECONF}"--with-libdir=lib"
    INST_PHPBASECONF=${INST_PHPBASECONF}" --with-xpm-dir=/usr --with-ldap=/usr"
    INST_PHPBASECONF=${INST_PHPBASECONF}" --cache-file=../config.cache"
    INST_PHPBASECONF=${INST_PHPBASECONF}" --prefix=${INST_PATH}"
    INST_PHPBASECONF=${INST_PHPBASECONF}" --with-config-file-path=${INST_INIPATH}"
    INST_PHPBASECONF=${INST_PHPBASECONF}" --with-config-file-scan-dir=${INST_INIPATH}php.d"
    
    # SAPI module
    if [ $INST_SAPI == 1 ];
        then
            INST_PHPBASECONF=${INST_PHPBASECONF}" --with-apxs2=${INST_APXSPATH}"
    fi

    # apply path settings
    INST_PHPBASECONF=${INST_PHPBASECONF}" --with-libxml-dir=${INST_PATH}"
    INST_PHPBASECONF=${INST_PHPBASECONF}" --with-pear=${INST_PATH}pear"
    INST_PHPBASECONF=${INST_PHPBASECONF}" --with-jpeg-dir=${INST_PATH}"
    INST_PHPBASECONF=${INST_PHPBASECONF}" --with-png-dir=${INST_PATH}"
    INST_PHPBASECONF=${INST_PHPBASECONF}" --with-freetype-dir=${INST_PATH}"
    
    INST_PHPCONFIGURE=

    PHPMODS=
    configure_extensions;
    
    # apply modules
    INST_PHPCONFIGURE=${INST_PHPCONFIGURE}" "${PHPMODS}
    
    # enable memcached
    if [ $INST_MEMCACHED == 1 ]; then
        INST_PHPCONFIGURE=${INST_PHPCONFIGURE}" --enable-memcached"
    fi
}


## assemble extension configuration
##
configure_extensions ()
{
    case "${CONFIGURE_MODE}" in
        *default*)
            PHPMODS=
        ;;
        *none*)
            PHPMODS=" --disable-all --without-pear"
            ##PHPMODS=" --disable-all --enable-xml"
        ;;
        *full*)
            for PHPMOD in ${INST_EXTENSIONS[@]}; do
                PHPMODS=${PHPMODS}" ${PHPMOD}"
            done
        ;;
        *custom*)
            for PHPMOD in ${INST_EXTENSIONS[@]}; do
                EXTENSION__CONFIRM=0
                confirm_extension "install extension '${PHPMOD}'"
                if [ $EXTENSION__CONFIRM == 1 ]; then 
                    PHPMODS=${PHPMODS}" ${PHPMOD}"
                fi
            done
        ;;
        *)
            ##
        ;;
    esac
    
}


## display confirm extension install dialog
##
confirm_extension () {
    EXTENSION__CONFIRM=0
    if [ "$1" != "" ] 
        then
            read -p ">>> $1 [(YJ)/n]: " CONFIRMNEXTSTEP
            case "$CONFIRMNEXTSTEP" in
                Yes|yes|Y|y|Ja|ja|J|j|"") ## confirm installing extension...
                    logMessage ">>> '$1' confirmed...";
                    EXTENSION__CONFIRM=1
                ;;
                *) ## do not install extension...
                ;;
            esac
    fi
}


## patch php version string
##
patch_PHP_Version ()
{

    logMessage ">>> apply php version string patch'...";
    echo ">>> apply php version string patch'...";
    if [ "$INST_VERBOSE" == "1" ]; then 
        replace "PHP_EXTRA_VERSION=\"\"" "PHP_EXTRA_VERSION=\"${INST_EXTRA_VERSION}\"" -- /tmp/php-${INST_VERSION}/configure.in
    else
        replace "include \"pdo/php_pdo" "include \"ext/pdo/php_pdo" -- /tmp/php-${INST_VERSION}/ext/pdo_*/*.c > /dev/null;
    fi

}

## patch php PDO files
##
patch_PDO_paths ()
{

    logMessage ">>> apply php PDO path patch'...";
    echo ">>> apply php PDO path patch'...";
    if [ "$INST_VERBOSE" == "1" ]; then 
        replace "include \"pdo/php_pdo" "include \"ext/pdo/php_pdo" -- /tmp/php-${INST_VERSION}/ext/pdo_*/*.c
    else
        replace "include \"pdo/php_pdo" "include \"ext/pdo/php_pdo" -- /tmp/php-${INST_VERSION}/ext/pdo_*/*.c > /dev/null;
    fi

}


## build php binary and extension files
##
build_php () {
    logMessage ">>> begin building new php version...";
    if [ "$INST_VERBOSE" == "1" ]; then 
        echo "";
        echo "================================================================================================";
        echo ">>> begin building new php version...";
        echo "";
    fi
    
    php_version_stripped=${INST_VERSION//[\.]/}
    
    cd ${INST_SRCPATH}
    logMessage ">>> build new php '${INST_VERSION}' from '${INST_SRCURL}' to '${INST_PATH}'...";
    
    if [ "$INST_VERBOSE" == "1" ]; then 
        echo ">>> build new php '${INST_VERSION}' from '${INST_SRCURL}' to '${INST_PATH}'...";
        echo "./configure ${INST_PHPBASECONF} ${INST_PHPCONFIGURE}";
        ./configure ${INST_PHPBASECONF} ${INST_PHPCONFIGURE};

        patch_PDO_paths;
        
        make;
        make install;
    else
        ./configure ${INST_PHPBASECONF} ${INST_PHPCONFIGURE} >/dev/null;

        patch_PDO_paths >/dev/null;

        make >/dev/null;
        make install >/dev/null;
    fi
    
    if [ ! -e "${INST_PATH}" ]; then
        exit;
    fi
    
    cd ${INST_PATH};
    mkdir etc;
    cd etc;
    mkdir php.d;
    
    cp ${INST_SRCPATH}/php.ini-development ${INST_INIPATH}php.ini
    if [ "$INST_VERBOSE" == "1" ]; then 
        echo ">>> ini file created in '${INST_INIPATH}php.ini'..."; 
    fi
    logMessage ">>> ini file created in '${INST_INIPATH}php.ini'..."
    
    
    if [ "$INST_VERBOSE" == "1" ]; then
        if [ "$INST_KEEPFILES" == "0" ]; then 
            rm -rf ${INST_SRCPATH}; 
            logMessage ">>> remove source files in '${INST_SRCPATH}'..."; 
        fi
    else
        if [ "$INST_KEEPFILES" == "0" ]; then 
            rm -rf ${INST_SRCPATH} >/dev/null; 
            logMessage ">>> remove source files in '${INST_SRCPATH}'..."; 
        fi
    fi
        
    if [ "$INST_EDITINI" == "1" ] || [ "$INST_VERBOSE" == "1" ]; then
        if [ "$NONINTERACTIVE" == "0" ]; then
            read -p "<<< Would you like to edit the 'php.ini' file '${INST_INIPATH}php.ini' [Y/n] ?" edit_php_ini
            case "$edit_php_ini" in
                    Yes|yes|Y|y|Ja|ja|J|j|"") 
                        vim ${INST_INIPATH}php.ini
                        ;;
                    *) ## ... go to next step...
                        ;;
            esac
        fi
    fi

    if [ "$INST_VERBOSE" == "1" ]; then 
        echo "";
        echo ">>> finish building new php version";
        echo "================================================================================================";
        echo "";
    fi
        logMessage ">>> finish building new php version";
}


## apply new php version to PLESK php-handlers
##
apply_php () {
    logMessage ">>> begin adding new php-handler to PLESK environment...";
    if [ "$INST_VERBOSE" == "1" ]; then 
        echo "";
        echo "================================================================================================";
        echo ">>> begin adding new php-handler to PLESK environment...";
        echo "";
    fi
        
    if [ "$INST_VERBOSE" == "1" ]; then
cat << EOF
        echo ">>> add new php handler '${INST_DISPLAYNAME}' (ID ${INST_PLESKID}, PHP ${INST_VERSION}) to PLESK environment...";
        ${INST_PHPHANDLER} --add -displayname ${INST_DISPLAYNAME} -path ${INST_PATH}bin/php-cgi -phpini ${INST_INIPATH}php.ini -type fastcgi -id ${INST_PLESKID}
EOF
    else
cat << EOF
        ${INST_PHPHANDLER} --add -displayname ${INST_DISPLAYNAME} -path ${INST_PATH}bin/php-cgi -phpini ${INST_INIPATH}php.ini -type fastcgi -id ${INST_PLESKID} >/dev/null
EOF
    fi

    if [ "$INST_VERBOSE" == "1" ]; then 
        echo "";
        echo ">>> finish adding new php-handler to PLESK environment";
        echo "================================================================================================";
        echo "";
    fi
    logMessage ">>> finish adding new php-handler to PLESK environment";
}


## apply SUHOSIN patch/extension to new php version
##
apply_suhosin () {
    logMessage ">>> begin applying SUHOSIN patch/extension to new php version...";
    if [ "$INST_VERBOSE" == "1" ]; then 
        echo "";
        echo "================================================================================================";
        echo ">>> begin applying SUHOSIN patch/extension to new php version...";
        echo "";
    fi
        
    if [ "$INST_VERBOSE" == "1" ]; then
        
        # goto inst-dir
        cd $INST_PATH
        
        # fetch suhosin
        if [ -d "${INST_SUHOSINURL}" ] && [ -f "${INST_SUHOSINURL}/suhosin.c" ]; then
            # path with source files in it is given, take sources from there...
            logMessage ">>> source path '${INST_SUHOSINURL}' given, do not download and extract new source archive...";
            cd ${INST_SUHOSINURL};
            if [ "$INST_VERBOSE" == "1" ]; then 
                echo ">>> source path '${INST_SUHOSINURL}' given, do not download and extract new source archive...";
            fi
        elif [ -r ${INST_SUHOSINURL} ] && [ -d ${INST_SUHOSINPATH} ] && [ "${INST_SUHOSINURL#*.}" == "tar.gz" ]; then
            # URL is an archive, extract and take sources from there...
            logMessage ">>> source archive '${INST_SUHOSINURL}' given, do not download new source archive...";
            if [ "$INST_VERBOSE" == "1" ]; then
                echo ">>> source archive '${INST_SUHOSINURL}' given, do not download new source archive...";
                ## tar xzvf ${INST_SUHOSINURL} ${INST_SUHOSINPATH}/.;
                if [ "$INST_KEEPARCHIVE" != "1" ]; then 
                    rm -rf ${INST_SUHOSINURL}; 
                    logMessage ">>> remove source archive in '${INST_SUHOSINURL}'..."; 
                fi
                cd suhosin-${INST_SUHOSINVERSION};
            else
                ## tar xzvf ${INST_SUHOSINURL} ${INST_SUHOSINPATH}/. >/dev/null;
                if [ "$INST_KEEPARCHIVE" != "1" ]; then 
                    rm -rf ${INST_SUHOSINURL} >/dev/null; 
                    logMessage ">>> remove source archive in '${INST_SUHOSINURL}'..."; 
                fi
                cd suhosin-${INST_SUHOSINVERSION};
            fi
        elif [ "${INST_SUHOSINURL:0:4}" == "http" ]; then
            # URL seems to be really an URL, download archive, etc... 
            logMessage ">>> source URL '${INST_SUHOSINURL}' given, download and extract new source archive...";
            if [ "$INST_VERBOSE" == "1" ]; then
                echo ">>> source URL '${INST_SUHOSINURL}' given, download and extract new source archive...";
                wget --no-check-certificate ${INST_SUHOSINURL} -O suhosin-${INST_SUHOSINVERSION}.tar.gz;
                tar xzvf suhosin-${INST_SUHOSINVERSION}.tar.gz;
                if [ "$INST_KEEPARCHIVE" != "1" ]; then 
                    rm suhosin-${INST_SUHOSINVERSION}.tar.gz; 
                    logMessage ">>> remove source archive in 'php-${INST_VERSION}.tar.gz'..."; 
                fi
                cd suhosin-${INST_SUHOSINVERSION};
            else
                wget --no-check-certificate ${INST_SUHOSINURL} -O suhosin-${INST_SUHOSINVERSION}.tar.gz >/dev/null;
                tar xzvf suhosin-${INST_SUHOSINVERSION}.tar.gz >/dev/null;
                if [ "$INST_KEEPARCHIVE" != "1" ]; then 
                    rm suhosin-${INST_SUHOSINVERSION}.tar.gz >/dev/null; 
                    logMessage ">>> remove source archive in 'php-${INST_VERSION}.tar.gz'..."; 
                fi
                cd suhosin-${INST_SUHOSINVERSION};
            fi
        else
            if [ "$INST_VERBOSE" == "1" ]; then 
                echo "WARNING: no source files to build SUHOSIN patch/extension, canceling operation...";
                exit;
            fi
        fi
        
        
        # php-ize module
        ${INST_PATH}/bin/phpize;
        
        # ./configure --with-php-config=....
        ./configure --with-php-config=${INST_PATH}/bin/php-config;
        
        # make && make install 
        make && make install;
        
        # cp suhosin.ini -> php/etc/php.d/
        cp suhosin.ini ${INST_PATH}/etc/php.d/;
        rm -f ${INST_PATH}/etc/php.d/suhosin_enabled.ini;
        
        # enable extension
        echo "extension=suhosin.so" >> ${INST_PATH}/etc/php.d/suhosin_enabled.ini;
        
        
    fi

    if [ "$INST_VERBOSE" == "1" ]; then 
        echo "";
        echo ">>> finish applying SUHOSIN patch/extension to new php version";
        echo "================================================================================================";
        echo "";
    fi
        logMessage ">>> finish applying SUHOSIN patch/extension to new php version";
}


## apply xDebug extension to new php version
##
apply_xdebug () {
    logMessage ">>> begin applying xDebug extension to new php version...";
    if [ "$INST_VERBOSE" == "1" ]; then 
        echo "";
        echo "================================================================================================";
        echo ">>> begin applying xDebug extension to new php version...";
        echo "";
    fi
        
    if [ "$INST_VERBOSE" == "1" ]; then
        
        # goto inst-dir
        cd $INST_PATH
        
        # fetch xDebug
        if [ -d "${INST_XDEBUGURL}" ] && [ -f "${INST_XDEBUGURL}/xdebug.c" ]; then
            # path with source files in it is given, take sources from there...
            logMessage ">>> source path '${INST_XDEBUGURL}' given, do not download and extract new source archive...";
            cd ${INST_XDEBUGURL};
            if [ "$INST_VERBOSE" == "1" ]; then 
                echo ">>> source path '${INST_XDEBUGURL}' given, do not download and extract new source archive...";
            fi
        elif [ -r ${INST_XDEBUGURL} ] && [ -d ${INST_XDEBUGPATH} ] && [ "${INST_XDEBUGURL#*.}" == "tar.gz" ]; then
            # URL is an archive, extract and take sources from there...
            logMessage ">>> source archive '${INST_XDEBUGURL}' given, do not download new source archive...";
            if [ "$INST_VERBOSE" == "1" ]; then
                echo ">>> source archive '${INST_XDEBUGURL}' given, do not download new source archive...";
                ## tar xzvf ${INST_XDEBUGURL} ${INST_XDEBUGPATH}/.;
                if [ "$INST_KEEPARCHIVE" != "1" ]; then 
                    rm -rf ${INST_XDEBUGURL}; 
                    logMessage ">>> remove source archive in '${INST_XDEBUGURL}'..."; 
                fi
                cd xdebug-${INST_XDEBUGVERSION};
            else
                ## tar xzvf ${INST_XDEBUGURL} ${INST_XDEBUGPATH}/. >/dev/null;
                if [ "$INST_KEEPARCHIVE" != "1" ]; then 
                    rm -rf ${INST_XDEBUGURL} >/dev/null; 
                    logMessage ">>> remove source archive in '${INST_XDEBUGURL}'..."; 
                fi
                cd xdebug-${INST_XDEBUGVERSION};
            fi
        elif [ "${INST_XDEBUGURL:0:4}" == "http" ]; then
            # URL seems to be really an URL, download archive, etc... 
            logMessage ">>> source URL '${INST_XDEBUGURL}' given, download and extract new source archive...";
            if [ "$INST_VERBOSE" == "1" ]; then
                echo ">>> source URL '${INST_XDEBUGURL}' given, download and extract new source archive...";
                wget --no-check-certificate ${INST_XDEBUGURL} -O xdebug-${INST_XDEBUGVERSION}.tar.gz;
                tar xzvf xdebug-${INST_XDEBUGVERSION}.tar.gz;
                if [ "$INST_KEEPARCHIVE" != "1" ]; then 
                    rm xdebug-${INST_XDEBUGVERSION}.tar.gz; 
                    logMessage ">>> remove source archive in 'xdebug-${INST_XDEBUGVERSION}.tar.gz'..."; 
                fi
                cd xdebug-${INST_XDEBUGVERSION};
            else
                wget --no-check-certificate ${INST_XDEBUGURL} -O xdebug-${INST_XDEBUGVERSION}.tar.gz >/dev/null;
                tar xzvf xdebug-${INST_XDEBUGVERSION}.tar.gz >/dev/null;
                if [ "$INST_KEEPARCHIVE" != "1" ]; then 
                    rm xdebug-${INST_XDEBUGVERSION}.tar.gz >/dev/null; 
                    logMessage ">>> remove source archive in 'xdebug-${INST_XDEBUGVERSION}.tar.gz'..."; 
                fi
                cd xdebug-${INST_XDEBUGVERSION};
            fi
        else
            if [ "$INST_VERBOSE" == "1" ]; then 
                echo "WARNING: no source files to build xDebug extension, canceling operation...";
                exit;
            fi
        fi
        
        
        # php-ize module
        ${INST_PATH}/bin/phpize;
        
        # ./configure --with-php-config=....
        ./configure --with-php-config=${INST_PATH}/bin/php-config;
        
        # make
        make;
        # make install
        mkdir -p ${INST_PATH}/lib/php/extensions/no-debug-non-zts/
        cp modules/xdebug.so ${INST_PATH}/lib/php/extensions/no-debug-non-zts/
        
        # cp xdebug.ini -> php/etc/php.d/
        cp xdebug.ini ${INST_PATH}/etc/php.d/;
        rm -f ${INST_PATH}/etc/php.d/xdebug_enabled.ini;
        
        # enable extension
        echo "zend_extension=${INST_PATH}/lib/php/extensions/no-debug-non-zts/xdebug.so" >> ${INST_PATH}/etc/php.d/xdebug_enabled.ini;
        
        
    fi

    if [ "$INST_VERBOSE" == "1" ]; then 
        echo "";
        echo ">>> finish applying xDebug extension to new php version";
        echo "================================================================================================";
        echo "";
    fi
        logMessage ">>> finish applying xDebug extension to new php version";
}


## apply memcached extension to new php version
##
apply_memcached () {
    logMessage ">>> begin applying memcached extension to new php version...";
    if [ "$INST_VERBOSE" == "1" ]; then 
        echo "";
        echo "================================================================================================";
        echo ">>> begin applying memcached extension to new php version...";
        echo "";
    fi
        
    if [ "$INST_VERBOSE" == "1" ]; then
        
        # goto inst-dir
        cd $INST_PATH
        
        # fetch memcached
        if [ -d "${INST_MEMCACHEDURL}" ] && [ -f "${INST_MEMCACHEDURL}/memcached.c" ]; then
            # path with source files in it is given, take sources from there...
            logMessage ">>> source path '${INST_MEMCACHEDURL}' given, do not download and extract new source archive...";
            cd ${INST_MEMCACHEDURL};
            if [ "$INST_VERBOSE" == "1" ]; then 
                echo ">>> source path '${INST_MEMCACHEDURL}' given, do not download and extract new source archive...";
            fi
        elif [ -r ${INST_MEMCACHEDURL} ] && [ -d ${INST_MEMCACHEDPATH} ] && [ "${INST_MEMCACHEDURL#*.}" == "tar.gz" ]; then
            # URL is an archive, extract and take sources from there...
            logMessage ">>> source archive '${INST_MEMCACHEDURL}' given, do not download new source archive...";
            if [ "$INST_VERBOSE" == "1" ]; then
                echo ">>> source archive '${INST_MEMCACHEDURL}' given, do not download new source archive...";
                ## tar xvfz ${INST_MEMCACHEDURL} ${INST_MEMCACHEDPATH}/.;
                if [ "$INST_KEEPARCHIVE" != "1" ]; then 
                    rm -rf ${INST_MEMCACHEDURL}; 
                    logMessage ">>> remove source archive in '${INST_MEMCACHEDURL}'..."; 
                fi
                chown -R root:root memcached-${INST_MEMCACHEDVERSION};
                cd memcached-${INST_MEMCACHEDVERSION};
            else
                ## tar xvfz ${INST_MEMCACHEDURL} ${INST_MEMCACHEDPATH}/. >/dev/null;
                if [ "$INST_KEEPARCHIVE" != "1" ]; then 
                    rm -rf ${INST_MEMCACHEDURL} >/dev/null; 
                    logMessage ">>> remove source archive in '${INST_MEMCACHEDURL}'..."; 
                fi
                chown -R root:root memcached-${INST_MEMCACHEDVERSION};
                cd memcached-${INST_MEMCACHEDVERSION};
            fi
        elif [ "${INST_MEMCACHEDURL:0:4}" == "http" ]; then
            # URL seems to be really an URL, download archive, etc... 
            logMessage ">>> source URL '${INST_MEMCACHEDURL}' given, download and extract new source archive...";
            if [ "$INST_VERBOSE" == "1" ]; then
                echo ">>> source URL '${INST_MEMCACHEDURL}' given, download and extract new source archive...";
                wget --no-check-certificate ${INST_MEMCACHEDURL} -O memcached-${INST_MEMCACHEDVERSION}.tar.gz;
                tar xvfz memcached-${INST_MEMCACHEDVERSION}.tar.gz;
                if [ "$INST_KEEPARCHIVE" != "1" ]; then 
                    rm memcached-${INST_MEMCACHEDVERSION}.tar.gz; 
                    logMessage ">>> remove source archive in 'memcached-${INST_MEMCACHEDVERSION}.tar.gz'..."; 
                fi
                chown -R root:root memcached-${INST_MEMCACHEDVERSION};
                cd memcached-${INST_MEMCACHEDVERSION};
            else
                wget --no-check-certificate ${INST_MEMCACHEDURL} -O memcached-${INST_MEMCACHEDVERSION}.tar.gz >/dev/null;
                tar xvfz memcached-${INST_MEMCACHEDVERSION}.tar.gz >/dev/null;
                if [ "$INST_KEEPARCHIVE" != "1" ]; then 
                    rm memcached-${INST_MEMCACHEDVERSION}.tar.gz >/dev/null; 
                    logMessage ">>> remove source archive in 'memcached-${INST_MEMCACHEDVERSION}.tar.gz'..."; 
                fi
                chown -R root:root memcached-${INST_MEMCACHEDVERSION};
                cd memcached-${INST_MEMCACHEDVERSION};
            fi
        else
            if [ "$INST_VERBOSE" == "1" ]; then 
                echo "WARNING: no source files to build memcached extension, canceling operation...";
                exit;
            fi
        fi
        
        
        # php-ize module
        ${INST_PATH}bin/phpize;
        
        # ./configure --with-php-config=....
        ./configure --with-php-config=${INST_PATH}/bin/php-config --with-libmemcached-dir=/usr --disable-memcached-sasl;
        
        # make && make install 
        make && make install;
        
        cp memcached.ini -> ${INST_PATH}/etc/php.d/
        cp memcached.ini ${INST_PATH}/etc/php.d/;
        rm -f ${INST_PATH}/etc/php.d/memcached_enabled.ini;
        
        # enable extension
        echo "zend_extension=memcached.so" >> ${INST_PATH}/etc/php.d/memcached_enabled.ini;
        
        
    fi

    if [ "$INST_VERBOSE" == "1" ]; then 
        echo "";
        echo ">>> finish applying memcached extension to new php version";
        echo "================================================================================================";
        echo "";
    fi
        logMessage ">>> finish applying memcached extension to new php version";
}


## display confirm dialog
##
confirm () {
    INST__CONFIRM=0
    if [ "$1" != "" ] 
        then
            read -p ">>> $1 [(YJ)/n]: " CONFIRMNEXTSTEP
            case "$CONFIRMNEXTSTEP" in
                Yes|yes|Y|y|Ja|ja|J|j|"") ## continue installing...
                    logMessage ">>> '$1' confirmed...";
                    INST__CONFIRM=1
                ;;
                *) ## operation canceled...
                    echo "WARNING: operation has been canceled through user interaction..."
                ;;
            esac
    fi
}


## write message to log-file...
##
logMessage () {
    if [ "$INST_SKIP_LOG" == "0" ] && [ "$1" != "" ]; then 
        echo "$1" >>${INST_LOGFILE}; 
    fi
}


## >>> START INSTALLER SCRIPT <<<
##


## init user parameters...
##
DISPLAYNAME=
PHPVERSION=
USERHOST=
USERURL=

TYPE=
OS=
ID=
CODENAME=
RELEASE=

detectOS

## parse installer arguments
##
CLI_ERROR=0
CLI_CMDOPTIONS_TEMP=`getopt -o d:p:t:i:l:H:I:s:u:T:envh --long displayname:,display-name:,php-version:,phpversion:,target-path:,targetpath:,path:,php-path:,phppath:,target-ini-path:,targetinipath:,ini-path:,inipath:,php-inipath:,phpinipath:,log-file:,logfile:,php-handler:,php-handler:,plesk-phphandler:,pleskphphandler:,plesk-id:,pleskid:,source-host:,sourcehost:,php-host:,phphost:,source-file:,sourcefile:,source-url:,sourceurl:,archive:,file:,sapi,apxs-path:,tmp-path:,tmppath:,edit-ini:,editini:,non-interactive,noninteractive,verbose,help,info,manual,man,skip-dependencies,disable-dependencies,skip-dependency-check,disable-dependency-check,skip-dependencycheck,disable-dependencycheck,skip-fetch,disable-fetch,skip-fetch-php,disable-fetch-php,skip-fetchphp,disable-fetchphp,skip-build,disable-build,skip-build-php,disable-build-php,skip-buildphp,disable-buildphp,skip-handler,disable-handler,skip-php-handler,disable-php-handler,skip-phphandler,disable-phphandler,apply-suhosin,suhosin,suhosin-host:,suhosin-version:,suhosin-url:,apply-xdebug,xdebug,xdebug-host:,xdebug-version:,xdebug-url:,apply-memcached,memcached,memcached-host:,memcached-version:,memcached-url:,configure: -n 'php2plesk.sh' -- "$@"`
while true; do
    case "${1}" in
    
## --- mandatory parameters --------
        -d|--display-name|--displayname)
        DISPLAYNAME=${2}
            shift 2
        ;;
        -p|--php-version|--phpversion)
        PHPVERSION=${2}
            shift 2
        ;;

## --- php version install options --------
        -t|--target-path|--targetpath|--path|--php-path|--phppath)
        TARGETINSTPATH=${2}
            shift 2
        ;;
        -i|--target-ini-path|--targetinipath|--inipath|--ini-path|--php-inipath|--phpinipath)
        TARGETINIPATH=${2}
            shift 2
        ;;
        -s|--source-host|--sourcehost|--php-host|--phphost)
            USERHOST=${2}
            shift 2
            ;;
        -u|--source-file|--sourcefile|--source-url|--sourceurl|--archive|--file)
            USERURL=${2}
            shift 2
            ;;
        --sapi)
            SAPI=1
            shift
            ;;
        --apxs-path)
            APXSPATH=${2}
            shift 2
            ;;
        --configure)
            CONFIGURE_MODE=${2}
            case "${CONFIGURE_MODE}" in
                *default*)
                    ## no action required now
                ;;
                *none*)
                    ## no action required now
                ;;
                *full*)
                    ## no action required now
                ;;
                *custom*)
                    ## no action required now
                ;;
                *)
                    CONFIGURE_MODE=default
                ;;
            esac
            
            shift 2
            ;;

## --- PLESK php_handler options --------
        -H|--php-handler|--phphandler|--plesk-phphandler|--pleskphphandler)
            PHPHANDLER=${2}
            shift 2
            ;;
        -I|--plesk-id|--pleskid)
            PLESKID=${2}
            shift 2
            ;;
        -T|--tmp-path|--tmppath)
            TMPPATH=${2}
            shift 2
            ;;


## --- SUHOSIN patch/extension options --------
        --apply-suhosin|--suhosin)
            shift
            SUHOSINAPPLY=1
            ;;
        --suhosin-version)
            SUHOSINVERSION=${2}
            shift 2
            ;;
        --suhosin-host)
            SUHOSINHOST=${2}
            shift 2
            ;;
        --suhosin-url)
            SUHOSINURL=${2}
            shift 2
            ;;


## --- xDebug extension options --------
        --apply-xdebug|--xdebug)
            shift
            XDEBUGAPPLY=1
            ;;
        --xdebug-version)
            XDEBUGVERSION=${2}
            shift 2
            ;;
        --xdebug-host)
            XDEBUGHOST=${2}
            shift 2
            ;;
        --xdebug-url)
            XDEBUGURL=${2}
            shift 2
            ;;


## --- memcached extension options --------
        --apply-memcached|--memcached)
            shift
            MEMCACHEDAPPLY=1
            ;;
        --memcached-version)
            MEMCACHEDVERSION=${2}
            shift 2
            ;;
        --memcached-host)
            MEMCACHEDHOST=${2}
            shift 2
            ;;
        --memcached-url)
            MEMCACHEDURL=${2}
            shift 2
            ;;


## --- installer script options -------
        -l|--log-file|--logfile)
            LOGFILE=${2}
            shift 2
            ;;

## --- installer script config flags -------
        -e|--edit-ini|--editini)
            shift
            INIEDIT=1
            ;;
        -n|--non-interactive|--noninteractive)    
            shift
            NONINTERACTIVE=1
            ;;
            
        -v|--verbose)    
            shift
            VERBOSE=1
            ;;

        -k|--keep-files)    
            shift
            KEEP_FILES=1
            ;;            
        -K|--keep-archive)    
            shift
            KEEP_ARCHIVE=1
            ;;

## --- installer script flags to skip operations -------
        --skip-dependencies|--disable-dependencies|--skip-dependency-check|--disable-dependency-check|--skip-dependencycheck|--disable-dependencycheck)
            shift
            SKIP_DEPENDENCIES=1
            ;;
        --skip-fetch|--disable-fetch|--skip-fetch-php|--disable-fetch-php|--skip-fetchphp|--disable-fetchphp)    
            shift
            SKIP_FETCHPHP=1
            ;;
        --skip-build|--disable-build|--skip-build-php|--disable-build-php|--skip-buildphp|--disable-buildphp)    
            shift
            SKIP_BUILDPHP=1
            ;;
        --skip-handler|--disable-handler|--skip-php-handler|--disable-php-handler|--skip-phphandler|--disable-phphandler)    
            shift
            SKIP_PHPHANDLER=1
            ;;
        
        --skip-log|--disable-log)    
            shift
            SKIP_LOG=1
            ;;

## --- installer script info/help --------
        -h|--help|--info|--manual|--man)
            shift    
            scriptusage
            scriptvendor
            exit
            ;;

        --) 
            shift
            break
            ;;
        *)    
            ## halt on unknown parameters
            #echo "ERROR: invalid command line option/argument : ${1}!"
            #CLI_ERROR=1
            #break
            
            ## ignore unknown parameters
            shift
            break
            ;;

    esac
done
CLI_CMDARGUMENTS=( ${CLI_CMDOPTIONS[@]} )

## halt on command line error...
##
if [ $CLI_ERROR == 1 ]
    then
        scriptusage    
        scriptvendor
        exit 1
fi

## check for mandatory installer argument values
##
if [[ -z $DISPLAYNAME ]] || [[ -z $PHPVERSION ]] || [[ -z $TARGETINSTPATH ]] || [[ -z $TARGETINIPATH ]] || [[ -z $LOGFILE ]] || [[ -z $PHPHANDLER ]] || [[ -z $PLESKID ]] || [[ -z $SRCHOST ]] || [[ -z $SRCURL ]]
then
     scriptusage    
     #scriptvendor
     exit 1
fi

## select/perform installer operations...
##

    ## sampling paths and vars...
    ##
    clear;
    current_work_dir=`pwd`;
    
    INST_VERSION=$PHPVERSION
    INST_EXTRA_VERSION=${" "/EXTRAVERSION/" @ "/`date`}
    INST_DISPLAYNAME=$DISPLAYNAME
    INST_PATH=${TARGETINSTPATH//_PHPVERSION_/"$INST_VERSION"}
    INST_INIPATH=${TARGETINIPATH//_PHPVERSION_/"$INST_VERSION"}
    INST_PHPHANDLER=$PHPHANDLER
    INST_LOGFILE=$LOGFILE
    INST_TMPPATH=${TMPPATH}
    INST_SRCPATH="${INST_TMPPATH}php-${INST_VERSION}/"
    INST_PLESKID=${PLESKID//_PHPVERSION_/"$INST_VERSION"}
    INST_SAPI=${SAPI}
    INST_APXSPATH=${APXSPATH}
    INST__CONFIRM=0
    
    INST_SKIP_DEPENDENCIES=$SKIP_DEPENDENCIES
    INST_SKIP_FETCHPHP=$SKIP_FETCHPHP
    INST_SKIP_BUILDPHP=$SKIP_BUILDPHP
    INST_SKIP_PHPHANDLER=$SKIP_PHPHANDLER
    INST_SKIP_LOG=$SKIP_LOG || [ ! -w ${INST_LOGFILE} ]
    
    INST_INIEDIT=${INIEDIT}
    INST_VERBOSE=${VERBOSE}
    INST_NONINTERACTIVE=${NONINTERACTIVE}
    INST_KEEPFILES=${KEEP_FILES}
    INST_KEEPARCHIVE=${KEEP_ARCHIVE}
    
    case "$USERHOST" in
        "") INST_SRCHOST=$SRCHOST
        ;;
        *) INST_SRCHOST=$USERHOST
        ;;
    esac
    case "$USERURL" in
        "") INST_SRCURL=${SRCURL//_PHPVERSION_/"$INST_VERSION"}
            INST_SRCURL=${INST_SRCURL//_PHPHOST_/"$INST_SRCHOST"}
        ;;
        *) INST_SRCURL=$USERURL
        ;;
    esac
    
    if [[ ${INST_SAPI} == 1 ]] 
        then 
            INST_PLESKID=${INST_PLESKID//"-cgi"/"-sapi"}
    fi
    
    INST_CONFIGURE_MODE=${CONFIGURE_MODE}
    INST_PHPBASECONF=
    INST_PHPCONFIGURE=${PHPMODS}
    
    # SUHOSIN
    INST_SUHOSIN=${SUHOSINAPPLY}
    if [[ ${INST_SUHOSIN} == 1 ]] 
        then 
            INST_PLESKID="${INST_PLESKID}-suhosin"
    fi
    INST_SUHOSINVERSION=${SUHOSINVERSION}
    INST_SUHOSINHOST=${SUHOSINHOST}
    INST_SUHOSINURL=${SUHOSINURL//_SUHOSINHOST_/"$INST_SUHOSINHOST"}
    INST_SUHOSINURL=${INST_SUHOSINURL//_SUHOSINVERSION_/"$INST_SUHOSINVERSION"}
    INST_SUHOSINPATH="${INST_PATH}/suhosin-${INST_SUHOSINVERSION}/"
    
    # xDebug
    INST_XDEBUG=${XDEBUGAPPLY}
    if [[ ${INST_XDEBUG} == 1 ]] 
        then 
            INST_PLESKID="${INST_PLESKID}-xdebug"
    fi
    INST_XDEBUGVERSION=${XDEBUGVERSION}
    INST_XDEBUGHOST=${XDEBUGHOST}
    INST_XDEBUGURL=${XDEBUGURL//_XDEBUGHOST_/"$INST_XDEBUGHOST"}
    INST_XDEBUGURL=${INST_XDEBUGURL//_XDEBUGVERSION_/"$INST_XDEBUGVERSION"}
    INST_XDEBUGPATH="${INST_PATH}/xdebug-${INST_XDEBUGVERSION}/"
    
    # memcached
    INST_MEMCACHED=${MEMCACHEDAPPLY}
    if [[ ${INST_MEMCACHED} == 1 ]] 
        then 
            INST_PLESKID="${INST_PLESKID}-memcached"
    fi
    INST_MEMCACHEDVERSION=${MEMCACHEDVERSION}
    INST_MEMCACHEDHOST=${MEMCACHEDHOST}
    INST_MEMCACHEDURL=${MEMCACHEDURL//_MEMCACHEDHOST_/"$INST_MEMCACHEDHOST"}
    INST_MEMCACHEDURL=${INST_MEMCACHEDURL//_MEMCACHEDVERSION_/"$INST_MEMCACHEDVERSION"}
    INST_MEMCACHEDPATH="${INST_PATH}/memcached-${INST_MEMCACHEDVERSION}/"
    
    ## check if paths and targets are set properly...
    ##
    SETTINGERROR=0
    if [[ -d $INST_PATH ]] 
        then
            echo "ERROR: there already is a php version installed under '$INST_PATH', please select another path using option '-t path'...";
            logMessage "ERROR: there already is a php version installed under '$INST_PATH', please select another path using option '-t path'...";
            SETTINGERROR=1
    fi 
    if [[ ! -d $INST_TMPPATH ]] 
        then
            echo "ERROR: '$INST_TMPPATH' does not exist or you have no permission to write there, please select another path using option '-T path'...";
            logMessage "ERROR: '$INST_TMPPATH' does not exist or you have no permission to write there, please select another path using option '-T path'...";
            SETTINGERROR=1
    fi 
    if [[ ! -d $INST_SRCPATH ]] 
        then
            mkdir $INST_SRCPATH
        else 
            echo "ERROR: '$INST_SRCPATH' already exists, in case another installation is already running, please wait for that process to finish (strongly recommended!) or select another temporary storage path using option '-T path' or remove it...";
            logMessage "ERROR: '$INST_SRCPATH' already exists, in case another installation is already running, please wait for that process to finish (strongly recommended!) or select another temporary storage path using option '-T path' or remove it...";
            SETTINGERROR=1
    fi 
    if [[ ! -f $INST_PHPHANDLER ]] 
        then
            echo "ERROR: PLESK 'php_handler' command could not be found '$INST_PHPHANDLER', please select another target path using option '--php-handler filepath'...";
            logMessage "ERROR: PLESK 'php_handler' command could not be found '$INST_PHPHANDLER', please select another target path using option '--php-handler filepath'...";
            SETTINGERROR=1
    fi 
    if [ $INST_SUHOSIN == 1 ] && [[ -z $INST_SUHOSINVERSION ]] 
        then
            echo "ERROR: to apply SUHOSIN patch/extension, you must specify a version with '--suhosin-version={version}'...";
            logMessage "ERROR: to apply SUHOSIN patch/extension, you must specify a version with '--suhosin-version={version}'...";
            SETTINGERROR=1
    fi 
    if [ $INST_XDEBUG == 1 ] && [[ -z $INST_XDEBUGVERSION ]] 
        then
            echo "ERROR: to apply xDebug extension, you must specify a version with '--xdebug-version={version}'...";
            logMessage "ERROR: to apply xDebug extension, you must specify a version with '--xdebug-version={version}'...";
            SETTINGERROR=1
    fi 
    
    touch $INST_LOGFILE
    if [[ ! -w $INST_LOGFILE ]] 
        then
            echo "ERROR: could not write to log-file '$INST_LOGFILE', please select another log-file using option '-l filepath'...";
            logMessage "ERROR: could not write to log-file '$INST_LOGFILE', please select another log-file using option '-l filepath'...";
            SETTINGERROR=1
    fi 
    
    ## assemple php configure parameters and set library paths
    ##
    configure_php;
    
    if [[ $SETTINGERROR == 1 ]] 
        then
            scriptinfo
            scriptusage
            scriptvendor
            exit
    fi 
    
    
    ## show installer configuration, confirm install
    ##
    scriptinfo
    
    CONTINUEINSTALL=0
    if [ $NONINTERACTIVE == 0 ]
        then
            confirm "Do you really want to continue installing a new php handler to your PLESK environment?";
            CONTINUEINSTALL=$INST__CONFIRM;
        else
            CONTINUEINSTALL=1;
    fi
    
    ## execute the installer methods...
    ##
    if [ $CONTINUEINSTALL == 1 ]
        then
            
            ## check and install basic dependencies...
            ##
            if [ $NONINTERACTIVE == 0 ] && [ $INST_SKIP_DEPENDENCIES == 0 ]
                then
                    confirm "Do you want to check for dependencies applying to your system environment?";
                    CONTINUE_STEP=$INST__CONFIRM;
                else
                    CONTINUE_STEP=1;
            fi
            if [ $CONTINUE_STEP == 1 ] && [ $CONTINUEINSTALL == 1 ] && [ $INST_SKIP_DEPENDENCIES == 0 ]
                then
                    install_basics;
            fi
        
            ## get php sources
            ##
            if [ $NONINTERACTIVE == 0 ] && [ $INST_SKIP_FETCHPHP == 0 ]
                then
                    confirm "Do you really want to download a new php source archive (php ${INST_VERSION})?";
                    CONTINUE_STEP=$INST__CONFIRM;
                else
                    CONTINUE_STEP=1;
            fi
            if [ $CONTINUE_STEP == 1 ] && [ $INST_SKIP_FETCHPHP == 0 ]
                then
                    ## get and prepare php sources
                    ##
                    fetch_php;
        
                    prepare_git_sources;

                    ## build php
                    ##
                    if [ $NONINTERACTIVE == 0 ] && [ $INST_SKIP_BUILDPHP == 0 ]
                        then
                            confirm "Do you want to build php version (php ${INST_VERSION}) for your system environment?";
                            CONTINUE_STEP=$INST__CONFIRM;
                        else
                            CONTINUE_STEP=1;
                    fi
                    if [ $CONTINUE_STEP == 1 ] && [ $INST_SKIP_BUILDPHP == 0 ]
                        then
                            
                            ## actually build php binaries
                            ##
                            build_php;


                            ## apply SUHOSIN patch/extension
                            ##
                            if [ $NONINTERACTIVE == 0 ] && [ $INST_SUHOSIN == 1 ]
                                then
                                    confirm "Do you want to add SUHOSIN patch/extension (${INST_SUHOSINVERSION}) to new php version?";
                                    CONTINUE_STEP=$INST__CONFIRM;
                                else
                                    CONTINUE_STEP=1;
                            fi
                            if [ $CONTINUE_STEP == 1 ] && [ $INST_SUHOSIN == 1 ]
                                then
                                    apply_suhosin;
                            
                            fi
                            
                            
                            ## apply xDebug extension
                            ##
                            if [ $NONINTERACTIVE == 0 ] && [ $INST_XDEBUG == 1 ]
                                then
                                    confirm "Do you want to add xDebug extension (${INST_MEMCACHEDVERSION}) to new php version?";
                                    CONTINUE_STEP=$INST__CONFIRM;
                                else
                                    CONTINUE_STEP=1;
                            fi
                            if [ $CONTINUE_STEP == 1 ] && [ $INST_XDEBUG == 1 ]
                                then
                                    apply_xdebug;
                            
                            fi
                            
                            
                            ## apply memcached extension
                            ##
                            if [ $NONINTERACTIVE == 0 ] && [ $INST_MEMCACHED == 1 ]
                                then
                                    confirm "Do you want to add memcached extension (${INST_MEMCACHEDVERSION}) to new php version?";
                                    CONTINUE_STEP=$INST__CONFIRM;
                                else
                                    CONTINUE_STEP=1;
                            fi
                            if [ $CONTINUE_STEP == 1 ] && [ $INST_MEMCACHED == 1 ]
                                then
                                    apply_memcached;
                            
                            fi
                            
                            
                            ## apply php-handler
                            ##
                            if [ $NONINTERACTIVE == 0 ] && [ $INST_SKIP_PHPHANDLER == 0 ]
                                then
                                    confirm "Do you want to add a new php handler -${INST_DISPLAYNAME}- (php ${INST_VERSION}) to your PLESK environment?";
                                    CONTINUE_STEP=$INST__CONFIRM;
                                else
                                    CONTINUE_STEP=1;
                            fi
                            if [ $CONTINUE_STEP == 1 ] && [ $INST_SKIP_PHPHANDLER == 0 ]
                                then
                                    apply_php;
                                    
                            fi
                            
                            
                    fi # skip build_php ?
                    
            fi # skip fetch_php ?
            
    fi # go?

    ## return to last working directory...
    cd ${current_work_dir};

    ## display installer vendor info
    scriptvendor;

## exit installer script
exit 0;