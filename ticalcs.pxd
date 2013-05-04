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

# libticalcs C API declaration

from libc.stdint cimport uint8_t, uint16_t

cimport ticables, tifiles

cdef extern from "ticalcs.h":
    ctypedef struct CalcHandle:
        pass

    int ticalcs_library_init()
    int ticalcs_library_exit()

    char* ticalcs_version_get()

    CalcHandle* ticalcs_handle_new(tifiles.CalcModel calc_model)
    int ticalcs_handle_del(CalcHandle* calc_handle)

    int ticalcs_cable_attach(CalcHandle* calc_handle, ticables.CableHandle* cable_handle)
    int ticalcs_cable_detach(CalcHandle* calc_handle)

    int ticalcs_calc_isready(CalcHandle* calc_handle)

    int ticalcs_probe(ticables.CableModel cable_model, ticables.CablePort cable_port, tifiles.CalcModel* calc_model, int all)
