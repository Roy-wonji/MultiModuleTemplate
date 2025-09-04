//
//  Project+InfoPlist.swift
//  Plugins
//
//  Created by Wonji Suh  on 3/22/25.
//

import Foundation
import ProjectDescription

public extension InfoPlist {
  static let appInfoPlist: Self = .extendingDefault(
    with: InfoPlistDictionary()
      .setUIUserInterfaceStyle("Light")
      .setUILaunchScreens()
      .setCFBundleDevelopmentRegion()
      .setCFBundleDevelopmentRegion("$(DEVELOPMENT_LANGUAGE)")
      .setCFBundleExecutable("$(EXECUTABLE_NAME)")
      .setCFBundleIdentifier("$(PRODUCT_BUNDLE_IDENTIFIER)")
      .setCFBundleInfoDictionaryVersion("6.0")
      .setCFBundleName("${BUNDLE_DISPLAY_NAME}")
      .setCFBundlePackageType("APPL")
      .setCFBundleShortVersionString(.appVersion())
      .setAppTransportSecurity()
      .setCFBundleURLTypes()
      .setAppUseExemptEncryption(value: false)
      .setCFBundleVersion(.appBuildVersion())
      .setLSRequiresIPhoneOS(true)
      .setUIAppFonts(["PretendardVariable.ttf"])
      .setUIApplicationSceneManifest([
        "UIApplicationSupportsMultipleScenes": true,
        "UISceneConfigurations": [
          "UIWindowSceneSessionRoleApplication": [
            [
              "UISceneConfigurationName": "Default Configuration",
            ]
          ]
        ]
      ])
  )

  static let moduleInfoPlist: Self = .extendingDefault(
    with: InfoPlistDictionary()
      .setUIUserInterfaceStyle("Light")
      .setCFBundleDevelopmentRegion("$(DEVELOPMENT_LANGUAGE)")
      .setCFBundleExecutable("$(EXECUTABLE_NAME)")
      .setCFBundleIdentifier("$(PRODUCT_BUNDLE_IDENTIFIER)")
      .setCFBundleInfoDictionaryVersion("6.0")
      .setCFBundlePackageType("APPL")
      .setCFBundleShortVersionString(.appVersion())
      .setBaseURL("$(BASE_URL)")
  )
}
