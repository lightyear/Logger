//
//  LevelTests.swift
//  Logger
//
//  Created by Steve Madsen on 12/23/19.
//

import XCTest
import Nimble
@testable import Logger

class LevelTests: XCTestCase {
    func testLevelComparable() {
        expect(Logger.Level.fatal) > Logger.Level.error
        expect(Logger.Level.error) > Logger.Level.warning
        expect(Logger.Level.warning) > Logger.Level.info
        expect(Logger.Level.info) > Logger.Level.debug

        expect(Logger.Level.debug) < Logger.Level.info
        expect(Logger.Level.info) < Logger.Level.warning
        expect(Logger.Level.warning) < Logger.Level.error
        expect(Logger.Level.error) < Logger.Level.fatal
    }
}
