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

# CyTI type wrappers

from cyti.clibs cimport tifiles, glib
from libc.stdint cimport uint8_t

cdef class VariableRequest:
    cdef tifiles.VarEntry var_entry
    cdef tifiles.CalcModel calc_model
    cdef readonly str name
    cdef readonly str folder
    cdef readonly int type_code
    cdef readonly int size
    cdef readonly int attr
    cdef readonly int action

cdef class Variable(VariableRequest):
    cdef public uint8_t[:] data

cdef _create_variable_request(tifiles.VarEntry* var_entry, tifiles.CalcModel calc_model)
cdef _gnode_tree_to_request_array(glib.GNode* tree, tifiles.CalcModel calc_model)
cdef _file_content_to_variable_array(tifiles.FileContent file_content)
