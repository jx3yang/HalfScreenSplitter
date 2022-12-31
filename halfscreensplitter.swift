import Accessibility
import Cocoa
import CoreGraphics

// enum to tell whether to put the active window to the left or to the right
enum Action {
    case putLeft, putRight, putMax
}

class HalfScreenSplitterAppDelegate : NSObject, NSApplicationDelegate {
    // immutable for now, but really this could change at runtime by switching monitors and whatnot
    let screenSize: CGSize

    init(screenSize: CGSize) {
        self.screenSize = screenSize
    }

    @MainActor func applicationWillFinishLaunching(_ notification: Notification) { }

    @MainActor func applicationDidFinishLaunching(_ notification: Notification) {
        // this sets up the monitoring of key presses
        // since this uses the accessibility functionalities, it will ask for permissions the first time around
        NSEvent.addGlobalMonitorForEvents(matching: NSEvent.EventTypeMask.keyDown, handler: keyHandler)
    }

    // this gets called on key presses
    func keyHandler(event: NSEvent) -> Void {
        if let action = combinationFilter(event: event) {
            handle(action: action)
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
        let pid = NSWorkspace.shared.frontmostApplication!.processIdentifier
        let appRef = AXUIElementCreateApplication(pid)
        var value: AnyObject?
        AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value)
        // the first window of the front most application is the front most window
        if let targetWindow = (value as? [AXUIElement])?.first(where: {
            // we need to filter out elements that do not have titles (e.g. the little tag that appears on browsers when an url is hovered)
            var axTitle: AnyObject?
            AXUIElementCopyAttributeValue($0, kAXTitleAttribute as CFString, &axTitle)
            if let axTitle = axTitle as? String {
                return axTitle != ""
            }
            return false
        }) {
            // the reason why these are mutable is because they are passed as pointers to the AXValueCreate below
            // but they are not meant to be mutable..
            var newPosition = positionFromAction(action: action)
            var newSize = sizeFromAction(action: action)

            let positionRef: CFTypeRef = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!, &newPosition)!
            let sizeRef: CFTypeRef = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!, &newSize)!

            AXUIElementSetAttributeValue(targetWindow, kAXPositionAttribute as CFString, positionRef)
            AXUIElementSetAttributeValue(targetWindow, kAXSizeAttribute as CFString, sizeRef)
        }
    }

    func positionFromAction(action: Action) -> CGPoint {
        switch action {
            case .putLeft, .putMax: return leftPosition(screenSize: screenSize)
            case .putRight: return rightPosition(screenSize: screenSize)
        }
    }

    func sizeFromAction(action: Action) -> CGSize {
        switch action {
            case .putLeft, .putRight: return halfScreenSize(screenSize: screenSize)
            case .putMax: return fullScreenSize(screenSize: screenSize)
        }
    }

    func fullScreenSize(screenSize: CGSize) -> CGSize {
        return screenSize
    }

    func halfScreenSize(screenSize: CGSize) -> CGSize {
        return CGSize(width: screenSize.width / 2, height: screenSize.height)
    }

    func leftPosition(screenSize: CGSize) -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }

    func rightPosition(screenSize: CGSize) -> CGPoint {
        return CGPoint(x: screenSize.width / 2, y: 0)
    }
}

func main() {
    if let mainScreenSize = NSScreen.main?.frame.size {
        print("Detected main screen with size \(mainScreenSize)")

        let delegate = HalfScreenSplitterAppDelegate(screenSize: mainScreenSize)
        NSApplication.shared.delegate = delegate

        // main loop
        NSApplication.shared.run()
    } else {
        assert(false)
    }
}

main()
