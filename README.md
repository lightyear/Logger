# Logger

This is a simple, thread-safe Logging framework for Swift.

## Usage

Logs can be sent to multiple destinations by adding sinks:

    Logger.shared.add(sink: ConsoleSink())

You can add as many sinks as you want, and later remove an instance of a specific sink with `remove(sink:)`:

    Logger.shared.remove(sink: mySink)

A log message is sent to all added sinks with `log(_:_:data:)`. The first argument is the log level, the second is the string message and the optional third argument is a dictionary of additional data.

    Logger.shared.log(.fatal, "Something catastrophic happened")
    Logger.shared.log(.error, "Something bad happened")
    Logger.shared.log(.warning, "Something unexpected happened")
    Logger.shared.log(.info, "This might be useful for debugging, but isn't pure noise")
    Logger.shared.log(.debug, "A probably noisy message for debugging")

`.fatal` logs are different from the others. A log at this level will be sent to each sink, the sinks will be flushed, and then the `Logger` will call `fatalError()` to crash the app.

There are also convenience functions that move the level argument to be the function's name:

    Logger.shared.fatal(_:data:) -> Never
    Logger.shared.error(_:data:)
    Logger.shared.warning(_:data:)
    Logger.shared.info(_:data:)
    Logger.shared.debug(_:data:)

Note that `fatal(_:data:)` returns `Never`, making it useful in situations where the app cannot continue and the function won't return a useful value, but you still want to log details about the problem before crashing.

Finally, if you're logging to the shared instance via `.shared`, you can use the static functions instead: `Logger.error(_:data:)`, `Logger.warning(_:data:)`, etc.

The logger itself is thread-safe, meaning that you can add/remove sinks and log messages from multiple threads simultaneously without corrupting the internal state of the logger. Individual sinks may impose synchronization of their own to preserve their internal state. For example, `ConsoleSink` logs via `print()` and `print()` (or something it calls) locks internally so that the output from two threads isn't intermixed in the console.

You might be wondering about that third `data` argument. Historically, logs have been flat text files, but this makes it harder to find things when you have a lot of logs. If you use a structured data storage system such as ElasticSearch, keeping the timestamp, level and other contextual data in a structured form makes searching more efficient. It also aids metrics, because you can put the contextual data that changes from one occurrence to the next in `data`, while the `message` is constant.

## Available Sinks

### ConsoleSink

Sends logs to the console via Swift's `print()` function. Lines include a timestamp, the identifier of the thread that invoked the log, the log level, message and data (if provided).

The timestamp is formatted using a `DateFormatter` with the ISO-8601 format. You can change this to something else by assigning a new format to the sink's `dateFormat` property.

### StringSink

Behaves pretty much exactly like `ConsoleSink`, except logs are appended to the `string` property on the sink. You can clear the accumulated logs by calling `truncate()`.

## Implementing a Custom Sink

`LogSink` is a very simple protocol with two functions:

    func log(timestamp: Date, level: Logger.Level, message: String, data: [String: Any])
    func flush()

Sinks are invoked on the same thread that called the logger, so you're responsible for synchronizing access to your sink's internal state.

`flush()` is called during `.fatal` logs. Your sink needs to persist any log data it wants to keep before returning.
