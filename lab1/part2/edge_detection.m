% Copyright (c) 2024 Leander Stephen D'Souza

% Program to test Edge Detection and Segmentation of Static Objects


og_image = imread('duckMallardDrake.jpg');

% Enhancement Contrast
enhance_contrast(og_image);

% Images with Different Types of Noise and Image Denoising
noise_analysis(og_image);

% Edge Detection
edge_detection_analysis(og_image);




% Function to analyze different methods to enhance contrast
function enhance_contrast(img)
    % 1. Plot RGB Histogram
    plot_rgb_histogram(img);

    % 2. Histogram Equalization
    hist_eq_image = histeq(img);
    plot_rgb_histogram(hist_eq_image);

    % 3. Gamma Correction
    gamma_image = imadjust(img, [], [], 0.5);
    plot_rgb_histogram(gamma_image);
end

% Function to analyze different types of noise
function noise_analysis(img)
    % 1. Gaussian Noise
    gaussian_noise_image = imnoise(img, 'gaussian', 0.02);

    % 2. Salt and Pepper Noise
    salt_pepper_noise_image = imnoise(img, 'salt & pepper', 0.02);

    % 3. Apply gaussian filter for both the images
    gaussian_filter_gaussian_image = imgaussfilt(gaussian_noise_image, 2);
    gaussian_filter_salt_and_pepper_image = imgaussfilt(salt_pepper_noise_image, 2);

    % 4. Apply median filter for the salt and pepper noise image
    % convert the image to grayscale
    median_filter_salt_and_pepper_image = medfilt2(rgb2gray(salt_pepper_noise_image), [3, 3]);

    % Plot all the images with appropriate titles
    figure;
    subplot(2, 3, 1);
    imshow(img);
    title('Original Image');

    subplot(2, 3, 2);
    imshow(gaussian_noise_image);
    title('Gaussian Noise Image');

    subplot(2, 3, 3);
    imshow(salt_pepper_noise_image);
    title('Salt & Pepper Noise Image');

    subplot(2, 3, 4);
    imshow(gaussian_filter_gaussian_image);
    title('Gaussian Filter on Gaussian Noise Image');

    subplot(2, 3, 5);
    imshow(gaussian_filter_salt_and_pepper_image);
    title('Gaussian Filter on Salt & Pepper Noise Image');

    subplot(2, 3, 6);
    imshow(median_filter_salt_and_pepper_image);
    title('Median Filter on Salt & Pepper Noise Image');
end

% Function to plot rgb histogram of an image
function plot_rgb_histogram(img)
    % Get the size of the image
    [~, ~, channels] = size(img);

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

function edge_detection_analysis(img)
    % 1. Apply Sobel Edge Detection
    sobel_edge_image = edge(rgb2gray(img), 'sobel', 0.1);

    % 2. Apply Cany Edge Detection
    canny_edge_image = edge(rgb2gray(img), 'canny', 0.1);

    % 3. Apply Prewitt Edge Detection
    prewitt_edge_image = edge(rgb2gray(img), 'prewitt', 0.1);

    % Plot all the images with appropriate titles
    figure;
    subplot(2, 2, 1);
    imshow(img);
    title('Original Image');

    subplot(2, 2, 2);
    imshow(sobel_edge_image);
    title('Sobel Edge Detection');

    subplot(2, 2, 3);
    imshow(canny_edge_image);
    title('Canny Edge Detection');

    subplot(2, 2, 4);
    imshow(prewitt_edge_image);
    title('Prewitt Edge Detection');
end
