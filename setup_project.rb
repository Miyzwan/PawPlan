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

# 2. Tambah Target PawPlanTests (iOS Unit Tests)
test_target = project.targets.find { |t| t.name == 'PawPlanTests' }
if test_target.nil?
  puts "Membuat target PawPlanTests..."
  test_target = project.new_target(:unit_test_bundle, 'PawPlanTests', :ios, '17.0')
  test_target.add_dependency(app_target)
  
  test_target.build_configurations.each do |config|
    config.build_settings['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/PawPlan.app/PawPlan'
    config.build_settings['BUNDLE_LOADER'] = '$(TEST_HOST)'
    config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.miyzwan.PawPlanTests'
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    config.build_settings['SWIFT_VERSION'] = '5.9'
  end
  puts "Target PawPlanTests berhasil dibuat."
end

# 3. Hubungkan file tes ke target
tests_group = project.main_group.find_subpath('PawPlanTests', true)
tests_group.set_source_tree('SOURCE_ROOT')

# Daftarkan file tes jika ada di disk
test_files = [
  'PawPlanTests/RootViewModelTests.swift',
  'PawPlanTests/DashboardViewModelTests.swift',
  'PawPlanTests/WatchNowViewModelTests.swift'
]

test_files.each do |path|
  file_ref = tests_group.find_file_by_path(path)
  if file_ref.nil?
    file_ref = tests_group.new_file(path)
    test_target.add_file_references([file_ref])
  end
end

project.save
puts "Selesai! File project.pbxproj telah dikonfigurasi untuk unit test."
