@echo off
flutter build windows --release & copy /y *.dll build\windows\runner\Release & copy /y changelog.md build\windows\runner\Release & 7z a worldsmith_studio-windows-%1.zip build\windows\runner\Release
