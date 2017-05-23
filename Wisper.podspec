
Pod::Spec.new do |s|
  s.name             = "Wisper"
  s.version          = "0.2.1"
  s.summary          = "Wisper a descrete and asynchronous communication protocol between platforms and processes."
  s.description      = <<-DESC
                        Wisper is an extension of the JSON RPC protocol that allows full remote objects with construction/destruction of instances, static/instance methods and events. Wisper can be used for the simplest implementation where you just want to call an exposed method or the more complex cases where you need to instantiate multiple instances of an exposed class, run instance methods and receive events.

                        Wisper was created at Widespace to improve the communication layer from a webview running JavaScript to a native host app and make it appear as if the different platforms where united and worked seamlessly together.

                        Wisper both defines a protocol and provides an implementation of said protocol in multiple abstraction levels on different platforms. Instantiating an object in Objective C from Javascript works like instantiating any other JavaScript object `var myObject = new Object()`.
                       DESC

  s.homepage         = "https://github.com/wisper-rpc/"

  # Some cool diagrams or the Wisper logo here
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.authors          = { "Patrik Nyblad" => "patrik.nyblad@widespace.com", "Ehssan Hoorvash" => "ehssan.hoorvash@widespace.com", "Oskar Segersvärd" => "oskar.segersvard@widespace.com" }
  s.source           = { :git => "https://github.com/wisper-rpc/wisper-ios.git", :tag => s.version.to_s }

  #Not sure about lowest compatible versions
  s.ios.deployment_target = "6.0"
  s.osx.deployment_target = "10.10"
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
end
