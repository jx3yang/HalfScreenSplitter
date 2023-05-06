# Half Screen Splitter

## Description

In MacOS, there is something called the [split view](https://support.apple.com/en-us/HT204948) which enables the user to work with two windows next to each other. I personally find it hard to use because I have to shuffle between several windows, and it seems like there's no easy way to facilitate my workflow using split views.

Half Screen Splitter is my solution. It is meant to be run as a background application, and listens for predefined key combinations. When it captures `cmd + ctrl + leftArrow`, it puts the active window to the left, and resizes it to have full height and half screen width. It does the same thing when it captures `cmd + ctrl + rightArrow`, except it puts the window to the right.

## Usage

**Note** that this assumes you are running on a Mac. Navigate to [the latest release](https://github.com/jx3yang/HalfScreenSplitter/releases/tag/1.0) and download the zip file. Unzip and move the .app file into your applications. The app will prompt you to grant Accessibility permissions the first time you run it. Those permissions are required to listen for the shortcuts. Once granted, the application will run in the background and the key combinations listed below should work as described.

When the application is running, a logo spelling `HSS` will appear on the status bar. A menu appears when the logo is clicked, giving the option for the user to temporarily disable/reenable the key combinations and to quit the program.

## Key Combinations

 Action | Key Combination |
-------------------------------|---------------------------|
Put active window to the left  | `cmd + ctrl + leftArrow`  |
Put active window to the right | `cmd + ctrl + rightArrow` |
Maximize active window         | `cmd + ctrl + upArrow`    |

## TODOs

- Ability to change key combinations
