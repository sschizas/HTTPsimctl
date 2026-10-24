[![Vapor Version](https://img.shields.io/badge/Vapor-4-30B6FC.svg)](http://vapor.codes)
[![Documentation](https://img.shields.io/badge/DocC-Documentation-blue)](https://sschizas.github.io/HTTPsimctl/documentation/httpsimctl/)

# HTTPsimctl

A command-line tool written in Swift/Vapor for interacting with iOS Simulators via the HTTP REST API. It enables developers to perform various simulator-related tasks programmatically, simplifying simulator management workflows.

**Documentation:** [sschizas.github.io/HTTPsimctl](https://sschizas.github.io/HTTPsimctl/documentation/httpsimctl/)

## Requirements

- Swift 6.x

## Installation

### Homebrew

To install `HTTPsimctl` using [Homebrew](https://brew.sh/), run the following command in your terminal:

```terminal
$ brew install sschizas/formulae/httpsimctl
```

### Manually

You have two options for manual installation:

1. **Download Binary**: You can download the pre-built binary from the [Releases](https://github.com/sschizas/HTTPsimctl/releases) page. Choose the appropriate version, and once downloaded, you can directly use the command-line tool.

2. **Clone and Build**: Alternatively, you can clone the repository and build it manually. Run the following commands in your terminal:

   ```terminal
   $ git clone https://github.com/sschizas/HTTPsimctl
   $ cd HTTPsimctl
   $ swift build --disable-sandbox --configuration release
   ```


## API Usage

The HTTPsimctl server runs on port `9000` by default. All endpoints accept JSON payloads and return appropriate HTTP status codes.

<details>
<summary><strong>Common Parameters</strong></summary>

### Common Parameters

Many endpoints share common parameters:

- **`simulatorUDID`** (optional): The UUID of the simulator. If not provided, defaults to `"booted"` (the currently booted simulator).
- **`isClone`** (required): Boolean indicating whether the simulator is a clone. When `true`, adds the `--set testing` flag to `simctl` commands.

</details>

### Endpoints

<details>
<summary><strong>Open URL</strong></summary>

#### Open URL

Opens a URL on the specified simulator.

**Endpoint:** `POST /open-url`

**Request Body:**
```json
{
  "urlToOpen": "https://example.com",
  "simulatorUDID": "12345678-1234-1234-1234-123456789012",
  "isClone": false
}
```

**Parameters:**
- `urlToOpen` (required): The URL to open (must be a valid URL).
- `simulatorUDID` (optional): UUID of the simulator.
- `isClone` (required): Boolean indicating if the simulator is a clone.

**Response:** `204 No Content`

**Example:**
```bash
curl -X POST http://localhost:9000/open-url \
  -H "Content-Type: application/json" \
  -d '{
    "urlToOpen": "com.example.app://deep-link",
    "isClone": false
  }'
```

</details>

<details>
<summary><strong>Start Recording Video</strong></summary>

#### Start Recording Video

Starts recording a video of the simulator screen.

**Endpoint:** `POST /record-video/start`

**Request Body:**
```json
{
  "fileName": "recording",
  "simulatorUDID": "12345678-1234-1234-1234-123456789012",
  "isClone": false
}
```

**Parameters:**
- `fileName` (required): Name of the video file (must be at least 3 characters, alphanumeric only). The file will be saved with `.mp4` extension.
- `simulatorUDID` (optional): UUID of the simulator.
- `isClone` (required): Boolean indicating if the simulator is a clone.

**Response:** `200 OK`

**Example:**
```bash
curl -X POST http://localhost:9000/record-video/start \
  -H "Content-Type: application/json" \
  -d '{
    "fileName": "my-recording",
    "isClone": false
  }'
```

</details>

<details>
<summary><strong>Stop Recording Video</strong></summary>

#### Stop Recording Video

Stops an ongoing video recording and returns the file path.

**Endpoint:** `POST /record-video/stop`

**Request Body:**
```json
{
  "fileName": "recording"
}
```

**Parameters:**
- `fileName` (required): The same filename used when starting the recording (must be at least 3 characters, alphanumeric only).

**Response:** `200 OK` with JSON body:
```json
{
  "filePath": "/absolute/path/to/recording.mp4"
}
```

**Example:**
```bash
curl -X POST http://localhost:9000/record-video/stop \
  -H "Content-Type: application/json" \
  -d '{
    "fileName": "my-recording"
  }'
```

</details>

<details>
<summary><strong>Delete Recorded Video</strong></summary>

#### Delete Recorded Video

Deletes a recorded video file.

**Endpoint:** `DELETE /record-video`

**Request Body:**
```json
{
  "fileName": "recording"
}
```

**Parameters:**
- `fileName` (required): The filename of the video to delete (must be at least 3 characters, alphanumeric only).

**Response:** `200 OK`

**Example:**
```bash
curl -X DELETE http://localhost:9000/record-video \
  -H "Content-Type: application/json" \
  -d '{
    "fileName": "my-recording"
  }'
```

</details>

<details>
<summary><strong>Grant Permission</strong></summary>

#### Grant Permission

Grants a permission to an app on the simulator.

**Endpoint:** `POST /permission/grant`

**Request Body:**
```json
{
  "permission": "photos-add",
  "appBundleId": "com.example.app",
  "simulatorUDID": "12345678-1234-1234-1234-123456789012",
  "isClone": false
}
```

**Parameters:**
- `permission` (required): The permission to grant. Valid values: `all`, `calendar`, `contacts-limited`, `location`, `location-always`, `photos-add`, `photos`, `media-library`, `microphone`, `motion`, `reminders`, `siri`.
- `appBundleId` (required): The bundle ID of the app.
- `simulatorUDID` (optional): UUID of the simulator.
- `isClone` (required): Boolean indicating if the simulator is a clone.

**Response:** `204 No Content`

**Example:**
```bash
curl -X POST http://localhost:9000/permission/grant \
  -H "Content-Type: application/json" \
  -d '{
    "permission": "photos-add",
    "appBundleId": "com.example.app",
    "isClone": false
  }'
```

</details>

<details>
<summary><strong>Revoke Permission</strong></summary>

#### Revoke Permission

Revokes a permission from an app on the simulator.

**Endpoint:** `POST /permission/revoke`

**Request Body:**
```json
{
  "permission": "photos-add",
  "appBundleId": "com.example.app",
  "simulatorUDID": "12345678-1234-1234-1234-123456789012",
  "isClone": false
}
```

**Parameters:**
- `permission` (required): The permission to revoke. Valid values: `all`, `calendar`, `contacts-limited`, `location`, `location-always`, `photos-add`, `photos`, `media-library`, `microphone`, `motion`, `reminders`, `siri`.
- `appBundleId` (required): The bundle ID of the app.
- `simulatorUDID` (optional): UUID of the simulator.
- `isClone` (required): Boolean indicating if the simulator is a clone.

**Response:** `204 No Content`

**Example:**
```bash
curl -X POST http://localhost:9000/permission/revoke \
  -H "Content-Type: application/json" \
  -d '{
    "permission": "location-always",
    "appBundleId": "com.example.app",
    "isClone": false
  }'
```

</details>

<details>
<summary><strong>Send APNS Push Notification</strong></summary>

#### Send APNS Push Notification

Sends an Apple Push Notification Service (APNS) notification to the simulator.

**Endpoint:** `POST /apns`

**Request Body:**
```json
{
  "apns": "{\"SimulatorTargetBundle\":\"com.example.app\",\"aps\":{\"alert\":{\"title\":\"Test\",\"body\":\"Hello World\"}}}",
  "appBundleId": "com.example.app",
  "simulatorUDID": "12345678-1234-1234-1234-123456789012",
  "isClone": false
}
```

**Parameters:**
- `apns` (required): JSON string containing the APNS payload. Must be valid JSON.
- `appBundleId` (required): The bundle ID of the app that will receive the notification.
- `simulatorUDID` (optional): UUID of the simulator.
- `isClone` (required): Boolean indicating if the simulator is a clone.

**Response:** `204 No Content`

**Example:**
```bash
curl -X POST http://localhost:9000/apns \
  -H "Content-Type: application/json" \
  -d '{
    "apns": "{\"SimulatorTargetBundle\":\"com.example.app\",\"aps\":{\"alert\":{\"title\":\"Test\",\"body\":\"Hello World\"}}}",
    "appBundleId": "com.example.app",
    "isClone": false
  }'
```

**APNS Payload Example:**
The `apns` parameter should be a JSON string. Here's a more detailed example:
```json
{
  "SimulatorTargetBundle": "com.example.app",
  "aps": {
    "alert": {
      "title": "Notification Title",
      "body": "Notification body text"
    },
    "badge": 1,
    "sound": "default"
  },
  "customKey": "customValue"
}
```

</details>

## Roadmap
- [x] Open urls.
- [x] Record videos of booted simulators.
- [x] Support installation via Homebrew.
- [x] Support sending APNS.
- [x] Grant/revoke app permissions.

## Built With

* [Vapor](https://vapor.codes) - Vapor is a framework for writing server applications, HTTP services and backends in Swift.

## Contributing

Contributions to HTTPsimctl are welcome and encouraged! To contribute, please fork the repository, create a new branch, make your changes, and submit a pull request.

Please make sure to include tests and update the documentation as necessary.

## License

HTTPsimctl is released under the [MIT License](https://github.com/sschizas/HTTPsimctl/blob/main/LICENSE).

## Contact

If you have any questions or issues, please open an issue on the [GitHub repository](https://github.com/sschizas/HTTPsimctl/issues) or contact me directly.
