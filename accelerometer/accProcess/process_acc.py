import accelerometer
from accelerometer.classification import trainClassificationModel

trainClassificationModel(
'/home/aayush/accelerometer/trainClassification_input.csv', # directory to the full dataset file
participantCol="participant", # column with participant IDs
labelCol="label", # column with labels
metCol=None, # column with MET values, if None, MET will not be used
featuresTxt="/home/aayush/accelerometer/features.txt", # directory to the list of features to use
nTrees=3000, # RF parameters: number of trees in the forest
maxDepth=10, # RF parameters: maximum depth of the tree
minSamplesLeaf=1, # RF parameters: minimum number of samples required to be at a leaf node
cv=None, # whether to report cross-validation results (None, 5, 10, etc.)
testParticipants="101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151",
outDir="/home/aayush/accelerometer/compare_classification/accProcess_original/model", # directory where to save results
nJobs=10 # number of parallel jobs to run
)