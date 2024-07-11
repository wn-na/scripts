#!/bin/bash

NODE_MODULES_DIR="./node_modules"

if [[ "$OSTYPE" == "darwin"* ]]; then
  SED_INPLACE="sed -i ''"
else
  SED_INPLACE="sed -i"
fi

find "$NODE_MODULES_DIR" \( -path "*/android/src/main/AndroidManifest.xml" -o -path "*/android/app/src/main/AndroidManifest.xml" \) | while read -r manifest_file; do
  echo "Processing $manifest_file"

  package_name=$(grep -o 'package="[^"]*"' "$manifest_file" | head -1 | sed 's/package="//;s/"//')

  if [ -n "$package_name" ]; then
    echo "Found package in AndroidManifest.xml / package_name: $package_name"

    # 모든 package 속성 제거
    $SED_INPLACE 's/package="[^"]*"//g' $manifest_file

    # build.gradle 파일 경로 설정
    if [[ $manifest_file =~ \./(node_modules/([^/]+/)+android)/ ]]; then
      extracted="${BASH_REMATCH[1]}"
      echo "$extracted"
      manifest_dir=$(dirname "./$extracted")

      # 모든 build.gradle 파일 탐색 및 처리
      find "$manifest_dir" -type f -name "build.gradle" | while read -r build_gradle_file; do
        echo "Found build.gradle: $build_gradle_file"

        # android 블록 안에 namespace가 있는지 확인
        if grep -q 'namespace' "$build_gradle_file"; then
          echo "Namespace already exists in $build_gradle_file, skipping..."
        else
          # android 블록이 없는 경우 추가
          if ! grep -q 'android *{' "$build_gradle_file"; then
            echo "android {" >> "$build_gradle_file"
            echo "    namespace \"$package_name\"" >> "$build_gradle_file"
            echo "}" >> "$build_gradle_file"
            echo "Added android { namespace \"$package_name\" } to $build_gradle_file"
          else
            # android 블록이 있는 경우에만 추가
            awk -v package_name="$package_name" '
              /android *{/ {
                print
                print "    namespace \"" package_name "\""
                next
              }
              { print }
            ' "$build_gradle_file" > "${build_gradle_file}.tmp" && mv "${build_gradle_file}.tmp" "$build_gradle_file"

            echo "Added namespace \"$package_name\" to $build_gradle_file"
          fi
        fi
      done
    else
      echo "No package build.gradle found in $manifest_file"
    fi
  else
    echo "No package attribute found in $manifest_file"
  fi
done
