#!/bin/sh
# A shell script for conversion of MOVA MuellerXX.koi dictionaries 
# into DICT format. 
# Written by Andrew Comech <comech@math.sunysb.edu>
# GNU GPL (2000)
# The latest version is available from
# http://www.math.sunysb.edu/~comech/tools/to-dict

version="0.1"
versiondate="November 11, 2000"

# We need the following binaries:
DICTFMT=`which dictfmt`
DICTZIP=`which dictzip`

INFO () {
  echo "
to-dict, version $version ($versiondate).
Conversion of MOVA MuellerXX.koi dictionaries into DICT format.
Written by Andrew Comech <comech@math.sunysb.edu>. GNU GPL (2000)

The latest version is available from
http://www.math.sunysb.edu/~comech/tools/to-dict
"
}

REQUIREMENTS () {
  echo "
REQUIREMENTS: you need the binaries \`dictfmt' and \`dictzip'. 

dictzip.c can be found in dictd-1.5.0.tar.gz (or later version) at
ftp://ftp.cs.unc.edu/pub/users/faith/dict/

dictfmt.c can be found in Debian/GNU Linux package dict-elements at
ftp://ftp.debian.org/debian/dists/potato/main/source/text/

Compiled binaries (dictfmt and dictzip) could be downloaded from
http://www.wh9.tu-dresden.de/~heinrich/dict/dict_leo_ftp/static-binaries/
or
http://iris.ltas.ulg.ac.be/download/apps/dict/
"
}

USAGE () {
    echo "
USAGE: 
 -version: show version
 -h, --help, or no parameters: show this help

(*) To make DICT database from Mueller7GPL.koi available from
http://www.chat.ru/~mueller_dic/Mueller7GPL.tgz

# Remove transcription:
./to-dict --no-trans Mueller7GPL.koi mueller7.notr
# Convert <source> into <data> (a file with %h, %d-headers):
./to-dict --src-data mueller7.notr mueller7.data && rm -i mueller7.notr
# Convert <data> into DICT-format (files <name>.dict.dz and <name>.index):
./to-dict --data-dict mueller7.data mueller7 && rm -i mueller7.data
# Expand index file (to be able to access lines like \"A, a\" by \"A\" and \"a\"):
./to-dict --expand-index mueller7.index mueller7.index.exp
# Install a new dictionary with expanded index (RUN AS ROOT).
# The location of files may depend on your distribution!!!
cp mueller7.dict.dz /usr/share/dictd/mueller7.dict.dz
cp mueller7.index.exp /usr/share/dictd/mueller7.index
dictdconfig -w && (killall dictd; dictd)

(*) To make DICT database from Mueller24.koi available from 
http://www.chat.ru/~mueller_dic/Mueller24.tgz (this one is preferred)

# Convert <source> into <data> (a file with %h, %d):
./to-dict --src-data Mueller24.koi mueller24.data
# Convert <data> into DICT-format (files <name>.dict.dz and <name>.index):
./to-dict --data-dict mueller24.data mueller24 && rm -i mueller24.data
# Install a new dictionary with expanded index (RUN AS ROOT).
# The location of files may depend on your distribution!!!
cp mueller24.dict.dz /usr/share/dictd/mueller24.dict.dz
cp mueller24.index /usr/share/dictd/mueller24.index
dictdconfig -w && (killall dictd; dictd)

(*) To re-convert <dict> into <data> (a file with %h, %d-headers):

./to-dict --dict-data <dict> <data>

 *************************************************************
    !!WARNING!!    !!WARNING!!    !!WARNING!!    !!WARNING!!   

 Temporary files created by this script occupy a lot of drive space!
 15 MB for Mueller7GPL.koi (have to strip off transcription first)
 12 MB for Mueller24.koi
 *************************************************************
"
}

# To remove the transcription except for [r] and [ju:] which found in the text. 
# This procedure should not change Mueller24.koi if applied to it.
NO_TRANS () {
sed 's/���\ \[ju�\]/���\ "ju:"/; s/\[l\],/"l",/g; s/\[r\]/"r"/g; s/\], \[/A/g; s/\]\; _��\. \[/A/g; s/\]\; _pl\. \[/A/g; s/\[[^]]*\]\ (����.. ����.). \[[^]]*\] (������������[^)]*)\ //g; s/\[[^]]*\]\ //g; s/\[[^]]*\],\ //; s/\ \[[^]]*\],/,/g; s/\ \[[^]]*\])/)/g; s/\ \[[^]]*\]:/:/g; s/\ \[[^]]*\];/;/g; s/\ \[[^]]*\]$//g; s/���\ "ju:"/���\ \[ju�\]/g; s/"l"/\[l\]/g; s/"r"/\[r\]/g '
}

# Strip the copyright/info
STRIP () {
sed -n '/^_[aA]/,$p'
}

# Format the file
MK_DATA () {
sed 's/$/\
/g; s/[^]]*\ \ /%h&\
%d/; s/_[IVX][IVX]* /\
 &/g; s/ [1-9]\. /\
  &/g; s/[1-9][0-9]*>/\
      &/g; s/[�������������������������������]>/(&>/g; s/>>/)/g; s/\ \_[AISE][a-z]*:/\
  &/g; s/>/:/g'\
|sed ' s/%d$/%z/; s/%d/%d\
   / ; s/%z/%d/; s/%h/%h / '  \
|fmt -s -w 74;}

########################################################################

if [ "$1" = "-version" ]; then 
    INFO
    exit 0
fi

if [ "$#" = 0 -o "$1" = "-h" -o "$1" = "--help" -o "$1" = "-help" ]; then 
    USAGE
    exit 0
fi

if [ "$#" != 3 ]; then 
    USAGE; exit 1;
fi

## Will not go further if there are no dictfmt and dictzip binaries:
if [ "$DICTFMT" = "" -o "$DICTZIP" = "" ]; then
    REQUIREMENTS
    exit 1
fi
##

if [ ! -f "$2" ]; then
    echo "No input file: $2"; USAGE; exit 1
fi

case $1 in
    "--no-trans")
	echo  "Removing transcription ($2 -> $3)..";
	cat $2 | NO_TRANS > $3 || exit 1
	echo "."; exit 0
	;;
    "--src-data")
	echo "Writing the header of $3.."
	echo -e "%h 00-database-info\n%d" > $3
	cat $2 | sed -n '1p' | sed 's/^/  /' | fmt -s -w 74 >> $3;
	cat $2 | sed -n '/^_/,/_��.  Japan ��������/p' | sed 's/^/  /' | fmt -s -w 74 >> $3;
	echo "" >> $3
	echo "Formatting data ($2 -> $3).."
	cat $2 | sed -n '/^_[aA]/,$p' | MK_DATA >> $3 || exit 1
	echo "."; exit 0
	;;
    "--data-dict")
	TITLE="Mueller English-Russian Dictionary"
	echo "dictfmt: $2 -> $3.dict and $3.index.."
	dictfmt -p -u "http://www.chat.ru/~mueller_dic" \
	    -s "$TITLE" $3 < $2 || exit 1
	echo "Compressing $3.dict.."; dictzip $3.dict || exit 1
#	echo -n "Restarting daemons"; killall dictd; dictd
	echo "."; exit 0
	;;
    "--expand-index")
# So that the line
# ``whisky, whiskey   a sort of spirit I like''
# could be found not only by /usr/bin/dict "whisky, whiskey", but also by 
# /usr/bin/dict "whisky" and /usr/bin/dict "whiskey"
	cat $2 | sed 's/^[^,]*, [^,]*/%TAG1&\
%REM2&\
%TAG3&/; s/^%TAG1[^,]*, /&%REM1/; s/, %REM1[^'$'\t'']*//; s/%REM2[^,]*, //; s/%TAG[13]//g' > $3 || exit 1
	exit 0
	;;
    "--dict-data")
	if [ "` file $2 | grep  gzip`" != "0" ]; then
	    CAT=zcat;
	else
	    CAT=cat;
	fi
	$CAT $2 | sed 's/^[^\ ].*/%h &\
%d/; s/^[\ ][\ ]*/   /' >$3 || exit 1
	echo "."; exit 0
	;;
    *) INFO; USAGE; exit 1
esac

echo "You are not supposed to be here."
exit 1
