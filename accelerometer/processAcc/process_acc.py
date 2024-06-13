### Launching processAcc (part of accelerometer package)

import accelerometer
from accelerometer.classification import trainClassificationModel

trainClassificationModel(
'/accelerometer/processed_data.csv', # directory to the full dataset file
participantCol="participant", # column with participant IDs
labelCol="label", # column with labels
metCol="MET", # column with MET values, if None, MET will not be used
featuresTxt="/home/yacine/accel/bespoke/features.txt", # directory to the list of features to use
nTrees=1000, # RF parameters: number of trees in the forest
maxDepth=10, # RF parameters: maximum depth of the tree
minSamplesLeaf=1, # RF parameters: minimum number of samples required to be at a leaf node
cv=None, # whether to report cross-validation results (None, 5, 10, etc.)
testParticipants="22.0,54.0",
outDir="results/", # directory where to save results
nJobs=10 # number of parallel jobs to run
)