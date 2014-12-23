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

# CyTI core types/functions

import atexit

from cyti.clibs cimport ticables, ticalcs, tifiles, ticonv, glib

from cyti.types cimport types
from cyti.types.types cimport *

from libc.stdint cimport uint8_t, uint32_t
from libc.stdlib cimport malloc, free
from libc.string cimport memset

from cyti import convert

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

    def __init__(self, cable_model, cable_port):
        self.cable_model = cable_model
        self.cable_port = cable_port

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
            ticables.ticables_handle_del(self.cable_handle)

    def connect(self):
        self.cable_handle = ticables.ticables_handle_new(self.cable_model, self.cable_port)

        calc = Calculator(self.calc_model)
        calc.connect(self.cable_handle)

        self.cable_handle = NULL

        return calc

cdef class Calculator:
    cdef ticables.CableHandle* cable_handle
    cdef ticalcs.CalcHandle* calc_handle
    cdef readonly tifiles.CalcModel calc_model
    cdef bint connected

    def __init__(self, calc_model):
        self.calc_model = calc_model
        self.connected = False
        self.calc_handle = ticalcs.ticalcs_handle_new(self.calc_model)

    def __str__(self):
        return "%s Calculator" % tifiles.tifiles_model_to_string(self.calc_model).decode("utf-8")

    def __dealloc__(self):
        if self.connected:
            ticalcs.ticalcs_cable_detach(self.calc_handle)
        if self.calc_handle:
            ticalcs.ticalcs_handle_del(self.calc_handle)
        if self.cable_handle:
            ticables.ticables_handle_del(self.cable_handle)

    cdef connect(self, ticables.CableHandle* cable_handle):
        self.cable_handle = cable_handle

        err = ticalcs.ticalcs_cable_attach(self.calc_handle, self.cable_handle)
        if err:
            self.cable_handle = NULL
            raise IOError("Unable to connect to calculator: %i" % err)

        self.connected = True

    def is_ready(self, retries = 0):
        if ticalcs.ticalcs_calc_isready(self.calc_handle) == 0:
            # The calculator is fine
            return True
        else:
            if retries < 1:
                # The calculator wasn't ready - reconnect and try again
                ticalcs.ticalcs_cable_detach(self.calc_handle)
                ticalcs.ticalcs_cable_attach(self.calc_handle, self.cable_handle)
                return self.is_ready(retries + 1)
            else:
                # The calculator is disconnected or off
                return False

    def send_key(self, keycode):
        if not self.is_ready():
            raise Exception("The calculator is not ready")

        ticalcs.ticalcs_calc_send_key(self.calc_handle, keycode)

    def get_id(self):
        if not self.is_ready():
            raise Exception("The calculator is not ready")

        cdef uint8_t buf[32]
        ticalcs.ticalcs_calc_recv_idlist(self.calc_handle, buf)
        return buf

    def get_file_list(self):
        if not self.is_ready():
            raise Exception("The calculator is not ready")

        cdef glib.GNode* var_tree
        cdef glib.GNode* app_tree

        ticalcs.ticalcs_calc_get_dirlist(self.calc_handle, &var_tree, &app_tree)

        variables = []
        variables += types._gnode_tree_to_request_array(var_tree, self.calc_model)
        variables += types._gnode_tree_to_request_array(app_tree, self.calc_model)

        ticalcs.ticalcs_dirlist_destroy(&var_tree)
        ticalcs.ticalcs_dirlist_destroy(&app_tree)

        return variables

    def get(self, item):
        if not self.is_ready():
            raise Exception("The calculator is not ready")

        request = None
        if isinstance(item, VariableRequest):
            request = item
        else:
            raise TypeError("Could not understand what to retrieve")

        variables = self._retrieve_variable_array(request)
        if variables is not None:
            if len(variables) == 1:
                return convert.to_python(variables[0])
            else:
                return variables
        else:
            return None

    cpdef _retrieve_variable_array(self, VariableRequest variable):
        cdef tifiles.FileContent file_content
        result = ticalcs.ticalcs_calc_recv_var(self.calc_handle, 0, &file_content, &variable.var_entry)
        if result == 0:
            return types._file_content_to_variable_array(file_content)
        else:
            return None

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
             "tifiles": tifiles.tifiles_version_get().decode("utf-8"),
             "ticonv": ticonv.ticonv_version_get().decode("utf-8") }
