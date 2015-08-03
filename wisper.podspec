Pod::Spec.new do |s|
  s.name             = "Wisper"
  s.version          = "0.0.1"
  s.summary          = "A short description of Wisper."
  s.description      = <<-DESC
                       An optional longer description of Wisper
                       DESC
  s.homepage         = "https://bitbucket.org/widespaceGIT/wisper-ios/"
  s.license          = 'MIT'
  s.authors          = { "Patrik Nyblad" => "patrik.nyblad@widespace.com", "Ehssan Hoorvash" => "ehssan.hoorvash@widespace.com", "Oskar Segersvärd" => "oskar.segersvard@widespace.com" }
  s.source           = { :git => "https://bitbucket.org/widespaceGIT/wisper-ios.git", :tag => s.version.to_s }

  s.platform     = :ios, '4.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'

end
