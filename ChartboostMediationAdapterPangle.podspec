Pod::Spec.new do |spec|
  spec.name        = 'ChartboostMediationAdapterPangle'
  spec.version     = '4.5.7.0.0.0'
  spec.license     = { :type => 'MIT', :file => 'LICENSE.md' }
  spec.homepage    = 'https://github.com/ChartBoost/chartboost-mediation-ios-adapter-pangle'
  spec.authors     = { 'Chartboost' => 'https://www.chartboost.com/' }
  spec.summary     = 'Chartboost Mediation iOS SDK Pangle adapter.'
  spec.description = 'Pangle Adapters for mediating through Chartboost Mediation. Supported ad formats: Banner, Interstitial, and Rewarded.'

  # Source
  spec.module_name  = 'ChartboostMediationAdapterPangle'
  spec.source       = { :git => 'https://github.com/ChartBoost/chartboost-mediation-ios-adapter-pangle.git', :tag => spec.version }
  spec.resource_bundles = { 'ChartboostMediationAdapterPangle' => ['PrivacyInfo.xcprivacy'] }
  spec.source_files = 'Source/**/*.{swift}'

  # Minimum supported versions
  spec.swift_version         = '5.0'
  spec.ios.deployment_target = '13.0'

  # System frameworks used
  spec.ios.frameworks = ['Foundation', 'UIKit']
  
  # This adapter is compatible with all Chartboost Mediation 4.X versions of the SDK.
  spec.dependency 'ChartboostMediationSDK', '~> 4.0'

  # Partner network SDK and version that this adapter is certified to work with.
  spec.dependency 'Ads-Global', '~> 5.7.0.0'
  spec.static_framework = true
end
