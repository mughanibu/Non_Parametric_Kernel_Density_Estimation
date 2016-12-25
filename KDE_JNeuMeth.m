clc; clear;close all;
rng(0,'twister');
format long;
% DNSM
[features, labels, raw] = xlsread('DNSM_N8M16_Segmented.xlsx',1);
% HOG
[hog_features,~, ~] = xlsread('HOG_SegROI_C_5_B_2_O_1_N_9_USO_T.csv',1);

% Concatenating feature sets
features = [features,hog_features];
% Standarize the features
features = zscore(features);

X = cell2mat(labels(1:end,1));
%% K-Fold Cross Validation
K = 10; %
indices = crossvalind('Kfold',X,K);
testData=[];
testLabels = [];
confusionMatrix_KDE = zeros(2,2);
class = [];
acc = [];
idx = 1;
pred =[];
nn_pred = [];
nn_acc = [];
dt_pred = [];
dt_acc = [];
label_hat_svm = [];
cont_acc = 0;
cont_total = 0;
for k = 1:K
    c = [];
    test = (indices == k);
    train = ~test;
    testData = [testData, find(test)'];
    [trainFt,testFt,trainX,testX ] = splitTrainTest( features, X, train);        
    %% Compute Kernel Size
    distMtx = zeros(size(trainFt,1));
    for i = 1: size(trainFt,1)
        distMtx(:,i) = computeDist(trainFt(i,:), trainFt);
        [~,~,ker_size(i)] = ksdensity(distMtx(:,i));
    end
    % KSize: Bracket Method
    s1 = min(ker_size);
    s2 = max(ker_size);
    numShapes = size(trainFt,1);
    for i=1:10
        s3=(s1+s2)/2;
        x3=g_score(distMtx,numShapes,s3);
        if x3 >0
            s1=s3;
        else
            s2=s3;
        end
    end
    ksize = (s1+s2)/2;
    
    % Split Mushroom, Stubby, and Thin Feature sets
    mi = 1; si = 1; ti =1;
    trainFt_m = [];
    trainFt_s = [];
    trainFt_t = [];
    for ii = 1:size(trainFt,1)
        if trainX(ii) == 1
            trainFt_m(mi,:) = trainFt(ii,:);
            mi = mi+1;
        elseif trainX(ii) == 2
            trainFt_s(si,:) = trainFt(ii,:);
            si = si+1;
        elseif trainX(ii) == 3
            trainFt_t(ti,:) = trainFt(ii,:);
            ti = ti+1;
        end
    end
  
    lrt = [];
    %% For testing: compute likelihoods for all test samples.
    for t = 1: size(testFt,1)
        
        dist_m = computeDist(testFt(t,:), trainFt_m);
        dist_s = computeDist(testFt(t,:), trainFt_s);
        dist_t = computeDist(testFt(t,:), trainFt_t);
        
        p_m = normpdf(dist_m,0,ksize);
        p_s = normpdf(dist_s,0,ksize);
        p_t = normpdf(dist_t,0,ksize);
        
        lik_m(idx) = sum(p_m)/length(p_m);
        lik_s(idx) = sum(p_s)/length(p_s);
        lik_t(idx) = sum(p_t)/length(p_t);
        
        L_s(idx) = (lik_s(idx) / lik_m(idx));
        L_t(idx) = (lik_t(idx) / lik_m(idx));
        
        %%Classification Using KDE
        if (L_s(idx) > 1) && (L_s(idx) > L_t(idx))
            c(t) = 2;
        elseif (L_t(idx) > 1) && (L_t(idx) > L_s(idx))
            c(t) = 3;
            else
            c(t) = 1;
        end
        
        idx = idx + 1;
    end
    
    %% Compute Accuracy for KDE based classification
    for test = 1: length(c)
        predClass = c(test);
        class = [class predClass];
        testLabels = [testLabels,testX(test)];
        if predClass == testX(test)
            acc = [acc 1];
        end
    end
end

KDE_Accuracy = sum(acc)/length(testLabels)*100
confusionMatrix_KDE = confusionmat(testLabels, class)

ht = [L_s;L_t]';
% to print histogram of 2D lr-space
figure;
hist3(ht(find(testLabels == 1),:),{0:0.5:2 0:0.5:2},'FaceColor','red','FaceAlpha',.65); hold on;
hist3(ht(find(testLabels == 2),:),{0:0.5:2 0:0.5:2},'FaceColor','yellow','FaceAlpha',0.65); hold on;
hist3(ht(find(testLabels == 3),:),{0:0.5:2 0:0.5:2},'FaceColor','blue','FaceAlpha',.65); hold on;grid;
legend('Mushroom','Stubby','Thin');
xlabel('L_s');
ylabel('L_t');
grid on;
set(gcf,'renderer','opengl');
% 
% 
ht_m = ht(testLabels==1,:);
ht_s = ht(testLabels==2,:);
ht_t = ht(testLabels==3,:);


%% MANOVA test
[d,p,stats] = manova1([L_s;L_t]',testLabels');

m_s = [ht_m;ht_s]; labels_m_s = [testLabels(testLabels==1),testLabels(testLabels==2)]; 
m_t = [ht_m;ht_t]; labels_m_t = [testLabels(testLabels==1),testLabels(testLabels==3)]; 
s_t = [ht_t;ht_s]; labels_s_t = [testLabels(testLabels==3),testLabels(testLabels==2)]; 
[d,p] = manova1([m_s;m_s],[labels_m_s';labels_m_s'])
[d,p] = manova1(m_t,labels_m_t')
[d,p] = manova1(s_t,labels_s_t')

% %% t-test
[H, pValue, KSstatistic] = kstest_2s_2d(ht_m, ht_s, 0.05)
[H, pValue, KSstatistic] = kstest_2s_2d(ht_m, ht_t, 0.05)
[H, pValue, KSstatistic] = kstest_2s_2d(ht_t, ht_s, 0.05)