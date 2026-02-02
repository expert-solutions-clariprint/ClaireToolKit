#!/bin/zsh

CLMODULES=(
#------- Building System Tools ----"
	"Zlib"
	"Sys"
	"Redis"
	"Md5"
	"Iconv"
	 "Regex"
	 "Openssl"
	 "Http"
	 "Wcl"
	 "Pdf"
	 # ------- 	ing Choco Tools ----
	 "choco"
	 "michoco"

	 # ------- 	ing XML Tools ----
#	 "Expat"
	 "Sax"
	 "Dom"
	 "Dom3"
	 "Xmlrpc"
	 "Json"
	 "Xmlo"
	 "Soap"
	 # ------- 	ing CASPER Tools ----
	 "Casper"

	 # ------- 	ing Database Tools ----"
	 "Db"
	 "Mysql"
#	 "Postgresql"
	 "Dbo"

	 #------- 	ing Graphic Tools ----"
	 "Gd"
	 "Gantt"

	 #------- 	ing Web/Internet Tools ----"
	 "LibLocale"
	 "Mail"
	 "WclSite"
	 "Postal"
	 "WebLocale"

	"Habor"
	"Pier"

	 # ------- 	ing legacy Tools ----"
	 # "tk2xl"

	 # ------- Jdf ----"
	 "Jdf"
)


if [ "$1" != "" ]
then
	START_MODULE=$1
	NOBUILD=1
else
	NOBUILD=0
fi


build()
{
	MODULE_NAME=$1;
	echo building $MODULE_NAME
	if [ -f "$MODULE_NAME/compile.sh" ]
	then
		if [ "$NOBUILD" = "1" ]
		then
			if [ "$START_MODULE" = "$MODULE_NAME" ]
			then
				NOBUILD=0
			fi
		fi
		cd $MODULE_NAME
		source compile.sh
		cd ..
	else
		if [ "$NOBUILD" = "1" ]
		then
			if [ "$START_MODULE" = "$MODULE_NAME" ]
			then
				NOBUILD=0
			fi
		fi
		if [ "$NOBUILD" = "0" ]
		then
			cd $MODULE_NAME;
			if [ -f "init.cl" ] 
			then
	#		claire -color -s 4 4 -v 2 -cpp -g -os 3 -D -cls -ov ${CLAIRE_PUBLISH_OPTION} -publish;
	#		claire -color -s 4 4 -v 2  -cpp -O3 -os 5 -cls -ov ${CLAIRE_PUBLISH_OPTION} -publish;
				claire -color -s 9 0  -v 2  -os 3  -cls -ov ${CLAIRE_PUBLISH_OPTION} -publish
			fi
			cd ..;
		fi
	fi
}
for i in $CLMODULES
do
	build $i
done

