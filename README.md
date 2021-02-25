# AMQP dangerous forkio repro

First, set up a ramitmq server locally.

Then run `stack exec worker-exe` in one terminal. And `stack exec sender-exe` in another.

You'll see this in the sender:

```
$ stack exec sender-exe
starting sender.
Sending two test messages
sender done.
Auto-closing the channel because we got: Left (ChanThreadKilledException {cause = ConnectionClosedException Normal "closed by user"})
```

You'll see this in the worker:

```
$ stack exec worker-exe
starting worker.
worker listening.
Auto-closing the channel because we got: Left didn't expect frame: HeartbeatPayload
 syd@nona  ~/src/amqp-forkio-repro  4  stack exec worker-exe
starting worker.
worker listening.
Auto-closing the channel because we got: Left didn't expect frame: HeartbeatPayload
CallStack (from HasCallStack):
  error, called at ./Network/AMQP/Internal.hs:116:14 in amqp-0.20.0.1-KTo8izWmHUKDlj6V7B3Ee5:Network.AMQP.Internal
ERROR: channel not open 1
ERROR: channel not open 1
ERROR: channel not open 1
ERROR: channel not open 1
ERROR: channel not open 1
ERROR: channel not open 1
```

As you can see, the worker has not crashed, even if the channel thread has crashed.
The channel is considered closed because it's being auto-closed upon an exception, but messages are still being routed there.
