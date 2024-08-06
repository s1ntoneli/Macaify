//
//  CheckForUpdatesViewModel.swift
//  Macaify
//
//  Created by lixindong on 2023/10/3.
//

import Foundation
import Sparkle

final class CheckForUpdatesViewModel: ObservableObject {
    @Published var canCheckForUpdates = false

    init(updater: SPUUpdater) {
        updater.publisher(for: \.canCheckForUpdates)
            .assign(to: &$canCheckForUpdates)
    }
}
