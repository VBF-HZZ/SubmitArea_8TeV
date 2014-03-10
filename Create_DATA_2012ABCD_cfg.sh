#!/bin/bash             

JobsPerDataset=1

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
      nJobsPerDataset=1
      counterArray[0]=$nLines
  else
      
      totalJobs=${nJobsPerDataset}
      if [[ "$nFilesLeftover" == "0" ]]; then
	  
	  for(( i=0; i<${totalJobs}; i++ ));
	    do
	    counterArray[$i]=${nFilesPerJob}
	  done
      else
	  let lastJob=${nJobsPerDataset}-1
	  
	  for(( i=0; i<${totalJobs}; i++ ));
	    do

	    if [[ "$i" == "$lastJob" ]]; then
		counterArray[$i]=$( echo "scale=0;${nFilesLeftover}+${nFilesPerJob}" | bc)
	    else
		counterArray[$i]=${nFilesPerJob}
	    fi
	  done
	  
      fi
      
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

process.load('FWCore.MessageService.MessageLogger_cfi')
process.MessageLogger.cerr.FwkReport.reportEvery = 1000
process.MessageLogger.categories.append('UFHZZ4LAna')

process.load('Configuration.StandardSequences.MagneticField_cff')
process.load('Configuration.StandardSequences.FrontierConditions_GlobalTag_cff')

process.GlobalTag.globaltag='FT_53_V21_AN4::All'


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
process.source.skipBadFiles = cms.untracked.bool( True )

process.TFileService = cms.Service(\"TFileService\",
                                   fileName = cms.string(\""${txtFile}_${jobCounter}".root\")
                                   )


process.reCorrectedPatJets = cms.EDProducer(\"PatJetReCorrector\",
                                            jets = cms.InputTag('selectedPatJets'),
                                            payload = cms.string('AK5PF'),
                                            rho = cms.InputTag('kt6PFJets', 'rho','RECO'),
                                            levels = cms.vstring('L1FastJet','L2Relative','L3Absolute','L2L3Residual')
                                            )



process.AnaAfterHlt = cms.EDAnalyzer('UFHZZ4LAna',
                              photonSrc    = cms.untracked.InputTag(\"cleanPatPhotons\"),
                              electronSrc  = cms.untracked.InputTag(\"calibratedPatElectrons\"),
                              muonSrc      = cms.untracked.InputTag(\"muscleMuons\"),
                              correctedJetSrc = cms.untracked.InputTag(\"reCorrectedPatJets\"),
                              jetSrc       = cms.untracked.InputTag(\"selectedPatJets\"),
                              metSrc       = cms.untracked.InputTag(\"patMETsPF\"),
                              vertexSrc    = cms.untracked.InputTag(\"goodOfflinePrimaryVertices\"), #or selectedVertices 
                              isMC         = cms.untracked.bool(False),
                              weightEvents = cms.untracked.bool(False),
                             elRhoSrc     = cms.untracked.InputTag(\"kt6PFJets\", \"rho\",\"RECO\"),
                             muRhoSrc     = cms.untracked.InputTag(\"kt6PFJetsCentralNeutral\", \"rho\",\"RECO\")

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



process.p = cms.Path(process.reCorrectedPatJets
                    *process.hltHighLevel
                    *process.AnaAfterHlt)



" >> ${workDir}/${cfgFile}

files=""
tmpCounter=1


  fi


done < $f

jobCounter=0
done

cd ../