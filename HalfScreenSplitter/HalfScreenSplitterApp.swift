//
//  HalfScreenSplitterApp.swift
//  HalfScreenSplitter
//
//  Created by Ji Xi Yang on 2023-05-04.
//

import SwiftUI
import Accessibility
import Cocoa
import CoreGraphics

@main
struct HalfScreenSplitterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let contentView = NSHostingView(rootView: ContentView())
        contentView.frame = NSRect(x: 0, y: 0, width: 200, height: 200)
        
        let menuItem = NSMenuItem()
        menuItem.view = contentView
        let menu = NSMenu()
        menu.addItem(menuItem)
        
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem.menu = menu
        statusBarItem?.button?.image = NSImage(named: NSImage.iconViewTemplateName)
    }
}
