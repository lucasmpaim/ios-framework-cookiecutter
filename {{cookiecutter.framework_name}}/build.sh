#!/bin/bash

WORKSPACE_DIR=$1
FRAMEWORK_NAME={{cookiecutter.framework_name}}

LOCKFILE=/tmp/.lock_$FRAMEWORK_NAME
TMP_DIR=$(mktemp -d -t $FRAMEWORK_NAME)


rm -r "./$FRAMEWORK_NAME.xcframework"

if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "already running"
    exit
fi


trap "rm -f ${LOCKFILE}; rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE}


notify_error_on_build()
{
    terminal-notifier -title BariBuild -message "Problemas ao compilar o módulo $FRAMEWORK_NAME" -sound default
}

xcodebuild archive \
	-scheme $FRAMEWORK_NAME \
	-workspace "${WORKSPACE_DIR}" \
	-archivePath "${TMP_DIR}/iOS/$FRAMEWORK_NAME" \
	-sdk iphoneos \
	SKIP_INSTALL=NO \
	BUILD_LIBRARIES_FOR_DISTRIBUTION=YES \
	clean build

if [[ $? != 0 ]]; then
    notify_error_on_build
    exit -1
fi

xcodebuild archive \
	-scheme $FRAMEWORK_NAME \
	-workspace "${WORKSPACE_DIR}" \
	-archivePath "${TMP_DIR}/simulator/$FRAMEWORK_NAME" \
	-sdk iphonesimulator \
	SKIP_INSTALL=NO \
	BUILD_LIBRARIES_FOR_DISTRIBUTION=YES \
	clean build

if [[ $? != 0 ]]; then
    notify_error_on_build
    exit -1
fi


xcodebuild -create-xcframework \
	-framework "${TMP_DIR}/iOS/$FRAMEWORK_NAME.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework" \
	-framework "${TMP_DIR}/simulator/$FRAMEWORK_NAME.xcarchive/Products/Library/Frameworks/$FRAMEWORK_NAME.framework" \
	-output "./$FRAMEWORK_NAME.xcframework"

if [[ $? != 0 ]]; then
    notify_error_on_build
    exit -1
fi

rm -f ${LOCKFILE}
rm -r ${TMP_DIR}

