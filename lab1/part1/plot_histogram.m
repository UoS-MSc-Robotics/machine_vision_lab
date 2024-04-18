% Copyright (c) 2024 Leander Stephen D'Souza

% Program to plot rgb histogram of an image

% Call the function with an example images
plot_rgb_histogram(imread('duckMallardDrake.jpg'));
plot_rgb_histogram(imread('Dog.jpg'));


% Function to plot rgb histogram of an image
function plot_rgb_histogram(img)
    % Get the size of the image
    [rows, cols, channels] = size(img);

    % Check if the image is rgb
    if channels ~= 3
        disp('The image is not an rgb image');
        return;
    end

    % Initialize the histogram
    histogram = zeros(256, 3);

    % Calculate the histogram using imhist
    for k = 1:channels
        histogram(:, k) = imhist(img(:, :, k));
    end

    % Display the image and histogram in a single figure
    figure;
    subplot(1, 2, 1);
    imshow(img);
    title('Original Image');

    subplot(1, 2, 2);
    bar(histogram(:, 1), 'r');
    hold on;
    bar(histogram(:, 2), 'g');
    bar(histogram(:, 3), 'b');
    title('RGB Histogram');
    xlabel('Intensity');
    ylabel('Frequency');
    legend('Red', 'Green', 'Blue');
end
