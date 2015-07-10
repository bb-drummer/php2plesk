## php-to-PLESK build and install script, v1.0


### USAGE: 

   `/root/php2plesk/php2plesk.sh {php-version} {displayname}`
   
   OR
   `/root/php2plesk/php2plesk.sh -p {php-version} -d {displayname} [more options] (see below)`
   



### DESCRIPTION:

   build new set of php binaries from (downloaded) sources and install addional PHP(-fast-cgi) version to PLESK 11.5+ environment on Ubuntu 10+ or similar...



### OPTIONS:


<table>
	<tr>
		<td align="right">-d</td>
		<td>name</td>
		<td>PLESK panel display name</td>
	</tr>
	<tr>
		<td align="right">-p</td>
		<td>version</td>
		<td>php version (ex: 5.6.9)</td>
	</tr>
</table>


<table>
	<tr>
		<td align="right">-t</td>
		<td>path</td>
		<td>target path for php installation (default '/usr/local/php_PHPVERSION_-cgi/')</td>
	</tr>
	<tr>
		<td align="right">-i</td>
		<td>filepath</td>
		<td>target path for php.ini file (default '/usr/local/php_PHPVERSION_-cgi/etc/')</td>
	</tr>
</table>


<table>
	<tr>
		<td align="right">-l</td>
		<td>filepath</td>
		<td>target path to installer logfile (default './php2plesk.log')</td>
	</tr>
	<tr>
		<td align="right">-H</td>
		<td>filepath</td>
		<td>target path to PLESK panel 'php_handler' command (default '/usr/local/psa/bin/php_handler')</td>
	</tr>
	<tr>
		<td align="right">-I</td>
		<td>plesk-id</td>
		<td>overwrite PLESK internal ID (default '_PHPVERSION_-custom')</td>
	</tr>
</table>


<table>
	<tr>
		<td align="right">-s</td>
		<td>hostname</td>
		<td>overwrite php.net mirror hostname to download php source files (default 'de1')</td>
	</tr>
	<tr>
		<td align="right">-u</td>
		<td>url</td>
		<td>overwrite url to download php source files (overranks '-H hostname' option)</td>
	</tr>
</table>


<table>
	<tr>
		<td align="right">-T</td>
		<td>path</td>
		<td>installer path for temporary file storage (default '/tmp/')</td>
	</tr>
	<tr>
		<td align="right">-h</td>
		<td> </td>
		<td>show this message</td>
	</tr>
	<tr>
		<td align="right">-v</td>
		<td> </td>
		<td>verbose output</td>
	</tr>
</table>


<table>
	<tr>
		<td align="right">--sapi</td>
		<td> </td>
		<td>also compile apache2 module, use with caution(!)</td>
	</tr>
	<tr>
		<td align="right">--apxs-path</td>
		<td>path</td>
		<td>set path to 'apxs2' command (default: '/usr/bin/apxs2')</td>
	</tr>
</table>


<table>
	<tr>
		<td align="right">--suhosin</td>
		<td> </td>
		<td>add SUHOSIN patch/extension to php configuration, must also set '--suhosin-version'</td>
	</tr>
	<tr>
		<td align="right">--suhosin-version</td>
		<td>version</td>
		<td>SUHOSIN patch/extension version (ex: '0.9.37.1')</td>
	</tr>
	<tr>
		<td align="right">--suhosin-host</td>
		<td>hostname</td>
		<td>hostname for SUHOSIN patch/extension source download (optional, default: 'download.suhosin.org')</td>
	</tr>
</table>


<table>
	<tr>
		<td align="right">--xdebug</td>
		<td> </td>
		<td>add xDebug extension to php configuration, must also set '--xdebug-version'</td>
	</tr>
	<tr>
		<td align="right">--xdebug-version</td>
		<td>version</td>
		<td>xDebug extension version (ex: '0.9.37.1')</td>
	</tr>
	<tr>
		<td align="right">--xdebug-host</td>
		<td>hostname</td>
		<td>hostname for xDebug extension source download (optional, default: 'xdebug.org')</td>
	</tr>
</table>


<table>
	<tr>
		<td align="right">--memcached</td>
		<td> </td>
		<td>add memcached extension to php configuration, must also set '--memcached-version'</td>
	</tr>
	<tr>
		<td align="right">--memcached-version</td>
		<td>version</td>
		<td>memcached extension version (ex: '0.9.37.1')</td>
	</tr>
	<tr>
		<td align="right">--memcached-host</td>
		<td>hostname</td>
		<td>hostname for memcached extension source download (optional, default: 'memcached.org')</td>
	</tr>
</table>



   
#### placeholders for path and hostname/url parameters:


<table>
	<tr>
		<td>\_PHPVERSION_</td>
		<td>php version (ex: '5.6.9')</td>
	</tr>
	<tr>
		<td>\_PHPHOST_</td>
		<td>php.net mirror hostname (ex: 'de1')</td>
	</tr>
	<tr>
		<td>\_SUHOSINVERSION_</td>
		<td>SUHOSIN patch/extension version (ex: '0.9.37.1')</td>
	</tr>
	<tr>
		<td>\_SUHOSINHOST_</td>
		<td>SUHOSIN patch/extension source download hostname (ex: 'download.suhosin.org')</td>
	</tr>
	<tr>
		<td>\_XDEBUGVERSION_</td>
		<td>xDebug extension version (ex: '2.3.2')</td>
	</tr>
	<tr>
		<td>\_XDEBUGHOST_</td>
		<td>xDebug extension source download hostname (ex: 'xdebug.org')</td>
	</tr>
	<tr>
		<td>\_MEMCACHEDVERSION_</td>
		<td>xDebug extension version (ex: '2.3.2')</td>
	</tr>
	<tr>
		<td>\_MEMCACHEDHOST_</td>
		<td>xDebug extension source download hostname (ex: 'memcached.org')</td>
	</tr>
</table>

	
	
### EXAMPLES:

-	to compile php5.6.9 including suhosin patch enter...

	  `/root/php2plesk/php2plesk.sh -v -p 5.6.9 -d 5.6.09-suhosin -t /usr/local/php5.6.9-cgi-suhosin/ --suhosin --suhosin-version 0.9.37.1 -i /usr/local/php5.6.9-cgi-suhosin/etc/ -n`
	
	  ...and add it to plesk's list of php-handlers:
	  
	  `/usr/local/psa/bin/php_handler --add -displayname 5.6.09-suhosin -path /usr/local/php5.6.9-cgi-suhosin/bin/php-cgi -phpini /usr/local/php5.6.9-cgi-suhosin/etc/php.ini -type fastcgi -id 5.6.9-cgi-custom-suhosin`
	
	  ...got to domain's hosting settings and select the new php handler, click 'Ok'
	
	
-	compile an older php version...

	  `/root/php2plesk/php2plesk.sh -v -p 5.3.2 -d 5.3.2 -t /usr/local/php5.3.2-cgi-suhosin/  -i /usr/local/php5.3.2-cgi-suhosin/etc/ --suhosin --suhosin-version 0.9.37.1 -n -u http://museum.php.net/php5/php-5.3.2.tar.gz`
