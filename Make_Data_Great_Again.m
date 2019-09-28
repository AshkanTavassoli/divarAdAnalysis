%Result Column ID
outputY = 8;
%Watchdog report day
reportDaysCount = 5;
maximumCityID = 7;
maximumBrandID = 29;
metadataCreatorPercentage = 0.5;
%Test/Train split
trainingDataPercentage = 0.85;
%Threshhold for classification
treshhold = 0.5;
global trainedClassifier processedTestData result;

%load input data

[baseName, folder] = uigetfile('.csv','Select MetaDataCreator File');
fullFileName = fullfile(folder, baseName);
inputRawData = csvread(fullFileName,1);
%create required meta data
metadataCreator(inputRawData,reportDaysCount,metadataCreatorPercentage,maximumBrandID,maximumCityID);
%train classifier
trainer(inputRawData,reportDaysCount,trainingDataPercentage,outputY);
%prepair test data
prepareTestData(outputY,reportDaysCount);
%predict
result = trainedClassifier.predictFcn(processedTestData(:,1:(outputY-1)));
%check result
checkData(treshhold,outputY);
