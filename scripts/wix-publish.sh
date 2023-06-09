#!/bin/bash -ex

version=$1
[ -n "$version" ] || {
  echo "Usage: $0 <version>" 1>&2
  exit 1
}

[ -z "$(git status --porcelain)" ] ||  {
  echo "working dir is not clean" 1>&2
  exit 1
}

list="darwin-arm64 darwin-x64 linux-arm linux-arm64 linux-ia32 linux-loong64 linux-mips64el linux-ppc64 linux-riscv64 linux-s390x linux-x64"

deps={\"$(echo ${list[@]/%/\":\"$version\"} | sed -e 's/ /","/g')}
jq ". += {\"dependencies\":${deps}}" npm/esbuild/package.json > npm/esbuild/package.json_
mv npm/esbuild/package.json{_,}

git commit -am "version $version"
git tag $version
git push -u origin $version

for b in $list; do
  pushd npm/\@esbuild/$b
    npm publish
  popd
done
pushd npm/esbuild
  npm publish
popd
