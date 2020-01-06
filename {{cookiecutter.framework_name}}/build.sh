#!/bin/bash

WORKSPACE_DIR=$1
FRAMEWORK_NAME={{cookiecutter.framework_name}}

LOCKFILE=/tmp/.lock_$FRAMEWORK_NAME
LOG_FILE=/tmp/xcode_build_$FRAMEWORK_NAME.log
TMP_DIR=$(mktemp -d -t $FRAMEWORK_NAME)


if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "already running"
    exit
fi

rm -r "./$FRAMEWORK_NAME.xcframework"


trap "rm -f ${LOCKFILE}; rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE}


notify_error_on_build()
{
    terminal-notifier -title BariBuild -message "Problemas ao compilar o módulo $FRAMEWORK_NAME"\
     -open "file://$LOG_FILE" \
     -sound default\
      -appIcon "https://media.licdn.com/dms/image/C4E0BAQGZ108LeTMGbA/company-logo_200_200/0?e=2159024400&v=beta&t=YOk8DxE2UfG3FUbrVoVuWlpme0c0PtISssG_S5yKdQE"
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

