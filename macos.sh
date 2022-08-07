[ -z "$GITHUB_WORKSPACE" ] && GITHUB_WORKSPACE="$( cd "$( dirname "$0" )"/.. && pwd )"

VERSION=$1

cd ~
git clone https://github.com/nodejs/node.git

cd node
git fetch origin v$VERSION
git checkout v$VERSION

echo "=====[Patching Node.js]====="

node $GITHUB_WORKSPACE/CRLF2LF.js $GITHUB_WORKSPACE/lib_uv_add_on_watcher_queue_updated_v$VERSION.patch
git apply --cached $GITHUB_WORKSPACE/lib_uv_add_on_watcher_queue_updated_v$VERSION.patch
git checkout -- .

echo "=====[ add ArrayBuffer_New_Without_Stl ]====="
node $GITHUB_WORKSPACE/add_arraybuffer_new_without_stl.js deps/v8

echo "=====[ add make_v8_inspector_export ]====="
node $GITHUB_WORKSPACE/make_v8_inspector_export.js

echo "=====[Building Node.js]====="

./configure --shared --no-browser-globals
make -j8

mkdir -p ../puerts-node/nodejs/include
mkdir -p ../puerts-node/nodejs/deps/uv/include
mkdir -p ../puerts-node/nodejs/deps/v8/include

mkdir -p ../puerts-node/nodejs/lib/macOS/
cp out/Release/libnode.*.dylib ../puerts-node/nodejs/lib/macOS/
