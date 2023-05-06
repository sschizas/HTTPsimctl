[![Swift Version](https://img.shields.io/badge/Swift-5.8-brightgreen.svg)](http://swift.org)
[![Vapor Version](https://img.shields.io/badge/Vapor-4-30B6FC.svg)](http://vapor.codes)

# HTTPsimctl

A command-line tool written in Swift/Vapor for interacting with iOS Simulators via the HTTP REST API. It enables developers to perform various simulator-related tasks programmatically, simplifying simulator management workflows.

## Requirements

- Swift 5.8+

## Installation

### Homebrew

To install `HTTPsimctl` using [Homebrew](https://brew.sh/), run the following command in your terminal:

```terminal
$ brew tap sschizas/formulae/httpsimctl
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

## Roadmap
- [x] Open urls.
- [x] Record videos of booted simulators.
- [x] Support installation via Homebrew.
- [ ] Support sending APNS.
- [ ] Grant/revoke app permissions.

## Built With

* [Vapor](https://vapor.codes) - Vapor is a framework for writing server applications, HTTP services and backends in Swift.

## Contributing

Contributions to HTTPsimctl are welcome and encouraged! To contribute, please fork the repository, create a new branch, make your changes, and submit a pull request.

Please make sure to include tests and update the documentation as necessary.

## License

HTTPsimctl is released under the [MIT License](https://github.com/sschizas/HTTPsimctl/blob/main/LICENSE).

## Contact

If you have any questions or issues, please open an issue on the [GitHub repository](https://github.com/sschizas/HTTPsimctl/issues) or contact me directly.
