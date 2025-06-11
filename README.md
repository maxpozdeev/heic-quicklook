# heic-quicklook
QuickLook plug-in for HEIC and AVIF images.

This plug-in can be useful on old macs with macOS 10.7 - 10.12 which has no native support of HEIC images. The support was introduced in iOS 11 and High Sierra (10.13) in 2017. Support of AVIF images was added in macOS 13 Ventura.

Requirements: macOS 10.7+ x86_64

## Build

```
cd libs
./1_setup_repos.sh
./2_build_libs.sh release

cd ../project
xcodebuild -project heic_quicklook.xcodeproj -target heic-quicklook -configuration Release  build
```
