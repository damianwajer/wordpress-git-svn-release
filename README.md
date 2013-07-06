# wp-release
*Tags and deploys a WordPress plugin release from Git to the Subversion WordPress Plugin Directory.*

WordPress plugin developers want to use this script, in case

1. you develop and maintain your plugin using Git (e.g., on [github](https://github.com))
1. you want to maintain and publish releases for your plugin in the [WordPress Plugin Directory](http://wordpress.org/plugins/about/)
1. you want to automate this process (and stay away from _ugh, Subversion_) as much as possible.

## Features

* Verifies and confirms release information prior to execution.
* Dump-exports git tag into svn checkout (without history), ignoring git specific files.
* Commits, pushes, and creates a new release tag in both git and svn.
* Cleanly separated configuration and execution to support plugin-specific configuration.
* _Dry-run_ support for initial testing.


## Installation

1. Clone or download this package; e.g.,

        /usr/local/bin/wp-release

1. Make `wp-release.sh` executable; e.g.,

        chmod 755 /usr/local/bin/wp-release/wp-release.sh

1. Optional: Make the script available in a directory of your shell environment `PATH`; e.g.,

        ln -s /usr/local/bin/wp-release/wp-release.sh /usr/local/bin/wp-release

1. Copy the included `.wp-release.conf` file into your plugin directory; e.g.,

        cp /usr/local/bin/wp-release/.wp-release.conf /path/to/myplugin/.wp-release.conf

1. Customize (and optionally commit) the `.wp-release.conf` file to your plugin's git repository.

        git add .wp-release.conf
        git commit

For example, a typical setup would look like this:

      (executable) /usr/local/bin/wp-release/wp-release.sh
      (link)       /usr/local/bin/wp-release -> wp-release/wp-release.sh
      
      (conf)       /var/www/mydevsite/wp-content/plugins/myplugin/.wp-release.conf

#### Windows

_Harder._  As usual.  Try this:

1. Start the mingw32 bash shell (assuming [TortoiseGit](http://code.google.com/p/tortoisegit/)) or [Cygwin](http://www.cygwin.com/) bash shell.
1. Change to your plugin directory.
1. Execute the script via `/c/path/to/wp-release/wp-release.sh`

Ideas and improvements very welcome.


## Usage

1. Change to your plugin directory.

         $ cd /var/www/mydevsite/wp-content/plugins/myplugin

1. Prepare the new release version in `readme.txt` and your plugin's main PHP file.

         $ vi readme.txt
         $ vi myplugin.php

1. Execute the script from within your plugin directory.

         $ wp-release.sh


Doing so will:

1. Validate your config file.
1. Verify whether versions in `readme.txt` and the plugin's PHP header match.
1. Validate that the specified version does not exist as tag yet.
1. Ask you to review & commit the changes to git.
1. Check out the WordPress subversion repository.
1. Dump-export the code of the git tag into svn trunk.
1. Ask you to confirm the changes to svn.
1. Commit the changes + new tag to the WordPress Plugin Directory.

After execution, the new release is effectively published and out of the door; both in git as well as on WordPress.org.


## FAQ

#### Why no history in svn?

Because WordPress.org infrastructure maintainers explicitly ask you to omit it.  You're using WordPress.org as a tool for publishing releases only.  If you don't develop on WordPress.org, there's no point in syncing the entire history.

Dump-export replacements for each release is all that you want and need. — This fact inherently eliminates the topic of `git-svn`.

#### Can I improve it?

Weird question.  Of course, you can! :)  Here's how:

1. Fork the repo on github, create a branch, do your changes, and create a pull request (PR) when you're done.
1. Ensure the changes in your PR are focused and atomic.  Change one thing at a time.  Use multiple PRs for multiple different issues.
1. Ensure your commits are topically atomic, isolated, and cleanly separated.  Perform one set of directly related changes at a time.  Use multiple commits for different/additional changes.


## Credits

* Daniel F. Kudwien (@sun)
* Ben Balter (@benbalter)
* Brent Shepherd (@thenbrent)
* Dean Clatworthy (@deanc)


### History

Open-source at its worst. ;)  To recap:

* Originally authored by @deanc  
  https://github.com/deanc/wordpress-plugin-git-svn
* Shell-ized by @spurge  
  https://github.com/spurge/wordpress-plugin-git-svn
* Improved by @thenbrent (unmergeable)  
  https://github.com/thenbrent/multisite-user-management/blob/master/deploy.sh
    * Further improved by @BFTrick  
      https://gist.github.com/BFTrick/3767319  
      cf. http://speakinginbytes.com/2012/10/wordpress-plugin-deployment-script/
    * Significantly improved by @benbalter  
      https://github.com/benbalter/Github-to-WordPress-Plugin-Directory-Deployment-Script
        * Slightly hardened by @cubetech  
          https://github.com/cubetech/wordpress.plugin-deployment-script.git
* Reviewed, replayed, merged history and revamped by @sun  
  https://github.com/sun/wordpress-git-svn-release


## License

No author ever specified a license; the most permissive MIT license is assumed.
