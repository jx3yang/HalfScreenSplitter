//
//  HalfScreenSplitterAppDelegate.swift
//  HalfScreenSplitter
//
//  Created by Ji Xi Yang on 2023-05-05.
//

import Accessibility
import Cocoa
import CoreGraphics

struct WindowStruct {
    var element: AXUIElement
    var title: String = ""
    var isMain: Bool = false
    var position: CGPoint = CGPoint.zero
    var size: CGSize = CGSize.zero

    init(axUIElement: AXUIElement) {
        element = axUIElement

        let attributes = [
            kAXTitleAttribute as CFString,
            kAXMainAttribute as CFString,
            kAXPositionAttribute as CFString,
            kAXSizeAttribute as CFString
        ]

        let options = AXCopyMultipleAttributeOptions(rawValue: 0)
        var values: CFArray?
        AXUIElementCopyMultipleAttributeValues(element, attributes as CFArray, options, &values)

        if let valuesArray: NSArray = values {
            title = valuesArray[0] as! String
            isMain = valuesArray[1] as! Bool
            AXValueGetValue(valuesArray[2] as! AXValue, AXValueType(rawValue: kAXValueCGPointType)!, &position)
            AXValueGetValue(valuesArray[3] as! AXValue, AXValueType(rawValue: kAXValueCGSizeType)!, &size)
        }
    }
}

func debugWindowStruct(_ windowStruct: WindowStruct) {
    print(windowStruct)
    print("")
}

// enum to tell whether to put the active window to the left or to the right
enum Action {
    case putLeft, putRight, putMax
}

class HalfScreenSplitterAppDelegate : NSObject, NSApplicationDelegate {
    var appMenu: AppMenu!
    var enabled = false

    @MainActor func applicationWillFinishLaunching(_ notification: Notification) { }

    @MainActor func applicationDidFinishLaunching(_ notification: Notification) {

        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        // set the options: false means it wont ask
        // true means it will popup and ask
        let options = [checkOptPrompt: true]
        // translate into boolean value
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)

        if (!accessEnabled) {
            print("Accessibility permissions needed")
            pollAccessibility()
        } else {
            setUp()
        }
    }

    func setUp() {
        // this sets up the monitoring of key presses
        // since this uses the accessibility functionalities, it will ask for permissions the first time around
        NSEvent.addGlobalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown, handler: keyHandler)
        enabled = true

        // this sets up the menu
        appMenu = AppMenu(delegate: self)
    }

    func pollAccessibility() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 , execute: {
            if !AXIsProcessTrusted() {
                self.pollAccessibility()
            } else {
                self.setUp()
            }
        })
    }

    func isEnabled() -> Bool {
        return enabled
    }

    func toggleEnabled() {
        enabled = !enabled
    }

    func quitApplication() {
        NSApplication.shared.terminate(nil)
    }

    // this gets called on key presses
    func keyHandler(event: NSEvent) -> Void {
        if enabled {
            if let action = combinationFilter(event: event) {
                handle(action: action)
            }
        }
    }

    // this filters the key presses
    // the combination to put the window to the left is ctrl + cmd + leftArrow
    // the combination to put it to the right is ctrl + cmd + rightArrow
    // the combination to maximize the window is ctrl + cmd + upArrow
    func combinationFilter(event: NSEvent) -> Action? {
        if let specialKey = event.specialKey {
            if (!(event.modifierFlags.contains(.control) && event.modifierFlags.contains(.command))) {
                return nil
            }
            switch specialKey {
            case .leftArrow: return .putLeft
            case .rightArrow: return .putRight
            case .upArrow: return .putMax
            default: return nil
            }
        }
        return nil
    }

    // the actual work is done here
    // essentially use the Accessibility functionalities to modify the attributes of the active window
    func handle(action: Action) -> Void {
        // query the current screen size
        if let frame = getScreenFrame() {
            let pid = NSWorkspace.shared.frontmostApplication!.processIdentifier
            let appRef = AXUIElementCreateApplication(pid)
            var value: CFTypeRef?
            AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value)

            // get the 'main' window of the front most application
            if let targetWindow = (value as? [AXUIElement])?.lazy.map<WindowStruct>({
                // note that this is lazily computed, so we do *not* create a WindowStruct for every visible window on the screen!
                return WindowStruct(axUIElement: $0)
            }).first(where: {
#if DEBUG
                debugWindowStruct($0)
#endif
                return $0.isMain
            }) {
                // the reason why these are mutable is because they are passed as pointers to the AXValueCreate below
                // but they are not meant to be mutable..
                var (newPosition, newSize) = getNewPositionAndSizeFromAction(action: action, frame: frame)

                let positionRef: CFTypeRef = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!, &newPosition)!
                let sizeRef: CFTypeRef = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!, &newSize)!

                if (targetWindow.position != newPosition) {
                    AXUIElementSetAttributeValue(targetWindow.element, kAXPositionAttribute as CFString, positionRef)
                }

                if (targetWindow.size != newSize) {
                    AXUIElementSetAttributeValue(targetWindow.element, kAXSizeAttribute as CFString, sizeRef)
                }
            }
        }
    }

    func getScreenFrame() -> CGRect? {
        return NSScreen.main?.frame
    }

    func getNewPositionAndSizeFromAction(action: Action, frame: CGRect) -> (CGPoint, CGSize) {
        switch action {
        case .putLeft:
            return (frame.origin, CGSize(width: frame.size.width / 2, height: frame.size.height))
        case .putRight:
            return (CGPoint(x: frame.origin.x + frame.size.width / 2, y: frame.origin.y), CGSize(width: frame.size.width / 2, height: frame.size.height))
        case .putMax:
            return (frame.origin, frame.size)
        }
    }
}
