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

# CyTI type helper functions

from cyti.clibs cimport tifiles, ticonv, glib
from cyti.types.types cimport *
from cython cimport view
from libc.string cimport strncpy

# Variable type codes
ti8x_type_codes = {
    0x00: "real",
    0x01: "list",
    0x02: "matrix",
    0x03: "y_var",
    0x04: "string",
    0x05: "program",
    0x06: "locked_program",
    0x07: "picture",
    0x08: "gdb",
    0x0C: "complex",
    0x0D: "complex_list"
}

# Create reverse mappings for variable type codes
for d in [ti8x_type_codes]:
    d.update({v: k for (k, v) in d.items()})

cdef class VariableRequest:
    def __str__(self):
        calc_str = tifiles.tifiles_model_to_string(self.calc_model).decode("utf-8")
        type_str = ti8x_type_codes[self.type_code]
        return "<Request for %s %s variable '%s'>" % (calc_str, type_str, self.name)

cdef class Variable(VariableRequest):
    def __str__(self):
        calc_str = tifiles.tifiles_model_to_string(self.calc_model).decode("utf-8")
        type_str = ti8x_type_codes[self.type_code]
        return "<%s %s variable '%s'>" % (calc_str, type_str, self.name)

cdef _create_variable_request(tifiles.VarEntry* var_entry, tifiles.CalcModel calc_model):
    v = VariableRequest()

    v.var_entry = var_entry[0]
    v.calc_model = calc_model

    n = ticonv.ticonv_varname_to_utf8(calc_model, var_entry.name, var_entry.type)
    v.name = n.decode("utf-8")
    glib.g_free(n)

    v.folder = var_entry.folder.decode("utf-8")

    v.type_code = var_entry.type
    v.size = var_entry.size
    v.attr = var_entry.attr
    v.action = var_entry.action

    return v

cpdef _create_variable(tifiles.CalcModel calc_model, str name, int type_code, int size):
    v = Variable()

    cdef bytes asc_name = name.encode('utf-16')[2:] + '\x00'.encode('utf-16-le')
    enc_name = ticonv.ticonv_charset_utf16_to_ti(calc_model, asc_name)
    tok_name = ticonv.ticonv_varname_tokenize(calc_model, enc_name, type_code)

    fmt_name = ticonv.ticonv_varname_to_utf8(calc_model, tok_name, type_code)
    v.name = fmt_name.decode('utf-8')
    strncpy(v.var_entry.name, tok_name, 1024)

    glib.g_free(enc_name)
    glib.g_free(tok_name)
    glib.g_free(fmt_name)

    v.folder = None
    v.var_entry.folder[0] = 0

    v.calc_model = calc_model

    v.type_code = v.var_entry.type = type_code
    v.size = v.var_entry.size = size
    v.attr = v.var_entry.attr = 0
    v.action = v.var_entry.action = 0

    cdef uint8_t[:] arr = view.array(shape=(size,), itemsize=sizeof(uint8_t), format="B", allocate_buffer=True)
    arr[:] = 0
    v.data = arr
    v.var_entry.data = &arr[0]

    return v

cdef _gnode_tree_to_request_array(glib.GNode* tree, tifiles.CalcModel calc_model):
    variables = []
    for i in range(0, glib.g_node_n_children(tree)):
        parent = glib.g_node_nth_child(tree, i)
        for j in range(0, glib.g_node_n_children(parent)):
            child = glib.g_node_nth_child(parent, j)
            entry = <tifiles.VarEntry*>child.data
            variables.append(_create_variable_request(entry, calc_model))
    return variables

cdef _file_content_to_variable_array(tifiles.FileContent file_content):
    variables = []
    cdef int i = 0
    cdef uint8_t[:] arr
    cdef uint8_t[:] tmp
    while(file_content.entries[i] != NULL):
        entry = file_content.entries[i]

        v = Variable()
        v.var_entry = entry[0]
        v.calc_model = file_content.model

        n = ticonv.ticonv_varname_to_utf8(file_content.model, entry.name, entry.type)
        v.name = n.decode("utf-8")
        glib.g_free(n)

        v.type_code = entry.type
        v.size = entry.size
        v.attr = entry.attr
        v.action = entry.action

        arr = view.array(shape=(v.size,), itemsize=sizeof(uint8_t), format="B", allocate_buffer=True)
        tmp = <uint8_t[:entry.size]>entry.data
        arr[:entry.size] = tmp
        v.data = arr
        glib.g_free(entry.data)
        v.var_entry.data = &arr[0]

        variables.append(v)
        i += 1

        glib.g_free(entry)

    glib.g_free(file_content.entries)
    return variables
