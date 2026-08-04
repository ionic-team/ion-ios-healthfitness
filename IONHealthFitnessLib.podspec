require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |spec|
  spec.name         = package['name']
  spec.version      = package['version']
  spec.summary      = package['description']

  spec.homepage     = package['repository']['url']
  spec.license      = { :type => package['license'], :file => "LICENSE" }
  spec.author       = { package['author'] => package['email'] }

  spec.ios.deployment_target = "13.0"

  spec.source       = { :git => package['repository']['url'], :tag => "#{spec.version}" }
  spec.source_files = "Sources/IONHealthFitnessLib/**/*.swift"
  spec.resources    = "Sources/IONHealthFitnessLib/LocalStorage/BackgroundModel.xcdatamodeld"

  spec.frameworks = "CloudKit", "CoreData", "HealthKit", "NotificationCenter", "UserNotifications"

  spec.swift_versions = ['5.0']
end
