#!/bin/bash

# Defaults
CURRENT_DIR=`pwd`
PLUGIN_NAME=''
SVN_REMOTE=''
SVN_DIR=''
SVN_MSG='Updating with version %s'
SVN_USR=''
SVN_PWD=''
GIT_REMOTE=''
GIT_COMMIT=''
GIT_DIR=''

help() {
	echo -e "\033[1;34mdeploy.sh\033[0m clones your git repository and pushes the content to a specified
subversion repository. It's written to deploy new versions of Wordpress plugins.

\033[0;34m-n \033[1;32mPlugin name\033[0m What's the name of your plugin?
\033[0;34m-s \033[1;32mSVN remote\033[0m Where's your SVN repository?
\033[0;34m-m \033[1;32mSVN message\033[0;33m[optional]\033[0m A message for the subversion commit (default: $SVN_MSG)
\033[0;34m-u \033[1;32mSVN username\033[0;33m[optional]\033[0m Subversion remote username
\033[0;34m-p \033[1;32mSVN password\033[0;33m[optional]\033[0m Subversion remote password
\033[0;34m-g \033[1;32mGit remote\033[0m Where's your git repository?
\033[0;34m-c \033[1;32mGit commit \033[0;33m[optional]\033[0m If you want to commit a specified commit
"
}

# Some loading animation :)

spinner() {
	s='.oOo'
	ds=`date "+%H:%M:%S"`
	while [ `ps -p $1 -o pid=` ]; do
		for (( n=0; n<${#s}; n+=1 )); do
			if [ `ps -p $1 -o pid=` ]; then
				break;
			fi
			printf "$2${s:$n:1}$3"; sleep 0.1; printf "\r"
		done
	done
	de=`date "+%H:%M:%S"`
	echo -e "$2# [$ds-$de]$3"
}

# Gather options and arguments

while getopts ":n:s:m:u:p:g:c:" opt; do
	case $opt in
		n ) PLUGIN_NAME=$OPTARG;;
		s ) SVN_REMOTE=$OPTARG;;
		m ) SVN_MSG=$OPTARG;;
		u ) SVN_USR=$OPTARG;;
		p ) SVN_PWD=$OPTARG;;
		g ) GIT_REMOTE=$OPTARG;;
		c ) GIT_COMMIT=$OPTARG;;
		\? ) help; echo -e "Option \033[1;34m-$OPTARG\033[0m does not exist"; exit;;
		: ) help; echo -e "Option \033[1;34m-$OPTARG\033[0m wants an argument"; exit;;
	esac
done

# Check specified options

if [ ! "$PLUGIN_NAME" ]; then
	help
	echo "You must specify the plugin's name with -n"
	exit
fi

if [ ! "$SVN_REMOTE" ]; then
	help
	echo "You must specify the Subversion repository remote URL with -s"
	exit
fi

if [ ! "$GIT_REMOTE" ]; then
	help
	echo "You must specify the Git repository remote URL with -g"
	exit
fi

# Start display what we're doing

echo ".........................................."
echo
echo -e "        \033[0;34mDeploying wordpress plugin\033[0m       "
echo
echo -e "\tPlugin name: $PLUGIN_NAME"

# Clone the with git

GIT_DIR="$PLUGIN_NAME-git"
echo -e "\tFrom: $GIT_REMOTE"
if [ -d $GIT_DIR ]; then
	cd $GIT_DIR
	git pull -q origin master &
	spinner $! "\t\033[0;34m" " \033[0mPulling in: $GIT_DIR"
	cd $CURRENT_DIR
else
	git clone -q $GIT_REMOTE $GIT_DIR &
	spinner $! "\t\033[0;34m" " \033[0mCloning into: $GIT_DIR"
fi

# Get a specified commit, if there is one

if [ "$GIT_COMMIT" ]; then
	cd $GIT_DIR;
	echo -e "\tUsing commit $GIT_COMMIT"
	git checkout -q $GIT_COMMIT
	cd $CURRENT_DIR;
fi

# Check version in readme.txt is the same as plugin file

if [ -f "$GIT_DIR/readme.txt" ] & [ -f "$GIT_DIR/$PLUGIN_NAME.php" ]; then
	NEWVERSION1=`grep "^ \?\(* \)\?Stable tag" $GIT_DIR/readme.txt | awk '{ print $NF}'`
	NEWVERSION2=`grep "^Version" $GIT_DIR/$PLUGIN_NAME.php | awk '{ print $NF}'`
else
	echo -e "\tFAIL: Could not find $GIT_DIR/readme.txt and/or $GIT_DIR/$PLUGIN_NAME.php"
	exit
fi

if [ "$NEWVERSION1" != "$NEWVERSION2" ]; then
	echo -e "\tFAIL: Versions don't match - $NEWVERSION1 != $NEWVERSION2"
	exit
fi

echo -e "\tVersion to deploy: $NEWVERSION1"

# Checkout the SVN repository

echo -e "\tTo: $SVN_REMOTE"
SVN_DIR="$PLUGIN_NAME-svn"
if [ -d "$SVN_DIR" ]; then
	cd $SVN_DIR;
	svn --quiet up &
	spinner $! "\t\033[0;34m" " \033[0mUpdating: $SVN_DIR"
	cd $CURRENT_DIR;
else
	svn --quiet co $SVN_REMOTE $SVN_DIR &
	spinner $! "\t\033[0;34m" " \033[0mCheckout into: $SVN_DIR"
fi

# Copy files from git to svn directories

cd $GIT_DIR
git checkout-index -q -a -f --prefix=../$SVN_DIR/trunk/ &
spinner $! "\t\033[0;34m" " \033[0mCopying files to: $SVN_DIR/trunk/"
cd $CURRENT_DIR;

# Change to SVN dir and commit changes

echo -e "\tCommitting subversion repository's trunk with files copied from git"
cd $SVN_DIR/trunk
SVN_MSG=$( printf "$SVN_MSG" $NEWVERSION1 )
if [ "$SVN_USR" ]; then
	SVN_USR="--username $SVN_USR"
fi
if [ "$SVN_PWD" ]; then
	SVN_PWD="--password $SVN_PWD"
fi

svn stat | grep '^?' | awk '{print $2}' | xargs svn add
svn ci $SVN_USR $SVN_PWD -m "$SVN_MSG"

echo -e "\tCommitting new version tag: $NEWVERSION1"
cd ..
svn copy $SVN_REMOTE/trunk $SVN_REMOTE/tags/$NEWVERSION1 $SVN_USR $SVN_PWD -m "Version tag $NEWVERSION1"

cd $CURRENT_DIR

echo
echo ".........................................."
echo
