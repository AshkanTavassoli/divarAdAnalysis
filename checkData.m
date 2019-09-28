function[] = checkData(treshhold,outputY)
global processedTestData result;

%checking zeros
all = 0;
correct = 0;
for i = 1:numel(result)
    %this part does nothing if we use classification
    %only for regression
    if (result(i)>treshhold)
        result(i) = 1;
    else
       result(i) = 0; 
    end
     if(result(i) == 0)
        all = all + 1;
        if result(i) == processedTestData(i,outputY)
            correct = correct + 1;
        end
     end
end
%disp result
disp(correct+" of "+all+" --0-- predicted was correct( "+correct/all+"% )")

%checking ones
all = 0;
correct = 0;
for i = 1:numel(result)
     if(result(i) == 1)
        all = all + 1;
        if result(i) == processedTestData(i,outputY)
            correct = correct + 1;
        end
     end
end
%disp result
disp(correct+" of "+all+" --1-- predicted was correct( "+correct/all+"% )") 
disp("Success Rate: "+numel(processedTestData(processedTestData(:,end)==result(:,1)))/numel(result))

end