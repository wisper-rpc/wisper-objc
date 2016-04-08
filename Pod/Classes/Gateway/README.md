# Gateway
A `Gateway` lies at the outmost edge of a Wisper system. It receives incoming messages through `-handleMessageAsJSONString:`, and sends messages through its delegate method `-gateway:didOutputMessage:`.

A gateway simply transforms JSON messages to native representations of those messages, keeps track of requests/responses and transforms native messages back into JSON.

This object by itself will not do much more than act as a gateway. To get more out of a Wisper gateway you should take a look at [`WSPRGatewayRouter`](../Router/) which not only converts messages back and forth but also routes the generated messages to Remote Objects.
