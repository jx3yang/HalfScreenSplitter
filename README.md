# Half Screen Splitter

## Description

I enjoy working with two windows side by side when I have access to only one monitor. In MacOS, there is something called the [split view](https://support.apple.com/en-us/HT204948) that enables this behavior, but I don't really enjoy it. It puts the windows in full screen mode, and I actually need to click and **hold** on a small green circle to enable it. I'd rather use something simpler which uses key combinations to enable this behavior...

Half Screen Splitter is my solution. It is meant to be run as a background application. When it captures `cmd + ctrl + leftArrow`, it puts the active window to the left, and resizes it to have full height and half screen width. It does the same thing when it captures `cmd + ctrl + rightArrow`, except it puts the window to the right.

## Usage

**Note** that this assumes you are running a Mac. To build the application, run the following on the terminal
```
make
```
The above should output an executable named `halfscreensplitter`.

To run the application, execute
```
./halfscreensplitter
```

Then, press on `cmd + ctrl + leftArrow` on your keyboard. The OS will ask you for accessibility permissions. Once granted, the process will start running properly.

If you want to run the application in the background, you may also run
```
./halfscreensplitter &
```
Just don't forget to kill the application if the key combinations are bothersome. You can find the pid of the process with `ps -a | grep 'halfscreensplitter'`.

## Key Combinations

 Action | Key Combination |
-------------------------------|---------------------------|
Put active window to the left  | `cmd + ctrl + leftArrow`  |
Put active window to the right | `cmd + ctrl + rightArrow` |
Maximize active window         | `cmd + ctrl + upArrow`    |

## TODOs

- Ability to change key combinations
- Maybe more ways of splitting (e.g. 2x2, etc.)    
- Maybe an actual UI?
