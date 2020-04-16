                                Sylvain Benilan - s.benilan@claire-language.com


                  Installation notice for mod_wcl

mod_wcl is an Apache 2.x module (i.e. a library that is dynamicaly loaded by
the httpd server). The WebClaire environment requires an installation of this
module.


== UNIX (Linux, Darwin, Sun, Cygwin ...) ==

			[PATH_TO_APACHE2_BIN/]apxs -a -i -c mod_wcl.c

		apxs is a tool part of the Apache distribution. It will compile the
		Apache 2.x module mod_wcl and install it in the Apache module repository.
		It will also add the module declaration directive in the Apache
		configuration file (httpd.conf).

== MacOSX 10.5 (for earlier release see UNIX section) ==

Tested under Intel based Mac.

			sudo apxs -a -Wc,-arch -Wc,x86_64 -Wl,-arch -Wl,x86_64 -i -c mod_wcl.c

		apxs will prompt you for your password to install the module.


== Win32 - VisualC++ ==

			copy mod_wcl.so "APACHE_HOME\modules"

		Where APACHE_HOME is the path where Apache 2.x is installed on Win32.
		For instance APACHE_HOME may be 'C:\Program Files\Apache Group\Apache2'.
		Note that for Win32 the mod_wcl.so is a precompiled version (However if
		one want to modify this module a makefile (Makefile.nt) is available in
		Wcl\cgi directory, the APR will then be needed).

		Then you'll have to edit the Apache 2.x httpd.conf file to add a directive
		that loads the module mod_wcl.so. The configuration file should already
		contain a line that contain 'LoadModule', Search for such a line and add
		manualy in the httpd.conf the following line :

			LoadModule wcl_module modules/mod_wcl.so

