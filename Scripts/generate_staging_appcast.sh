#!/bin/sh

if ( [ $# -ne 5 ] ) then
  	echo "Usage: ./generate_staging_appcast.sh <TAR_NAME> <VERSION> <BUILD_NUMBER> <SIGNATURE> <OUTPUT_FILE>"
	exit -1
else
	TAR_NAME="$1"
	VERSION="$2"
	BUILD_NUMBER="$3"
	SIGNATURE="$4"
	OUTPUT_FILE="$5"

  NOW=`date -R`

	echo '<?xml version="1.0" encoding="utf-8"?>' > "${OUTPUT_FILE}"
	echo '<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle">' >> "${OUTPUT_FILE}"
		echo '<channel>' >> "${OUTPUT_FILE}"
    		echo '<title>Fontstore Changelog</title>' >> "${OUTPUT_FILE}"
    		echo '<link>https://app.fontstore.com/staging/mac/appcast.xml</link>' >> "${OUTPUT_FILE}"
    		echo '<description>Most recent changes with links to updates.</description>' >> "${OUTPUT_FILE}"
    		echo '<language>en</language>' >> "${OUTPUT_FILE}"

    		echo '<item>' >> "${OUTPUT_FILE}"
    			echo "<title>Version ${VERSION}</title>" >> "${OUTPUT_FILE}"
    			echo "<pubDate>${NOW}</pubDate>" >> "${OUTPUT_FILE}"
    			echo "<enclosure url='https://app.fontstore.com/staging/mac/${TAR_NAME}' sparkle:version='${BUILD_NUMBER}' sparkle:shortVersionString='${VERSION}' sparkle:dsaSignature='${SIGNATURE}' type='application/octet-stream' />" >> "${OUTPUT_FILE}"
    		echo '</item>' >> "${OUTPUT_FILE}"
		echo '</channel>' >> "${OUTPUT_FILE}"
	echo '</rss>' >> "${OUTPUT_FILE}"


	exit 0
fi