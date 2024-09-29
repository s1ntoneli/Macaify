//
//  View+Base.swift
//  Macaify
//
//  Created by lixindong on 2024/9/28.
//

import Foundation
import SwiftUI

extension String? {
    var isBlank: Bool {
        self?.isEmpty ?? true
    }
}
