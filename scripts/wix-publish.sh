#!/bin/bash -e

version=$1
[ -n "$version" ] || {
  echo "Usage: $0 <version>" 1>&2
  exit 1
}

[ -z "$(git status --porcelain)" ] ||  {
  echo "working dir is not clean" 1>&2
  exit 1
}

echo $version > version.txt
make platform-all

list=(`jq .optionalDependencies npm/esbuild/package.json | grep esbuild | cut -d \" -f2 | cut -d/ -f2`)

for b in ${list[@]}; do
  pushd npm/\@esbuild/$b
    npm publish
  popd
done
pushd npm/esbuild
  npm publish
popd

git commit -am "version $version"
git tag $version
git push -u origin $version
