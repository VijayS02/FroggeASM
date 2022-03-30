[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

# Frogger in Assembly
 This project is frogger written in assembly. There are very limited features working and this was a project for CSC258 (Computer Organization) at UofT.

## Execution
 In order to execute and run this program, please use [MARS](http://courses.missouristate.edu/kenvollmar/mars/). A bitmap display needs to be connected where the following conditions must be met:
  - The screen size must be square
  - There must be at least 32 x 32 pixels for the program to run successfully
  - The screen must be attached at the address set by <code>displayAddress</code> variable

They keyboard can be found in MARS under <code>Tools > Keyboard and Display MMIO Simulator</code>. 

## Modification
 The code provided has been written in order to allow as much modification as possible without over complicating the task. Currently, values such as screen size and unit size can be changed within certain bounds. If any errors are found please refer to the error codes listed at the top of the program or below.
 
 ## Error codes
 The following error codes are printed out to the console
 - <code>10</code> - Screen size is not a multiple of 64
 - <code>20</code> - Canvas Size not set
 - <code>30</code> - BlockSize not set
 - <code>100</code> - frog x position out of range
 - <code>110</code> - frog y position out of range
 - <code>200</code> - Non-Static is not set (Initialization order has been tampered with incorrectly)
 - <code>400</code> - frog blocksize not implemented (Resolution required is too high / has not been implemented for frog drawing purposes)
