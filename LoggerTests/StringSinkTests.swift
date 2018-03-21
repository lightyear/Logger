//
//  StringSinkTests.swift
//  LoggerTests
//
//  Created by Steve Madsen on 3/20/18.
//  Copyright © 2018 Light Year Software, LLC. All rights reserved.
//

import XCTest
import Nimble
@testable import Logger

class StringSinkTests: XCTestCase {
    var logger: Logger!
    var sink: StringSink!

    override func setUp() {
        super.setUp()
        self.logger = Logger()
        self.sink = StringSink()
        self.logger.add(sink: self.sink)
    }
    
    override func tearDown() {
        self.logger = nil
        self.sink = nil
        super.tearDown()
    }

    func testLog() {
        self.logger.log(.info, "test")

        expect(self.sink.string).to(endWith("INFO test\n"))
    }

    func testDateFormat() {
        self.sink.dateFormat = "'date format'"
        self.logger.log(.info, "test")

        expect(self.sink.string) == "date format [\(pthread_mach_thread_np(pthread_self()))] INFO test\n"
    }

    func testTruncate() {
        self.logger.log(.info, "first")
        self.sink.truncate()

        expect(self.sink.string).to(beEmpty())
    }
}
