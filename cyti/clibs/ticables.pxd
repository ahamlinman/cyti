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

# libticables C API declaration

from libc.stdint cimport uint8_t, uint32_t

cdef extern from "ticables.h":
    ctypedef enum CableModel:
        CABLE_NUL = 0, CABLE_GRY, CABLE_BLK, CABLE_PAR,
        CABLE_SLV, CABLE_USB, CABLE_VTI, CABLE_TIE, CABLE_ILP,
        CABLE_DEV, CABLE_MAX

    ctypedef enum CablePort:
        PORT_0 = 0, PORT_1, PORT_2, PORT_3, PORT_4

    ctypedef enum ProbingMethod:
        PROBE_NONE = 0,
        PROBE_FIRST = 1,
        PROBE_USB = 2,
        PROBE_DBUS = 4,
        PROBE_ALL = 6

    ctypedef struct CableHandle:
        pass

    int ticables_library_init()
    int ticables_library_exit()

    char* ticables_version_get()

    CableHandle* ticables_handle_new(CableModel cable_model, CablePort cable_port)
    int ticables_handle_del(CableHandle* cable_handle)

    int ticables_options_set_timeout(CableHandle* cable_handle, int timeout)
    int ticables_options_set_delay(CableHandle* cable_handle, int delay)

    CableModel ticables_get_model(CableHandle* cable_handle)
    CablePort ticables_get_port(CableHandle* cable_handle)

    int ticables_cable_open(CableHandle* cable_handle)
    int ticables_cable_close(CableHandle* cable_handle)

    int ticables_cable_send(CableHandle* cable_handle, uint8_t* data, uint32_t length)
    int ticables_cable_recv(CableHandle* cable_handle, uint8_t* data, uint32_t length)

    int ticables_probing_do(int*** result, int timeout, ProbingMethod probing_method)
    int ticables_probing_finish(int*** result)

    const char* ticables_model_to_string(CableModel cable_model)
    const char* ticables_port_to_string(CablePort cable_port)
