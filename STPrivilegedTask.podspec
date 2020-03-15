Pod::Spec.new do |s|
  s.name         = "STPrivilegedTask"
  s.version      = "1.0.8"
  s.summary      = "An NSTask-like wrapper around the macOS Security Framework's AuthorizationExecuteWithPrivileges()"
  s.description  = "An NSTask-like wrapper around AuthorizationExecuteWithPrivileges() in the Security API to run shell commands with root privileges on macOS."
  s.homepage     = "http://github.com/sveinbjornt/STPrivilegedTask"
  s.license      = { :type => 'BSD' }
  s.author       = { "Sveinbjorn Thordarson" => "sveinbjorn@sveinbjorn.org" }
  s.osx.deployment_target = "10.8"
  s.source       = { :git => "https://github.com/sveinbjornt/STPrivilegedTask.git", :tag => "1.0.8" }
  s.source_files = "STPrivilegedTask.{h,m}"
  s.exclude_files = "PrivilegedTaskExample"
  s.public_header_files = "STPrivilegedTask.h"
  s.framework  = "Security"
  s.requires_arc = true
end
