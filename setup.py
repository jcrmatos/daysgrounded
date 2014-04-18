#!/usr/bin/env python
# -*- coding: latin-1 -*-

from __future__ import (absolute_import, division, print_function,
                        unicode_literals)

from setuptools import setup, find_packages

from daysgrounded import *

setup(
    name=__title__,
    version=__version__,

    description=__desc__,
    long_description=open('README.rst').read(),
    #long_description=(read('README.rst') + '\n\n' +
    #                  read('HISTORY.rst') + '\n\n' +
    #                  read('AUTHORS.rst')),
    license=__license__,
    url=__url__,

    author=__author__,
    author_email=__email__,

    keywords=__keywords__,
    classifiers=__classifiers__,

    packages=find_packages(exclude=['tests*']),
    #packages=__packages__,

    entry_points=__entrypoints__,
    install_requires=open('requirements.txt').read(),
    #install_requires=open('requirements.txt').read().splitlines(),

    include_package_data=True,
    package_data=__pkgdata__
)