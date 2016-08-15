#!/usr/bin/env bash

CI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${CI_DIR}/common.sh"

travis_retry make fetchthirdparty
make all

# install tesseract trained language data for testing OCR functionality
travis_retry wget https://tesseract-ocr.googlecode.com/files/tesseract-ocr-3.02.eng.tar.gz
tar zxf tesseract-ocr-3.02.eng.tar.gz

pushd koreader-emulator*/koreader
    export TESSDATA_PREFIX=`pwd`/data
    mv ../../tesseract-ocr/tessdata data/
popd

make testfront

set +o pipefail
luajit $(which luacheck) --no-color -q frontend | tee ./luacheck.out
test $(grep Total ./luacheck.out | awk '{print $2}') -le 19
