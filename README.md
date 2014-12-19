Development Status
==================

CyTI has been on hold for quite a while. However, I am starting to come back to it as of December 2014. The current priority for the project is being able to receive a usable file list from the calculator. This will lead into the ability to receive files.

Basic Instructions
==================

Building CyTI
-------------

On Linux, build CyTI using distutils and setup.py:

    python setup.py build_ext -i

or

    python3 setup.py build_ext -i

You must have Cython installed for whichever version of Python you use. Visit [Cython][] for more information.

Using CyTI
----------

With your calculator on the home screen, try running this code to make it do a simple math problem (I've occasionally had some issues when using USB, so your mileage may vary):

    import cyti
    calculator = cyti.connect()
    for key in [0x90, 0x80, 0x90, 0x05]:
        calculator.send_key(key)

There are some other functions you can try as well:

    calculator.is_ready()        # Returns True or False
    calculator.get_id()          # Returns the unique ID reported by the calculator
    calculator.get_file_names()  # Gets a list of everything in the calculator's memory

Introduction to CyTI
====================

What is CyTI?
-------------

CyTI (pronounced "city") is an in-development Cython module for linking with Texas Instruments (TI) graphing calculators. It presents an object-oriented interface to the [TiLP Framework][], including the ticables, ticalcs, tifiles, and ticonv libraries.

What might I use it for?
------------------------

CyTI can be used for just about anything that involves transferring programs or other data between a computer and a TI calculator. Here are a few ideas to get you started:

It might help you recreate certain software in Python, such as...

* A linking program, similar to TI-Connect or TiLP
* A program, similar to [NoteFolio][], that allows a user to open a text document from a calculator, edit it on a computer, convert it to another format, etc.

It could also help you create something new...

* A one-click backup program with advanced features like versioning
* A sync client that transfers contact or calendar data to a personal organizer program
* A [FUSE][] file system that makes the calculator look like a removable drive or similar device (several projects exist that allow Python to interface with FUSE)

...or add features to existing software, such as...

* Allowing the Python-based [ticalc.org Package Manager][] to automatically put downloaded programs onto a calculator without the need to open a separate linking program

What is the point of making something for a calculator?
-------------------------------------------------------

This seems to be a somewhat common question. A graphing calculator is an investment, usually worth over $100, that is made by a large number of people, especially high school students. Some students choose to create software for the devices that they can use to have fun, perform calculations, and accomplish a variety of personal and school-related tasks. These advanced uses help them get the most out of their purchase.

Some calculator owners are part of a worldwide community of programmers that seeks to realize the full potential of such an apparently limited system. However, many of the connections between calculators and this Internet-based world must be made through dedicated linking programs that sometimes do little more than read and write files. Through the efforts of groups like [Cemetech][] and coders like [KermMartian][], projects like [globalCALCnet][] (a system for real-time multi-calculator linking over the Internet) and [Gossamer][] (a simple web browser for TI calculators) have started to close the gap between these two systems. CyTI is designed to help bring them even closer.

It is my hope that, by combining the ease and power of the Python language (apparently well-known within the community) with an easy-to-use library that works with these devices, I and others will be inspired to develop new software that links calculators to computers in ways never seen before. This gives greater value to a device that high school students are very familiar with and may serve as an incentive to obtain valuable coding experience.

Besides all that, I think it's somewhat fun! I consider it an interesting personal challenge and development experience.

Has anything like this been attempted?
--------------------------------------

After some research, I came across a project known as [PyTICables][] that successfully brought functions from the ticables library into Python. A brief thread on Cemetech in 2010 referenced the project, but it appears that little work has been done with it since it was first developed in 2006, and its current status seems uncertain.

### Why start over with something new?

PyTICables seemed like a relatively thin wrapper that allowed Python users to use the functions provided by the ticables library. Originally, I had intended to create a similar system using [SWIG][] so that it could be more flexible and work with more languages than PyTICables. However, there were several issues:

* I attempted to follow SWIG's directions, but still had difficulty making the different libraries (ticables, ticalcs, etc.) work together properly.
* I had to write Python-specific C code in certain places, negating the multi-language support promised by SWIG.
* I wanted the library to be somehow object-oriented, which would have required my own separate Python code in addition to that generated by SWIG. I felt that this would make the library needlessly complex (the SAGE project had [similar concerns about SWIG][]).

Thus, I decided to change gears. My goal for CyTI is that it become much more than what PyTICables and my own previous efforts provided. I believe that a truly useful, high-quality Python-TI library should consist of much more than just a ticables wrapper. It should provide greater abstraction and high-level functionality in order to make it easy to use and possibly even fun to work with.

Ideally, I would like to give a new user, possibly with little or no programming experience, a simple tutorial that can have them connected to a calculator and actively working with it in about a half-hour or so, using only a few lines of code. I do not feel that the TiLP libraries alone can do this (simply probing for available calculators requires one to work with a pointer to a 2D array and manage its memory - I don't consider these "beginner" concepts).

I'm interested! How can I help?
-------------------------------

At the moment, this is still largely a work in progress, and there are certain basic details that still need to be worked out. However, if you have any ideas, please feel free to share. The code is free, so do take it if you think that you can make it more useful.

<!-- Links -->
[Cemetech]: http://cemete.ch/
[Cython]: http://cython.org
[FUSE]: http://fuse.sourceforge.net/
[globalCALCnet]: http://cemete.ch/pr35
[Gossamer]: http://cemete.ch/pr37
[KermMartian]: http://resume.cemetech.net/
[NoteFolio]: http://education.ti.com/educationportal/sites/US/productDetail/us_notefolio_83_84.html
[PyTICables]: http://cemete.ch/p32274
[similar concerns about SWIG]: http://sage.math.washington.edu/tmp/sage-2.8.12.alpha0/doc/prog/node36.html
[SWIG]: http://www.swig.org/
[ticalc.org Package Manager]: http://www.ticalc.org/archives/files/fileinfo/433/43348.html
[TiLP Framework]: http://lpg.ticalc.org/prj_tilp/architecture.html
