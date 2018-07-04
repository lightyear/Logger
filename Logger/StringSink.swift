//
//  StringSink.swift
//  Logger
//
//  Created by Steve Madsen on 3/20/18.
//  Copyright © 2018 Light Year Software, LLC. All rights reserved.
//

import Foundation

public class StringSink: LogSink {
    public var dateFormat: String {
        didSet {
            self.timeFormatter.dateFormat = self.dateFormat
        }
    }

    public private(set) var string = ""
    let timeFormatter: DateFormatter
    let queue = DispatchQueue(label: "Logger.StringSink")

    public init() {
        self.dateFormat = "YYYY-MM-dd HH:mm:ss.SSS"
        self.timeFormatter = DateFormatter()
        self.timeFormatter.dateFormat = self.dateFormat
    }

    public func truncate() {
        self.string = ""
    }

    public func log(timestamp: Date, level: Logger.Level, message: String, data: [String: Any]) {
        let timestamp = self.timeFormatter.string(from: timestamp)
        let thread = pthread_mach_thread_np(pthread_self())
        let data = data.isEmpty ? "" : " \(data)"
        self.queue.sync {
            print("\(timestamp) [\(thread)] \(level.rawValue) \(message)\(data)", to: &self.string)
        }
    }

    public func flush() {
    }
}
