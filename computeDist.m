function dist = computeDist(testFt, trainFt)

dist = zeros(size(trainFt,1),1);
for i = 1:size(trainFt,1)
    distVector = testFt - trainFt(i,:);
%     dist(i) = sqrt((distVector * distVector')/length(testFt));
dist(i) = norm(distVector,2);
end
end

