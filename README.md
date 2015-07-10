## php-to-PLESK build and install script, v1.0


### USAGE: 

`/root/php2plesk/php2plesk.sh {php-version} {displayname}`
   
OR

`/root/php2plesk/php2plesk.sh -p {php-version} -d {displayname} [more options]` (see below)
   



### DESCRIPTION:

   build new set of php binaries from (downloaded) sources and install addional PHP(-fast-cgi) version to PLESK 11.5+ environment on Ubuntu 10+ or similar...



### OPTIONS:


*	`-d name`                        PLESK panel display name
*	`-p version`                     php version (ex: 5.6.9)
*	`-t path`                        target path for php installation (default '/usr/local/php_PHPVERSION_-cgi/')
*	`-i filepath`                    target path for php.ini file (default '/usr/local/php_PHPVERSION_-cgi/etc/')
*	`-l filepath`                    target path to installer logfile (default './php2plesk.log')
*	`-H filepath`                    target path to PLESK panel 'php_handler' command (default '/usr/local/psa/bin/php_handler')
*	`-I plesk-id`                    overwrite PLESK internal ID (default '_PHPVERSION_-custom')
*	`-s hostname`                    overwrite php.net mirror hostname to download php source files (default 'de1')
*	`-u url`                         overwrite url to download php source files (overranks '-H hostname' option)
*	`-T path`                        installer path for temporary file storage (default '/tmp/')
*	`-e`                             open php.ini file to be edited (requires vim)
*	`-n`                             be non-interactive (overranks '-e' option)
*	`-h`                             show this message
*	`-v`                             verbose output
*	`--sapi`                         also compile apache2 module, use with caution(!)
*	`--apxs-path`                    set path to 'apxs2' command (default: '/usr/bin/apxs2')
*	`--suhosin`                      add SUHOSIN patch/extension to php configuration, must also set '--suhosin-version'
*	`--suhosin-version version`      SUHOSIN patch/extension version (ex: '0.9.37.1') 
*	`--suhosin-host hostname`        hostname for SUHOSIN patch/extension source download (optional, default: 'download.suhosin.org')
*	`--xdebug`                       add xDebug extension to php configuration, must also set '--xdebug-version'
*	`--xdebug-version version`       xDebug extension version (ex: '2.3.2') 
*	`--xdebug-host hostname`         hostname for xDebug extension source download (optional, default: 'xdebug.org')
*	`--memcached`                    add memcached extension to php configuration, must also set '--memcached-version'
*	`--memcached-version version`    memcached extension version (ex: '1.4.24') 
*	`--memcached-host hostname`      hostname for memcached extension source download (optional, default: 'memcached.org')



   
#### placeholders for path and hostname/url parameters:


*	`_PHPVERSION_`          php version (ex: '5.6.9')
*	`_PHPHOST_`             php.net mirror hostname (ex: 'de1')
*	`_SUHOSINVERSION_`      SUHOSIN patch/extension version (ex: '0.9.37.1')
*	`_SUHOSINHOST_`         SUHOSIN patch/extension source download hostname (ex: 'download.suhosin.org')
*	`_XDEBUGVERSION_`       xDebug extension version (ex: '2.3.2')
*	`_XDEBUGHOST_`          xDebug extension source download hostname (ex: 'xdebug.org')
*	`_MEMCACHEDVERSION_`    xDebug extension version (ex: '2.3.2')
*	`_MEMCACHEDHOST_`       xDebug extension source download hostname (ex: 'memcached.org')

	
	
### EXAMPLES:

-	to compile php5.6.9 including suhosin patch enter...

	  `/root/php2plesk/php2plesk.sh -v -p 5.6.9 -d 5.6.09-suhosin -t /usr/local/php5.6.9-cgi-suhosin/ --suhosin --suhosin-version 0.9.37.1 -i /usr/local/php5.6.9-cgi-suhosin/etc/ -n`
	
	  ...and add it to plesk's list of php-handlers:
	  
	  `/usr/local/psa/bin/php_handler --add -displayname 5.6.09-suhosin -path /usr/local/php5.6.9-cgi-suhosin/bin/php-cgi -phpini /usr/local/php5.6.9-cgi-suhosin/etc/php.ini -type fastcgi -id 5.6.9-cgi-custom-suhosin`
	
	  ...got to domain's hosting settings and select the new php handler, click 'Ok'
	
	
-	compile an older php version...

	  `/root/php2plesk/php2plesk.sh -v -p 5.3.2 -d 5.3.2 -t /usr/local/php5.3.2-cgi-suhosin/  -i /usr/local/php5.3.2-cgi-suhosin/etc/ --suhosin --suhosin-version 0.9.37.1 -n -u http://museum.php.net/php5/php-5.3.2.tar.gz`
	  
	  
	  

### @TODO: 


*	inside methods, check if files/directories are generated properly or if they are executable if needed
*	simplify basics/dependencies install method


