# HTTPsimctl

@Metadata {
    @TechnologyRoot
}

A command-line tool written in Swift/Vapor for interacting with iOS Simulators via an HTTP REST API.

## Overview

HTTPsimctl lets you drive common `simctl` workflows over HTTP — open URLs, record video, manage app permissions, and send APNs — so you can automate simulator tasks from CI, scripts, or other tools.

The server listens on port `9000` by default. All endpoints accept JSON payloads and return appropriate HTTP status codes.

## Topics

### Essentials

- <doc:Installation>
- <doc:GettingStarted>
- <doc:CommonParameters>

### REST API

- <doc:OpenURL>
- <doc:RecordVideo>
- <doc:Permissions>
- <doc:APNS>
