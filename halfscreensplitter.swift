import Accessibility
import Cocoa
import CoreGraphics

// enum to tell whether to put the active window to the left or to the right
enum Action {
    case putLeft, putRight, putMax
}

class HalfScreenSplitterAppDelegate : NSObject, NSApplicationDelegate {

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
        // query the current screen size
        if let frame = getScreenFrame() {
            let pid = NSWorkspace.shared.frontmostApplication!.processIdentifier
            let appRef = AXUIElementCreateApplication(pid)
            var value: CFTypeRef?
            AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value)
            // the first window of the front most application is the front most window
            if let targetWindow = (value as? [AXUIElement])?.first(where: {
                // we need to filter out elements that do not have titles (e.g. the little tag that appears on browsers when an url is hovered)
                var axTitle: CFTypeRef?
                AXUIElementCopyAttributeValue($0, kAXTitleAttribute as CFString, &axTitle)
                if let axTitle = axTitle as? String {
                    // isInCurrentFrame is an important check
                    // e.g. if window A and window B of the same application are in different frames, and we switch to window B from A via
                    //      cmd + `, then it is possible that window A is in front of B in this array.
                    return axTitle != "" && isInCurrentFrame(window: $0, currentFrame: frame)
                }
                return false
            }) {
                let currentPosition = getWindowPosition(window: targetWindow)
                let currentSize = getWindowSize(window: targetWindow)

                // the reason why these are mutable is because they are passed as pointers to the AXValueCreate below
                // but they are not meant to be mutable..
                var (newPosition, newSize) = getNewPositionAndSizeFromAction(action: action, frame: frame)

                let positionRef: CFTypeRef = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!, &newPosition)!
                let sizeRef: CFTypeRef = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!, &newSize)!

                if (currentPosition != newPosition) {
                    AXUIElementSetAttributeValue(targetWindow, kAXPositionAttribute as CFString, positionRef)
                }

                if (currentSize != newSize) {
                    AXUIElementSetAttributeValue(targetWindow, kAXSizeAttribute as CFString, sizeRef)
                }
            }
        }
    }

    func isInCurrentFrame(window: AXUIElement, currentFrame: CGRect) -> Bool {
        let position = getWindowPosition(window: window)
        return currentFrame.origin.x <= position.x && position.x <= currentFrame.origin.x + currentFrame.size.width
    }

    func getWindowPosition(window: AXUIElement) -> CGPoint {
        var positionRef: CFTypeRef?
        AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &positionRef)
        var position: CGPoint = CGPoint.zero
        AXValueGetValue(positionRef as! AXValue, AXValueType(rawValue: kAXValueCGPointType)!, &position)
        return position
    }

    func getWindowSize(window: AXUIElement) -> CGSize {
        var sizeRef: CFTypeRef?
        AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeRef)
        var size: CGSize = CGSize.zero
        AXValueGetValue(sizeRef as! AXValue, AXValueType(rawValue: kAXValueCGSizeType)!, &size)
        return size
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

func main() {
    let delegate = HalfScreenSplitterAppDelegate()
    NSApplication.shared.delegate = delegate

    // main loop
    NSApplication.shared.run()
}

main()
