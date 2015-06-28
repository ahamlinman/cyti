# coding=utf-8
#
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

# CyTI types

from cyti.types.core import *
from cyti.types import core

# CyTI pseudotypes
pseudotypes = {
    "number": ["real", "complex"],
    "list": ["real_list", "complex_list"]
}

# Correct list names for L1-L6 on TI-8x
_num_list_conversion_table = {
    "1": "L₁",
    "2": "L₂",
    "3": "L₃",
    "4": "L₄",
    "5": "L₅",
    "6": "L₆",
 }

def _create_request(calc, name, type_arg):
    if not isinstance(type_arg, int): # type_arg needs to be an int by the time we get to C
        if not type_arg in ti8x_type_codes:
            raise KeyError("The given variable type (%s) is not known" % type_arg)
        type_arg = ti8x_type_codes[type_arg]

    if type_arg == 0x00 or type_arg == 0x0C:
        name = __normalize_ti8x_number_name(name)

    if type_arg == 0x01 or type_arg == 0x0D:
        name = __normalize_ti8x_list_name(name)

    return core._create_variable_request(calc.calc_model, name, type_arg)

def _create_ti8x_real_var(calc_model, name):
    name = __normalize_ti8x_number_name(name)
    return core._create_variable(calc_model, name, 0x00, 9)

def _create_ti8x_real_list_var(calc_model, name, num_elements):
    size = num_elements * 9 + 2
    name = __normalize_ti8x_list_name(name)
    return core._create_variable(calc_model, name, 0x01, size)

def _create_ti8x_complex_var(calc_model, name):
    name = __normalize_ti8x_number_name(name)
    return core._create_variable(calc_model, name, 0x0C, 18)

def _create_ti8x_complex_list_var(calc_model, name, num_elements):
    size = num_elements * 18 + 2
    name = __normalize_ti8x_list_name(name)
    return core._create_variable(calc_model, name, 0x0D, size)

def __normalize_ti8x_number_name(name):
    if name == "theta":
        return "θ"
    elif len(name) > 1:
        raise TypeError("Number variable names must consist of one letter or 'theta'")

    return name.upper()

def __normalize_ti8x_list_name(name):
    if str(name) in _num_list_conversion_table:
        name = _num_list_conversion_table[str(name)]
    elif str(name).isnumeric():
        raise IndexError("Numbered list names must be in the range 1-6")

    return name.upper()
