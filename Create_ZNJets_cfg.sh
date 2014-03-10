#!/bin/bash             

PUReWeight=True
JobsPerDataset=10
weightEvents=True #True or False

if [ "$1" == "" ]; then 
    echo "Please pass a dir with txt files for datasets to be processed!"
    exit 1;
fi


dir=${1}


if [ ! -d "Submission_${dir}" ]
      then mkdir Submission_${dir}
fi


cd $dir

for f in $(ls *.txt)
  do
  
  patTuples=$(cat $f)
  
  txtFile=${f%%.txt*}
  
  mH=$(../bin/getHiggsMass.exe ${txtFile} )  
  if [[ "$mH" == "0" ]]; then
      isSignal="False"
  else
      isSignal="True"
  fi
  
  CrossSect=$(../bin/getCrossSection.exe ${txtFile} )
  FilterEff=$(../bin/getFilterEff.exe ${txtFile} )
  nEvents=$(../bin/getNEvents.exe ${txtFile} )
  
  workDir=../Submission_${dir}
  cfgSRC2=../${cfgSRC}
  
  echo $f
  
  nJobsPerDataset=${JobsPerDataset}  
  nLines=$(cat $f | wc -l)
  
  nFilesPerJob=$( echo "scale=0;${nLines}/${nJobsPerDataset}" | bc)
  nFilesLeftover=$( echo "${nLines}%${nJobsPerDataset}" | bc)
  
  nJobsPerDataset=${JobsPerDataset}
  
  if(( $nLines < $nJobsPerDataset)); then
      nJobsPerDataset=$nLines
      nFilesPerJob=1
      nFilesLeftover=0
  fi
  

  if [[ "$nFilesLeftover" == "0" ]]; then
  totalJobs=${nJobsPerDataset}
      
      for(( i=0; i<${totalJobs}; i++ ));
	do
	counterArray[$i]=${nFilesPerJob}
      done
  else
     let totalJobs=${nJobsPerDataset}+1
     let lastJob=${nJobsPerDataset}
      
      for(( i=0; i<${totalJobs}; i++ ));
	do
	
	if [[ "$i" == "$lastJob" ]]; then
	    counterArray[$i]=${nFilesLeftover}
	else
	    counterArray[$i]=${nFilesPerJob}
	fi
      done
      
  fi
  
  
  
  tmpCounter=1
  arrayCounter=0
  jobCounter=0
  
  files=""
  while read line
    do

    if [[ "$tmpCounter" != "${counterArray[arrayCounter]}" ]]; then
      
	files+=$line,
	let tmpCounter=${tmpCounter}+1
    else
	files+=$line
	let arrayCounter=${arrayCounter}+1
	
	cfgFile=${txtFile}_cfg_${jobCounter}.py
	let jobCounter=${jobCounter}+1
	
echo "import FWCore.ParameterSet.Config as cms

process = cms.Process(\"UFHZZ4LAnalysis\")

process.load(\"FWCore.MessageService.MessageLogger_cfi\")
process.MessageLogger.cerr.FwkReport.reportEvery = 10000
process.MessageLogger.categories.append('UFHZZ4LAna')
process.load('Configuration.StandardSequences.MagneticField_cff')
process.load('Configuration.StandardSequences.FrontierConditions_GlobalTag_cff')

process.GlobalTag.globaltag='START53_V23::All'


process.Timing = cms.Service(\"Timing\",
                             summaryOnly = cms.untracked.bool(True)
                             )


process.maxEvents = cms.untracked.PSet( input = cms.untracked.int32(-1) )

myfilelist = cms.untracked.vstring()
myfilelist.extend( [

" >> ${workDir}/${cfgFile}

echo $files >> ${workDir}/${cfgFile}

echo "

]
)

process.source = cms.Source(\"PoolSource\",fileNames = myfilelist)

process.TFileService = cms.Service(\"TFileService\",
                                   fileName = cms.string(\""${txtFile}_${jobCounter}".root\")
                                   )

process.reCorrectedPatJets = cms.EDProducer(\"PatJetReCorrector\",
                                            jets = cms.InputTag('selectedPatJets'),
                                            payload = cms.string('AK5PF'),
                                            rho = cms.InputTag('kt6PFJets', 'rho','RECO'),
                                            levels = cms.vstring('L1FastJet','L2Relative','L3Absolute')
                                            )



process.Ana = cms.EDAnalyzer('UFHZZ4LAna',
                              photonSrc    = cms.untracked.InputTag(\"cleanPatPhotons\"),
                              electronSrc  = cms.untracked.InputTag(\"cleanPatElectrons\"),
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
                              electronSrc  = cms.untracked.InputTag(\"cleanPatElectrons\"),
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
                                    HLTPaths = cms.vstring( 'HLT_Mu17_TkMu8*',
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



#process.load('HZZAnalysis.UFHZZ4LAna.LheNup6Nup7Filter_cfi')
process.load('HZZAnalysis.UFHZZ4LAna.LHEFilterByPartonIDUP_cfi')

#process.p = cms.Path(process.Ana)

process.p = cms.Path(process.reCorrectedPatJets
                     *process.LHEFilterByPartonIDUP
                     *process.Ana
                     *process.hltHighLevel  
                     *process.AnaAfterHlt
                     )


" >> ${workDir}/${cfgFile}

files=""
tmpCounter=1


  fi


done < $f

jobCounter=0
done

cd ../