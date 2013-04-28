<div style="background-color: #ffeeee; border: 2px solid red; padding: 1em;">
<h1>PLEASE READ: Important Notice Regarding the Current State of CyTI</h1>
<p><b>CyTI is currently in the early stages of conceptualization and implementation. The information below should help give you a very general idea of my plans for CyTI and what I hope to create. Assume that it is subject to change without notice.</b></p>
<p>Thank you for your interest in CyTI, and please check back for further updates.</p>
</div>

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

Here is an example of scanning for calculators connected to your computer:

    import cyti
    scan_result = cyti.scan_for_devices()
    if scan_result == None:
        print("No devices found.")
    else:
        print("Devices found on (cable, port):")
        print(scan_result)

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

Has anything like this been attempted?
--------------------------------------

After some research, I came across a project known as [PyTICables][] that successfully brought functions from the ticables library into Python. A brief thread on Cemetech in 2010 referenced the project, but it appears that little work has been done with it since it was first developed in 2006, and its current status seems uncertain.

### Why start over with something new?

PyTICables seemed like a relatively thin wrapper that allowed Python users to use the functions provided by the ticables library. Originally, I had intended to create a similar system using [SWIG][] so that it could be more flexible and work with more languages than PyTICables. However, there were several issues:

* I was unable to make the different libraries (ticables, ticalcs, etc.) work together, even after following SWIG's directions.
* I had to write several lines of Python-specific C code, negating the multi-language support promised by SWIG.
* I wanted the library to be object-oriented, which would have required my own separate Python code in addition to that generated by SWIG. I felt that this would make the library needlessly complex (the SAGE project had [similar concerns about SWIG][]).

Thus, I decided to change gears. My goal for CyTI is that it become much more than what PyTICables and my own previous efforts provided. I believe that a truly useful, high-quality Python-TI library should consist of much more than just a ticables wrapper. It should provide greater abstraction and high-level functionality in order to make it easy to use and possibly even fun to work with.

Ideally, I would like to give a new user, possibly with little or no programming experience, a simple tutorial that can have them connected to a calculator and actively working with it in about a half-hour or so, using only a few lines of code. I do not feel that the TiLP framework alone can necessarily do this (simply probing for available calculators requires one to work with a pointer to a 2D array and manage its memory - these do not seem like "beginner" concepts).

I'm interested! How can I help?
-------------------------------

Currently, the best thing you can do to help is to check back later for more updates. I am working out basic details of the library (structure, etc.) and will provide details regarding this matter at a later time. Thank you for your understanding and for your interest in CyTI.

<!--- Links --->
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
[TiLP Framework]: http://lpg.ticalc.org/prj_tilp/
