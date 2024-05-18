###########################################################3
# AAB 파일을 adb를 통해 설치할때 사용하는 스크립트 입니다
# https://github.com/google/bundletool
###########################################################
BUNDLETOOL_PATH="bundletool-all-1.16.0.jar"
AAB_FILE="./app-release.aab"
APKS_OUTPUT_FILE="./app-release.apks"
KEY_STORE_FILE="./android/keystore.jks"
KEY_STORE_PASSWORD=storepassword
KEY_ALIAS=keyalias
KEY_PASSWORD=keypassword

if [ -e $APKS_OUTPUT_FILE ]; then
  rm -rf $APKS_OUTPUT_FILE
fi
java -jar $BUNDLETOOL_PATH build-apks \
  --bundle=$AAB_FILE \
  --output=$APKS_OUTPUT_FILE \
  --ks=$KEY_STORE_FILE \
  --ks-pass=pass:$KEY_STORE_PASSWORD \
  --ks-key-alias=$KEY_ALIAS \
  --key-pass=pass:$KEY_PASSWORD
java -jar $BUNDLETOOL_PATH install-apks --apks=$APKS_OUTPUT_FILE
