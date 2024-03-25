//
//  ExampleApp.swift
//  Example
//
//  Created by 王楚江 on 2024/3/25.
//

import SwiftUI

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        //        .windowStyle(HiddenTitleBarWindowStyle())
        #endif
    }
}
