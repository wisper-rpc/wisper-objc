# GatewayRouter
A gateway router is the root route in a Wisper system. It acts as the delegate for it's gateway and tries to route all messages it receives through the tree of routers under it. It also takes every reverse routed message and puts it through it's Gateway to send messages and events to another Wisper system. The GatewayRouter also has a delegate that a message channel (UIWebView, socket or any other way of sending messages to another Wisper system) is supposed to implement to pass messages to other Wisper systems.

Incoming messages will either be sent to a [Router](../routers/), or used as the response to a request.

```
receiveJSON +-------------------------------+      +---------------+
    <---    |           Gateway             | ---> | GatewayRouter |
    --->    +-------------------------------+      +---------------+
  sendJSON  |  -handleMessageAsJSONString:  |
            |  -sendMessage:                |
            +-------------------------------+
                  |
                  v
            +-----------+
            |  Waiting  |
            |  Requests |
            +-----------+
```
