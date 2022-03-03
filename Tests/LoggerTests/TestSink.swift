//
//  TestSink.swift
//  LoggerTests
//
//  Created by Steve Madsen on 3/18/18.
//  Copyright © 2018 Light Year Software, LLC
//

import Foundation
@testable import Logger

struct Log {
    let timestamp: Date
    let level: Logger.Level
    let message: String
    let data: [String: Any]
}

class TestSink: LogSink {
    var logs = [Log]()

    func log(timestamp: Date, level: Logger.Level, message: String, data: [String: Any]) {
        logs.append(Log(timestamp: timestamp, level: level, message: message, data: data))
    }

    func flush() {
    }
}
