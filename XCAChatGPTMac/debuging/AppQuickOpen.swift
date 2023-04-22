//
//  AppQuickOpen.swift
//  Found
//
//  Created by lixindong on 2023/4/21.
//

import SwiftUI
import KeyboardShortcuts

struct AppQuickOpen: View {
    // 使用 @StateObject 修饰符来管理数据，当数据发生改变时，自动刷新视图
    @StateObject var viewModel = InstalledAppsViewModel()
    @EnvironmentObject var pathManager: PathManager

    var body: some View {
        VStack {
            ConfigurableView(onBack: { pathManager.back() }, title: "", showLeftButton: true) {}
            List(viewModel.installedApps) { app in
                HStack {
                    Image(nsImage: app.icon ?? NSImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                    Text(app.name)
                    Spacer()
                    Form {
                        KeyboardShortcuts.Recorder("", name: KeyboardShortcuts.Name(app.bundleIdentifier))
                    }
                }
            }
            .frame(minWidth: 400, idealWidth: 500, maxWidth: .infinity, minHeight: 300, idealHeight: 500, maxHeight: .infinity)
        }
        .navigationBarBackButtonHidden(true)
        .background(.white)
    }
}

class InstalledAppsViewModel: ObservableObject {
    @Published var installedApps: [AppInfo] = []

    init() {
        // 使用 NSWorkspace 类获取已安装的应用程序列表
        let workspace = NSWorkspace.shared
        let apps = workspace.runningApplications
        for app in apps {
            let appInfo = AppInfo(name: app.localizedName ?? "", icon: app.icon, bundleIdentifier: app.bundleIdentifier ?? "")
            installedApps.append(appInfo)
        }
    }
    
    struct AppInfo: Identifiable {
        let id = UUID()
        let name: String
        let icon: NSImage?
        let bundleIdentifier: String
    }
}

struct AppQuickOpen_Previews: PreviewProvider {
    static var previews: some View {
        AppQuickOpen()
    }
}
