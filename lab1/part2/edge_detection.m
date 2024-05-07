% Copyright (c) 2024 Leander Stephen D'Souza

% Program to test Edge Detection and Segmentation of Static Objects


og_image = imread('duckMallardDrake.jpg');

% Edge Detection
edge_detection_analysis(og_image);


function edge_detection_analysis(img)
    % 1. Apply Sobel Edge Detection
    sobel_edge_image = edge(rgb2gray(img), 'sobel', 0.1);

    % 2. Apply Cany Edge Detection
    canny_edge_image = edge(rgb2gray(img), 'canny', 0.15);

    % 3. Apply Prewitt Edge Detection
    prewitt_edge_image = edge(rgb2gray(img), 'prewitt', 0.05);

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
