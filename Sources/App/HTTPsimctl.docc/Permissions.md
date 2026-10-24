# Permissions

Grant or revoke app permissions on a simulator.

## Valid Permission Values

`all`, `calendar`, `contacts-limited`, `location`, `location-always`, `photos-add`, `photos`, `media-library`, `microphone`, `motion`, `reminders`, `siri`

## Grant Permission

`POST /permission/grant`

### Request Body

```json
{
  "permission": "photos-add",
  "appBundleId": "com.example.app",
  "simulatorUDID": "12345678-1234-1234-1234-123456789012",
  "isClone": false
}
```

### Parameters

- `permission` (required): Permission to grant. See valid values above.
- `appBundleId` (required): Bundle ID of the app.
- `simulatorUDID` (optional): UUID of the simulator. See <doc:CommonParameters>.
- `isClone` (required): Whether the simulator is a clone. See <doc:CommonParameters>.

### Response

`204 No Content`

### Example

```bash
curl -X POST http://localhost:9000/permission/grant \
  -H "Content-Type: application/json" \
  -d '{
    "permission": "photos-add",
    "appBundleId": "com.example.app",
    "isClone": false
  }'
```

## Revoke Permission

`POST /permission/revoke`

### Request Body

```json
{
  "permission": "photos-add",
  "appBundleId": "com.example.app",
  "simulatorUDID": "12345678-1234-1234-1234-123456789012",
  "isClone": false
}
```

### Parameters

- `permission` (required): Permission to revoke. See valid values above.
- `appBundleId` (required): Bundle ID of the app.
- `simulatorUDID` (optional): UUID of the simulator. See <doc:CommonParameters>.
- `isClone` (required): Whether the simulator is a clone. See <doc:CommonParameters>.

### Response

`204 No Content`

### Example

```bash
curl -X POST http://localhost:9000/permission/revoke \
  -H "Content-Type: application/json" \
  -d '{
    "permission": "location-always",
    "appBundleId": "com.example.app",
    "isClone": false
  }'
```
