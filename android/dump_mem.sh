#!/bin/bash
APP_ID=com.example
pid=$(adb shell pidof $APP_ID)
adb shell dumpsys meminfo $pid >> androidmeminfo.log
