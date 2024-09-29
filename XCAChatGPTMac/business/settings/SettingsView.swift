//
//  SettingsView.swift
//  XCAChatGPT
//
//  Created by lixindong on 2024/9/29.
//

import SwiftUI
import AppUpdater

struct SettingsView: View {
    @StateObject var updater = AppUpdater(owner: "s1ntoneli", repo: "Macaify", proxy: GithubProxy())

    var body: some View {
        AppUpdateSettings()
            .environmentObject(updater)
    }
}
