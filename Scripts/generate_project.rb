#!/usr/bin/env ruby

require 'fileutils'
require 'xcodeproj'

ROOT_PATH = File.expand_path('..', __dir__)
PROJECT_PATH = File.join(ROOT_PATH, 'TanyaAISandbox.xcodeproj')
APP_PATH = File.join(ROOT_PATH, 'TanyaAISandboxApp')
UI_TEST_PATH = File.join(ROOT_PATH, 'TanyaAISandboxUITests')

FileUtils.rm_rf(PROJECT_PATH)

project = Xcodeproj::Project.new(PROJECT_PATH)
project.root_object.attributes['LastSwiftUpdateCheck'] = '2660'
project.root_object.attributes['LastUpgradeCheck'] = '2660'

app_group = project.main_group.new_group(
  'TanyaAISandboxApp',
  'TanyaAISandboxApp'
)
target = project.new_target(
  :application,
  'TanyaAISandbox',
  :ios,
  '13.0'
)
target.product_reference.path = 'Tanya AI Sandbox.app'
ui_test_target = project.new_target(
  :ui_test_bundle,
  'TanyaAISandboxUITests',
  :ios,
  '13.0'
)

source_paths = Dir.glob(File.join(APP_PATH, '*.swift')).sort
source_references = source_paths.map do |source_path|
  app_group.new_file(File.basename(source_path))
end
target.add_file_references(source_references)
app_group.new_file('Info.plist')
launch_screen = app_group.new_file('LaunchScreen.storyboard')
target.resources_build_phase.add_file_reference(launch_screen)

target.build_configurations.each do |configuration|
  settings = configuration.build_settings
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.tanyaai.sandbox'
  settings['PRODUCT_NAME'] = 'Tanya AI Sandbox'
  settings['INFOPLIST_FILE'] = 'TanyaAISandboxApp/Info.plist'
  settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
  settings['SWIFT_VERSION'] = '5.0'
  settings['TARGETED_DEVICE_FAMILY'] = '1'
  settings['CODE_SIGN_STYLE'] = 'Automatic'
  settings['GENERATE_INFOPLIST_FILE'] = 'NO'
  settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = ''
end

ui_test_group = project.main_group.new_group(
  'TanyaAISandboxUITests',
  'TanyaAISandboxUITests'
)
ui_test_paths = Dir.glob(File.join(UI_TEST_PATH, '*.swift')).sort
ui_test_references = ui_test_paths.map do |source_path|
  ui_test_group.new_file(File.basename(source_path))
end
ui_test_target.add_file_references(ui_test_references)
ui_test_target.add_dependency(target)

ui_test_target.build_configurations.each do |configuration|
  settings = configuration.build_settings
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.tanyaai.sandbox.uitests'
  settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
  settings['SWIFT_VERSION'] = '5.0'
  settings['TARGETED_DEVICE_FAMILY'] = '1'
  settings['CODE_SIGN_STYLE'] = 'Automatic'
  settings['TEST_TARGET_NAME'] = 'TanyaAISandbox'
  settings['GENERATE_INFOPLIST_FILE'] = 'YES'
end

package_reference = project.new(
  Xcodeproj::Project::Object::XCLocalSwiftPackageReference
)
package_reference.relative_path = 'Packages/TanyaAI'
project.root_object.package_references << package_reference

%w[TanyaAI TanyaAITestSupport].each do |product_name|
  product = project.new(
    Xcodeproj::Project::Object::XCSwiftPackageProductDependency
  )
  product.package = package_reference
  product.product_name = product_name
  target.package_product_dependencies << product

  build_file = project.new(
    Xcodeproj::Project::Object::PBXBuildFile
  )
  build_file.product_ref = product
  target.frameworks_build_phase.files << build_file
end

project.save

scheme = Xcodeproj::XCScheme.new
scheme.configure_with_targets(target, ui_test_target, launch_target: true)
scheme.save_as(PROJECT_PATH, 'TanyaAISandbox', true)

puts "Generated #{PROJECT_PATH}"
