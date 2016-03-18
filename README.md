# C Libraries
Commonly used C libraries for use on the TI84+CE/TI83PCE

# User Installation
Simply send the libraries in the root directory of the zip file to your calculator using TI Connect CE or TILP.

# Developer Installation

*Note to developers:* Because of versioning for these libraries, it is highly recommended you do not include these libraries with your programs. You can simply link the release in so that way users have an ability to download the latest version: https://github.com/CE-Programming/libraries/releases/latest

To use this libraries in development, simply navigate to the `\library_headers` directory, and copy all the files inside into your C development library include directory, which is located at `CEdev\lib\ce`.

Once copied, you can simply `#include <lib/ce/libname.h>` to use the library's functions within your program.
