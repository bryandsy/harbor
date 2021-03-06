#!/bin/bash
set -e
echo "mode: set" >>profile.cov

deps=""

# listDeps lists packages referenced by package in $1, 
# excluding golang standard library and packages in 
# direcotry vendor
function listDeps(){
	pkg=$1
	deps=$pkg
	ds=$(echo $(go list -f '{{.Imports}}' $pkg) | sed 's/[][]//g')
	for d in $ds
	do
		if echo $d | grep -q "github.com/vmware/harbor" && echo $d | grep -qv "vendor"
		then
			deps="$deps,$d"
		fi
	done
}

packages=$(go list ./... | grep -v -E 'vendor|tests')

for package in $packages
do
	listDeps $package
	
	go test -cover -coverprofile=profile.tmp -coverpkg "$deps" $package
	if [ -f profile.tmp ]	
	then
		cat profile.tmp | tail -n +2 >> profile.cov
		rm profile.tmp
	fi	
done
