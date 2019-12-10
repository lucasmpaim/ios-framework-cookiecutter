#!/bin/bash

LOCKFILE=/tmp/.lock_{{cookiecutter.framework_name}}
TMP_DIR=$(mktemp -d -t {{cookiecutter.framework_name}})

rm -r "./{{cookiecutter.framework_name}}.xcframework"


if [ -e ${LOCKFILE} ] && kill -0 `cat ${LOCKFILE}`; then
    echo "already running"
    exit
fi


trap "rm -f ${LOCKFILE}; exit" INT TERM EXIT
echo $$ > ${LOCKFILE}

xcodebuild archive -scheme {{cookiecutter.framework_name}} \
 -archivePath "${TMP_DIR}/iOS/{{cookiecutter.framework_name}}" \
  -sdk iphoneos \
   SKIP_INSTALL=NO \
   BUILD_LIBRARIES_FOR_DISTRIBUTION=YES \
   clean build


xcodebuild archive -scheme {{cookiecutter.framework_name}} \
 -archivePath "${TMP_DIR}/simulator/{{cookiecutter.framework_name}}" \
  -sdk iphonesimulator \
   SKIP_INSTALL=NO \
   BUILD_LIBRARIES_FOR_DISTRIBUTION=YES \
   clean build


xcodebuild -create-xcframework \
	-framework "${TMP_DIR}/iOS/{{cookiecutter.framework_name}}.xcarchive/Products/Library/Frameworks/{{cookiecutter.framework_name}}.framework" \
	-framework "${TMP_DIR}/simulator/{{cookiecutter.framework_name}}.xcarchive/Products/Library/Frameworks/{{cookiecutter.framework_name}}.framework" \
	-output "./{{cookiecutter.framework_name}}.xcframework"

rm -f ${LOCKFILE}
rm -r ${TMP_DIR}
