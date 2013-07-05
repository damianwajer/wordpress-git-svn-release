Github to WordPress Plugin Directory Deployment Script
======================================================
*Deploys a WordPress plugin from Github (git) to the WordPress Plugin Repostiory (svn)*

Features
--------

* Prompts for plugin slug and commit message 
* Verifies plugin header version number matches readme stable version number
* Commits local version to github and tags
* Copies git export to svn trunk
* Removes git specific files (.gitignore, readme.md) from trunk
* Commits to svn trunk, and creates new svn tag

Use
---

Place in parent directory (e.g. wp-content/plugins/) and run as ./deploy.sh (may need to chmod 0755 first)

History
-------

Adapted from https://github.com/thenbrent/multisite-user-management/blob/master/deploy.sh

thenbrent's version was a modification of Dean Clatworthy's deploy script found at
https://github.com/deanc/wordpress-plugin-git-svn

Changes
-------

* Don't require existing SVN (thenbrent)
* Move from plugin repo to parent
* Prompt for plugin slug
* SVN 1.6 compatibility (svn propset before exporting from git)
* Capitalized the "P" in WordPress

Note
-----

This deployment script does everything. Once it's run your plugin will be updated on WordPress and pushed out to all your users. 