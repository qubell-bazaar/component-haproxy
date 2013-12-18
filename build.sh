#!/bin/bash

REPO_NAME=$(echo ${TRAVIS_REPO_SLUG} | cut -d/ -f2)
OWNER_NAME=$(echo ${TRAVIS_REPO_SLUG} | cut -d/ -f1)
GIT_REVISION=$(git log --pretty=format:'%h' -n 1)

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

function publish_github {
    git config user.name ${GIT_NAME}
    git config user.email ${GIT_EMAIL}
    git config credential.helper "store --file=.git/credentials"
    echo "https://${GH_TOKEN}:@github.com" > .git/credentials
    sed -i.bak -e 's/'${REPO_NAME}'-cookbooks-dev/'${REPO_NAME}'-cookbooks-stable-'${GIT_REVISION}'/g' ${REPO_NAME}.yml
    git commit -a -m "CI: Success build ${TRAVIS_BUILD_NUMBER}"
    git push origin master
    rm -rf .git/credentials
}

if [[ ${TRAVIS_PULL_REQUEST} == "false" ]]; then
    publish dev
    replace

    pushd test

    check python test_runner.py

    popd

    publish "stable-${GIT_REVISION}"
    publish_github
fi