#!/bin/bash
#
# Creates and pushes a git tag to the svn WordPress.org Plugin Directory.

SELFDIR=${BASH_SOURCE%/*}

source .wp-release.conf

# Validate configuration.
[[ -n $SHORTNAME ]] || { echo >&2 "ERROR: Plugin shortname must not be empty."; exit 1; }
[[ -e $PLUGINPATH ]] || { echo >&2 "ERROR: Configured plugin path does not exist."; exit 1; }
[[ -e $PLUGINPATH/$MAINFILE ]] || { echo >&2 "ERROR: Configure main plugin file does not exist."; exit 1; }
[[ -n $SVNUSER ]] || { echo >&2 "ERROR: Subversion username must not be empty."; exit 1; }
[[ -n $SVNPASS ]] || { echo >&2 "ERROR: Subversion password must not be empty."; exit 1; }

if [ ! -f "$PLUGINPATH/$MAINFILE" ]; then echo "Plugin is not properly developed. Needed file '$PLUGINPATH/$MAINFILE' does not exists. Exiting...."; exit 1; fi
if [ ! -f "$PLUGINPATH/readme.txt" ]; then echo "Plugin is not properly developed. Needed file '$PLUGINPATH/readme.txt' does not exists. Exiting...."; exit 1; fi
if [ `egrep -l $'\r'\$ $PLUGINPATH/readme.txt` ] || [ `egrep -l $'\r'\$ $PLUGINPATH/$MAINFILE` ]; then echo "STOP! There are files with windows line ending. Please clean this up! Exiting...."; exit 1; fi

# Initialize variables.
SVNURL=${SVNURL:="http://plugins.svn.wordpress.org/$SHORTNAME/"}
SVNCMD="svn --username=$SVNUSER --password=$SVNPASS"

if [[ $DRYRUN != 0 ]]; then
	DRYRUN="echo +"
else
	DRYRUN=
fi

# Output header.
echo "Project: $SHORTNAME"
echo "Source:  $PLUGINPATH"
echo "Target:  $SVNURL"
echo

# Validate new version.
NEWVERSION=`grep -E "Version:" "$PLUGINPATH/$MAINFILE" | awk -F' ' '{print $2}'`
READMEVERSION=`grep "^Stable tag" "$PLUGINPATH/readme.txt" | awk -F' ' '{print $3}'`

echo "$MAINFILE version: $NEWVERSION"
echo "readme.txt version: $READMEVERSION"

if [ "$NEWVERSION" != "$READMEVERSION" ]; then
	echo >&2 "ERROR: readme.txt version does not match version in $MAINFILE."
	exit 1
fi

if git show-ref --tags --quiet --verify -- "refs/tags/$NEWVERSION"; then
	echo >&2 "ERROR: git tag $NEWVERSION already exists.";
	exit 1;
fi


# Review and confirm changes to be committed/released.
echo "Review and confirm changes to be committed/released:"
echo
$DRYRUN git commit -pem "Preparing release $NEWVERSION."

echo
echo "Tagging release in git..."
$DRYRUN git tag -a "$NEWVERSION" -m "Tagging release $NEWVERSION."


# Safety net; pushing tags to the public is ultimate.
echo
echo -e "Ready to publish release to git? (Y/n) [n] \c"
read CONFIRMED
[[ $CONFIRMED == "Y" ]] || { echo "Aborted."; exit 1; }

echo
echo "Pushing master to origin, including tags..."
$DRYRUN git push origin master --tags


# Begin Subversion dump-export process.
echo
echo "Checking out SVN repository in $SVNPATH..."
$SVNCMD checkout $SVNURL $SVNPATH

if [ -d "tags/$NEWVERSION/" ]; then
	echo "ERROR: SVN tag $NEWVERSION already exists."
	exit 1
fi

echo
echo "Setting svn:ignore for git and release specific files..."
svn propset svn:ignore "
README.md
.git*
.wp-release.conf
banner-*
" "$SVNPATH/trunk/"

echo
echo "Exporting git HEAD of master to SVN trunk..."
git checkout-index --all --force --prefix=$SVNPATH/trunk/

# Recursively check out submodules, if any.
if [ -f ".gitmodules" ]; then
	echo "Exporting git HEAD of submodules to SVN trunk..."
	git submodule init
	git submodule update
	git submodule foreach --recursive 'git checkout-index --all --force --prefix=$SVNPATH/trunk/$path/'
fi

echo
echo "Exporting to SVN..."
pushd $SVNPATH > /dev/null
pushd trunk > /dev/null
# Add all new files; svn:ignore files are not listed.
svn status | grep "^?" | awk '{print $2}' | xargs svn add

echo
echo "Exporting banner images (if any)..."
if [ -f "$PLUGINPATH/banner-*" ]; then
	mkdir -p $SVNPATH/assets
	cp $PLUGINPATH/banner-* $SVNPATH/assets/ 
fi

# Extra safety net; SVN does not allow to rewrite history.
echo
echo "Changes to be committed to SVN:"
svn status
echo
echo -e "Ready to publish release to SVN? (Y/n) [n] \c"
read CONFIRMED
[[ $CONFIRMED == "Y" ]] || { echo "Aborted."; exit 1; }

$DRYRUN $SVNCMD commit -m "Preparing release $NEWVERSION."

echo
echo "Creating and committing SVN tag..."
popd > /dev/null
svn copy trunk tags/$NEWVERSION/
pushd tags/$NEWVERSION > /dev/null
$DRYRUN $SVNCMD commit -m "Tagging release $NEWVERSION."
popd > /dev/null

echo "Done."
popd > /dev/null
