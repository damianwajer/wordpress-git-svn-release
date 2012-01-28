Wordpress Plugin Deployment
===========================

1. Initialise your git repository using 'git init' in your wordpress plugin directory (e.g. /path/to/wordpress/wp-content/plugins/<plugin-name>/
2. Preferably create a project on github and push your project there.
3. Clone this deploy-thing somewhere and go there.
4. Run deploy.sh

Options
-------

If no options are specified, the script will prompt for your input.

* -n Plugin name What's the name of your plugin?
* -s SVN remote Where's your SVN repository?
* -m SVN message [optional] A message for the subversion commit (default:
	Updating with version %s)
* -u SVN username [optional] Subversion remote username
* -p SVN password [optional] Subversion remote password
* -g Git remote Where's your git repository?
* -c Git commit [optional] If you want to commit a specified commit

Example
-------

`./deploy.sh -n my-awesome-plugin -s http://plugins.svn.wordpress.org/my-awesome-plugin -g git@github.com:pluginauthor/my-awesome-plugin.git`

Warning
-------

This deployment script does everything. Once it's run your plugin will be
updated on wordpress and pushed out to all your users. So make sure your
code is ready and tested and that you have increase the version numbers
in your files :)
