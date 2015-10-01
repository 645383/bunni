## Changes between Bunni 2.1.0 and 2.2.0

### Add :addresses to connect options

Before this the connection options only allowed multiple hosts, an
address is a combination of a host and a port. This makes it possible to
specify different hosts with different ports.

Contributed by Bart van Zon (Tele2).

### Recover from connection.close by default

Bunni will now try to reconnect also when server sent connection.close is
received, e.g. when a server is restarting (but also when the connection is
force closed by the server). This is in-line with how many other clients behave.
The old default was `recover_from_connection_close: false`.

Contributed by Carl Hörberg (CloudAMQP).


## Changes between Bunni 2.0.0 and 2.1.0

Bunni 2.1.0 has an **important breaking change**. It is highly
advised that 2.1.0 is not mixed with earlier versions of Bunni
in case your applications include **integers in message headers**.

### Integer Value Serialisation in Headers

Integer values in headers are now serialised as signed 64-bit integers. Previously
they were serialised as 32-bit unsigned integers, causing both underflows
and overflows: incorrect values were observed by consumers.

It is highly
advised that 2.1.0 is not mixed with earlier versions of Bunni
in case your applications include integers in message headers.

If that's not the case, Bunni 2.1 will integeroperate with any earlier version
starting with 0.9.0 just fine. Popular clients in other languages
(e.g. Java and .NET) will interoperate with Bunni 2.1.0 without
issues.


### Explicit Ruby 2.0 Requirement

Bunni now requires Ruby 2.0 in the gemspec.

Contributed by Carl Hörberg.

### JRuby Fix

Bunni runs again on JRuby. Note that
JRuby users are strongly advised to use March Hare instead.

Contributed by Teodor Pripoae.



## Changes between Bunni 1.7.0 and 2.0.0

Bunni `2.0` doesn't have any breaking API changes
but drops Ruby 1.8 and 1.9 (both EOL'ed) support,
hence the version.

### Minimum Required Ruby Version is 2.0

Bunni `2.0` requires Ruby 2.0 or later.

## Non-Blocking Writes

Bunni now uses non-blocking socket writes, uses a reduced
number of writes for message publishing (frames are batched
into a single write), and handles TCP back pressure from
RabbitMQ better.

Contributed by Irina Bednova and Michael Klishin.

### Reduced Timeout Use

`Bunni::ContinuationQueue#poll` no longer relies on Ruby's `Timeout` which has
numerous issues, including starting a new "interruptor" thread per operation,
which is far from efficient.

Contributed by Joe Eli McIlvain and Carl Hörberg.

### Capped Number of Connection Recovery Attempts

`:recovery_attempts` is a new option that limits the number of
connection recovery attempts performed by Bunni. `nil` means
"no limit".

Contributed by Irina Bednova.

### Bunni::Channel#basic_ack and Related Methods Improvements

`Bunni::Channel#basic_ack`, `Bunni::Channel#basic_nack`, and `Bunni::Channel#basic_reject`
now adjust delivery tags between connection recoveries, as well as have a default value for
the second argument.

Contributed by Wayne Conrad.

### Logger Output Remains Consistent

Setting the `@logger.progname` attribute changes the output of the logger.
This is not expected behaviour when the client provides a custom logger.
Behaviour remains unchainged when the internally initialized logger is used.

Contributed by Justin Carter.

### prefetch_count is Limited to 65535

Since `basic.qos`'s `prefetch_count` field is of type `short` in the protocol,
Bunni must enforce its maximum allowed value to `2^16 - 1` to avoid
confusing issues due to overflow.

### Per-Consumer and Per-Channel Prefetch

Recent RabbitMQ versions support `basic.qos` `global` flag, controlling whether
`prefetch` applies per-consumer or per-channel. Bunni `Channel#prefetch` now
allows flag to be set as optional parameter, with the same default behaviour as
before (per-consumer).

Contributed by tiredpixel.


## Changes between Bunni 1.6.0 and 1.7.0

### TLS Peer Verification Enabled by Default

When using TLS, peer verification is now enabled by default.
It is still possible to [disable verification](http://rubybunni.info/articles/tls.html), e.g. for convenient
development locally.

Peer verification is a means of protection against man-in-the-middle attacks
and is highly recommended in production settings. However, it can be an inconvenience
during local development. We believe it's time to have the default to be
more secure.

Contributed by Michael Klishin (Pivotal) and Andre Foeken (Nedap).


### Higher Default Connection Timeout

Default connection timeout has been increased to 25 seconds. The older
default of 5 seconds wasn't sufficient in some edge cases with DNS
resolution (e.g. when primary DNS server is down).

The value can be overriden at connection time.

Contributed by Yury Batenko.


### Socket Read Timeout No Longer Set to 0 With Disabled Heartbeats

GH issue: [#267](https://github.com/ruby-amqp/bunni/pull/267).


### JRuby Writes Fixes

On JRuby, Bunni reverts back to using plain old `write(2)` for writes. The CRuby implementation
on JRuby suffers from I/O incompatibilities. Until JRuby

Bunni users who run on JRuby are highly recommended to switch to [March Hare](http://rubymarchhare.info),
which has nearly identical API and is significantly more efficient.


### Bunni::Session#with_channel Synchornisation Improvements

`Bunni::Session#with_channel` is now fully synchronised and won't run into `COMMAND_INVALID` errors
when used from multiple threads that share a connection.



## Changes between Bunni 1.5.0 and 1.6.0

### TLSv1 by Default

TLS connections now prefer TLSv1 (or later, if available) due to the recently discovered
[POODLE attack](https://www.openssl.org/~bodo/ssl-poodle.pdf) on SSLv3.

Contributed by Michael Klishin (Pivotal) and Justin Powers (Desk.com).

GH issues:

 * [#259](https://github.com/ruby-amqp/bunni/pull/259)
 * [#260](https://github.com/ruby-amqp/bunni/pull/260)
 * [#261](https://github.com/ruby-amqp/bunni/pull/261)


### Socket Read and Write Timeout Improvements

Bunni now sets a read timeout on the sockets it opens, and uses
`IO.select` timeouts as the most reliable option available
on Ruby 1.9 and later.

GH issue: [#254](https://github.com/ruby-amqp/bunni/pull/254).

Contributed by Andre Foeken (Nedap).

### Inline TLS Certificates Support

TLS certificate options now accept inline certificates as well as
file paths.

GH issues: [#255](https://github.com/ruby-amqp/bunni/pull/255), [#256](https://github.com/ruby-amqp/bunni/pull/256).

Contributed by Will Barrett (Sqwiggle).


## Changes between Bunni 1.4.0 and 1.5.0

### Improved Uncaught Exception Handler

Uncaught exception handler now provides more information about the exception,
including its caller (one more stack trace line).

Contributed by Carl Hörberg (CloudAMQP).


### Convenience Method for Temporary (Server-named, Exclusive) Queue Declaration

`Bunni::Channel#temporary_queue` is a convenience method that declares a new
server-named exclusive queue:

``` ruby
q = ch.temporary_queue
```

Contributed by Daniel Schierbeck (Zendesk).

### Recovery Reliability Improvements

Automatic connection recovery robustness improvements.
Contributed by Andre Foeken (Nedap).

### Host Lists

It is now possible to pass the `:hosts` option to `Bunni.new`/`Bunni::Session#initialize`.
When connection to RabbitMQ (including during connection recovery), a random host
will be chosen from the list.

Connection shuffling and robustness improvements.

Contributed by Andre Foeken (Nedap).

### Default Channel Removed

Breaks compatibility with Bunni 0.8.x.

`Bunni:Session#default_channel` was removed. Please open channels explicitly now,
as all the examples in the docs do.


## Changes between Bunni 1.3.0 and 1.4.0

### Channel#wait_for_confirms Returns Immediately If All Publishes Confirmed

Contributed by Matt Campbell.

### Publisher Confirms is In Sync After Recovery

When a connection is recovered, the sequence counter resets on the
broker, but not the client. To keep things in sync the client must store a confirmation
offset after a recovery.

Contributed by Devin Christensen.

### NoMethodError on Thread During Shutdown

During abnormal termination, `Bunni::Session#close` no longer tries
to call the non-existent `terminate_with` method on its origin
thread.


## Changes between Bunni 1.2.0 and 1.3.0

### TLS Can Be Explicitly Disabled

TLS now can be explicitly disabled even when connecting (without TLS)
to the default RabbitMQ TLS/amqps port (5671):

``` ruby
conn = Bunni.new(:port => 5671, :tls => false)
```

Contributed by Muhan Zou.


### Single Threaded Connections Raise Shutdown Exceptions

Single threaded Bunni connections will now raise exceptions
that occur during shutdown as is (instead of trying to shut down
I/O loop which only threaded ones have).

Contributed by Carl Hörberg.


### Synchronization Improvements for Session#close

`Bunni::Session#close` now better synchronizes state transitions,
eliminating a few race condition scenarios with I/O reader thread.


### Bunni::Exchange.default Fix

`Bunni::Exchange.default` no longer raises an exception.

Note that it is a legacy compatibility method. Please use
`Bunni::Channel#default_exchange` instead.

Contributed by Justin Litchfield.

GH issue [#211](https://github.com/ruby-amqp/bunni/pull/211).

### Bunni::Queue#pop_as_hash Removed

`Bunni::Queue#pop_as_hash`, which was added to ease migration
to Bunni 0.9, was removed.

### Bunni::Queue#pop Wraps Metadata

`Bunni::Queue#pop` now wraps `basic.get-ok` and message properties
into `Bunni::GetResponse` and `Bunni::MessageProperties`, just like
`basic.consume` deliveries.

GH issue: [#212](https://github.com/ruby-amqp/bunni/issues/212).

### Better Synchronization for Publisher Confirms

Publisher confirms implementation now synchronizes unconfirmed
set better.

Contributed by Nicolas Viennot.

### Channel Allocation After Recovery

Channel id allocator is no longer reset after recovery
if there are channels open. Makes it possible to open channels
on a recovered connection (in addition to the channels
it already had).



## Changes between Bunni 1.1.0 and 1.2.0

### :key Supported in Bunni::Channel#queue_bind

It is now possible to use `:key` (which Bunni versions prior to 0.9 used)
as well as `:routing_key` as an argument to `Bunni::Queue#bind`.

### System Exceptions Not Rescued by the Library

Bunni now rescues `StandardError` instead of `Exception` where
it automatically does so (e.g. when dispatching deliveries to consumers).

Contributed by Alex Young.


### Initial Socket Connection Timeout Again Raises Bunni::TCPConnectionFailed

Initial socket connection timeout again raises `Bunni::TCPConnectionFailed`
on the connection origin thread.

### Thread Leaks Plugged

`Bunni::Session#close` on connections that have experienced a network failure
will correctly clean up I/O and heartbeat sender threads.

Contributed by m-o-e.

### Bunni::Concurrent::ContinuationQueue#poll Rounding Fix

`Bunni::Concurrent::ContinuationQueue#poll` no longer floors the argument
to the nearest second.

Contributed by Brian Abreu.

### Routing Key Limit

Per AMQP 0-9-1 spec, routing keys cannot be longer than 255 characters.
`Bunni::Channel#basic_publish` and `Bunni::Exchange#publish` now enforces
this limit.

### Nagle's Algorithm Disabled Correctly

Bunni now properly disables [Nagle's algorithm](http://boundary.com/blog/2012/05/02/know-a-delay-nagles-algorithm-and-you/)
on the sockets it opens. This likely means
significantly lower latency for workloads that involve
sending a lot of small messages very frequently.

[Contributed](https://github.com/ruby-amqp/bunni/pull/187) by Nelson Gauthier (AirBnB).

### Internal Exchanges

Exchanges now can be declared as internal:

``` ruby
ch = conn.create_channel
x  = ch.fanout("bunni.tests.exchanges.internal", :internal => true)
```

Internal exchanges cannot be published to by clients and are solely used
for [Exchange-to-Exchange bindings](http://rabbitmq.com/e2e.html) and various
plugins but apps may still need to bind them. Now it is possible
to do so with Bunni.

### Uncaught Consumer Exceptions

Uncaught consumer exceptions are now handled by uncaught exceptions
handler that can be defined per channel:

``` ruby
ch.on_uncaught_exception do |e, consumer|
  # ...
end
```



## Changes between Bunni 1.1.0.rc1 and 1.1.0

### Synchronized Session#create_channel and Session#close_channel

Full bodies of `Bunni::Session#create_channel` and `Bunni::Session#close_channel`
are now synchronized, which makes sure concurrent `channel.open` and subsequent
operations (e.g. `exchange.declare`) do not result in connection-level exceptions
(incorrect connection state transitions).

### Corrected Recovery Log Message

Bunni will now use actual recovery interval in the log.

Contributed by Chad Fowler.




## Changes between Bunni 1.1.0.pre2 and 1.1.0.rc1

### Full Channel State Recovery

Channel recovery now involves recovery of publisher confirms and
transaction modes.


### TLS	Without Peer Verification

Bunni now successfully performs	TLS upgrade when peer verification
is disabled.

Contributed by Jordan Curzon.

### Bunni::Session#with_channel Ensures the Channel is Closed

`Bunni::Session#with_channel` now makes sure the channel is closed
even if provided block raises an exception

Contributed by Carl Hoerberg.



### Channel Number = 0 is Rejected

`Bunni::Session#create_channel` will now reject channel number 0.


### Single Threaded Mode Fixes

Single threaded mode no longer fails with

```
undefined method `event_loop'
```



## Changes between Bunni 1.1.0.pre1 and 1.1.0.pre2

### connection.tune.channel_max No Longer Overflows

`connection.tune.channel_max` could previously be configured to values
greater than 2^16 - 1 (65535). This would result in a silent overflow
during serialization. The issue was harmless in practice but is still
a bug that can be quite confusing.

Bunni now caps max number of channels to 65535. This allows it to be
forward compatible with future RabbitMQ versions that may allow limiting
total # of open channels via server configuration.

### amq-protocol Update

Minimum `amq-protocol` version is now `1.9.0` which includes
bug fixes and performance improvements for channel ID allocator.

### Thread Leaks Fixes

Bunni will now correctly release heartbeat sender when allocating
a new one (usually happens only when connection recovers from a network
failure).


## Changes between Bunni 1.0.0 and 1.1.0.pre1

### Versioned Delivery Tag Fix

Versioned delivery tag now ensures all the arguments it operates
(original delivery tag, atomic fixnum instances, etc) are coerced to `Integer`
before comparison.

GitHub issues: #171.

### User-Provided Loggers

Bunni now can use any logger that provides the same API as Ruby standard library's `Logger`:

``` ruby
require "logger"
require "stringio"

io = StringIO.new
# will log to `io`
Bunni.new(:logger => Logger.new(io))
```

### Default CA's Paths Are Disabled on JRuby

Bunni uses OpenSSL provided CA certificate paths. This
caused problems on some platforms on JRuby (see [jruby/jruby#155](https://github.com/jruby/jruby/issues/1055)).

To avoid these issues, Bunni no longer uses default CA certificate paths on JRuby
(there are no changes for other Rubies), so it's necessary to provide
CA certificate explicitly.

### Fixes CPU Burn on JRuby

Bunni now uses slightly different ways of continuously reading from the socket
on CRuby and JRuby, to prevent abnormally high CPU usage on JRuby after a
certain period of time (the frequency of `EWOULDBLOCK` being raised spiked
sharply).



## Changes between Bunni 1.0.0.rc2 and 1.0.0.rc3

### [Authentication Failure Notification](http://www.rabbitmq.com/auth-notification.html) Support

`Bunni::AuthenticationFailureError` is a new auth failure exception
that subclasses `Bunni::PossibleAuthenticationFailureError` for
backwards compatibility.

As such, `Bunni::PossibleAuthenticationFailureError`'s error message
has changed.

This extension is available in RabbitMQ 3.2+.


### Bunni::Session#exchange_exists?

`Bunni::Session#exchange_exists?` is a new predicate that makes it
easier to check if a exchange exists.

It uses a one-off channel and `exchange.declare` with `passive` set to true
under the hood.

### Bunni::Session#queue_exists?

`Bunni::Session#queue_exists?` is a new predicate that makes it
easier to check if a queue exists.

It uses a one-off channel and `queue.declare` with `passive` set to true
under the hood.


### Inline TLS Certificates and Keys

It is now possible to provide inline client
certificate and private key (as strings) instead
of filesystem paths. The options are the same:

 * `:tls` which, when set to `true`, will set SSL context up and switch to TLS port (5671)
 * `:tls_cert` which now can be a client certificate (public key) in PEM format
 * `:tls_key` which now can be a client key (private key) in PEM format
 * `:tls_ca_certificates` which is an array of string paths to CA certificates in PEM format

For example:

``` ruby
conn = Bunni.new(:tls                   => true,
                 :tls_cert              => ENV["TLS_CERTIFICATE"],
                 :tls_key               => ENV["TLS_PRIVATE_KEY"],
                 :tls_ca_certificates   => ["./examples/tls/cacert.pem"])
```



## Changes between Bunni 1.0.0.rc1 and 1.0.0.rc2

### Ruby 1.8.7 Compatibility Fixes

Ruby 1.8.7 compatibility fixes around timeouts.



## Changes between Bunni 1.0.0.pre6 and 1.0.0.rc1

### amq-protocol Update

Minimum `amq-protocol` version is now `1.8.0` which includes
a bug fix for messages exactly 128 Kb in size.


### Add timeout Bunni::ConsumerWorkPool#join

`Bunni::ConsumerWorkPool#join` now accepts an optional
timeout argument.


## Changes between Bunni 1.0.0.pre5 and 1.0.0.pre6

### Respect RABBITMQ_URL value

`RABBITMQ_URL` env variable will now have effect even if
Bunni.new is invoked without arguments.



## Changes between Bunni 1.0.0.pre4 and 1.0.0.pre5

### Ruby 1.8 Compatibility

Bunni is Ruby 1.8-compatible again and no longer references
`RUBY_ENGINE`.

### Bunni::Session.parse_uri

`Bunni::Session.parse_uri` is a new method that parses
connection URIs into hashes that `Bunni::Session#initialize`
accepts.

``` ruby
Bunni::Session.parse_uri("amqp://user:pwd@broker.eng.megacorp.local/myapp_qa")
```

### Default Paths for TLS/SSL CA's on All OS'es

Bunni now uses OpenSSL to detect default TLS/SSL CA's paths, extending
this feature to OS'es other than Linux.

Contributed by Jingwen Owen Ou.


## Changes between Bunni 1.0.0.pre3 and 1.0.0.pre4

### Default Paths for TLS/SSL CA's on Linux

Bunni now will use the following TLS/SSL CA's paths on Linux by default:

 * `/etc/ssl/certs/ca-certificates.crt` on Ubuntu/Debian
 * `/etc/ssl/certs/ca-bundle.crt` on Amazon Linux
 * `/etc/ssl/ca-bundle.pem` on OpenSUSE
 * `/etc/pki/tls/certs/ca-bundle.crt` on Fedora/RHEL

and will log a warning if no CA files are available via default paths
or `:tls_ca_certificates`.

Contributed by Carl Hörberg.

### Consumers Can Be Re-Registered From Bunni::Consumer#handle_cancellation

It is now possible to re-register a consumer (and use any other synchronous methods)
from `Bunni::Consumer#handle_cancellation`, which is now invoked in the channel's
thread pool.


### Bunni::Session#close Fixed for Single Threaded Connections

`Bunni::Session#close` with single threaded connections no longer fails
with a nil pointer exception.



## Changes between Bunni 1.0.0.pre2 and 1.0.0.pre3

This release has **breaking API changes**.

### Safe[r] basic.ack, basic.nack and basic.reject implementation

Previously if a channel was recovered (reopened) by automatic connection
recovery before a message was acknowledged or rejected, it would cause
any operation on the channel that uses delivery tags to fail and
cause the channel to be closed.

To avoid this issue, every channel keeps a counter of how many times
it has been reopened and marks delivery tags with them. Using a stale
tag to ack or reject a message will produce no method sent to RabbitMQ.
Note that unacknowledged messages will be requeued by RabbitMQ when connection
goes down anyway.

This involves an API change: `Bunni::DeliveryMetadata#delivery_tag` is now
and instance of a class that responds to `#tag` and `#to_i` and is accepted
by `Bunni::Channel#ack` and related methods.

Integers are still accepted by the same methods.


## Changes between Bunni 1.0.0.pre1 and 1.0.0.pre2

### Exclusivity Violation for Consumers Now Raises a Reasonable Exception

When a second consumer is registered for the same queue on different channels,
a reasonable exception (`Bunni::AccessRefused`) will be raised.


### Reentrant Mutex Implementation

Bunni now allows mutex impl to be configurable, uses reentrant Monitor
by default.

Non-reentrant mutexes is a major PITA and may affect code that
uses Bunni.

Avg. publishing throughput with Monitor drops slightly from
5.73 Khz to 5.49 Khz (about 4% decrease), which is reasonable
for Bunni.

Apps that need these 4% can configure what mutex implementation
is used on per-connection basis.

### Eliminated Race Condition in Bunni::Session#close

`Bunni::Session#close` had a race condition that caused (non-deterministic)
exceptions when connection transport was closed before connection
reader loop was guaranteed to have stopped.

### connection.close Raises Exceptions on Connection Thread

Connection-level exceptions (including when a connection is closed via
management UI or `rabbitmqctl`) will now be raised on the connection
thread so they

 * can be handled by applications
 * do not start connection recovery, which may be uncalled for

### Client TLS Certificates are Optional

Bunni will no longer require client TLS certificates. Note that CA certificate
list is still necessary.

If RabbitMQ TLS configuration requires peer verification, client certificate
and private key are mandatory.


## Changes between Bunni 0.9.0 and 1.0.0.pre1

### Publishing Over Closed Connections

Publishing a message over a closed connection (during a network outage, before the connection
is open) will now correctly result in an exception.

Contributed by Matt Campbell.


### Reliability Improvement in Automatic Network Failure Recovery

Bunni now ensures a new connection transport (socket) is initialized
before any recovery is attempted.


### Reliability Improvement in Bunni::Session#create_channel

`Bunni::Session#create_channel` now uses two separate mutexes to avoid
a (very rare) issue when the previous implementation would try to
re-acquire the same mutex and fail (Ruby mutexes are non-reentrant).



## Changes between Bunni 0.9.0.rc1 and 0.9.0.rc2

### Channel Now Properly Restarts Consumer Pool

In a case when all consumers are cancelled, `Bunni::Channel`
will shut down its consumer delivery thread pool.

It will also now mark the pool as not running so that it can be
started again successfully if new consumers are registered later.

GH issue: #133.


### Bunni::Queue#pop_waiting is Removed

A little bit of background: on MRI, the method raised `ThreadErrors`
reliably. On JRuby, we used a different [internal] queue implementation
from JDK so it wasn't an issue.

`Timeout.timeout` uses `Thread#kill` and `Thread#join`, both of which
eventually attempt to acquire a mutex used by Queue#pop, which Bunni
currently uses for continuations. The mutex is already has an owner
and so a ThreadError is raised.

This is not a problem on JRuby because there we don't use Ruby's
Timeout and Queue and instead rely on a JDK concurrency primitive
which provides "poll with a timeout".

[The issue with `Thread#kill` and `Thread#raise`](http://blog.headius.com/2008/02/ruby-threadraise-threadkill-timeoutrb.html)
has been first investigated and blogged about by Ruby implementers
in 2008.

Finding a workaround will probably take a bit of time and may involve
reimplementing standard library and core classes.

We don't want this issue to block Bunni 0.9 release. Neither we want
to ship a broken feature.  So as a result, we will drop
Bunni::Queue#pop_waiting since it cannot be reliably implemented in a
reasonable amount of time on MRI.

Per issue #131.


### More Flexible SSLContext Configuration

Bunni will now upgrade connection to SSL in `Bunni::Session#start`,
so it is possible to fine tune SSLContext and socket settings
before that:

``` ruby
require "bunni"

conn = Bunni.new(:tls                   => true,
                 :tls_cert              => "examples/tls/client_cert.pem",
                 :tls_key               => "examples/tls/client_key.pem",
                 :tls_ca_certificates   => ["./examples/tls/cacert.pem"])

puts conn.transport.socket.inspect
puts conn.transport.tls_context.inspect
```

This also means that `Bunni.new` will now open the socket. Previously
it was only done when `Bunni::Session#start` was invoked.


## Changes between Bunni 0.9.0.pre13 and 0.9.0.rc1

### TLS Support

Bunni 0.9 finally supports TLS. There are 3 new options `Bunni.new` takes:

 * `:tls` which, when set to `true`, will set SSL context up and switch to TLS port (5671)
 * `:tls_cert` which is a string path to the client certificate (public key) in PEM format
 * `:tls_key` which is a string path to the client key (private key) in PEM format
 * `:tls_ca_certificates` which is an array of string paths to CA certificates in PEM format

An example:

``` ruby
conn = Bunni.new(:tls                   => true,
                 :tls_cert              => "examples/tls/client_cert.pem",
                 :tls_key               => "examples/tls/client_key.pem",
                 :tls_ca_certificates   => ["./examples/tls/cacert.pem"])
```


### Bunni::Queue#pop_waiting

**This function was removed in v0.9.0.rc2**

`Bunni::Queue#pop_waiting` is a new function that mimics `Bunni::Queue#pop`
but will wait until a message is available. It uses a `:timeout` option and will
raise an exception if the timeout is hit:

``` ruby
# given 1 message in the queue,
# works exactly as Bunni::Queue#get
q.pop_waiting

# given no messages in the queue, will wait for up to 0.5 seconds
# for a message to become available. Raises an exception if the timeout
# is hit
q.pop_waiting(:timeout => 0.5)
```

This method only makes sense for collecting Request/Reply ("RPC") replies.


### Bunni::InvalidCommand is now Bunni::CommandInvalid

`Bunni::InvalidCommand` is now `Bunni::CommandInvalid` (follows
the exception class naming convention based on response status
name).



## Changes between Bunni 0.9.0.pre12 and 0.9.0.pre13

### Channels Without Consumers Now Tear Down Consumer Pools

Channels without consumers left (when all consumers were cancelled)
will now tear down their consumer work thread pools, thus making
`HotBunnies::Queue#subscribe(:block => true)` calls unblock.

This is typically the desired behavior.

### Consumer and Channel Available In Delivery Handlers

Delivery handlers registered via `Bunni::Queue#subscribe` now will have
access to the consumer and channel they are associated with via the
`delivery_info` argument:

``` ruby
q.subscribe do |delivery_info, properties, payload|
  delivery_info.consumer # => the consumer this delivery is for
  delivery_info.consumer # => the channel this delivery is on
end
```

This allows using `Bunni::Queue#subscribe` for one-off consumers
much easier, including when used with the `:block` option.

### Bunni::Exchange#wait_for_confirms

`Bunni::Exchange#wait_for_confirms` is a convenience method on `Bunni::Exchange` that
delegates to the method with the same name on exchange's channel.


## Changes between Bunni 0.9.0.pre11 and 0.9.0.pre12

### Ruby 1.8 Compatibility Regression Fix

`Bunni::Socket` no longer uses Ruby 1.9-specific constants.


### Bunni::Channel#wait_for_confirms Return Value Regression Fix

`Bunni::Channel#wait_for_confirms` returns `true` or `false` again.



## Changes between Bunni 0.9.0.pre10 and 0.9.0.pre11

### Bunni::Session#create_channel Now Accepts Consumer Work Pool Size

`Bunni::Session#create_channel` now accepts consumer work pool size as
the second argument:

``` ruby
# nil means channel id will be allocated by Bunni.
# 8 is the number of threads in the consumer work pool this channel will use.
ch = conn.create_channel(nil, 8)
```

### Heartbeat Fix For Long Running Consumers

Long running consumers that don't send any data will no longer
suffer from connections closed by RabbitMQ because of skipped
heartbeats.

Activity tracking now takes sent frames into account.


### Time-bound continuations

If a network loop exception causes "main" session thread to never
receive a response, methods such as `Bunni::Channel#queue` will simply time out
and raise Timeout::Error now, which can be handled.

It will not start automatic recovery for two reasons:

 * It will be started in the network activity loop anyway
 * It may do more damage than good

Kicking off network recovery manually is a matter of calling
`Bunni::Session#handle_network_failure`.

The main benefit of this implementation is that it will never
block the main app/session thread forever, and it is really
efficient on JRuby thanks to a j.u.c. blocking queue.

Fixes #112.


### Logging Support

Every Bunni connection now has a logger. By default, Bunni will use STDOUT
as logging device. This is configurable using the `:log_file` option:

``` ruby
require "bunni"

conn = Bunni.new(:log_level => :warn)
```

or the `BUNNY_LOG_LEVEL` environment variable that can take one of the following
values:

 * `debug` (very verbose)
 * `info`
 * `warn`
 * `error`
 * `fatal` (least verbose)

Severity is set to `warn` by default. To disable logging completely, set the level
to `fatal`.

To redirect logging to a file or any other object that can act as an I/O entity,
pass it to the `:log_file` option.


## Changes between Bunni 0.9.0.pre9 and 0.9.0.pre10

This release contains a **breaking API change**.

### Concurrency Improvements On JRuby

On JRuby, Bunni now will use `java.util.concurrent`-backed implementations
of some of the concurrency primitives. This both improves client stability
(JDK concurrency primitives has been around for 9 years and have
well-defined, documented semantics) and opens the door to solving
some tricky failure handling problems in the future.


### Explicitly Closed Sockets

Bunni now will correctly close the socket previous connection had
when recovering from network issues.


### Bunni::Exception Now Extends StandardError

`Bunni::Exception` now inherits from `StandardError` and not `Exception`.

Naked rescue like this

``` ruby
begin
  # ...
rescue => e
  # ...
end
```

catches only descendents of `StandardError`. Most people don't
know this and this is a very counter-intuitive practice, but
apparently there is code out there that can't be changed that
depends on this behavior.

This is a **breaking API change**.



## Changes between Bunni 0.9.0.pre8 and 0.9.0.pre9

### Bunni::Session#start Now Returns a Session

`Bunni::Session#start` now returns a session instead of the default channel
(which wasn't intentional, default channel is a backwards-compatibility implementation
detail).

`Bunni::Session#start` also no longer leaves dead threads behind if called multiple
times on the same connection.


### More Reliable Heartbeat Sender

Heartbeat sender no longer slips into an infinite loop if it encounters an exception.
Instead, it will just stop (and presumably re-started when the network error recovery
kicks in or the app reconnects manually).


### Network Recovery After Delay

Network reconnection now kicks in after a delay to avoid aggressive
reconnections in situations when we don't want to endlessly reconnect
(e.g. when the connection was closed via the Management UI).

The `:network_recovery_interval` option passed to `Bunni::Session#initialize` and `Bunni.new`
controls the interval. Default is 5 seconds.


### Default Heartbeat Value Is Now Server-Defined

Bunni will now use heartbeat value provided by RabbitMQ by default.



## Changes between Bunni 0.9.0.pre7 and 0.9.0.pre8

### Stability Improvements

Several stability improvements in the network
layer, connection error handling, and concurrency hazards.


### Automatic Connection Recovery Can Be Disabled

Automatic connection recovery now can be disabled by passing
the `:automatically_recover => false` option to `Bunni#initialize`).

When the recovery is disabled, network I/O-related exceptions will
cause an exception to be raised in thee thread the connection was
started on.


### No Timeout Control For Publishing

`Bunni::Exchange#publish` and `Bunni::Channel#basic_publish` no
longer perform timeout control (using the timeout module) which
roughly increases throughput for flood publishing by 350%.

Apps that need delivery guarantees should use publisher confirms.



## Changes between Bunni 0.9.0.pre6 and 0.9.0.pre7

### Bunni::Channel#on_error

`Bunni::Channel#on_error` is a new method that lets you define
handlers for channel errors that are caused by methods that have no
responses in the protocol (`basic.ack`, `basic.reject`, and `basic.nack`).

This is rarely necessary but helps make sure no error goes unnoticed.

Example:

``` ruby
channel.on_error |ch, channel_close|
  puts channel_close.inspect
end
```

### Fixed Framing of Larger Messages With Unicode Characters

Larger (over 128K) messages with non-ASCII characters are now always encoded
correctly with amq-protocol `1.2.0`.


### Efficiency Improvements

Publishing of large messages is now done more efficiently.

Contributed by Greg Brockman.


### API Reference

[Bunni API reference](http://reference.rubybunni.info) is now up online.


### Bunni::Channel#basic_publish Support For :persistent

`Bunni::Channel#basic_publish` now supports both
`:delivery_mode` and `:persistent` options.

### Bunni::Channel#nacked_set

`Bunni::Channel#nacked_set` is a counter-part to `Bunni::Channel#unacked_set`
that contains `basic.nack`-ed (rejected) delivery tags.


### Single-threaded Network Activity Mode

Passing `:threaded => false` to `Bunni.new` now will use the same
thread for publisher confirmations (may be useful for retry logic
implementation).

Contributed by Greg Brockman.


## Changes between Bunni 0.9.0.pre5 and 0.9.0.pre6

### Automatic Network Failure Recovery

Automatic Network Failure Recovery is a new Bunni feature that was earlier
impemented and vetted out in [amqp gem](http://rubyamqp.info). What it does
is, when a network activity loop detects an issue, it will try to
periodically recover [first TCP, then] AMQP 0.9.1 connection, reopen
all channels, recover all exchanges, queues, bindings and consumers
on those channels (to be clear: this only includes entities and consumers added via
Bunni).

Publishers and consumers will continue operating shortly after the network
connection recovers.

Learn more in the [Error Handling and Recovery](http://rubybunni.info/articles/error_handling.html)
documentation guide.

### Confirms Listeners

Bunni now supports listeners (callbacks) on

``` ruby
ch.confirm_select do |delivery_tag, multiple, nack|
  # handle confirms (e.g. perform retries) here
end
```

Contributed by Greg Brockman.

### Publisher Confirms Improvements

Publisher confirms implementation now uses non-strict equality (`<=`) for
cases when multiple messages are confirmed by RabbitMQ at once.

`Bunni::Channel#unconfirmed_set` is now part of the public API that lets
developers access unconfirmed delivery tags to perform retries and such.

Contributed by Greg Brockman.

### Publisher Confirms Concurrency Fix

`Bunni::Channel#wait_for_confirms` will now correctly block the calling
thread until all pending confirms are received.


## Changes between Bunni 0.9.0.pre4 and 0.9.0.pre5

### Channel Errors Reset

Channel error information is now properly reset when a channel is (re)opened.

GH issue: #83.

### Bunni::Consumer#initial Default Change

the default value of `Bunni::Consumer` noack argument changed from false to true
for consistency.

### Bunni::Session#prefetch Removed

Global prefetch is not implemented in RabbitMQ, so `Bunni::Session#prefetch`
is gone from the API.

### Queue Redeclaration Bug Fix

Fixed a problem when a queue was not declared after being deleted and redeclared

GH issue: #80

### Channel Cache Invalidation

Channel queue and exchange caches are now properly invalidated when queues and
exchanges are deleted.


## Changes between Bunni 0.9.0.pre3 and 0.9.0.pre4

### Heartbeats Support Fixes

Heartbeats are now correctly sent at safe intervals (half of the configured
interval). In addition, setting `:heartbeat => 0` (or `nil`) will disable
heartbeats, just like in Bunni 0.8 and [amqp gem](http://rubyamqp.info).

Default `:heartbeat` value is now `600` (seconds), the same as RabbitMQ 3.0
default.


### Eliminate Race Conditions When Registering Consumers

Fixes a potential race condition between `basic.consume-ok` handler and
delivery handler when a consumer is registered for a queue that has
messages in it.

GH issue: #78.

### Support for Alternative Authentication Mechanisms

Bunni now supports two authentication mechanisms and can be extended
to support more. The supported methods are `"PLAIN"` (username
and password) and `"EXTERNAL"` (typically uses TLS, UNIX sockets or
another mechanism that does not rely on username/challenge pairs).

To use the `"EXTERNAL"` method, pass `:auth_mechanism => "EXTERNAL"` to
`Bunni.new`:

``` ruby
# uses the EXTERNAL authentication mechanism
conn = Bunni.new(:auth_method => "EXTERNAL")
conn.start
```

### Bunni::Consumer#cancel

A new high-level API method: `Bunni::Consumer#cancel`, can be used to
cancel a consumer. `Bunni::Queue#subscribe` will now return consumer
instances when the `:block` option is passed in as `false`.


### Bunni::Exchange#delete Behavior Change

`Bunni::Exchange#delete` will no longer delete pre-declared exchanges
that cannot be declared by Bunni (`amq.*` and the default exchange).


### Bunni::DeliveryInfo#redelivered?

`Bunni::DeliveryInfo#redelivered?` is a new method that is an alias
to `Bunni::DeliveryInfo#redelivered` but follows the Ruby community convention
about predicate method names.

### Corrected Bunni::DeliveryInfo#delivery_tag Name

`Bunni::DeliveryInfo#delivery_tag` had a typo which is now fixed.


## Changes between Bunni 0.9.0.pre2 and 0.9.0.pre3

### Client Capabilities

Bunni now correctly lists RabbitMQ extensions it currently supports in client capabilities:

 * `basic.nack`
 * exchange-to-exchange bindings
 * consumer cancellation notifications
 * publisher confirms

### Publisher Confirms Support

[Lightweight Publisher Confirms](http://www.rabbitmq.com/blog/2011/02/10/introducing-publisher-confirms/) is a
RabbitMQ feature that lets publishers keep track of message routing without adding
noticeable throughput degradation as it is the case with AMQP 0.9.1 transactions.

Bunni `0.9.0.pre3` supports publisher confirms. Publisher confirms are enabled per channel,
using the `Bunni::Channel#confirm_select` method. `Bunni::Channel#wait_for_confirms` is a method
that blocks current thread until the client gets confirmations for all unconfirmed published
messages:

``` ruby
ch = connection.create_channel
ch.confirm_select

ch.using_publisher_confirmations? # => true

q  = ch.queue("", :exclusive => true)
x  = ch.default_exchange

5000.times do
  x.publish("xyzzy", :routing_key => q.name)
end

ch.next_publish_seq_no.should == 5001
ch.wait_for_confirms # waits until all 5000 published messages are acknowledged by RabbitMQ
```


### Consumers as Objects

It is now possible to register a consumer as an object instead
of a block. Consumers that are class instances support cancellation
notifications (e.g. when a queue they're registered with is deleted).

To support this, Bunni introduces two new methods: `Bunni::Channel#basic_consume_with`
and `Bunni::Queue#subscribe_with`, that operate on consumer objects. Objects are
supposed to respond to three selectors:

 * `:handle_delivery` with 3 arguments
 * `:handle_cancellation` with 1 argument
 * `:consumer_tag=` with 1 argument

An example:

``` ruby
class ExampleConsumer < Bunni::Consumer
  def cancelled?
    @cancelled
  end

  def handle_cancellation(_)
    @cancelled = true
  end
end

# "high-level" API
ch1 = connection.create_channel
q1  = ch1.queue("", :auto_delete => true)

consumer = ExampleConsumer.new(ch1, q)
q1.subscribe_with(consumer)

# "low-level" API
ch2 = connection.create_channel
q1  = ch2.queue("", :auto_delete => true)

consumer = ExampleConsumer.new(ch2, q)
ch2.basic_consume_with.(consumer)
```

### RABBITMQ_URL ENV variable support

If `RABBITMQ_URL` environment variable is set, Bunni will assume
it contains a valid amqp URI string and will use it. This is convenient
with some PaaS technologies such as Heroku.


## Changes between Bunni 0.9.0.pre1 and 0.9.0.pre2

### Change Bunni::Queue#pop default for :ack to false

It makes more sense for beginners that way.


### Bunni::Queue#subscribe now support the new :block option

`Bunni::Queue#subscribe` support the new `:block` option
(a boolean).

It controls whether the current thread will be blocked
by `Bunni::Queue#subscribe`.


### Bunni::Exchange#publish now supports :key again

`Bunni::Exchange#publish` now supports `:key` as an alias for
`:routing_key`.


### Bunni::Session#queue et al.

`Bunni::Session#queue`, `Bunni::Session#direct`, `Bunni::Session#fanout`, `Bunni::Session#topic`,
and `Bunni::Session#headers` were added to simplify migration. They all delegate to their respective
`Bunni::Channel` methods on the default channel every connection has.


### Bunni::Channel#exchange, Bunni::Session#exchange

`Bunni::Channel#exchange` and `Bunni::Session#exchange` were added to simplify
migration:

``` ruby
b = Bunni.new
b.start

# uses default connection channel
x = b.exchange("logs.events", :topic)
```

### Bunni::Queue#subscribe now properly takes 3 arguments

``` ruby
q.subscribe(:exclusive => false, :ack => false) do |delivery_info, properties, payload|
  # ...
end
```



## Changes between Bunni 0.8.x and 0.9.0.pre1

### New convenience functions: Bunni::Channel#fanout, Bunni::Channel#topic

`Bunni::Channel#fanout`, `Bunni::Channel#topic`, `Bunni::Channel#direct`, `Bunni::Channel#headers`,
and`Bunni::Channel#default_exchange` are new convenience methods to instantiate exchanges:

``` ruby
conn = Bunni.new
conn.start

ch = conn.create_channel
x  = ch.fanout("logging.events", :durable => true)
```


### Bunni::Queue#pop and consumer handlers (Bunni::Queue#subscribe) signatures have changed

Bunni `< 0.9.x` example:

``` ruby
h = queue.pop

puts h[:delivery_info], h[:header], h[:payload]
```

Bunni `>= 0.9.x` example:

``` ruby
delivery_info, properties, payload = queue.pop
```

The improve is both in that Ruby has positional destructuring, e.g.

``` ruby
delivery_info, _, content = q.pop
```

but not hash destructuring, like, say, Clojure does.

In addition we return nil for content when it should be nil
(basic.get-empty) and unify these arguments betwee

 * Bunni::Queue#pop

 * Consumer (Bunni::Queue#subscribe, etc) handlers

 * Returned message handlers

The unification moment was the driving factor.



### Bunni::Client#write now raises Bunni::ConnectionError

Bunni::Client#write now raises `Bunni::ConnectionError` instead of `Bunni::ServerDownError` when network
I/O operations fail.


### Bunni::Client.create_channel now uses a bitset-based allocator

Instead of reusing channel instances, `Bunni::Client.create_channel` now opens new channels and
uses bitset-based allocator to keep track of used channel ids. This avoids situations when
channels are reused or shared without developer's explicit intent but also work well for
long running applications that aggressively open and release channels.

This is also how amqp gem and RabbitMQ Java client manage channel ids.


### Bunni::ServerDownError is now Bunni::TCPConnectionFailed

`Bunni::ServerDownError` is now an alias for `Bunni::TCPConnectionFailed`
