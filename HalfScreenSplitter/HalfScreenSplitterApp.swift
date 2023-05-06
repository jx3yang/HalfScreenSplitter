//
//  HalfScreenSplitterApp.swift
//  HalfScreenSplitter
//
//  Created by Ji Xi Yang on 2023-05-04.
//

import SwiftUI

@main
struct HalfScreenSplitterApp: App {
    @NSApplicationDelegateAdaptor(HalfScreenSplitterAppDelegate.self) var halfScreenSplitterAppDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
