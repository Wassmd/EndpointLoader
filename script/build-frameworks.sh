#!/bin/sh
# iOS universal library build script supporting swift modules, including dSYM and simulator slices

# prevention from running xcodebuild in a recusive way
if [ "true" == ${ALREADYRUNNING:-false} ]; then
echo "RECURSION: Detected, stopping"
else
export ALREADYRUNNING="true"

# path defines including output directory for universal framework
BASE_PATH="${PROJECT_DIR}/build"

SIMULATOR_CONFIG="${CONFIGURATION}-iphonesimulator"
DEVICE_CONFIG="${CONFIGURATION}-iphoneos"

SIMULATOR_PATH="${BASE_PATH}/${SIMULATOR_CONFIG}"
DEVICE_PATH="${BASE_PATH}/${DEVICE_CONFIG}"

SIMULATOR_PRODUCTS="Build/Products/${SIMULATOR_CONFIG}"
DEVICE_PRODUCTS="Build/Products/${DEVICE_CONFIG}"

FRAMEWORKS_DIR="${BASE_PATH}/${CONFIGURATION}-frameworks"
OUTPUT_DIR="${BASE_PATH}/universal-framework"

mkdir -p "${FRAMEWORKS_DIR}"
mkdir -p "${OUTPUT_DIR}"

echo "Project path = ${PROJECT_DIR}"
echo "Xcode build configuration = ${CONFIGURATION}"
echo "Output directory = ${OUTPUT_DIR}"

# build both device and simulator versions for iOS
xcodebuild -project "${PROJECT_NAME}.xcodeproj" -scheme "${PROJECT_NAME}" \
			-sdk iphonesimulator \
			-configuration ${CONFIGURATION} \
			-destination "platform=iOS Simulator,name=iPhone Xs" \
			ONLY_ACTIVE_ARCH=NO \
			 -UseNewBuildSystem=YES \
			clean build -derivedDataPath "${SIMULATOR_PATH}"


# as folders get deleted on subsequent xcodebuild calls copy the framework structure from simulator build to the universal folder
cp -R "${SIMULATOR_PATH}/${SIMULATOR_PRODUCTS}/${PROJECT_NAME}.framework" "${FRAMEWORKS_DIR}"
cp -R "${SIMULATOR_PATH}/${SIMULATOR_PRODUCTS}/${PROJECT_NAME}.framework.dSYM" "${FRAMEWORKS_DIR}"

xcodebuild -project "${PROJECT_NAME}.xcodeproj" -scheme "${PROJECT_NAME}" \
			-sdk iphoneos \
			-configuration ${CONFIGURATION} \
			ONLY_ACTIVE_ARCH=NO \
			 -UseNewBuildSystem=YES \
			clean build -derivedDataPath "${DEVICE_PATH}"

# copy the framework structure from iphoneos build to the universal folder
cp -R "${DEVICE_PATH}/${DEVICE_PRODUCTS}/${PROJECT_NAME}.framework" "${FRAMEWORKS_DIR}"
cp -R "${DEVICE_PATH}/${DEVICE_PRODUCTS}/${PROJECT_NAME}.framework.dSYM" "${FRAMEWORKS_DIR}"

# copy existing Swift modules from iphonesimulator build to the universal framework directory
SIMULATOR_SWIFT_MODULES_DIR="${SIMULATOR_PATH}/${SIMULATOR_PRODUCTS}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/"
if [ -d "${SIMULATOR_SWIFT_MODULES_DIR}" ]; then
cp -R "${SIMULATOR_SWIFT_MODULES_DIR}" "${FRAMEWORKS_DIR}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule"
fi

# create universal binary file using lipo and place the combined executable in the universal framework directory
lipo -create -output "${FRAMEWORKS_DIR}/${PROJECT_NAME}.framework/${PROJECT_NAME}" \
						"${SIMULATOR_PATH}/${SIMULATOR_PRODUCTS}/${PROJECT_NAME}.framework/${PROJECT_NAME}" \
						"${DEVICE_PATH}/${DEVICE_PRODUCTS}/${PROJECT_NAME}.framework/${PROJECT_NAME}"

# move the framework folder to the project's directory
cp -R "${FRAMEWORKS_DIR}/." "${OUTPUT_DIR}"

fi
