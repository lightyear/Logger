//
//  Logger.swift
//  Logger
//
//  Created by Steve Madsen on 3/18/18.
//  Copyright © 2018 Light Year Software, LLC. All rights reserved.
//

import Foundation

/// A type suitable for use as a destination for log messages.
public protocol LogSink: class {
    /** Write/store/send a log message.

    This function is the primary entry point for a sink. It is responsible for
    writing/storing/sending the log message and related data to its ultimate
    destination. A file sink, for example, would write the message to a file.

    - Important: This function must be thread-safe. If you write to a shared
    resource that does not itself synchronize multiple threads, create a serial
    queue in `init()` and dispatch to it. (A serial queue is usually a better
    choice than a concurrent one, since it maintains log order.)

    - parameter timestamp: The time that the message was logged.
    - parameter level: The log level
    - parameter message: The textual message
    - parameter data: Extra data
    */
    func log(timestamp: Date, level: Logger.Level, message: String, data: [String: Any])

    /** Flush any unprocessed log data.

    This function is called by `Logger` when a `.fatal` message is logged.

    - Important: If your sink cares about the data passed to it, you must be
    done processing it before this function returns. Sinks that write to files
    should ensure that file handles are flushed to disk, for example.

    Sinks that synchronize concurrent access using a serial dispatch queue
    should enqueue their flush work to that same queue with
    `DispatchQueue.sync()` to ensure the flush completes before `Logger` calls
    `fatalError()`.

    Sinks that synchronize with a concurrent dispatch queue should enqueue their
    flush work with `DispatchQueue.sync(flags: .barrier)` to ensure that all
    previously queued blocks have executed before the flush work executes.
    */
    func flush()
}

/** A funnel for an application's log messages.

Send log messages to one or more sinks. Sinks may be added and removed at
runtime, and can write messages to all sorts of places: the console, files,
network log aggregation servers, error collection services, etc.
*/
public class Logger {
    /// The severity level of a log message.
    public enum Level: String, Equatable, Comparable {

        case debug   = "DEBUG"
        case info    = "INFO"
        case warning = "WARNING"
        case error   = "ERROR"
        case fatal   = "FATAL"

        private var ordinal: Int {
            switch self {
            case .debug:   return 0
            case .info:    return 1
            case .warning: return 2
            case .error:   return 3
            case .fatal:   return 4
            }
        }

        public static func < (lhs: Level, rhs: Level) -> Bool {
            return lhs.ordinal < rhs.ordinal
        }

        static public func > (lhs: Level, rhs: Level) -> Bool {
            return lhs.ordinal > rhs.ordinal
        }
    }

    /** The application-wide shared Logger instance.

    When you use the static log functions (`Logger.log`, `Logger.debug`,
    `Logger.info`, `Logger.warning`, and `Logger.error`), they delegate to this
    `Logger` instance.
    */
    public internal(set) static var shared = Logger()

    private var lock = pthread_rwlock_t()
    internal var sinks = [LogSink]()

    init() {
        if pthread_rwlock_init(&self.lock, nil) != 0 {
            fatalError("Failed to initialize internal Logger lock: errno=\(errno)")
        }
    }

    deinit {
        pthread_rwlock_destroy(&self.lock)
    }

    /** Add a sink instance to the list of active sinks.

    - parameter sink: The sink instance. Keep a reference to this instance if
      you want to remove it later.
    */
    public func add(sink: LogSink) {
        pthread_rwlock_wrlock(&self.lock)
        defer { pthread_rwlock_unlock(&self.lock) }
        self.sinks.append(sink)
    }

    /** Remove a sink instance from the list of active sinks.

    - parameter sink: The sink instance to remove. If the instance is not in
      the list of active sinks, the list is unchanged.
    */
    public func remove(sink: LogSink) {
        pthread_rwlock_wrlock(&self.lock)
        defer { pthread_rwlock_unlock(&self.lock) }
        if let index = self.sinks.firstIndex(where: { $0 === sink }) {
            self.sinks.remove(at: index)
        }
    }

    /** Send a log message to all active sinks.

    Each sink is passed the `level`, `message`, and optional `data`. This
    function does not block multiple queues calling it simultaneously.

    If `level` is `.fatal`, this function calls `fatalError()` after sending
    the message along to each active sink and flushing them.

    - parameter level: The severity level of the message.
    - parameter message: The textual message.
    - parameter data: Extra data (optional).
    */
    public func log(_ level: Level, _ message: String, data: [String: Any] = [:]) {
        let timestamp = Date()
        pthread_rwlock_rdlock(&self.lock)
        self.sinks.forEach { $0.log(timestamp: timestamp, level: level, message: message, data: data) }
        pthread_rwlock_unlock(&self.lock)

        if level == .fatal {
            // Acquire a writer lock to block all other loggers. Note that it's
            // never released because we're about to crash the process.
            pthread_rwlock_wrlock(&self.lock)
            self.sinks.forEach { $0.flush() }
            let data = data.isEmpty ? "" : " \(data)"
            fatalError("\(message)\(data)")
        }
    }

    /** Send a log message at level `.debug` to all active sinks.

    This function is a shorthand for calling `log(.debug, ...)`.

    - parameter message: The textual message.
    - parameter data: Extra data (optional).
    */
    public func debug(_ message: String, data: [String: Any] = [:]) {
        log(.debug, message, data: data)
    }

    /** Send a log message at level `.error` to all active sinks.

     This function is a shorthand for calling `log(.error, ...)`.

     - parameter message: The textual message.
     - parameter data: Extra data (optional).
     */
    public func error(_ message: String, data: [String: Any] = [:]) {
        log(.error, message, data: data)
    }

    /** Send a log message at level `.fatal` to all active sinks.

     This function is a shorthand for calling `log(.fatal, ...)`.

     - parameter message: The textual message.
     - parameter data: Extra data (optional).
     */
    public func fatal(_ message: String, data: [String: Any] = [:]) -> Never {
        log(.fatal, message, data: data)
        fatalError()
    }

    /** Send a log message at level `.info` to all active sinks.

     This function is a shorthand for calling `log(.info, ...)`.

     - parameter message: The textual message.
     - parameter data: Extra data (optional).
     */
    public func info(_ message: String, data: [String: Any] = [:]) {
        log(.info, message, data: data)
    }

    /** Send a log message at level `.warning` to all active sinks.

     This function is a shorthand for calling `log(.warning, ...)`.

     - parameter message: The textual message.
     - parameter data: Extra data (optional).
     */
    public func warning(_ message: String, data: [String: Any] = [:]) {
        log(.warning, message, data: data)
    }

    /** Send a log message using the shared `Logger` instance.

    This function sends a log message to all active sinks on the shared `Logger`
    instance. It's a shorthand for calling `Logger.shared.log(...)`.

    - parameter level: The severity level of the message.
    - parameter message: The textual message.
    - parameter data: Extra data (optional).
    */
    public static func log(_ level: Level, _ message: String, data: [String: Any] = [:]) {
        self.shared.log(level, message, data: data)
    }

    /** Send a log message at level `.debug` to the shared `Logger` instance.

    This function is shorthand for calling `Logger.shared.log(.debug, ...)`.

    - parameter message: The textual message.
    - parameter data: Extra data (optional).
    */
    public static func debug(_ message: String, data: [String: Any] = [:]) {
        self.shared.log(.debug, message, data: data)
    }

    /** Send a log message at level `.error` to the shared `Logger` instance.

     This function is shorthand for calling `Logger.shared.log(.error, ...)`.

     - parameter message: The textual message.
     - parameter data: Extra data (optional).
     */
    public static func error(_ message: String, data: [String: Any] = [:]) {
        self.shared.log(.error, message, data: data)
    }

    /** Send a log message at level `.fatal` to the shared `Logger` instance.

     This function is shorthand for calling `Logger.shared.log(.fatal, ...)`.

     - parameter message: The textual message.
     - parameter data: Extra data (optional).
     */
    public static func fatal(_ message: String, data: [String: Any] = [:]) -> Never {
        self.shared.fatal(message, data: data)
    }

    /** Send a log message at level `.info` to the shared `Logger` instance.

     This function is shorthand for calling `Logger.shared.log(.info, ...)`.

     - parameter message: The textual message.
     - parameter data: Extra data (optional).
     */
    public static func info(_ message: String, data: [String: Any] = [:]) {
        self.shared.log(.info, message, data: data)
    }

    /** Send a log message at level `.warning` to the shared `Logger` instance.

     This function is shorthand for calling `Logger.shared.log(.warning, ...)`.

     - parameter message: The textual message.
     - parameter data: Extra data (optional).
     */
    public static func warning(_ message: String, data: [String: Any] = [:]) {
        self.shared.log(.warning, message, data: data)
    }
}
