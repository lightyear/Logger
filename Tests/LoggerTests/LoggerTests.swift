//
//  LoggerTests.swift
//  LoggerTests
//
//  Created by Steve Madsen on 3/18/18.
//  Copyright © 2018 Light Year Software, LLC
//

import XCTest
import Nimble
@testable import Logger

final class LoggerTests: XCTestCase {
    var logger: Logger!
    var sink: TestSink!

    override func setUp() {
        super.setUp()
        self.logger = Logger()
        self.sink = TestSink()
        self.logger.add(sink: self.sink)
    }

    override func tearDown() {
        self.logger = nil
        self.sink = nil
        super.tearDown()
    }

    func testAddSink() {
        expect(self.logger.sinks.first) === self.sink
    }

    func testRemoveSink() {
        self.logger.remove(sink: self.sink)

        expect(self.logger.sinks).to(beEmpty())
    }

    func testLog() {
        let timestamp = Date()
        self.logger.log(.debug, "message", data: ["key": "value"])

        expect(self.sink.logs).to(haveCount(1))
        let log = self.sink.logs[0]
        expect(log.timestamp).to(beCloseTo(timestamp, within: 0.003))
        expect(log.level) == Logger.Level.debug
        expect(log.message) == "message"
        expect(log.data).to(haveCount(1))
        expect(log.data["key"] as? String) == "value"
    }

    func testDebug() {
        let timestamp = Date()
        self.logger.debug("message", data: ["key": "value"])

        expect(self.sink.logs).to(haveCount(1))
        let log = self.sink.logs[0]
        expect(log.timestamp).to(beCloseTo(timestamp, within: 0.003))
        expect(log.level) == Logger.Level.debug
        expect(log.message) == "message"
        expect(log.data).to(haveCount(1))
        expect(log.data["key"] as? String) == "value"
    }

    func testInfo() {
        let timestamp = Date()
        self.logger.info("message", data: ["key": "value"])

        let log = self.sink.logs[0]
        expect(log.timestamp).to(beCloseTo(timestamp, within: 0.003))
        expect(log.level) == Logger.Level.info
        expect(log.message) == "message"
        expect(log.data).to(haveCount(1))
        expect(log.data["key"] as? String) == "value"
    }

    func testWarning() {
        let timestamp = Date()
        self.logger.warning("message", data: ["key": "value"])

        let log = self.sink.logs[0]
        expect(log.timestamp).to(beCloseTo(timestamp, within: 0.003))
        expect(log.level) == Logger.Level.warning
        expect(log.message) == "message"
        expect(log.data).to(haveCount(1))
        expect(log.data["key"] as? String) == "value"
    }

    func testError() {
        let timestamp = Date()
        self.logger.error("message", data: ["key": "value"])

        let log = self.sink.logs[0]
        expect(log.timestamp).to(beCloseTo(timestamp, within: 0.003))
        expect(log.level) == Logger.Level.error
        expect(log.message) == "message"
        expect(log.data).to(haveCount(1))
        expect(log.data["key"] as? String) == "value"
    }

#if !SWIFT_PACKAGE
    func testFatal() {
        let timestamp = Date()
        expect { self.logger.fatal("message", data: ["key": "value"]) }.to(throwAssertion())

        let log = self.sink.logs[0]
        expect(log.timestamp).to(beCloseTo(timestamp, within: 0.003))
        expect(log.level) == Logger.Level.fatal
        expect(log.message) == "message"
        expect(log.data).to(haveCount(1))
        expect(log.data["key"] as? String) == "value"
    }
#endif

    func testClassLogDelegatesToSharedLogger() {
        Logger.shared = self.logger
        Logger.log(.debug, "message")

        expect(self.sink.logs).to(haveCount(1))
    }

    func testClassDebugDelegatesToSharedLogger() {
        Logger.shared = self.logger
        Logger.debug("message")

        expect(self.sink.logs).to(haveCount(1))
    }

    func testClassErrorDelegatesToSharedLogger() {
        Logger.shared = self.logger
        Logger.error("message")

        expect(self.sink.logs).to(haveCount(1))
    }

#if !SWIFT_PACKAGE
    func testClassFatalDelegatesToSharedLogger() {
        Logger.shared = self.logger
        expect { Logger.fatal("message") }.to(throwAssertion())

        expect(self.sink.logs).to(haveCount(1))
    }
#endif

    func testClassInfoDelegatesToSharedLogger() {
        Logger.shared = self.logger
        Logger.info("message")

        expect(self.sink.logs).to(haveCount(1))
    }

    func testClassWarningDelegatesToSharedLogger() {
        Logger.shared = self.logger
        Logger.warning("message")

        expect(self.sink.logs).to(haveCount(1))
    }
}
