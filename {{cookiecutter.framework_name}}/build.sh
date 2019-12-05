xcodebuild archive -scheme {{cookiecutter.framework_name}} \
 -archivePath "./archives/iOS/{{cookiecutter.framework_name}}" \
  -sdk iphoneos \
   SKIP_INSTALL=NO \
   BUILD_LIBRARIES_FOR_DISTRIBUTION=YES \
   clean build


xcodebuild archive -scheme {{cookiecutter.framework_name}} \
 -archivePath "./archives/simulator/{{cookiecutter.framework_name}}" \
  -sdk iphonesimulator \
   SKIP_INSTALL=NO \
   BUILD_LIBRARIES_FOR_DISTRIBUTION=YES \
   clean build


xcodebuild -create-xcframework \
	-framework "./archives/iOS/{{cookiecutter.framework_name}}.xcarchive/Products/Library/Frameworks/{{cookiecutter.framework_name}}.framework" \
	-framework "./archives/simulator/{{cookiecutter.framework_name}}.xcarchive/Products/Library/Frameworks/{{cookiecutter.framework_name}}.framework" \
	-output "./{{cookiecutter.framework_name}}.xcframework"