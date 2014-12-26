What is CyTI?
=============

CyTI (pronounced "city") is an in-development Cython module for linking with Texas Instruments (TI) graphing calculators. It presents a high-level interface to the [TiLP Framework][], including the ticables, ticalcs, tifiles, and ticonv libraries.

Development Status
==================

I consider CyTI to be alpha-quality software. It is largely undocumented and untested, the API is somewhat unstable, and I would not recommend its use in serious software projects for the time being. For more information, see the [Development Status][] page on the wiki.

Basic Instructions
==================

Building CyTI
-------------

On Linux, build CyTI using distutils and setup.py:

    python3 setup.py build_ext -i

Python 3 is highly recommended, though Python 2 should work (simply use the desired Python version when running setup.py). You must have Cython installed for whichever version of Python you use. Visit [Cython][] for more information. You must also have the TiLP framework libraries (with development headers) and pkg-config. On Ubuntu, you should be able to install everything you need with:

    sudo apt-get install tilp cython3 libticables-dev libticalcs-dev libtifiles-dev libticonv-dev

Note that this will build CyTI in-place without installing it, so you must be in the CyTI directory to import it. This should be fine for playing around with the library.

Using CyTI
----------

Attach your calculator to your computer and start the Python interpreter. When you only have one calculator, connecting to it is very simple:

    import cyti
    calculator = cyti.connect()

If you have multiple calculators attached, `cyti.find_connections()` should return a list of connections. Simply find the right one and call `connect()`, similar to the above code.

With your calculator on the home screen, try running this code to make it do a simple math problem (I've occasionally had some issues, so your mileage may vary):

    for key in [0x90, 0x80, 0x90, 0x05]:
        calculator.send_key(key)

Now, try this to see what variables and apps are on your calculator:

    vars = calculator.get_file_list()
    for index, var in enumerate(vars):
        print(index, var)

One type of variable on the calculator is the *real* variable. This is simply a number stored in one of the A-Z (or theta) variables. Try storing 42 to A by going to the home screen of your calculator and pressing (4) (2) (STO>) (ALPHA) (MATH) (ENTER). CyTI gives you easy access to this value by running the following code:

    calculator["real", "A"]

You should see the number 42 printed in your terminal. Try storing different values to different variables and then retrieving them. The value of a real variable on your calculator can also be set with CyTI:

    calculator["real", "B"] = -5.47

Now, take a look at the value of B on your calculator by pressing (ALPHA) (APPS) (ENTER).

There are some other functions you can try as well:

    calculator.is_ready()        # Returns True or False
    calculator.get_id()          # Returns the unique ID reported by the calculator

I'm interested! How can I help?
-------------------------------

At the moment, this is still largely a work in progress, and there are certain basic details that still need to be worked out. However, if you have any ideas, please feel free to share. The code is free, so do take it if you think that you can make it more useful.

<!-- Links -->
[Cython]: http://cython.org
[Development Status]: https://github.com/ahamlinman/cyti/wiki/Development-Status
[TiLP Framework]: http://lpg.ticalc.org/prj_tilp/architecture.html
