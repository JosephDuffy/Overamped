# Overamped

Overamped is an iOS app that disables AMP and Yandex Turbo in Safari via a Web Extension. More information is available at [overamped.app](https://overamped.app). The app is also available for [download on the App Store](https://apps.apple.com/app/apple-store/id1573901090?mt=8).

## Auditing

This repo is provided **for auditing purposes only**. This means you can read the code to ensure nothing nefarious is being done with your data without only taking my word for it.

### Validating Builds

It is almost impossible to prove that the source code in this repo is the same code that is distributed via the App Store. With a jailbroken device and [reproducible builds it would be possible, but this is an arduous process](https://core.telegram.org/reproducible-builds#reproducible-builds-for-ios) and not something I wish to pursue.

#### GitHub CI Builds

From version 1.0.1 (build 24) all builds are compiled and submitted using GitHub CI, which provide public logs. This should make it possible to validate that the app is uploaded to the Yetii Ltd. developer account. Since App Store Connect will not accept multiple builds of the same version or duplicate bundle identifiers you can validate that the uploaded build is the same that has been published.

### Repo Security

All commits are signed with [my GPG key](https://josephduffy.co.uk/commits.asc), which should – assuming my security has not been compromised – prove that all code is written and committed by myself.

### Forks

There is nothing stopping others from forking/downloading the repo and making changes, possibly even then uploading it to the App Store. Not only would this be illegal but you should not trust the fork; they could've easily added tracking and data exfiltration without your knowledge. Please [contact me](https://overamped.app/contact) if you find such an app or fork.

## Contributing

As this is a commercial app that costs money I **will not** be accepting contributions. If you have a feature request or have found a bug you are welcome to open an issue or fill out the feedback form on the app.

## License

The Overamped source code is provided **for auditing purposes only** and may not be used, shared, or copied without prior permission. The project is copyright [Yetii Ltd.](https://yetii.co.uk).

If a large enough subset of the app would be useful and could be extracted in to a separate Swift Package with a permissive license I will consider this.
