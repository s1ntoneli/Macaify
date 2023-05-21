//
//  StartUpView.swift
//  Found
//
//  Created by lixindong on 2023/5/21.
//

import SwiftUI

struct StartUpView: View {
    @AppStorage("showNewFeature_0_4") var showNewFeatureIntroduction: Bool = true
    @AppStorage("showPreferenceInitializer_1") var showPreferenceInitializer: Bool = true
    @AppStorage("selectedLanguage") var userDefaultsSelectedLanguage: String?
    
    @State private var showNewFeature: Bool = false
    @State private var showInitializer: Bool = false

    var body: some View {
        ZStack {}
            .sheet(isPresented: $showInitializer) {
                PreferenceInitializerView()
                    .environment(\.locale, .init(identifier: userDefaultsSelectedLanguage ?? "en"))
            }
            .sheet(isPresented: $showNewFeature) {
                NewFeatureIntroductionView()
                    .environment(\.locale, .init(identifier: userDefaultsSelectedLanguage ?? "en"))
            }
            .onAppear {
                showNewFeature = showNewFeatureIntroduction
                showInitializer = showPreferenceInitializer
            }
    }
}

struct StartUpView_Previews: PreviewProvider {
    static var previews: some View {
        StartUpView()
    }
}
