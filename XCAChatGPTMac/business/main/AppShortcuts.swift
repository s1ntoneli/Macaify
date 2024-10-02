//
//  AppShortcuts.swift
//  Found
//
//  Created by lixindong on 2023/5/19.
//

import SwiftUI

struct AppShortcuts: View {
    let options: [AppShortcutOption] = [.init(name: "double_click_cmd", id: "command"),
                                        .init(name: "double_click_option", id: "option"),
                                        .init(name: "double_click_control", id: "control"),
                                        .init(name: "double_click_fn", id: "function"),
                                        .init(name: "customize", id: "custom")]
    @AppStorage("appShortcutOption") var appShortcutOption: String = "option"

    var body: some View {
        HStack {
            Picker("global_wakeup_hotkey", selection: $appShortcutOption) {
                ForEach(options, id: \.id) { option in
                    Text(LocalizedStringKey(option.name))
                }
            }
            .onChange(of: appShortcutOption, perform: { newValue in
                KeyMonitorManager.shared.updateModifier(appShortcutKey())
            })
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
