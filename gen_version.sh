#!/bin/bash
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

set -exuo pipefail

base_dir=$(ls -d --indicator-style=none base/types-urllib3-*)
# Currently assuming there will not be a 1.26.26 released by typeshed
# Really, I don't expect even a 1.26.25.15, but this pattern
# will handle it if that gets released.
expected_pattern='^base/types-urllib3-1[.]26[.]25[.](1[4-9]|1[0-9][0-9]+|[2-9][0-9]*)$'

if [[ ! ${base_dir} =~ ${expected_pattern} ]]; then
    echo "ERROR: Unexpected version in base directory name: '${base_dir}'" 1>&2
    exit 1
fi

base_version=$(echo "${base_dir}" | sed 's#^base/types-urllib3-\(.*\)$#\1#')
echo "Upstream version appears to be ${base_version}"

base_version_egrep_pattern=$(echo "${base_version}" | sed 's/[.]/[.]/g')


tagfile=$(mktemp)
git fetch -a
head_commit=$(git rev-parse HEAD)
echo "HEAD commit is ${head_commit}"
git tag -l "v${base_version}.*" | tee "${tagfile}"
TAG=no
X=1
while grep -Eq "^v${base_version_egrep_pattern}[.]${X}$" "${tagfile}"; do
    # The other way this may be the correct version is if this commit
    # is tagged with that version
    if [[ ${head_commit} == $(git rev-parse v${base_version}.${X}) ]]; then
        TAG=yes
        break
    fi
    let X+=1
done
version="${base_version}.${X}"
if [[ ${TAG} == no ]]; then
    echo "Next available patch version: ${version}"
else
    echo "This commit is tagged for version ${version}"
fi
echo "${version}" > .version
rm "${tagfile}" || true
