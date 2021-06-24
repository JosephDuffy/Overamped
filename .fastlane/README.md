fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios submit_beta
```
fastlane ios submit_beta
```
Submit a new iOS build to TestFlight
### ios submit_app_store
```
fastlane ios submit_app_store
```
Submit a new build to the App Store
### ios upload_metadata
```
fastlane ios upload_metadata
```
Upload metadata the App Store
### ios generate_screenshots
```
fastlane ios generate_screenshots
```
Generate and frame App Store screenshots
### ios download_certs
```
fastlane ios download_certs
```
Download iOS certificates (read only)
### ios generate_certs
```
fastlane ios generate_certs
```
Force recreation of iOS certificates

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
