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

from cyti.types.types import *
from cyti.types import types

# Correct list names for L1-L6 on TI-8x
_num_list_conversion_table = {
    "1": "L₁",
    "2": "L₂",
    "3": "L₃",
    "4": "L₄",
    "5": "L₅",
    "6": "L₆",
 }

def _create_ti8x_real_var(calc_model, name):
    return types._create_variable(calc_model, name, 0x00, 9)

def _create_ti8x_real_list_var(calc_model, name, num_elements):
    size = num_elements * 9 + 2

    if name in _num_list_conversion_table:
        name = _num_list_conversion_table[name]

    return types._create_variable(calc_model, name, 0x01, size)
