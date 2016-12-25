function [trainA,testA,trainX,testX ] = splitTrainTest( A, X, train)
% Splits train and test data according to provided instances
tr = 1; te = 1;

for i = 1:length(X)
    if (X(i) == 'm' || X(i) == 1)
        label(i) = 1;
    elseif (X(i) == 's' || X(i) == 2)
        label(i) = 2;
    elseif (X(i) == 't' || X(i) == 3)
        label(i) = 3;
    end
end

for i = 1:length(train)
    if label(i) == 1 || label(i) == 2 || label(i) == 3
        if train(i) == 1
            trainA(tr,:) = A(i,:);
            trainX(tr,1) = label(i);
            tr = tr+1;
        else
            testA(te,:) = A(i,:);
            testX(te,1) = label(i);
            te = te+1;
        end
    end
end

end

