# Getting Started

Start the server and call an endpoint.

## Start the Server

After installing HTTPsimctl, run the executable. By default it serves on port `9000`:

```bash
httpsimctl
```

Or, when building from source:

```bash
swift run App
```

## First Request

Open a deep link on the currently booted simulator:

```bash
curl -X POST http://localhost:9000/open-url \
  -H "Content-Type: application/json" \
  -d '{
    "urlToOpen": "com.example.app://deep-link",
    "isClone": false
  }'
```

A successful response returns `204 No Content`.

## Next Steps

- Review <doc:CommonParameters> shared by most endpoints.
- Explore the <doc:OpenURL>, <doc:RecordVideo>, <doc:Permissions>, and <doc:APNS> APIs.
