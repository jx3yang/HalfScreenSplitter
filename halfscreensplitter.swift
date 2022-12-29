import Cocoa
import Accessibility

// enum to tell whether to put the active window to the left, to the right, or do nothing
enum Action {
    case putLeft, putRight, pass
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
        let action = combinationFilter(event: event)
        if action != .pass {
            handle(action: action)
        }
    }

    // this filters the key presses
    // the combination to put the window to the left is ctrl + cmd + leftArrow
    // and the combination to put it to the right is ctrl + cmd + rightArrow
    func combinationFilter(event: NSEvent) -> Action {
        if let specialKey = event.specialKey {
            if (!(event.modifierFlags.contains(.control) && event.modifierFlags.contains(.command))) {
                return Action.pass
            }
            if (specialKey == NSEvent.SpecialKey.leftArrow) {
                return Action.putLeft
            }
            if (specialKey == NSEvent.SpecialKey.rightArrow) {
                return Action.putRight
            }
        }
        return Action.pass
    }

    // the actual work is done here
    // essentially use the Accessibility functionalities to modify the attributes of the active window
    func handle(action: Action) -> Void {
        let pid = NSWorkspace.shared.frontmostApplication!.processIdentifier
        let appRef = AXUIElementCreateApplication(pid)
        var value: AnyObject?
        AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value)
        // the first window of the front most application is the front most window
        if let targetWindow = (value as? [AXUIElement])?.first {
            // the reason why these are mutable is because they are passed as pointers to the AXValueCreate below
            // but they are not meant to be mutable..
            var newPosition = action == .putLeft ? leftPosition(screenSize: screenSize) : rightPosition(screenSize: screenSize)
            var newSize = halfScreenSize(screenSize: screenSize)

            let positionRef: CFTypeRef = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!, &newPosition)!
            let sizeRef: CFTypeRef = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!, &newSize)!

            AXUIElementSetAttributeValue(targetWindow, kAXPositionAttribute as CFString, positionRef)
            AXUIElementSetAttributeValue(targetWindow, kAXSizeAttribute as CFString, sizeRef)
        }
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
