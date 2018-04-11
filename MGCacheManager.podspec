Pod::Spec.new do |s|
  s.name        = 'MGCacheManager'
  s.version     = '1.0.x'
  s.summary     = 'A tool to manage caches on disk, useful for API caching and NSEncoder classes instances caching.'
  s.description      = <<-DESC
  Caching is very important in order to speedup you application performace and to decrease API requests and load on your servers. MGCacheManager helps you handle most of caching cases. MGCacheManager is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:
                       DESC

  s.homepage    = 'https://github.com/Mortgy/MGCacheManager.git'
  s.authors     = { 'Muhammed Mortgy' => 'm.mortgy@mortgy.com' }
  s.source      = { :git => 'https://github.com/Mortgy/MGCacheManager.git',
                    :tag => s.version.to_s }
  s.license     = { :type => "MIT", :file => "LICENSE" }

  s.platform = :ios, '6.0'
  s.requires_arc = true
  s.source_files = 'MGCacheManager/MGCacheManager/*'
  s.public_header_files = 'MGCacheManager/MGCacheManager/*.h'

  s.ios.deployment_target = '6.0'
end