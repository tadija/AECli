/**
 *  https://github.com/tadija/AECli
 *  Copyright © 2020 Marko Tadić
 *  Licensed under the MIT license
 */

import Foundation

// MARK: - Command

public protocol Command {
    var name: String { get }
    var overview: String { get }
    var commands: [Command] { get }
    var help: String? { get }

    func run(_ arguments: [String], in cli: Cli) throws
}

public extension Command {
    var name: String {
        String(describing: type(of: self)).lowercased()
    }

    var overview: String {
        "n/a"
    }

    var commands: [Command] { [] }

    var help: String? { nil }

    func run(_ arguments: [String] = [], in cli: Cli) throws {
        if arguments.isEmpty {
            cli.output(self)
        } else {
            let filtered = commands.filter { $0.name == arguments.first }
            guard let command = filtered.first else {
                throw "\(name): command not found: \(arguments[0])"
            }
            let next = Array(arguments.dropFirst())
            try command.run(next, in: cli)
        }
    }
}

// MARK: - Output

public protocol Output {
    func text(_ text: String)
    func error(_ error: Error)

    func describe(_ command: Command) -> String
    func describe(_ commands: [Command]) -> String
}

public extension Output {
    func text(_ text: String) {
        print(text)
    }

    func error(_ error: Error) {
        fputs("\(error.localizedDescription)\n", stderr)
    }

    func describe(_ command: Command) -> String {
        var description = "\(command.overview)\n\n"
        if !command.commands.isEmpty {
            description += describe(command.commands)
        }
        if let help = command.help {
            description += "\n\n\(help)"
        }
        return description
    }

    func describe(_ commands: [Command]) -> String {
        let maxLength = commands.map({ $0.name.count }).max() ?? 0
        return commands
            .map({
                "  \($0.name.padding(maxLength))  >  \($0.overview)"
            })
            .joined(separator: "\n")
    }
}

public final class StandardOutput: Output {
    public init() {}
}

// MARK: - Cli

public protocol Cli: Command {
    var output: Output { get }

    func run(_ arguments: [String])
}

public extension Cli {
    func run(_ arguments: [String]) {
        do {
            try run(arguments, in: self)
        } catch {
            output.error(error)
        }
    }

    func launch(with arguments: [String] = CommandLine.arguments) {
        run(Array(arguments.dropFirst()))
    }

    func output(_ text: String) {
        output.text(text)
    }

    func output(_ command: Command) {
        let description = output.describe(command)
        output(description)
    }
}

// MARK: - SimpleCli

public final class SimpleCli: Cli {
    public let name: String
    public let overview: String
    public let commands: [Command]
    public let help: String?

    public let output: Output

    public init(name: String = CommandLine.arguments[0],
                overview: String,
                commands: [Command],
                help: String? = nil,
                output: Output = StandardOutput()) {
        self.name = name
        self.overview = overview
        self.commands = commands
        self.help = help
        self.output = output
    }
}

// MARK: - Helpers

extension String: Error, LocalizedError {
    public var errorDescription: String? {
        self
    }

    public func padding(_ length: Int) -> String {
        padding(toLength: length, withPad: " ", startingAt: 0)
    }
}
