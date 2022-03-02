#!/bin/sh
flutter build linux --release && cp *.so build/linux/x64/release/bundle
