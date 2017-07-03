#!/bin/sh

if ( [ $# -ne 1 ] ) then
	echo "Usage: ./build_and_deploy_in_staging.sh <PROJECT_ROOT>"
	exit -1
else
  PROJECT_ROOT="$1"
	PROJECT_FILE="${PROJECT_ROOT}/FontStore.xcodeproj"
	PLIST_FILE="${PROJECT_ROOT}/FontYou/Info.plist"

	# Clean project
	xcodebuild -configuration Debug clean -project "${PROJECT_FILE}"
	# Build project
	xcodebuild -configuration Debug -project "${PROJECT_FILE}"

	# Parse version and build for updates
	VERSION=`/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${PLIST_FILE}"`
	BUILD_NUMBER=`/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "${PLIST_FILE}"`
	
	BUILD_DIR="${PROJECT_ROOT}/build"
  OUTPUT_APP_DIR="${BUILD_DIR}/Debug"
  OUTPUT_APP_NAME="Fontstore.app"
	OUTPUT_APP="${OUTPUT_APP_DIR}/${OUTPUT_APP_NAME}"

  DMG_NAME="Fontstore.dmg"
  TAR_NAME="Fontstore_${VERSION}.tar"
  APPCAST_NAME="appcast.xml"

	OUTPUT_DMG="${BUILD_DIR}/${DMG_NAME}"
	OUTPUT_TAR="${BUILD_DIR}/${TAR_NAME}"
  OUTPUT_APPCAST="${BUILD_DIR}/${APPCAST_NAME}"

	# Generate DMG for downloads
	${PROJECT_ROOT}/Scripts/package_dmg.sh "${OUTPUT_APP}" "${OUTPUT_DMG}"

	# Generate TAR for updates
  echo "Generating update TAR..."
  cp -rf "${OUTPUT_APP}" "./${OUTPUT_APP_NAME}"
	tar cf "${OUTPUT_TAR}" "./${OUTPUT_APP_NAME}"
  rm -rf "./${OUTPUT_APP_NAME}"
  echo "Update TAR generated"

  SIGN_TOOL="${PROJECT_ROOT}/Scripts/sign_update"
  PRIVATE_DSA_KEY="${PROJECT_ROOT}/dsa_priv.pem"

	# Sign TAR and retrive signature
  echo "Signing update TAR..."
  SIGNATURE=`${SIGN_TOOL} ${OUTPUT_TAR} ${PRIVATE_DSA_KEY}`
  echo "Update TAR signed with signature ${SIGNATURE}"

	# Generate APPCAST
  echo "Generating update appcast"
  ${PROJECT_ROOT}/Scripts/generate_staging_appcast.sh "${TAR_NAME}" "${VERSION}" "${BUILD_NUMBER}" "${SIGNATURE}" "${OUTPUT_APPCAST}"
  echo "Update appcast generated"

  # Deploy to FTP
  echo "Deploying to staging FTP"
  ${PROJECT_ROOT}/Scripts/deploy.sh "${BUILD_DIR}" "${TAR_NAME}" "${DMG_NAME}" "${APPCAST_NAME}" "apps/staging/mac"
  echo "Deploy done"

	exit 0
fi