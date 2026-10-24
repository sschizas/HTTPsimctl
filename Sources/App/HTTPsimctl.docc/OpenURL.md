# Open URL

Opens a URL on the specified simulator.

## Endpoint

`POST /open-url`

## Request Body

```json
{
  "urlToOpen": "https://example.com",
  "simulatorUDID": "12345678-1234-1234-1234-123456789012",
  "isClone": false
}
```

### Parameters

- `urlToOpen` (required): The URL to open. Must be a valid URL.
- `simulatorUDID` (optional): UUID of the simulator. See <doc:CommonParameters>.
- `isClone` (required): Whether the simulator is a clone. See <doc:CommonParameters>.

## Response

`204 No Content`

## Example

```bash
curl -X POST http://localhost:9000/open-url \
  -H "Content-Type: application/json" \
  -d '{
    "urlToOpen": "com.example.app://deep-link",
    "isClone": false
  }'
```
