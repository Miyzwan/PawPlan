require 'xcodeproj'

project_path = 'PawPlan.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# 1. Targets
app_target = project.targets.find { |t| t.name == 'PawPlan' }
watch_target = project.targets.find { |t| t.name == 'PawPlan Watch App' }

if app_target.nil?
  puts "Error: Target PawPlan tidak ditemukan."
  exit 1
end

# Get the deployment target from the app_target
app_deployment_target = nil
app_target.build_configurations.each do |config|
  if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
    app_deployment_target = config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
  end
end
app_deployment_target ||= '17.0'

# 2. Tambah Target PawPlanTests (iOS Unit Tests)
test_target = project.targets.find { |t| t.name == 'PawPlanTests' }
if test_target.nil?
  puts "Membuat target PawPlanTests..."
  test_target = project.new_target(:unit_test_bundle, 'PawPlanTests', :ios, app_deployment_target)
  test_target.add_dependency(app_target)
  
  test_target.build_configurations.each do |config|
    config.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/PawPlan.app/PawPlan'
    config.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.miyzwan.PawPlanTests'
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = app_deployment_target
    config.build_settings['SWIFT_VERSION'] = '5.9'
    config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
    config.build_settings['PRODUCT_NAME'] = 'PawPlanTests'
  end
  puts "Target PawPlanTests berhasil dibuat dengan target #{app_deployment_target}."
else
  # Always ensure GENERATE_INFOPLIST_FILE and PRODUCT_NAME are set
  test_target.build_configurations.each do |config|
    config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
    config.build_settings['PRODUCT_NAME'] = 'PawPlanTests'
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = app_deployment_target
  end
  puts "Target PawPlanTests sudah ada, dipastikan settings ter-update ke target #{app_deployment_target}."
end

# 3. Hubungkan file tes ke target
tests_group = project.main_group.find_subpath('PawPlanTests', true)
tests_group.set_source_tree('SOURCE_ROOT')

# Daftarkan file tes dari folder PawPlanTests (kecuali watchOS tests)
test_files = Dir.glob('PawPlanTests/*.swift').reject { |f| f.include?('WatchNowViewModelTests.swift') }

test_files.each do |path|
  file_ref = tests_group.find_file_by_path(path)
  if file_ref.nil?
    file_ref = tests_group.new_file(path)
    test_target.add_file_references([file_ref])
  end
end

project.save
puts "Selesai! File project.pbxproj telah dikonfigurasi untuk unit test."
