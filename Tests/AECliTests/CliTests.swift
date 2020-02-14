import XCTest
@testable import AECli

final class CliTests: XCTestCase {

    // MARK: Cli

    let cli = SimpleCli(
        name: "my",
        overview: "test tool",
        commands: [Thing()],
        output: TestOutput()
    )

    var output: TestOutput {
        cli.output as! TestOutput
    }

    class TestOutput: Output {
        var text = String()
        var error: Error = ""

        func text(_ text: String) {
            self.text = text
        }

        func error(_ error: Error) {
            self.error = error
        }
    }

    // MARK: Commands

    struct Thing: Command {
        var overview: String {
            "does something"
        }

        var commands: [Command] {
            [Foo(), Bar()]
        }

        var help: String? {
            "USAGE: command [options]"
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

    // MARK: Helpers

    let fooOutput = "foo"
    let barOutput = "bar"

    let thingDescription = """
    does something

    • foo > foo something
    • bar > bar something

    USAGE: command [options]
    """

    let thingUnknownCommand = "thing: command not found: unknown"

    let cliDescription = """
    test tool

    • thing > does something
    """

    let cliUnknownCommand = "my: command not found: unknown"

    // MARK: Tests

    func testCommand() throws {
        let foo = Foo()
        try foo.run(in: cli)
        XCTAssertEqual(output.text, fooOutput)

        let bar = Bar()
        try bar.run(in: cli)
        XCTAssertEqual(output.text, barOutput)

        let thing = Thing()
        try thing.run(in: cli)
        XCTAssertEqual(output.text, thingDescription)

        try thing.run(["foo"], in: cli)
        XCTAssertEqual(output.text, fooOutput)

        try thing.run(["bar"], in: cli)
        XCTAssertEqual(output.text, barOutput)

        XCTAssertThrowsError(
            try thing.run(["unknown"], in: cli)
        ) { (error) in
            XCTAssertEqual("\(error)", thingUnknownCommand)
        }
    }

    func testCli() {
        XCTAssertEqual(thingDescription, cli.describe(Thing()))

        cli.run([])
        XCTAssertEqual(output.text, cliDescription)

        cli.run(["unknown"])
        XCTAssertEqual(output.error.localizedDescription, cliUnknownCommand)

        cli.run(["thing"])
        XCTAssertEqual(output.text, thingDescription)

        cli.run(["thing", "foo"])
        XCTAssertEqual(output.text, fooOutput)

        cli.launch(with: ["my"])
        XCTAssertEqual(output.text, cliDescription)

        cli.launch(with: ["my", "unknown"])
        XCTAssertEqual(output.error.localizedDescription, cliUnknownCommand)

        cli.launch(with: ["my", "thing"])
        XCTAssertEqual(output.text, thingDescription)

        cli.launch(with: ["my", "thing", "unknown"])
        XCTAssertEqual(output.error.localizedDescription, thingUnknownCommand)

        cli.launch(with: ["my", "thing", "foo"])
        XCTAssertEqual(output.text, fooOutput)

        cli.launch(with: ["my", "thing", "bar"])
        XCTAssertEqual(output.text, barOutput)
    }

    static var allTests = [
        ("testCommand", testCommand),
        ("testCli", testCli),
    ]

}
