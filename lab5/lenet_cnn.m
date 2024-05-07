% Copyright (c) 2024 Leander Stephen D'Souza

% Program to implement Google LeNet CNN for Image Classification for the Digit Dataset
close all; clear; clc;

% define constants
image_size = [32, 32];
num_classes = 10;

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
[lenet_layers, lenet_options] = lenet_architecture(image_size, num_classes, imdsValidation);

% Define custom architecture
[custom_layers, custom_options] = custom_architecture(image_size, num_classes, imdsValidation);


for i = 1:2
    if i == 1
        layers = lenet_layers;
        options = lenet_options;
    else
        layers = custom_layers;
        options = custom_options;
    end

    % Train the network
    net = trainNetwork(imdsTrain, layers, options);

    % Classify validation images and compute accuracy
    YPred = classify(net, imdsValidation);
    YValidation = imdsValidation.Labels;
    accuracy = sum(YPred == YValidation) / numel(YValidation);
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

    % Display the precision, recall, and F1 score
    fprintf('Precision: %f\n', mean(precision));
    fprintf('Recall: %f\n', mean(recall));
    fprintf('F1 Score: %f\n', mean(f1Score));

    % Display the precision, recall, and F1 score for each class
    disp("precision" + precision);
    disp("recall" + recall);
    disp("f1Score" + f1Score);

end

% Function to define the LeNet-5 architecture
function [layers, options] = lenet_architecture(image_size, num_classes, validation_data)
    % Define the LeNet-5 architecture
    layers = [
        imageInputLayer([image_size 1],'Name','input')

        convolution2dLayer(5,6,'Padding','same','Name','conv_1')
        averagePooling2dLayer(2,'Stride',2,'Name','avgpool_1')

        convolution2dLayer(5,16,'Padding','same','Name','conv_2')
        averagePooling2dLayer(2,'Stride',2,'Name','avgpool_2')

        fullyConnectedLayer(120,'Name','fc_1')
        fullyConnectedLayer(84,'Name','fc_2')

        fullyConnectedLayer(num_classes, 'Name', 'fc_3')
        softmaxLayer('Name','softmax')
        classificationLayer('Name','output')
    ];

    % Specify the training options
    options = trainingOptions('sgdm', ...
        'InitialLearnRate',0.0001, ...
        'MaxEpochs',10, ...
        'Shuffle','every-epoch', ...
        'ValidationData', validation_data, ...
        'ValidationFrequency',30, ...
        'Verbose',false, ...
        'Plots','training-progress', ...
        'ExecutionEnvironment', 'gpu');
end

% Function to define a custom architecture
function [layers, options] = custom_architecture(image_size, num_classes, validation_data)
    % Define the custom architecture
    filterSize = 5;
    numFilters = 16;
    fullyConnectedLayerSize = 64;
    l2_reg = 0.0001;

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
        'ValidationData', validation_data, ...
        'ValidationFrequency',30, ...
        'Verbose',false, ...
        'Plots','training-progress', ...
        'ExecutionEnvironment', 'gpu');

end


