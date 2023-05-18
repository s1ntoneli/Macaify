//
//  LanguageOptions.swift
//  Found
//
//  Created by lixindong on 2023/5/19.
//

import SwiftUI

import SwiftUI

struct LanguageOptions: View {
    @State private var selectedLanguage: String = "en"

    @AppStorage("selectedLanguage") var userDefaultsSelectedLanguage: String?
    
    private let options = [Lang(name: "English", localeIdentifier: "en"), Lang(name: "简体中文", localeIdentifier: "zh-cn")]
    
    var body: some View {
        Picker("", selection: $selectedLanguage) {
            ForEach(options, id: \.localeIdentifier) { language in
                Text(language.name).tag(language.localeIdentifier)
            }
        }
        .onChange(of: selectedLanguage) { language in
            userDefaultsSelectedLanguage = language
        }
        .onAppear {
            selectedLanguage = userDefaultsSelectedLanguage ?? "en"
        }
    }
}

struct Lang: Hashable {
    let name: String
    var localeIdentifier: String
}



struct LanguageOptions_Previews: PreviewProvider {
    static var previews: some View {
        LanguageOptions()
    }
}
