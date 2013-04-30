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

cimport ticables, ticalcs, tifiles

from libc.stdint cimport uint8_t, uint32_t
from libc.stdlib cimport malloc, free
from libc.string cimport memset

ticables.ticables_library_init()
tifiles.tifiles_library_init()
ticalcs.ticalcs_library_init()

# Cython complains if these aren't lambdas
atexit.register(lambda: ticables.ticables_library_exit())
atexit.register(lambda: tifiles.tifiles_library_exit())
atexit.register(lambda: ticalcs.ticalcs_library_exit())

cdef class Connection:
    cdef ticables.CableHandle* cable_handle
    cdef ticables.CableModel cable_model
    cdef ticables.CablePort cable_port
    cdef tifiles.CalcModel calc_model
    cdef bint connected

    def __init__(self, cable_model, cable_port):
        self.cable_model = cable_model
        self.cable_port = cable_port
        self.connected = False

        cdef tifiles.CalcModel calc_model
        probe_result = ticalcs.ticalcs_probe(self.cable_model, self.cable_port, &calc_model, 1)
        if probe_result == 0:
            self.calc_model = calc_model
        else:
            self.calc_model = tifiles.CALC_NONE

    def __str__(self):
        if self.calc_model != tifiles.CALC_NONE:
            return "%s connection to %s on port %s" % (
                ticables.ticables_model_to_string(self.cable_model).decode("utf-8"),
                tifiles.tifiles_model_to_string(self.calc_model).decode("utf-8"),
                ticables.ticables_port_to_string(self.cable_port).decode("utf-8"))
        else:
            return "%s connection on port %s" % (
                ticables.ticables_model_to_string(self.cable_model).decode("utf-8"),
                ticables.ticables_port_to_string(self.cable_port).decode("utf-8"))

    def __dealloc__(self):
        if self.cable_handle:
            ticables.ticables_cable_close(self.cable_handle)
            ticables.ticables_handle_del(self.cable_handle)

    def connect(self):
        self.cable_handle = ticables.ticables_handle_new(self.cable_model, self.cable_port)
        err = ticables.ticables_cable_open(self.cable_handle)
        if err:
            ticables.ticables_handle_del(self.cable_handle)
            self.cable_handle = NULL
            raise IOError("Unable to open cable: %i" % err)
        self.connected = True

    def send_bytes(self, uint8_t* data):
        cdef uint32_t length
        length = len(data)

        if not self.connected:
            raise IOError("Cable is not open")

        if ticables.ticables_cable_send(self.cable_handle, data, length):
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
        ticables.ticables_cable_recv(self.cable_handle, buf, length)
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

def library_versions():
    return { "ticables": ticables.ticables_version_get().decode("utf-8"),
             "ticalcs": ticalcs.ticalcs_version_get().decode("utf-8"),
             "tifiles": tifiles.tifiles_version_get().decode("utf-8") }
