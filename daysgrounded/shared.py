#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright 2009-2015 Joao Carlos Roseta Matos
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

"""Shared constants and functions."""

# Python 3 compatibility
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function
from __future__ import unicode_literals

# import builtins  # Python 3 compatibility
import datetime as dt
# import future  # Python 3 compatibility
# import io  # Python 3 compatibility
import pickle as pkl
import os

import common
import localization as lcl


DATA_FILE = common.DATA_PATH + 'daysgrounded.pkl'

LOG = False
LOG_FILE = common.DATA_PATH + 'daysgrounded_log.pkl'

MAX_DAYS = 99
MAX_DAYS_STR = str(MAX_DAYS)


def update_file(childs, last_upd):
    """Update data file and log file.

    The log file creates an history to be used in the future.
    """
    with open(DATA_FILE, 'wb') as file_:
        pkl.dump((childs, last_upd), file_)
    if LOG:
        with open(LOG_FILE, 'ab') as file_:
            pkl.dump((childs, last_upd), file_)


def create_file():
    """Create new data file and log file."""
    # use lower case letters or names
    childs = {'t': 0, 's': 0}
    last_upd = dt.date.today()
    update_file(childs, last_upd)
    return childs, last_upd


def read_file():
    """Reads and returns childs and last_upd from the data file."""
    if os.path.isfile(DATA_FILE):  # if file exists
        with open(DATA_FILE, 'rb') as file_:
            (childs, last_upd) = pkl.load(file_)
    else:
        print(lcl.FILE_NOT_FOUND)
        childs = None
        last_upd = None
    return childs, last_upd


def auto_upd_datafile(childs, last_upd):
    """Automatic update based on current date vs last update date."""
    right_now = dt.date.today()
    days_to_remove = (right_now - last_upd).days  # convert to days and assign
    for child in childs:
        childs[child] -= days_to_remove
        childs[child] = max(0, childs[child])
    update_file(childs, right_now)
    return right_now


def open_create_datafile():
    """Opens datafile if it exists, otherwise creates it."""
    if os.path.isfile(DATA_FILE):  # if file exists
        childs, last_upd = read_file()
    else:
        childs, last_upd = create_file()
    return childs, last_upd


if __name__ == '__main__':
    # import doctest
    # doctest.testmod(verbose=True)
    pass
