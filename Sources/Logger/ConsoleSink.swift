//
//  ConsoleSink.swift
//  Logger
//
//  Created by Steve Madsen on 3/19/18.
//  Copyright © 2018 Light Year Software, LLC
//

import Foundation

public class ConsoleSink: LogSink {
    public var dateFormat: String {
        didSet {
            self.timeFormatter.dateFormat = self.dateFormat
        }
    }

    let timeFormatter: DateFormatter

    public init() {
        self.dateFormat = "YYYY-MM-dd HH:mm:ss.SSS"
        self.timeFormatter = DateFormatter()
        self.timeFormatter.dateFormat = self.dateFormat
    }

    public func log(timestamp: Date, level: Logger.Level, message: String, data: [String: Any]) {
        let timestamp = self.timeFormatter.string(from: timestamp)
        let thread = pthread_mach_thread_np(pthread_self())
        let data = data.isEmpty ? "" : " \(data)"
        print("\(timestamp) [\(thread)] \(level.rawValue) \(message)\(data)")
    }

    public func flush() {
    }
}
