#!/bin/bash

git submodule deinit mb-rep && git rm mb-rep &&
git submodule deinit mb-exec && git rm mb-exec &&
git submodule deinit mb-exec-deps && git rm mb-exec-deps &&
git submodule deinit jsglr && git rm jsglr &&
git submodule deinit runtime-libraries && git rm runtime-libraries &&
git submodule deinit spoofax && git rm spoofax &&
git submodule deinit spoofax-debug && git rm spoofax-debug &&
git submodule deinit spoofax-deploy && git rm spoofax-deploy &&
git submodule deinit sdf && git rm sdf &&
git submodule deinit rtg && git rm rtg &&
git submodule deinit box && git rm box &&
git submodule deinit esv && git rm esv &&
git submodule deinit stratego && git rm stratego &&
git submodule deinit aster && git rm aster &&
git submodule deinit nabl && git rm nabl &&
git submodule deinit ts && git rm ts &&
git submodule deinit spt && git rm spt &&
git submodule deinit tdl && git rm tdl &&
git submodule deinit imp-patched && git rm imp-patched &&
git submodule deinit strategoxt && git rm strategoxt &&

git submodule init
