
Pod::Spec.new do |s|

  s.name = 'Communicator'
  s.version = '1.0.0'
  s.swift_version = '4.2'
  s.summary = 'Communicator to abstract away from communication implementation'
  s.homepage = 'https://github.com/igormuzyka/Communicator'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = { 'Igor Muzyka' => 'igormuzyka42@gmail.com' }
  s.source = { :git => 'https://github.com/igormuzyka/Communicator.git', :tag => s.version.to_s }
  s.source_files = 'Sources/**/*'

  s.osx.deployment_target = "10.10"
  s.ios.deployment_target  = "9.0"
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '3.0'
  s.dependency 'TypePreservingCodingAdapter', :podspec => 'https://github.com/igormuzyka/Type-Preserving-Coding-Adapter/TypePreservingCodingAdapter.podspec'

end
