# CyTI - A Cython module for linking with TI calculators.
#
# Copyright (C) 2013 Alex Hamlin
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import atexit
cimport ticables

ticables.ticables_library_init()

# Cython complains if these aren't lambdas
atexit.register(lambda: ticables.ticables_library_exit())


def scan_for_devices():
    cdef int** array

    result = ticables.ticables_probing_do(&array, 5, ticables.PROBE_ALL)

    if result == 50:
        ticables.ticables_probing_finish(&array)
        return None

    found_devices = []
    for cable in range(1, 6):
        for port in range(1, 5):
            if array[cable][port]:
                found_devices.append((cable, port))

    ticables.ticables_probing_finish(&array)

    for device in found_devices:
        cable_str = ticables.ticables_model_to_string(device[0])
        port_str = ticables.ticables_port_to_string(device[1])
        print("Found %s cable on port %s" % 
            (cable_str.decode("utf-8"), port_str.decode("utf-8")))

    return found_devices
