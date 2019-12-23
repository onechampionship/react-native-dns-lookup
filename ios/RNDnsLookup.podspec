require 'json'

package = JSON.parse(File.read(File.join(__dir__, '../package.json')))

Pod::Spec.new do |s|
  s.name         = "RNDnsLookup"
  s.version      = package['version']
  s.summary      = "RNDnsLookup"

  s.homepage     = "https://github.com/tableau/react-native-dns-lookup#readme"
  s.license      = "MIT"

  s.author       = { "Tableau" => "github@tableau.com" }
  s.platform     = :ios, "11.0"
  s.source       = { :git => "https://github.com/author/RNDnsLookup.git", :tag => "master" }
  #s.source_files = "RNDnsLookup/**/*.{h,m}"
  s.requires_arc = true
  
  s.ios.deployment_target = "11.0"
  
  s.subspec "RNDnsLookup" do |ss|
     ss.source_files  = "*.{h,m}"
     s.static_framework = true
   end
  
  s.default_subspec = "RNDnsLookup"

  s.dependency "React"

end

