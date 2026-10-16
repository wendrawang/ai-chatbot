#!/usr/bin/env ruby
#
#  generate_project.rb
#  ai-chatbot
#
#  Created by Wendra on 15/10/26.
#

require 'fileutils'
require 'xcodeproj'

ROOT_PATH = File.expand_path('..', __dir__)
PROJECT_PATH = File.join(ROOT_PATH, 'TanyaAISandbox.xcodeproj')
APP_PATH = File.join(ROOT_PATH, 'TanyaAISandboxApp')
UI_TEST_PATH = File.join(ROOT_PATH, 'TanyaAISandboxUITests')
UNIT_TEST_PATH = File.join(ROOT_PATH, 'TanyaAISandboxTests')

FileUtils.rm_rf(PROJECT_PATH)

project = Xcodeproj::Project.new(PROJECT_PATH)
project.root_object.attributes['LastSwiftUpdateCheck'] = '2660'
project.root_object.attributes['LastUpgradeCheck'] = '2660'
project.root_object.known_regions = ['en', 'id', 'zh-Hans', 'Base']

app_group = project.main_group.new_group(
  'TanyaAISandboxApp',
  'TanyaAISandboxApp'
)
target = project.new_target(
  :application,
  'TanyaAISandbox',
  :ios,
  '15.0'
)
target.product_reference.path = 'Tanya AI Sandbox.app'
ui_test_target = project.new_target(
  :ui_test_bundle,
  'TanyaAISandboxUITests',
  :ios,
  '15.0'
)
unit_test_target = project.new_target(:unit_test_bundle, 'TanyaAISandboxTests', :ios, '17.0')

source_paths = Dir.glob(File.join(APP_PATH, '*.swift')).sort
source_references = source_paths.map do |source_path|
  app_group.new_file(File.basename(source_path))
end
target.add_file_references(source_references)
app_group.new_file('Info.plist')
launch_screen = app_group.new_file('LaunchScreen.storyboard')
target.resources_build_phase.add_file_reference(launch_screen)

resources_group = app_group.new_group('Resources', 'Resources')
localization = resources_group.new_variant_group('Localizable.strings')
%w[en id zh-Hans].each do |language|
  reference = localization.new_file("#{language}.lproj/Localizable.strings")
  reference.name = language
end
target.resources_build_phase.add_file_reference(localization)

target.build_configurations.each do |configuration|
  settings = configuration.build_settings
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.tanyaai.sandbox'
  settings['PRODUCT_NAME'] = 'Tanya AI Sandbox'
  settings['INFOPLIST_FILE'] = 'TanyaAISandboxApp/Info.plist'
  settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
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

unit_test_group = project.main_group.new_group('TanyaAISandboxTests', 'TanyaAISandboxTests')
unit_test_references = Dir.glob(File.join(UNIT_TEST_PATH, '*.swift')).sort.map do |source_path|
  unit_test_group.new_file(File.basename(source_path))
end
unit_test_target.add_file_references(unit_test_references)
unit_test_target.add_dependency(target)
unit_test_target.build_configurations.each do |configuration|
  settings = configuration.build_settings
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.tanyaai.sandbox.tests'
  settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  settings['SWIFT_VERSION'] = '5.0'
  settings['TARGETED_DEVICE_FAMILY'] = '1'
  settings['CODE_SIGN_STYLE'] = 'Automatic'
  settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/Tanya AI Sandbox.app/Tanya AI Sandbox'
  settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
end

ui_test_target.build_configurations.each do |configuration|
  settings = configuration.build_settings
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.example.tanyaai.sandbox.uitests'
  settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
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

design_kit_reference = project.new(Xcodeproj::Project::Object::XCLocalSwiftPackageReference)
design_kit_reference.relative_path = 'Packages/DesignKit'
project.root_object.package_references << design_kit_reference

[
  [target, package_reference, 'TanyaAI'],
  [target, design_kit_reference, 'DesignKit'],
  [unit_test_target, package_reference, 'TanyaAI'],
  [unit_test_target, design_kit_reference, 'DesignKit']
].each do |linked_target, reference, product_name|
  product = project.new(
    Xcodeproj::Project::Object::XCSwiftPackageProductDependency
  )
  product.package = reference
  product.product_name = product_name
  linked_target.package_product_dependencies << product

  build_file = project.new(
    Xcodeproj::Project::Object::PBXBuildFile
  )
  build_file.product_ref = product
  linked_target.frameworks_build_phase.files << build_file
end

# R.swift runs in each resource-owning target; the app never borrows package accessors.
rswift_reference = project.new(Xcodeproj::Project::Object::XCRemoteSwiftPackageReference)
rswift_reference.repositoryURL = 'https://github.com/mac-cain13/R.swift.git'
rswift_reference.requirement = { 'kind' => 'exactVersion', 'version' => '7.8.0' }
project.root_object.package_references << rswift_reference

rswift_library = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
rswift_library.package = rswift_reference
rswift_library.product_name = 'RswiftLibrary'
target.package_product_dependencies << rswift_library
rswift_build_file = project.new(Xcodeproj::Project::Object::PBXBuildFile)
rswift_build_file.product_ref = rswift_library
target.frameworks_build_phase.files << rswift_build_file

# Plugin references omit package, following R.swift's own Xcode project examples.
rswift_plugin = project.new(Xcodeproj::Project::Object::XCSwiftPackageProductDependency)
rswift_plugin.product_name = 'plugin:RswiftGenerateInternalResources'
plugin_dependency = project.new(Xcodeproj::Project::Object::PBXTargetDependency)
plugin_dependency.product_ref = rswift_plugin
target.dependencies << plugin_dependency

project.save

scheme = Xcodeproj::XCScheme.new
scheme.configure_with_targets(target, ui_test_target, launch_target: true)
scheme.add_test_target(unit_test_target)
scheme.save_as(PROJECT_PATH, 'TanyaAISandbox', true)

puts "Generated #{PROJECT_PATH}"
