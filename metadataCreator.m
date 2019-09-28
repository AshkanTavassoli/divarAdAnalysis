function[] = metadataCreator(inputRawData,reportDaysCount,metadataCreatorPercentage,maximumBrandID,maximumCityID)

global cityGroups brandGroups duration isArchived brandCityAverageCount brandCityChance;
global brandCityBuyVSContactChance averageBuyVSContactChance imageInfluence hourChance;
%Selectin metaDataCreator input
maxClassificationRow = fix(metadataCreatorPercentage*numel(inputRawData(:,1))); 
tempData = zeros(numel(inputRawData(:,1)),numel(inputRawData(1,:))+1);
tempData(:,1:numel(inputRawData(1,:))) = inputRawData;
for i = 1 : numel(inputRawData(:,1))
    tempData(i,end) = rand();
end
tempData = sortrows(tempData,numel(inputRawData(1,:))+1);
metaDataInput = tempData(1:maxClassificationRow,1:numel(inputRawData(1,:)));

%Brand and city classification
%Cities: small, medium and large
cityTotalView = zeros(maximumCityID+1,1);
for c = 0 : maximumCityID
    cityTotalView(c+1) = sum(metaDataInput((metaDataInput(:,2) == c) , 8));
end
biggestCityView = max(cityTotalView);
smallestCityView = max(cityTotalView);
for c = 0 : maximumCityID
    if cityTotalView(c+1) ~=0
        if smallestCityView > cityTotalView(c+1)
            smallestCityView = cityTotalView(c+1);
        end
    end
end
marginOne = smallestCityView + 1*((biggestCityView - smallestCityView)/3);
marginTwo = smallestCityView + 2*((biggestCityView - smallestCityView)/3);
cityGroups = zeros(maximumCityID+1,1);
for c = 1 : maximumCityID+1
    if cityTotalView(c) > marginTwo
       cityGroups(c) = 3;
    elseif cityTotalView(c) > marginOne
       cityGroups(c) = 2;
    else
       cityGroups(c) = 1;
    end
end

%Brands: low, medium and large possible buyers
brandTotalView = zeros(maximumBrandID+1,1);
for c = 0 : maximumBrandID
    brandTotalView(c+1) = sum(metaDataInput((metaDataInput(:,1) == c) , 8));
end
biggestBrandView = max(brandTotalView);
smallestBrandView = max(brandTotalView);
for c = 0 : maximumBrandID
    if brandTotalView(c+1) ~=0
        if smallestBrandView > brandTotalView(c+1)
            smallestBrandView = brandTotalView(c+1);
        end
    end
end
marginOne = smallestBrandView + 1*((biggestBrandView - smallestBrandView)/3);
marginTwo = smallestBrandView + 2*((biggestBrandView - smallestBrandView)/3);
brandGroups = zeros(maximumBrandID+1,1);
for c = 1 : maximumBrandID+1
    if brandTotalView(c) > marginTwo
       brandGroups(c) = 3;
    elseif brandTotalView(c) > marginOne
       brandGroups(c) = 2;
    else
       brandGroups(c) = 1;
    end
end

%use new city and brand groups
for i = 1 : numel(metaDataInput(:,1))
    metaDataInput(i,1) = brandGroups(metaDataInput(i,1)+1);
    metaDataInput(i,2) = cityGroups(metaDataInput(i,2)+1);
end

%Active Duration , Is Archived?
cityBrandDuration = zeros(3,3);
duration = zeros(numel(metaDataInput(:,1)),1);
isArchived = zeros(numel(metaDataInput(:,1)),1);
for i = 1 : numel(metaDataInput(:,1))
    duration(i) = ((metaDataInput(i,5) - metaDataInput(i,3))*24) + (metaDataInput(i,6) - metaDataInput(i,4));
    if (duration(i) > 0) && (duration(i) < (24*reportDaysCount))
        isArchived(i) = 1;
    else
        duration(i) = (24*reportDaysCount);
    end
    cityBrandDuration(metaDataInput(i,1),metaDataInput(i,2)) = cityBrandDuration(metaDataInput(i,1),metaDataInput(i,2)) + duration(i);
end

%calculationg brand per city chance
brandCityAverageCount = zeros(3,3,3);
brandCityChance = zeros(3,3);
brandCityBuyVSContactChance = zeros(3,3);
averageBuyVSContactChance = sum(metaDataInput(:,10))/sum(metaDataInput(:,9));
for b = 1 : 3
    for c = 1 : 3 
        %disp("For C, B: "+c+" - "+b)
        ones = sum(metaDataInput((metaDataInput(:,1) == b) & (metaDataInput(:,2) == c) , 10));
        all = numel(metaDataInput((metaDataInput(:,1) == b) & (metaDataInput(:,2) == c),10));
        sumOfviewCountPerHour = sum(metaDataInput((metaDataInput(:,1) == b) & (metaDataInput(:,2) == c) , 8))/cityBrandDuration(b,c);
        sumOfContactCount = sum(metaDataInput((metaDataInput(:,1) == b) & (metaDataInput(:,2) == c) , 9));
        if all > 0
            brandCityChance(b,c) = ones / all;
            brandCityAverageCount(b,c,1) = (sumOfviewCountPerHour/all);
            brandCityAverageCount(b,c,2) = all; 
            brandCityBuyVSContactChance(b,c) = ones / sumOfContactCount;
        else
            totalAverageView = (sum(metaDataInput((metaDataInput(:,1) == b),8))/numel(metaDataInput((metaDataInput(:,1) == b),1)))/sum(cityBrandDuration(b,:));
            brandCityAverageCount(b,c,1) = totalAverageView;
            brandCityAverageCount(b,c,2) = 0; 
            brandCityChance(b,c) = sum(metaDataInput((metaDataInput(:,1) == b) , 10)) / numel(metaDataInput((metaDataInput(:,1) == b),10));
            brandCityBuyVSContactChance(b,c) = averageBuyVSContactChance;
        end 
    end
end

%Image Effect
maxImage = max(metaDataInput(:,7));
imageInfluence = zeros(3,maxImage+1);
for i = 1:3
    for j = 0:maxImage
        imageInfluence(i,j+1) = sum(metaDataInput((metaDataInput(:,2)==i) & (metaDataInput(:,7)==j),10)) / numel(metaDataInput((metaDataInput(:,2)==i) & (metaDataInput(:,7)==j),10));
    end
end

%Publish Hour
hourChance = zeros(24,1);
for h = 0:23
    ones = sum(metaDataInput((metaDataInput(:,4) == h) & duration(:,1) < 24, 10));
    all = numel(metaDataInput((metaDataInput(:,4) == h) & duration(:,1) < 24,10));
    if(all == 0)
        if(h ~= 0)
            hourChance(h+1) = hourChance(h);
        end
    else
        hourChance(h+1) = ones/all;
    end
end

end