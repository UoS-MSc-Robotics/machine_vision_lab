% Copyright (c) 2024 Leander Stephen D'Souza

% Program to implement Google LeNet CNN for Image Classification for the Digit Dataset

% define constants
image_size = [32, 32];

% Load the digit dataset
digitDatasetPath = fullfile(toolboxdir('nnet'), 'nndemos', ...
    'nndatasets', 'DigitDataset');
%
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders', true, 'LabelSource', 'foldernames');

imds.ReadFcn = @(loc)imresize(imread(loc), image_size);

% Split the data into training and validation datasets
[imdsTrain, imdsValidation] = splitEachLabel(imds, 0.7, 'randomized');

% Define the LeNet-5 architecture
filterSize = 5;
numFilters = 16;
fullyConnectedLayerSize = 64;
l1_reg = 0.0001;
l2_reg = 0.0001;
num_classes = 10;

layers = [
    imageInputLayer([image_size 1])

    % Hidden Layer 1
    convolution2dLayer(filterSize, numFilters,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'Stride',2)

    % Hidden Layer 2
    convolution2dLayer(filterSize, numFilters,'Padding','same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2,'Stride',2)

    fullyConnectedLayer(fullyConnectedLayerSize, ...
        'WeightLearnRateFactor', l1_reg, 'BiasLearnRateFactor', l1_reg, ...
        'WeightL2Factor', l2_reg, 'BiasL2Factor', l2_reg)
    dropoutLayer(0.2)

    fullyConnectedLayer(num_classes)
    softmaxLayer

    classificationLayer
];

% Specify the training options
options = trainingOptions('adam', ...
    'InitialLearnRate',0.001, ...
    'MaxEpochs',10, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress', ...
    'ExecutionEnvironment', 'gpu');

 % Train the network
net = trainNetwork(imdsTrain,layers,options);

% Classify validation images and compute accuracy
YPred = classify(net,imdsValidation);
YValidation = imdsValidation.Labels;
accuracy = sum(YPred == YValidation)/numel(YValidation);
fprintf('Accuracy of the network on the validation images: %f\n', accuracy);

% Calculate the confusion matrix
confusionMatrix = confusionmat(YValidation, YPred);

% Display the confusion matrix as a heatmap
figure;
heatmap(confusionMatrix);
title('Confusion Matrix');
xlabel('Predicted Class');
ylabel('True Class');

% Calculate precision, recall, and F1 score for each class
precision = diag(confusionMatrix) ./ sum(confusionMatrix, 2);
recall = diag(confusionMatrix) ./ sum(confusionMatrix, 1)';
f1Score = 2 * (precision .* recall) ./ (precision + recall);

% Display the precision, recall, and F1 score for each class
for i = 1:num_classes
    fprintf('Class %d: Precision = %f, Recall = %f, F1 Score = %f\n', i, precision(i), recall(i), f1Score(i));
end
