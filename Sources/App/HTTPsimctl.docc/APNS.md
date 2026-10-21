# Send APNs

Sends an Apple Push Notification Service (APNs) notification to the simulator.

## Endpoint

`POST /apns`

## Request Body

```json
{
  "apns": "{\"SimulatorTargetBundle\":\"com.example.app\",\"aps\":{\"alert\":{\"title\":\"Test\",\"body\":\"Hello World\"}}}",
  "appBundleId": "com.example.app",
  "simulatorUDID": "12345678-1234-1234-1234-123456789012",
  "isClone": false
}
```

> Note: The `apns` value is a JSON **string**. Escape quotes when embedding it in the outer request body.

### Parameters

- `apns` (required): JSON string containing the APNs payload. Must be valid JSON.
- `appBundleId` (required): Bundle ID of the app that receives the notification.
- `simulatorUDID` (optional): UUID of the simulator. See <doc:CommonParameters>.
- `isClone` (required): Whether the simulator is a clone. See <doc:CommonParameters>.

## Response

`204 No Content`

## Example

```bash
curl -X POST http://localhost:9000/apns \
  -H "Content-Type: application/json" \
  -d '{
    "apns": "{\"SimulatorTargetBundle\":\"com.example.app\",\"aps\":{\"alert\":{\"title\":\"Test\",\"body\":\"Hello World\"}}}",
    "appBundleId": "com.example.app",
    "isClone": false
  }'
```

## APNs Payload Example

The decoded `apns` string can look like:

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
