#!/bin/bash

##Job settings                                                         
#PBS -q default
#PBS -o outFiles/"${jobName}".out                          
#PBS -e errFiles/"${jobName}".err                                       
#PBS -m a                                                
#PBS -M snowball@phys.ufl.edu                            
             
##Job Configuration                                         
                                                                                                                     
##Job Resources                                                     
#PBS -l walltime=03:00:00 
#PBS -l nodes=1:ppn=1                                                  
#PBS -l pmem=8gb 

##Create Work Area
CMSSWVER=CMSSW_5_3_9_patch3
export SCRAM_ARCH=slc5_amd64_gcc462
export OSG_APP=/osg/app                                         
export VO_CMS_SW_DIR=${OSG_APP}/cmssoft/cms                               
export CMS_PATH=${VO_CMS_SW_DIR}                                                                                
. ${CMS_PATH}/cmsset_default.sh
cd $TMPDIR
eval `scramv1 project CMSSW ${CMSSWVER}`
cd ${CMSSWVER}/
#rm -rf lib/ src/ config/ python/
rm -rf ./*
cp -r -d ${curDir}/../${CMSSWVER}/* ./

cd src
eval `scramv1 runtime -sh`
#eval `scramv1 setup mcfm >& tmp.out`
edmPluginRefresh -p ../lib/$SCRAM_ARCH

#fix mcfm issue
rm -rf Pdfdata
cp -r ${CMSSW_BASE}/src/ZZMatrixElement/MELA/data/Pdfdata ./

cp ${curDir}/${submitDir}/${cfgFile} ./  

echo "Job running on `hostname` at `date`"

##execute job
cmsRun ${cfgFile}

ls -l ./*

rm can_*.root

cp *.root ${curDir}/${outDir}/


echo "Job ended at `date`"                              

