#!/bin/sh

PUReWeight=True
if [ "$2" == "" ]; then
  SETNJOBS=5
else
  SETNJOBS=$2
fi

weightEvents="True" #True or False

if [ "$1" == "" ]; then 
  echo "Please pass a dir with txt files for datasets to be processed!"
  exit 1;
fi


INPUTDIR=${1}


if [ ! -d "Submission_${INPUTDIR}" ]; then 
  mkdir Submission_${INPUTDIR}
fi


cd ${INPUTDIR}

for file in  *.txt;
do
  
  patTuples=`cat $file`
  
  txtFile=`basename $file .txt`
  
  mH=`../getXSec.exe ${txtFile} higgsMass ../CrossSectionList.txt`
  if [ "$mH" == "0" ]; then
      isSignal="False"
  else
      isSignal="True"
  fi
  
  CrossSect=`../getXSec.exe ${txtFile} crossSection ../CrossSectionList.txt`
  FilterEff=`../getXSec.exe ${txtFile} filterEff ../CrossSectionList.txt`
  nEvents=`../getXSec.exe ${txtFile} nEvents ../CrossSectionList.txt` 
 
  workDir=../Submission_${INPUTDIR}
  cfgSRC2=../${cfgSRC}
  
  echo $file
  
  NFILES_TOTAL=`cat $file | wc -l`

  NFILES_PERJOB1=$(( NFILES_TOTAL / SETNJOBS + 1 )) # N files for each job except the last job
  NJOBS=$(( NFILES_TOTAL / NFILES_PERJOB1 + 1 )) # reset NJOBS
  NFILES_PERJOB2=$(( NFILES_TOTAL % NFILES_PERJOB1 )) # N files for the last job

  echo "NJOBS=$NJOBS; NFILES_PERJOB1=$NFILES_PERJOB1; NFILES_PERJOB2=$NFILES_PERJOB2"

  NFILES=1 #counter, number of jobs added per job
  IJOB=1 # job number, counter
  FILES_IN_JOB="" #string to hold the files 

  for infile in `cat $file`; 
  do
    # decide with NFILES_PERJOB to use
    NFILES_PERJOB=""
    if [ "$IJOB" -lt "$NJOBS" ]; then
      NFILES_PERJOB=${NFILES_PERJOB1}
    else
      NFILES_PERJOB=${NFILES_PERJOB2}
    fi

    # if less than number fo files per job, count it
    if [ "$NFILES" -le "$NFILES_PERJOB" ]; then
    #
      if [ "$NFILES" -eq "1" ]; then
        FILES_IN_JOB="${infile}"
      else
        FILES_IN_JOB="${FILES_IN_JOB},${infile}"
      fi
      # if eq number of files per job, fill in file
      if [ "$NFILES" -eq "$NFILES_PERJOB" ]; then

        cfgFile=${txtFile}_cfg_$(( IJOB - 1 )).py

        echo "import FWCore.ParameterSet.Config as cms

process = cms.Process(\"UFHZZ4LAnalysis\")

process.load(\"FWCore.MessageService.MessageLogger_cfi\")
process.MessageLogger.cerr.FwkReport.reportEvery = 1000
process.MessageLogger.categories.append('UFHZZ4LAna')

process.load(\"Configuration.StandardSequences.MagneticField_cff\")
process.load('Configuration.StandardSequences.FrontierConditions_GlobalTag_cff')

process.GlobalTag.globaltag='START53_V23::All'

process.Timing = cms.Service(\"Timing\",
                             summaryOnly = cms.untracked.bool(True)
                             )


process.maxEvents = cms.untracked.PSet( input = cms.untracked.int32(-1) )

myfilelist = cms.untracked.vstring()
myfilelist.extend( [

" >> ${workDir}/${cfgFile}

echo ${FILES_IN_JOB} >> ${workDir}/${cfgFile}

echo "

]
)

process.source = cms.Source(\"PoolSource\",fileNames = myfilelist,
                            )

process.TFileService = cms.Service(\"TFileService\",
                                   fileName = cms.string(\""${txtFile}_$(( IJOB - 1 ))".root\")
                                   )

process.reCorrectedPatJets = cms.EDProducer(\"PatJetReCorrector\",
                                            jets = cms.InputTag('selectedPatJets'),
                                            payload = cms.string('AK5PF'),
                                            rho = cms.InputTag('kt6PFJets', 'rho','RECO'),
                                            levels = cms.vstring('L1FastJet','L2Relative','L3Absolute')
                                            )


process.Ana = cms.EDAnalyzer('UFHZZ4LAna',
                              photonSrc    = cms.untracked.InputTag(\"cleanPatPhotons\"),
                              electronSrc  = cms.untracked.InputTag(\"calibratedPatElectrons\"),
                              muonSrc      = cms.untracked.InputTag(\"muscleMuons\"),
                              correctedJetSrc = cms.untracked.InputTag(\"reCorrectedPatJets\"),
                              jetSrc       = cms.untracked.InputTag(\"selectedPatJets\"),
                              metSrc       = cms.untracked.InputTag(\"patMETsPF\"),
                              vertexSrc    = cms.untracked.InputTag(\"goodOfflinePrimaryVertices\"), #or selectedVertices
                              isMC         = cms.untracked.bool(True),
                              isSignal     = cms.untracked.bool("$isSignal"),
                              mH           = cms.untracked.uint32("$mH"),
                              CrossSection = cms.untracked.double("$CrossSect" ),
                              FilterEff    = cms.untracked.double("$FilterEff"),
                              weightEvents = cms.untracked.bool("$weightEvents"),
                              elRhoSrc     = cms.untracked.InputTag(\"kt6PFJets\", \"rho\",\"RECO\"),
                              muRhoSrc     = cms.untracked.InputTag(\"kt6PFJetsCentralNeutral\", \"rho\",\"RECO\"),
                              reweightForPU = cms.untracked.bool("$PUReWeight")
                             )

process.AnaAfterHlt = cms.EDAnalyzer('UFHZZ4LAna',
                              photonSrc    = cms.untracked.InputTag(\"cleanPatPhotons\"),
                              electronSrc  = cms.untracked.InputTag(\"calibratedPatElectrons\"),
                              muonSrc      = cms.untracked.InputTag(\"muscleMuons\"),
                              correctedJetSrc = cms.untracked.InputTag(\"reCorrectedPatJets\"),
                              jetSrc       = cms.untracked.InputTag(\"selectedPatJets\"),
                              metSrc       = cms.untracked.InputTag(\"patMETsPF\"),
                              vertexSrc    = cms.untracked.InputTag(\"goodOfflinePrimaryVertices\"), #or selectedVertices
                              isMC         = cms.untracked.bool(True),
                              isSignal     = cms.untracked.bool("$isSignal"),
                              mH           = cms.untracked.uint32("$mH"),
                              CrossSection = cms.untracked.double("$CrossSect" ),
                              FilterEff    = cms.untracked.double("$FilterEff"),
                              weightEvents = cms.untracked.bool("$weightEvents"),
                              elRhoSrc     = cms.untracked.InputTag(\"kt6PFJets\", \"rho\",\"RECO\"),
                              muRhoSrc     = cms.untracked.InputTag(\"kt6PFJetsCentralNeutral\", \"rho\",\"RECO\"),
                             reweightForPU = cms.untracked.bool("$PUReWeight")
                             )




# Trigger
process.hltHighLevel = cms.EDFilter(\"HLTHighLevel\",
                                    TriggerResultsTag = cms.InputTag(\"TriggerResults\",\"\",\"HLT\"),
                                    HLTPaths = cms.vstring('HLT_Mu17_TkMu8*',
                                                            'HLT_Mu17_Mu8*',
                                                            'HLT_Ele17_CaloIdT_CaloIsoVL_TrkIdVL_TrkIsoVL_Ele8_CaloIdT_CaloIsoVL_TrkIdVL_TrkIsoVL*',
                                                            'HLT_Mu8_Ele17_CaloIdT_CaloIsoVL_TrkIdVL_TrkIsoVL*',
                                                            'HLT_Mu17_Ele8_CaloIdT_CaloIsoVL_TrkIdVL_TrkIsoVL*',
                                                            'HLT_Ele15_Ele8_Ele5_CaloIdL_TrkIdVL*'
                                                             ),
                                    # provide list of HLT paths (or patterns) you want
                                    eventSetupPathsKey = cms.string(''), # not empty => use read paths from AlCaRecoTriggerBitsRcd via this key
                                    andOr = cms.bool(True),             # how to deal with multiple triggers: True (OR) accept if ANY is true, False (AND) accept if ALL are true
                                    throw = cms.bool(False)    # throw exception on unknown path names
                                    )



process.p = cms.Path(process.reCorrectedPatJets
                     *process.Ana
                     *process.hltHighLevel
                     *process.AnaAfterHlt
                     )


" >> ${workDir}/${cfgFile}

        IJOB=$(( IJOB + 1 )) # reset
        FILES_IN_JOB="" #reset
        NFILES=1 #reset
      else
        NFILES=$(( NFILES + 1 ))
      fi
    fi
  done 

done


cd ../
