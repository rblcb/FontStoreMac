#!/bin/sh

if ( [ $# -ne 5 ] ) then
  echo "Usage: ./deploy.sh <BUILD_DIR> <TAR_NAME> <DMG_NAME> <APPCAST_NAME> <DEPLOY_DIR>"
  exit -1
else
  BUILD_DIR="$1"
  TAR_NAME="$2"
  DMG_NAME="$3"
  APPCAST_NAME="$4"
  DEPLOY_DIR="$5"

  FTP_HOST="51.15.139.241"
  FTP_USER="fontyou"
  FTP_PASS="7e656654034d0e4836c018c7a5499f35"
  
  ftp -n "${FTP_HOST}" <<END_FTP
quote USER "${FTP_USER}"
quote PASS "${FTP_PASS}"
cd "${DEPLOY_DIR}"
binary
put "${BUILD_DIR}/${DMG_NAME}" "${DMG_NAME}"
put "${BUILD_DIR}/${TAR_NAME}" "${TAR_NAME}"
put "${BUILD_DIR}/${APPCAST_NAME}" "${APPCAST_NAME}"
quit
END_FTP

  exit 0
fi
