#!/bin/sh
flutter build linux --release && cp *.so changelog.md build/linux/x64/release/bundle
