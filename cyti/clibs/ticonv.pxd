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

# libticonv C API declaration

from tifiles cimport CalcModel

cdef extern from "ticonv.h":
    const char* ticonv_version_get()

    char* ticonv_varname_to_utf8(CalcModel calc_model, const char* src, unsigned char type)
    char* ticonv_charset_utf16_to_ti(CalcModel calc_model, const char* src)
    char* ticonv_varname_tokenize(CalcModel calc_model, const char *src, unsigned char type)
