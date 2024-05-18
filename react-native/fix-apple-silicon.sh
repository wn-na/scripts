#!/usr/bin/env bash
CLEANBUILD_FLAG=false   

if [[ $(sysctl -n machdep.cpu.brand_string) =~ "Apple" ]]; then
  echo "Apple Silicon detected"
  cd ios 

  if ! grep -q -F "build_settings[\"ONLY_ACTIVE_ARCH\"]" "Podfile"; then
    sed -i '' -r -e "s/([ ]*)(config\.build_settings\[\"DEVELOPMENT_TEAM\"\].*)/\1\2\n\1config\.build_settings\[\"ONLY_ACTIVE_ARCH\"\] = \"NO\"/"  Podfile
  fi
  if ! grep -q -F "build_settings[\"GCC_PREPROCESSOR_DEFINITIONS\"]" "Podfile"; then
    sed -i '' -r -e "s/([ ]*)(config\.build_settings\[\"DEVELOPMENT_TEAM\"\].*)/\1\2\n\1config\.build_settings\[\"GCC_PREPROCESSOR_DEFINITIONS\"\] \|\|= \[\"\$\(inherited\)\", \"_LIBCPP_ENABLE_CXX17_REMOVED_UNARY_BINARY_FUNCTION\"\]/"  Podfile
  fi
  if ! grep -q -F "build_settings[\"CODE_SIGNING_ALLOWED\"]" "Podfile"; then
    sed -i '' -r -e "s/([ ]*)(config\.build_settings\[\"DEVELOPMENT_TEAM\"\].*)/\1\2\n\1config\.build_settings\[\"CODE_SIGNING_ALLOWED\"\] = \"NO\"/" Podfile
  fi

  pod deintegrate 
  rm -rf Podfile.lock
  pod install

  # fix Flipper Type
  sed -i '' "11s/.*/#include <functional>/g" Pods/Flipper/xplat/Flipper/FlipperTransportTypes.h
  sed -Eri '' "s/\"?EXCLUDED_ARCHS.*/EXCLUDED_ARCHS = arm64;/" fanding.xcodeproj/project.pbxproj
  
  echo "Fin"
else 
  echo "Not doing anything"
fi
