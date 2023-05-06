//
//  AppMenu.swift
//  HalfScreenSplitter
//
//  Created by Ji Xi Yang on 2023-05-05.
//

import SwiftUI

class AppMenu {
    var statusBarItem: NSStatusItem!
    var appDelegate: HalfScreenSplitterAppDelegate!

    init(delegate: HalfScreenSplitterAppDelegate) {
        appDelegate = delegate

        let enableItem = NSMenuItem()
        enableItem.title = "✓ Enable Half Screen Splitter"
        enableItem.target = self
        enableItem.action = #selector(enableClicked(_:))

        let quitItem = NSMenuItem()
        quitItem.title = "⠀ Quit Half Screen Splitter"
        quitItem.target = self
        quitItem.action = #selector(quitClicked(_:))

        let menu = NSMenu()
        menu.minimumWidth = 100
        menu.addItem(enableItem)
        menu.addItem(.separator())
        menu.addItem(quitItem)

        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem.menu = menu
        statusBarItem.button?.title = "HSS"
    }

    @objc func enableClicked(_ sender: NSMenuItem) {
        if (appDelegate.isEnabled()) {
            sender.title = "⠀ Enable Half Screen Splitter"
        } else {
            sender.title = "✓ Enable Half Screen Splitter"
        }
        appDelegate.toggleEnabled()
    }

    @objc func quitClicked(_ sender: NSMenuItem) {
        appDelegate.quitApplication()
    }
}
