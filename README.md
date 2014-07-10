UF Higgs Analyzer Submit Area
----

Install instruction:

This is supposed to be an accompany package for UFHZZAnalysis8TeV
It is to be instealled in the same directory as CMSSW_5_x_x_xxx, in a structure like:

[lihengne@alachua analyzer8tev]$ ls -l
total 12
drwxr-xr-x 16 lihengne cms 4096 Jul 10 11:59 CMSSW_5_3_9_patch3
-rwxr-xr-x  1 lihengne cms  296 Jul 10 11:57 install.sh
drwxr-xr-x  4 lihengne cms 4096 Jul 10 12:13 SubmitArea_8TeV

To install:
git clone https://github.com/VBF-HZZ/SubmitArea_8TeV.git
cd SubmitArea_8TeV 
git checkout -b testProd origin/testProd

To use:
Please temporarily refer to the other readme file SubmitArea_8TeV/README


