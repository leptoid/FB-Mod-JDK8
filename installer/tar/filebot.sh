#!/bin/sh
PRG="$0"

# resolve relative symlinks
while [ -h "$PRG" ] ; do
	ls=`ls -ld "$PRG"`
	link=`expr "$ls" : '.*-> \(.*\)$'`
	if expr "$link" : '/.*' > /dev/null; then
		PRG="$link"
	else
		PRG="`dirname "$PRG"`/$link"
	fi
done

# get canonical path
PRG_DIR=`dirname "$PRG"`
FILEBOT_HOME=`cd "$PRG_DIR" && pwd`


# make sure required environment variables are set
if [ -z "$USER" ]; then
	export USER=`whoami`
fi


# add package lib folder to library path
PACKAGE_LIBRARY_ARCH="$(uname -s)-$(uname -m)"
PACKAGE_LIBRARY_PATH="$FILEBOT_HOME/lib/$PACKAGE_LIBRARY_ARCH"

# add fpcalc to the $PATH by default
export PATH="$PATH:$PACKAGE_LIBRARY_PATH"


# force JVM language and encoding settings
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# choose archive extractor / media characteristics parser
case $PACKAGE_LIBRARY_ARCH in
	Linux-x86_64|Linux-i686)
		# i686 or x86_64
		ARCHIVE_EXTRACTOR="SevenZipNativeBindings"
		MEDIA_PARSER="libmediainfo"
	;;
	*)
		# armv7l or aarch64
		ARCHIVE_EXTRACTOR="ApacheVFS"
		MEDIA_PARSER="ffprobe"
	;;
esac

# select application data folder
APP_DATA="$FILEBOT_HOME/data/$USER"
LIBRARY_PATH="$PACKAGE_LIBRARY_PATH:$LD_LIBRARY_PATH"

# start filebot
java -Dapplication.deployment=tar -Dnet.filebot.license="$FILEBOT_HOME/data/.license" -Dnet.filebot.media.parser="$MEDIA_PARSER" -Dnet.filebot.Archive.extractor="$ARCHIVE_EXTRACTOR" -Dunixfs=false -DuseExtendedFileAttributes=true -DuseCreationDate=false -Djava.net.useSystemProxies=true -Djna.nosys=true -Djna.nounpack=true -Djna.boot.library.path="$LIBRARY_PATH" -Djna.library.path="$LIBRARY_PATH" -Djava.library.path="$LIBRARY_PATH" -Dapplication.dir="$APP_DATA" -Dapplication.cache="$APP_DATA/cache" -Djava.io.tmpdir="$APP_DATA/tmp" -Dfile.encoding="UTF-8" -Dsun.jnu.encoding="UTF-8" -Duser.home="$APP_DATA" -Djava.util.prefs.PreferencesFactory=net.filebot.util.prefs.FilePreferencesFactory -Dnet.filebot.util.prefs.file="$APP_DATA/prefs.properties" $JAVA_OPTS $FILEBOT_OPTS -jar "$FILEBOT_HOME/jar/filebot.jar" "$@"

