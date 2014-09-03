#!/bin/sh

INDIR=results_HZZSamples_Sept
#INDIR=results_HZZSamples_RMDUP
OUTDIR=rootFiles
hadd ${OUTDIR}/mH_125_WH.root ${INDIR}/WH_HToZZTo4L_M-125_8TeV*
hadd ${OUTDIR}/mH_126_WH.root ${INDIR}/WH_HToZZTo4L_M-126_8TeV*
#hadd ${OUTDIR}/mH_126_SMH.root ${INDIR}/SMHiggsToZZTo4L_M-126_8TeV-powheg15*.root
#hadd ${OUTDIR}/ZZJetsTo4L.root ${INDIR}/ZZJetsTo4L_TuneZ2star*.root
#hadd ${OUTDIR}/ZZ_2e2mu.root ${INDIR}/ZZTo2e2mu*.root 
#hadd ${OUTDIR}/ZZ_4e.root ${INDIR}/ZZTo4e*.root
#hadd ${OUTDIR}/ZZ_4mu.root ${INDIR}/ZZTo4mu*.root
#hadd ${OUTDIR}/ZZto2e2tau.root ${INDIR}/ZZTo2e2tau*.root
#hadd ${OUTDIR}/ZZto2mu2tau.root ${INDIR}/ZZTo2mu2tau*.root
#hadd ${OUTDIR}/ZZto4tau.root ${INDIR}/ZZTo4tau*.root
#hadd ${OUTDIR}/ggZZ_2e2mu.root ${INDIR}/GluGluToZZTo2L2L*.root
#hadd ${OUTDIR}/ggZZ_4l.root ${INDIR}/GluGluToZZTo4L*.root
#hadd ${OUTDIR}/mH_126_VBF.root ${INDIR}/VBF_HToZZTo4L_M-126_*root
#hadd ${OUTDIR}/mH_126_ggH.root ${INDIR}/GluGluToHToZZTo4L_M-126_8TeV-powheg-*.root
#hadd ${OUTDIR}/mH_126_ggH_powheg15.root ${INDIR}/GluGluToHToZZTo4L_M-126_8TeV-powheg15-*.root
#hadd ${OUTDIR}/mH_125_ggH_powheg15.root ${INDIR}/GluGluToHToZZTo4L_M-125_8TeV-powheg15-*.root
#hadd ${OUTDIR}/mH_350_VBF.root ${INDIR}/VBF_HToZZTo4L_M-350_*root
#hadd ${OUTDIR}/mH_350_ggH.root ${INDIR}/GluGluToHToZZTo4L_M-350_*root

