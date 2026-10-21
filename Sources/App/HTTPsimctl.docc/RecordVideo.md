# Record Video

Start, stop, and delete simulator screen recordings.

## Start Recording

`POST /record-video/start`

### Request Body

```json
{
  "fileName": "recording",
  "simulatorUDID": "12345678-1234-1234-1234-123456789012",
  "isClone": false
}
```

### Parameters

- `fileName` (required): Name of the video file (at least 3 characters, alphanumeric only). Saved with a `.mp4` extension.
- `simulatorUDID` (optional): UUID of the simulator. See <doc:CommonParameters>.
- `isClone` (required): Whether the simulator is a clone. See <doc:CommonParameters>.

### Response

`200 OK`

### Example

```bash
curl -X POST http://localhost:9000/record-video/start \
  -H "Content-Type: application/json" \
  -d '{
    "fileName": "my-recording",
    "isClone": false
  }'
```

## Stop Recording

`POST /record-video/stop`

Stops an ongoing recording and returns the file path.

### Request Body

```json
{
  "fileName": "recording"
}
```

### Parameters

- `fileName` (required): The same filename used when starting the recording (at least 3 characters, alphanumeric only).

### Response

`200 OK` with JSON body:

```json
{
  "filePath": "/absolute/path/to/recording.mp4"
}
```

### Example

```bash
curl -X POST http://localhost:9000/record-video/stop \
  -H "Content-Type: application/json" \
  -d '{
    "fileName": "my-recording"
  }'
```

## Delete Recording

`DELETE /record-video`

### Request Body

```json
{
  "fileName": "recording"
}
```

### Parameters

- `fileName` (required): Filename of the video to delete (at least 3 characters, alphanumeric only).

### Response

`200 OK`

### Example

```bash
curl -X DELETE http://localhost:9000/record-video \
  -H "Content-Type: application/json" \
  -d '{
    "fileName": "my-recording"
  }'
```
