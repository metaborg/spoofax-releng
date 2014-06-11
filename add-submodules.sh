#!/bin/bash

git submodule add -b mvn-build git@github.com:metaborg/mb-rep.git mb-rep && git add mb-rep
git submodule add -b mvn-build git@github.com:metaborg/mb-exec.git mb-exec && git add mb-exec
git submodule add -b mvn-build git@github.com:metaborg/mb-exec-deps.git mb-exec-deps && git add mb-exec-deps
git submodule add -b mvn-build git@github.com:metaborg/jsglr.git jsglr && git add jsglr
git submodule add -b mvn-build git@github.com:metaborg/runtime-libraries.git runtime-libraries && git add runtime-libraries
git submodule add -b mvn-build git@github.com:metaborg/spoofax.git spoofax && git add spoofax
git submodule add -b mvn-build git@github.com:metaborg/spoofax-debug.git spoofax-debug && git add spoofax-debug
git submodule add -b mvn-build git@github.com:metaborg/spoofax-deploy.git spoofax-deploy && git add spoofax-deploy
git submodule add -b mvn-build git@github.com:metaborg/sdf.git sdf && git add sdf
git submodule add -b mvn-build git@github.com:metaborg/rtg.git rtg && git add rtg
git submodule add -b mvn-build git@github.com:metaborg/box.git box && git add box
git submodule add -b mvn-build git@github.com:metaborg/esv.git esv && git add esv
git submodule add -b mvn-build git@github.com:metaborg/stratego.git stratego && git add stratego
git submodule add -b mvn-build git@github.com:metaborg/aster.git aster && git add aster
git submodule add -b mvn-build git@github.com:metaborg/nabl.git nabl && git add nabl
git submodule add -b mvn-build git@github.com:metaborg/ts.git ts && git add ts
git submodule add -b mvn-build git@github.com:metaborg/spt.git spt && git add spt
git submodule add -b mvn-build git@github.com:metaborg/spoofax-modelware.git modelware && git add modelware
git submodule add -b mvn-build git@github.com:metaborg/imp-patched.git imp-patched && git add imp-patched
git submodule add -b mvn-build git@github.com:metaborg/lpg-runtime.git lpg-runtime && git add lpg-runtime
git submodule add -b mvn-build git@github.com:metaborg/shrike.git shrike && git add shrike
git submodule add -b mvn-build git@github.com:metaborg/strategoxt.git strategoxt && git add strategoxt

git submodule init
