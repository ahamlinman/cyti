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

from libc.stdint cimport uint8_t, uint32_t
from libc.stdlib cimport malloc, free
from libc.string cimport memset

ticables.ticables_library_init()

# Cython complains if these aren't lambdas
atexit.register(lambda: ticables.ticables_library_exit())

cdef class Connection:
    cdef ticables.CableHandle* handle
    cdef ticables.CableModel cable
    cdef ticables.CablePort port
    cdef bint connected

    def __init__(self, cable, port):
        self.cable = cable
        self.port = port
        self.connected = False

    def __str__(self):
        return "%s connection on port %s" % (
            ticables.ticables_model_to_string(self.cable).decode("utf-8"),
            ticables.ticables_port_to_string(self.port).decode("utf-8"))

    def __dealloc__(self):
        if self.handle:
            ticables.ticables_cable_close(self.handle)
            ticables.ticables_handle_del(self.handle)

    def connect(self):
        self.handle = ticables.ticables_handle_new(self.cable, self.port)
        err = ticables.ticables_cable_open(self.handle)
        if err:
            ticables.ticables_handle_del(self.handle)
            self.handle = NULL
            raise IOError("Unable to open cable: %i" % err)
        self.connected = True

    def send_bytes(self, uint8_t* data):
        cdef uint32_t length
        length = len(data)

        if not self.connected:
            raise IOError("Cable is not open")

        if ticables.ticables_cable_send(self.handle, data, length):
            raise IOError("Error sending data")

    def receive_bytes(self, uint32_t length):
        cdef uint8_t* buf
        cdef uint8_t[:] arr

        if not self.connected:
            raise IOError("Cable is not open")

        buf = <uint8_t *>malloc(length)
        if buf is NULL:
            raise MemoryError("Unable to allocate receive buffer")

        memset(buf, 0, length)
        ticables.ticables_cable_recv(self.handle, buf, length)
        arr = <uint8_t[:length]>buf
        free(buf)
        return arr


def find_connections():
    cdef int** array

    result = ticables.ticables_probing_do(&array, 5, ticables.PROBE_ALL)

    if result == 50:
        ticables.ticables_probing_finish(&array)
        return None

    found_connections = []
    for cable in range(1, 6):
        for port in range(1, 5):
            if array[cable][port]:
                found_connections.append(Connection(cable, port))

    ticables.ticables_probing_finish(&array)

    return found_connections
