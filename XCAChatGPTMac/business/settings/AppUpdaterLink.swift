//
//  AppUpdaterLink.swift
//  Macaify
//
//  Created by lixindong on 2024/9/29.
//

import Foundation
import SwiftUI
import AppUpdater

struct AppUpdaterLink: View {

    @EnvironmentObject var updater: AppUpdater
    
    var body: some View {
        switch updater.state {
        case .none, .newVersionDetected:
            Button {
                updater.check()
            } label: {
                Text("check_for_updates")
            }
        case .downloading(_, _, fraction: let fraction):
           Text("Downloading \(Int(fraction * 10000) / 100)%")
        case .downloaded(_, _, let bundle):
            Button {
                updater.install(bundle)
            } label: {
                Text("install_and_restart")
            }
        }
    }
}
