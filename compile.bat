@echo off
flutter build windows --release & copy /y SDL2.dll build\windows\runner\Release & copy /y synthizer.dll build\windows\runner\Release & copy /y libsndfile-1.dll build\windows\runner\release