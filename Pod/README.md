# wisper-objc
The Objective C implementation of a simple, JSON-based RPC protocol.

Details about the wisper protocol itself can be found [here](https://github.com/wisper-rpc/wisper-protocol).

## Getting Started
Take a look at the documentation for the [`WSPRGateway` class](./Classes/Gateway/), it's at the core of `wisper-objc` and will point you in the right direction for everything else.

#### Example: Communicating across a UIWebView boundary
To communicate across a `UIWebView` boundary we simply set our selves as the delegate of the `WSPRGateway` and wrap generated messages in a javascript expression. A good way to receive messages from a UIWebView is to listen for navigations to a predefined protocol of your choice and not let the UIWebView load those requests.

**Receive messages from UIWebView**

```objc
#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)uiWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
  if (request.URL.scheme.length != 3 || !([request.URL.scheme caseInsensitiveCompare:@"rpc"] == NSOrderedSame))
  {
      NSString * jsonString = [[[[request URL] absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] substringFromIndex:4];
      [self.gateway handleMessageAsJSONString:jsonString];
      return NO;
  }

  return YES;
}
```

**Send messages to UIWebView**

```objc
#pragma mark - WSPRGatewayDelegate
-(void)gateway:(WSPRGateway *)gateway didOutputMessage:(NSString *)message
{
  NSString * jsEvalString = [NSString stringWithFormat:@"%@('%@')", @"wisper.message", message];
  [self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
  return YES;
}
```
