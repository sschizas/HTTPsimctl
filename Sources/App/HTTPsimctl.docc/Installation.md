# Installation

Install HTTPsimctl with Homebrew, a release binary, or by building from source.

## Requirements

- Swift 6.x
- macOS 13 or later

## Homebrew

```bash
brew install sschizas/formulae/httpsimctl
```

## Download a Binary

Download a pre-built binary from the [Releases](https://github.com/sschizas/HTTPsimctl/releases) page and run it directly.

## Build from Source

```bash
git clone https://github.com/sschizas/HTTPsimctl
cd HTTPsimctl
swift build --disable-sandbox --configuration release
```

The built executable is available under `.build/release/`.
