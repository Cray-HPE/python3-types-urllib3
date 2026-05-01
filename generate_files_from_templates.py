#!/usr/bin/env python3
#
# MIT License
#
# (C) Copyright 2026 Hewlett Packard Enterprise Development LP
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#

"""
Generate the target files from the template files by filling in the
description text
"""

from pathlib import Path
import sys
from typing import NoReturn

TARGET_FILES = [ 'setup.py', 'PKG-INFO' ]
DESCRIPTION_FILE = "package_description.md"
DESCRIPTION_TARGET_LINE = "INSERT_DESCRIPTION_HERE\n"

def err_exit(msg: str) -> NoReturn:
    """ Print the message (prepended with ERROR: ) to stderr and exit """
    sys.stderr.write(f"ERROR: {msg}\n")
    sys.exit(1)


def generate_file_with_description(target_filename: str, description_text: str) -> None:
    """
    Generate the target file from its template file by filling in the
    description text
    """
    if Path(target_filename).exists():
        err_exit(f"Specified target file ('{target_filename}') already exists")
    template_filename = target_filename + ".template"
    found = False
    with open(template_filename, "rt") as template_file:
        with open(target_filename, "wt") as target_file:
            for template_line in template_file:
                if template_line == DESCRIPTION_TARGET_LINE:
                    target_file.write(description_text)
                    found = True
                else:
                    target_file.write(template_line)
    if not found:
        err_exit(f"No line in {template_filename} matches {DESCRIPTION_TARGET_LINE}")
    print(f"Generated {target_filename} from {template_filename} and {DESCRIPTION_FILE}")


def main():
    with open(DESCRIPTION_FILE, "rt") as dfile:
        description_text = dfile.read()
    # Make sure the description text ends with a newline
    if description_text[-1] != '\n':
        description_text += '\n'
    for target_file in TARGET_FILES:
        generate_file_with_description(target_file, description_text)

if __name__ == '__main__':
    main()