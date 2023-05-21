//
//  AppShortcuts.swift
//  Found
//
//  Created by lixindong on 2023/5/19.
//

import SwiftUI

struct AppShortcuts: View {
    let options: [AppShortcutOption] = [.init(name: "双击 ⌘", id: "command"),
                                        .init(name: "双击 ⌥", id: "option"),
                                        .init(name: "双击 ⌃", id: "control"),
                                        .init(name: "自定义", id: "custom")]
    @AppStorage("appShortcutOption") var appShortcutOption: String = "custom"

    var body: some View {
        HStack {
            Picker("", selection: $appShortcutOption) {
                ForEach(options, id: \.id) { option in
                    Text(LocalizedStringKey(option.name))
                }
            }
            .onChange(of: appShortcutOption, perform: { newValue in
                KeyMonitorManager.shared.updateModifier(appShortcutKey())
            })
            .pickerStyle(.menu)
            .frame(width: 150)

        }
    }
}

struct AppShortcutOption {
    let name: String
    let id: String
}

struct AppShortcuts_Previews: PreviewProvider {
    static var previews: some View {
        AppShortcuts()
    }
}
