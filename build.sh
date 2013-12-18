#!/bin/bash

REPO_NAME=$(echo ${TRAVIS_REPO_SLUG} | cut -d/ -f2)
OWNER_NAME=$(echo ${TRAVIS_REPO_SLUG} | cut -d/ -f1)

function check {
    "$@"
    status=$?
    if [ $status -ne 0 ]; then
        echo "error run $@"
        exit $status
    fi
    return $status
}

function package {
    local REVISION=$1

    tar -czf ${REPO_NAME}-cookbooks-${REVISION}.tar.gz cookbooks
}

function publish {
    local REVISION=$1

    package $REVISION

    travis-artifacts upload --path ${REPO_NAME}-cookbooks-${REVISION}.tar.gz --target-path ${OWNER_NAME}/
}

function replace {
    check sed -i.bak -e 's/'${REPO_NAME}'-cookbooks-stable/'${REPO_NAME}'-cookbooks-dev/g' ${REPO_NAME}.yml
    cat ${REPO_NAME}.yml
}


publish dev
replace

pushd test

check python test_runner.py

popd

publish stable
