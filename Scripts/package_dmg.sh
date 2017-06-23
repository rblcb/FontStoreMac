#!/bin/sh

if ( [ $# -gt 1 ] ) then

  APP="$1"
  DST_DMG="$2"
  DATE=`date +%Y%m%d_%H%M%S`
  SIGN_ID="Mac Developer: satya@fontstore.com (C33HCANT84)"

  DISK_NAME="Fonstore"

  TMP_DIR="/tmp/fontstore"
  TMP_DMG_DIR="${TMP_DIR}/DMG_${DATE}"
  TMP_DMG_NAME="fontstore_${DATE}.tmp.dmg"
  TMP_DMG="${TMP_DIR}/${TMP_DMG_NAME}"
  TMP_RELEASE_NAME="fontstore_${DATE}.dmg"
  TMP_RELEASE_DMG="${TMP_DIR}/${TMP_RELEASE_NAME}"

  echo "Creating tmp directory ${TMP_DMG_DIR}"
  rm -rf "${TMP_DMG_DIR}"
  mkdir -p "${TMP_DMG_DIR}"

  echo "Creating link to the Application folder"
  ln -s "/Applications" "${TMP_DMG_DIR}/Applications"

  echo "Copying ${APP} to ${TMP_DMG_DIR}"
  cp -R "${APP}" "${TMP_DMG_DIR}"

  echo "Creating tmp DMG"
  hdiutil create -ov -srcfolder "${TMP_DMG_DIR}" -volname "${DISK_NAME}" -fs HFS+ \
    -fsargs "-c c=64,a=16,e=16" -format UDRW "${TMP_DMG}"

  echo "Opening tmp DMG"
  DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "${TMP_DMG}" | egrep '^/dev/' | sed 1q | awk '{print $1}')
  echo "Openned as ${DEVICE}"

  echo "Converting tmp DMG to release DMG"
  ls -l "/Volumes"
  chmod -Rf go-w "/Volumes/${DISK_NAME}"
  sync
  hdiutil detach "${DEVICE}"
  rm -f "${TMP_RELEASE_DMG}"
  hdiutil convert "${TMP_DMG}" -format UDZO -imagekey zlib-level=9 -o "${TMP_RELEASE_DMG}"
  rm -f "${TMP_DMG}"

  echo "Moving ${TMP_RELEASE_DMG} to ${DST_DMG}"
  mv "${TMP_RELEASE_DMG}" "${DST_DMG}"

  echo "Signing ${DST_DMG}"
  codesign -s"${SIGN_ID}" -v "${DST_DMG}"

  echo "Done."
  exit 0
else
  echo "Usage: ./package_dmg.sh <APPLICATION_PACKAGE> <DMG_OUTPUT>"
  exit -1
fi