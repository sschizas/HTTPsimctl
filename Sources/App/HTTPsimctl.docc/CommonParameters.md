# Common Parameters

Many endpoints share the same simulator targeting fields.

## Parameters

### `simulatorUDID`

- **Type:** string
- **Required:** no
- **Default:** `"booted"` (the currently booted simulator)

The UUID of the target simulator. Omit this field to target the booted device.

### `isClone`

- **Type:** boolean
- **Required:** yes

When `true`, HTTPsimctl adds the `--set testing` flag to underlying `simctl` commands so they operate against cloned simulators used in testing setups.
