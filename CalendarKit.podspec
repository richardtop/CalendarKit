Pod::Spec.new do |s|
  s.name             = "CalendarKit"
  s.summary          = "Clone of iOS Calendar app"
  s.version          = "0.1.0"
  s.homepage         = "https://github.com/richardtop/CalendarKit"
  s.license          = 'MIT'
  s.author           = { "Richard Topchii" => "richardot4@gmail.com" }
  s.source           = { :git => "https://github.com/richardtop/CalendarKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/RTopchiy'
  s.platform     = :ios, '9.0'
  s.requires_arc = true
  s.source_files = 'Source/*  */*'
  s.dependency 'DateTools'
  s.dependency 'Neon'
  s.dependency 'DynamicColor'
end
