Pod::Spec.new do |s|
  s.name             = "CalendarKit"
  s.summary          = "Fully customizable calendar for iOS"
  s.version          = "0.12.3"
  s.homepage         = "https://github.com/richardtop/CalendarKit"
  s.license          = 'MIT'
  s.author           = { "Richard Topchii" => "richardtop@users.noreply.github.com" }
  s.source           = { :git => "https://github.com/richardtop/CalendarKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://github.com/richardtop'
  s.platform     = :ios, '9.0'
  s.swift_version = '5.2'
  s.requires_arc = true
  s.source_files = 'Source/**/*'
  s.ios.resource_bundle = { 'CalendarKit' => ['Localizations/*.lproj'] }
end
