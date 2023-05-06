# Half Screen Splitter

## Description

I enjoy working with two windows side by side when I have access to only one monitor. In MacOS, there is something called the [split view](https://support.apple.com/en-us/HT204948) that enables this behavior, but I don't really enjoy it. It puts the windows in full screen mode, and I actually need to click on and **hold** a small green circle to enable it. I'd rather use something simpler which uses key combinations to enable this behavior...

Half Screen Splitter is my solution. It is meant to be run as a background application. When it captures `cmd + ctrl + leftArrow`, it puts the active window to the left, and resizes it to have full height and half screen width. It does the same thing when it captures `cmd + ctrl + rightArrow`, except it puts the window to the right.

## Usage

**Note** that this assumes you are running a Mac. Navigate to [the latest release](https://github.com/jx3yang/HalfScreenSplitter/releases/tag/1.0) and download the zip file. Unzip and move the .app file into your applications. The app will prompt you to grant Accessibility permissions the first time you run it. Those permissions are required to listen for the shortcuts. Once granted, the application will run in the background and the key combinations listed below should work as described. 

## Key Combinations

 Action | Key Combination |
-------------------------------|---------------------------|
Put active window to the left  | `cmd + ctrl + leftArrow`  |
Put active window to the right | `cmd + ctrl + rightArrow` |
Maximize active window         | `cmd + ctrl + upArrow`    |

## TODOs

- Ability to change key combinations
- Maybe more ways of splitting (e.g. 2x2, etc.)
