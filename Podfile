# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
  
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
  end
end

target 'avito-task-internship' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for avito-task-internship
  pod 'CocoaLumberjack/Swift', '~> 3.7.0'
  pod 'SwiftLint', '~> 0.47.0'

end
