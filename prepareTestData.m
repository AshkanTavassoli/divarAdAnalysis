function[] = prepareTestData(outputY,reportDaysCount)
global testData processedTestData;
global cityGroups brandGroups duration isArchived brandCityAverageCount brandCityChance;
global imageInfluence hourChance;

%using  data that was not used in training
processedTestData = zeros(numel(testData(:,1)),outputY);
duration = zeros(numel(testData(:,1)),1);
processedTestData(:,outputY) = testData(:,10);
isArchived = zeros(numel(testData(:,1)),1);
%using brand and cuty groups
for i = 1 : numel(testData(:,1))
    testData(i,1) = brandGroups(testData(i,1)+1);
    testData(i,2) = cityGroups(testData(i,2)+1);
end
%Duration and is archived?
for i = 1 : numel(testData(:,1))
    duration(i) = ((testData(i,5) - testData(i,3))*24) + (testData(i,6) - testData(i,4));
    if (duration(i) > 0) && (duration(i) < (24*reportDaysCount))
        isArchived(i) = 1;
    else
        duration(i) = (24*reportDaysCount);
    end
end

%Filling processedTestData
for i = 1 : numel(testData(:,1))
    %Brand and City Chance
    processedTestData(i,1) = brandCityChance(testData(i,1),testData(i,2));
    %Publish Hour Chance
    if(duration(i)<24)
        processedTestData(i,2) = hourChance(testData(i,4)+1);
    else
        %setting zero instead of average has a better outcome
        %processedTestData(i,2) = sum(hourChance) / numel(hourChance(:,1));
    end
    processedTestData(i,3) = isArchived(i);
    processedTestData(i,4) = duration(i);
    processedTestData(i,5) = testData(i,9)/testData(i,8);
    processedTestData(i,6) = processedTestData(i,1)*(testData(i,8)/duration(i))/brandCityAverageCount(testData(i,1),testData(i,2),1);
    processedTestData(i,7) = imageInfluence(testData(i,2),testData(i,7)+1);
end
end