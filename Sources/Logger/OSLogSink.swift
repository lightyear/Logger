//
//  OSLogSink.swift
//  Logger
//
//  Created by Steve Madsen on 6/24/18.
//  Copyright © 2018 Light Year Software, LLC
//

import Foundation
import os

private extension OSLogType {
    init(level: Logger.Level) {
        switch level {
        case .debug:   self = .debug
        case .info:    self = .info
        case .warning: self = .error
        case .error:   self = .error
        case .fatal:   self = .error
        }
    }
}

public class OSLogSink: LogSink {
    public func log(timestamp: Date, level: Logger.Level, message: String, data: [String: Any]) {
        os_log("%s", type: OSLogType(level: level), message)
    }

    public func flush() {
    }
}
