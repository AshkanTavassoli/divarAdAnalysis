function [] = trainer(inputRawData,reportDaysCount,trainingDataPercentage,outputY)
global testData trainingDataSet trainedClassifier;
global cityGroups brandGroups duration isArchived brandCityAverageCount brandCityChance;
global imageInfluence hourChance;

%choosing random training data
trainingDataNumberOfRows = fix(trainingDataPercentage*numel(inputRawData(:,1)));
tempData = zeros(numel(inputRawData(:,1)),numel(inputRawData(1,:))+1);
tempData(:,1:numel(inputRawData(1,:))) = inputRawData;
for i = 1 : numel(inputRawData(:,1))
    tempData(i,end) = rand();
end
tempData = sortrows(tempData,numel(inputRawData(1,:))+1);
trainigDataInput = tempData(1:trainingDataNumberOfRows - 1,1:numel(inputRawData(1,:)));
%isolating test data
testData = tempData(trainingDataNumberOfRows:end,1:numel(inputRawData(1,:)));
trainingDataSet = zeros(trainingDataNumberOfRows-1,outputY);
%LastColumn: Result
trainingDataSet(:,end) = trainigDataInput(:,end);
%using city and brand groups from metaData
for i = 1 : numel(trainigDataInput(:,1))
    trainigDataInput(i,1) = brandGroups(trainigDataInput(i,1)+1);
    trainigDataInput(i,2) = cityGroups(trainigDataInput(i,2)+1);
end

%calculating duration and isArchived?
duration = zeros(numel(trainigDataInput(:,1)),1);
isArchived = zeros(numel(trainigDataInput(:,1)),1);
for i = 1 : numel(trainigDataInput(:,1))
    duration(i) = ((trainigDataInput(i,5) - trainigDataInput(i,3))*24) + (trainigDataInput(i,6) - trainigDataInput(i,4));
    if (duration(i) > 0) && (duration(i) < (24*reportDaysCount))
        isArchived(i) = 1;
    else
        duration(i) = (24*reportDaysCount);
    end
end

%Filling trainingDataSet
for i = 1 : numel(trainigDataInput(:,1))
    %Brand and City Chance
    trainingDataSet(i,1) = brandCityChance(trainigDataInput(i,1),trainigDataInput(i,2));
    %Publish Hour Chance
    if(duration(i)<24)
        trainingDataSet(i,2) = hourChance(trainigDataInput(i,4)+1);
    else
        %setting zero instead of average has a better outcome
        %trainingDataSet(i,2) = sum(hourChance) / numel(hourChance(:,1));
    end
    trainingDataSet(i,3) = isArchived(i);
    trainingDataSet(i,4) = duration(i);
    trainingDataSet(i,5) = trainigDataInput(i,9)/trainigDataInput(i,8);
    trainingDataSet(i,6) = trainingDataSet(i,1)*(trainigDataInput(i,8)/duration(i))/brandCityAverageCount(trainigDataInput(i,1),trainigDataInput(i,2),1);
    trainingDataSet(i,7) = imageInfluence(trainigDataInput(i,2),trainigDataInput(i,7)+1);
end
%train cassifier with selected Data

%                       ___
%                      |###|
%                      |###|
%                     _|###|_
%                     \#####/
%                      \###/
%                       \#/
%                        *
trainedClassifier = FineGaussianScaled(trainingDataSet);

end