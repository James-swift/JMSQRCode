Pod::Spec.new do |s|

  s.name          = "JMSQRCode"
  s.version       = "1.0.0"
  s.license       = "MIT"
  s.summary       = "A qr code generation and scanning tools using Swift."
  s.homepage      = "https://github.com/James-swift/JMSQRCode"
  s.author        = { "xiaobs" => "1007785739@qq.com" }
  s.source        = { :git => "https://github.com/James-swift/JMSQRCode.git", :tag => "1.0.0" }
  s.requires_arc  = true
  s.description   = <<-DESC
                   JMSQRCode - A qr code generation and scanning tools using Swift.
                   DESC
  s.source_files  = "JMSQRCode/*.swift"
  s.platform      = :ios, '8.0'
  s.framework     = 'Foundation', 'UIKit'  

end
