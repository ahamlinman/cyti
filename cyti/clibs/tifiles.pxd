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

# libtifiles C API declaration

from libc.stdint cimport uint8_t, uint16_t, uint32_t

cdef extern from "tifiles.h":
    ctypedef enum CalcModel:
        CALC_NONE = 0, CALC_TI73, CALC_TI82, CALC_TI83, CALC_TI83P,
        CALC_TI84P, CALC_TI85, CALC_TI86, CALC_TI89, CALC_TI89T,
        CALC_TI92, CALC_TI92P, CALC_V200, CALC_TI84P_USB, CALC_TI89T_USB,
        CALC_NSPIRE, CALC_TI80, CALC_MAX

    ctypedef struct VarEntry:
        char folder[1024], # FLDNAME_MAX
        char name[1024], # VARNAME_MAX

        uint8_t type,
        uint8_t attr,
        uint32_t size,
        uint8_t* data,

        int action

    ctypedef struct FileContent:
        CalcModel model,

        char default_folder[1024], # FLDNAME_MAX
        char comment[43],

        int num_entries,
        VarEntry** entries,

        uint16_t checksum,

        CalcModel model_dst

    int tifiles_library_init()
    int tifiles_library_exit()

    const char* tifiles_version_get()

    const char* tifiles_model_to_string(CalcModel calc_model)
