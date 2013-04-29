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

    ctypedef enum UsbPid:
        PID_UNKNOWN  = 0,
        PID_TIGLUSB  = 0xE001,
        PID_TI89TM   = 0xE004,
        PID_TI84P    = 0xE003,
        PID_TI84P_SE = 0xE008,
        PID_NSPIRE   = 0xE012

    ctypedef enum CableStatus:
        STATUS_NONE = 0,
        STATUS_RX = 1,
        STATUS_TX = 2

    ctypedef enum ProbingMethod:
        PROBE_NONE = 0,
        PROBE_FIRST = 1,
        PROBE_USB = 2,
        PROBE_DBUS = 4,
        PROBE_ALL = 6

    ctypedef struct CableHandle:
        pass

    ctypedef struct CableOptions:
        CableModel model,
        CablePort port,
        int timeout,
        int delay,
        int calc

    int ticables_library_init()
    int ticables_library_exit()

    char* ticables_version_get()

    CableHandle* ticables_handle_new(CableModel model, CablePort port)
    int ticables_handle_del(CableHandle* handle)

    int ticables_options_set_timeout(CableHandle* handle, int timeout)
    int ticables_options_set_delay(CableHandle* handle, int delay)

    CableModel ticables_get_model(CableHandle* handle)
    CablePort ticables_get_port(CableHandle* handle)

    int ticables_cable_open(CableHandle* handle)
    int ticables_cable_close(CableHandle* handle)

    int ticables_cable_reset(CableHandle* handle)
    int ticables_cable_probe(CableHandle*, int* result)

    int ticables_cable_send(CableHandle* handle, uint8_t* data, uint32_t length)
    int ticables_cable_recv(CableHandle* handle, uint8_t* data, uint32_t length)

    int ticables_cable_check(CableHandle* handle, CableStatus* status)

    int ticables_progress_reset(CableHandle* handle)
    int ticables_progress_get(CableHandle* handle, int* count, int* msec, int* rate)

    int ticables_probing_do(int*** result, int timeout, ProbingMethod method)
    int ticables_probing_finish(int*** result)
    bint ticables_is_usb_enabled()
    int ticables_get_usb_devices(int** array, int* length)

    const char* ticables_model_to_string(CableModel model)
    const char* ticables_port_to_string(CablePort port)
    const char* ticables_usbpid_to_string(UsbPid pid)
