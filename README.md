# AECli

**Swift package for making simple command line tools**

> I made this for personal use, but feel free to use it or contribute.

## Intro

There is a `Command` which can run some arguments in `Cli` which has its `Output` 
and contains any defined commands. *For the example of a more custom implementation, 
see [AETool](https://github.com/tadija/AETool).*

## Example

- Create executable Swift package and open it with Xcode

    ```sh
    mkdir My && cd My && swift package init --type executable && xed .
    ```

- Edit `Package.swift`

    ```swift
    // swift-tools-version:5.1

    import PackageDescription

    let package = Package(
        name: "My",
        products: [
            .executable(name: "my", targets: ["My"])
        ],
        dependencies: [
            .package(url: "https://github.com/tadija/AECli.git", from: "0.1.0")
        ],
        targets: [
            .target(name: "My", dependencies: ["AECli"]),
        ]
    )
    ```

- Edit `Sources/My/main.swift`

    ```swift
    import AECli

    // MARK: - Commands

    struct Thing: Command {
        var overview: String {
            "does something"
        }
        
        var commands: [Command] {
            [Foo(), Bar()]
        }
    }

    struct Foo: Command {
        var overview: String {
            "foo something"
        }

        func run(_ arguments: [String] = [], in cli: Cli) throws {
            cli.output("foo")
        }
    }

    struct Bar: Command {
        var overview: String {
            "bar something"
        }

        func run(_ arguments: [String] = [], in cli: Cli) throws {
            cli.output("bar")
        }
    }

    // MARK: - Cli

    SimpleCli(
        overview: "my cli",
        commands: [Thing()],
        help: "USAGE: command [options]"
    ).launch()
    ```

- Install

    ```sh
    swift build -c release && install .build/release/my /usr/local/bin/my
    ```
    
- Uninstall

    ```sh
    rm /usr/local/bin/my
    ```
    
## Usage

- Run **my**

    ```
    my
    ```
    > describes cli with all available commands

    ```sh
    my cli

    • thing > does something
    
    USAGE: command [options]
    ```
    
- Run **thing** command

    ```sh
    my thing
    ```
    > describes command with all its subcommands
    
    ```sh
    does something
    
    • foo > foo something
    • bar > bar something
    ```
    
- Run **foo** command

    ```sh
    my thing foo
    ```
    > runs **foo** comand
    
    ```sh
    foo
    ```

## Installation

- [Swift Package Manager](https://swift.org/package-manager/):

    ```swift
    .package(
        url: "https://github.com/tadija/AECli.git", from: "0.1.0"
    )
    ```

## License
This code is released under the MIT license. See [LICENSE](LICENSE) for details.
