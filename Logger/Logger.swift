//
//  Logger.swift
//  Logger
//
//  Created by Steve Madsen on 3/18/18.
//  Copyright © 2018 Light Year Software, LLC. All rights reserved.
//

import Foundation

public protocol LogSink {
    func log(timestamp: Date, level: Logger.Level, message: String, data: [String: Any])
}

public class Logger {
    public enum Level {
        case debug
        case info
        case warning
        case error
    }

    public internal(set) static var shared = Logger()

    internal var sinks = [LogSink]()

    public func add(sink: LogSink) {
        self.sinks.append(sink)
    }

    public func log(_ level: Level, _ message: String, data: [String: Any] = [:]) {
        let timestamp = Date()
        self.sinks.forEach { $0.log(timestamp: timestamp, level: level, message: message, data: data) }
    }

    public func debug(_ message: String, data: [String: Any] = [:]) {
        log(.debug, message, data: data)
    }

    public func error(_ message: String, data: [String: Any] = [:]) {
        log(.error, message, data: data)
    }

    public func info(_ message: String, data: [String: Any] = [:]) {
        log(.info, message, data: data)
    }

    public func warning(_ message: String, data: [String: Any] = [:]) {
        log(.warning, message, data: data)
    }

    public static func log(_ level: Level, _ message: String, data: [String: Any] = [:]) {
        self.shared.log(level, message, data: data)
    }

    public static func debug(_ message: String, data: [String: Any] = [:]) {
        self.shared.log(.debug, message, data: data)
    }

    public static func error(_ message: String, data: [String: Any] = [:]) {
        self.shared.log(.error, message, data: data)
    }

    public static func info(_ message: String, data: [String: Any] = [:]) {
        self.shared.log(.info, message, data: data)
    }

    public static func warning(_ message: String, data: [String: Any] = [:]) {
        self.shared.log(.warning, message, data: data)
    }
}
