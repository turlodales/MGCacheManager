Pod::Spec.new do |s|
  s.name        = 'MGCacheManager'
  s.version     = '1.0.x'
  s.authors     = { 'Muhammed Mortgy' => 'm.mortgy@mortgy.com' }
  s.homepage    = 'https://github.com/Mortgy/MGCacheManager.git'
  s.summary     = 'A tool to manage caches with adding expire date for each endpoint.'
  s.source      = { :git => 'https://github.com/Mortgy/MGCacheManager.git',
                    :tag => s.version.to_s }
  s.license     = { :type => "MIT", :file => "LICENSE" }

  s.platform = :ios, '6.0'
  s.requires_arc = true
  s.source_files = 'MGCacheManager/MGCacheManager'
  s.public_header_files = 'MGCacheManager/MGCacheManager/*.h'

  s.ios.deployment_target = '6.0'
end