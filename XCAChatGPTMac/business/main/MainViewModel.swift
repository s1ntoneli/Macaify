//
//  MainViewModel.swift
//  XCAChatGPTMac
//
//  Created by lixindong on 2023/4/16.
//

import Foundation

class MainViewModel: ObservableObject {
    
    static let shared = MainViewModel()
    
    @Published var searchText = ""
}
