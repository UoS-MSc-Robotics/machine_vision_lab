% Copyright (c) 2024 Leander Stephen D'Souza

% Program to analyze Optical Flow in a Video Sequence
clc; clear; close all;

% Task 1: Find Corner Points
% find_corner_points(imread('red_square_static.jpg'), 'Red Square');
find_corner_points(imread('GingerBreadMan_first.jpg'), 'Ginger Bread Man');

% % Task 2: Optical Flow
first_image = imread('GingerBreadMan_first.jpg');
second_image = imread('GingerBreadMan_second.jpg');
estimate_optical_flow(first_image, second_image);

% % Task 3: Optical Flow in Video Sequence
video = VideoReader('red_square_video.mp4');
ground_truth = load('new_red_square_gt.mat');
% optical_flow_video(video, ground_truth);


% Function to analyze the optical flow in a video sequence
function optical_flow_video(video, ground_truth)
    % Read the video frames
    video_frames = read(video);
    num_frames = video.NumFrames;

    % Create an optical flow object
    opticalFlow = opticalFlowLK('NoiseThreshold', 0.009);

    % Load the actual corner trajectory
    actual_trajectory = cell2mat(struct2cell(ground_truth));

    % Save all the estimated trajectory of the corner points
    predicted_trajectory = zeros(num_frames - 1, 2);

    % Initialize the corner points
    first_frame = rgb2gray(video_frames(:,:,:,1));
    corners = corner(first_frame, 'Harris');
    corner_x = corners(1, 1);
    corner_y = corners(1, 2);

    % Initialize flow
    flow = estimateFlow(opticalFlow, first_frame);

    % Initialize corner trajectory
    vx = flow.Vx(round(corner_y), round(corner_x));
    vy = flow.Vy(round(corner_y), round(corner_x));

    % Compute the new position by adding the velocity vector to the current position
    x_new = corner_x + vx;
    y_new = corner_y + vy;
    predicted_trajectory(1, :) = [x_new, y_new];

    % Iterate through the video frames
    for i = 2:num_frames
        % Read the current frame
        current_frame = rgb2gray(video_frames(:,:,:,i));

        % Detect corners in the current frame
        corners = corner(current_frame, 'Harris');

        % Find the nearest corner to the previous corner
        min_dist = 1000000;
        for j = 1:size(corners, 1)
            dist = sqrt((corners(j, 1) - x_new)^2 + (corners(j, 2) - y_new)^2);
            if dist < min_dist
                min_dist = dist;
                nearest_corner = corners(j, :);
            end
        end

        % Update the corner position
        corner_x = nearest_corner(1);
        corner_y = nearest_corner(2);

        % Estimate the optical flow for the current frame
        flow = estimateFlow(opticalFlow, current_frame);

        % Compute the new position by adding the velocity vector to the current position
        vx = flow.Vx(round(corner_y), round(corner_x));
        vy = flow.Vy(round(corner_y), round(corner_x));

        % Update the track with the new position
        predicted_trajectory(i, :) = [corner_x + vx, corner_y + vy];
    end

    % Plot the estimated corner trajectory and the actual corner trajectory
    last_frame = video_frames(:,:,:,num_frames);

    imshow(last_frame);
    hold on
    plot(predicted_trajectory(:, 1), predicted_trajectory(:, 2), 'r');
    plot(actual_trajectory(:, 1), actual_trajectory(:, 2), 'b');
    title('Estimated vs Actual Corner Trajectory');
    xlabel('X');
    ylabel('Y');
    legend('Estimated Trajectory', 'Actual Trajectory');
    hold off

    % Get RMSEx, RMSEy, and RMSE
    for i = 1:num_frames-1
        RMSE_x(i) = sqrt((actual_trajectory(i+1, 1) - predicted_trajectory(i, 1)) ^ 2);
        RMSE_y(i) = sqrt((actual_trajectory(i+1, 2) - predicted_trajectory(i, 2)) ^ 2);
        RMSE(i) = sqrt((actual_trajectory(i+1, 1) - predicted_trajectory(i, 1)) ^ 2 + ...
                        (actual_trajectory(i+1, 2) - predicted_trajectory(i, 2)) ^ 2);
    end

    % Plot the RMSE values
    figure;
    plot(2:num_frames, RMSE_x, 'b');
    hold on;
    plot(2:num_frames, RMSE_y, 'r');
    plot(2:num_frames, RMSE, 'g');
    title('RMSE Values');
    xlabel('Frame Number');
    ylabel('RMSE');
    legend('RMSE_x', 'RMSE_y', 'RMSE');
    hold off;

    % Print the RMSE values
    fprintf('RMSE_x: %f\n', mean(RMSE_x));
    fprintf('RMSE_y: %f\n', mean(RMSE_y));
    fprintf('RMSE: %f\n', mean(RMSE));
end


% Function to estimate the optical flow between two images
function estimate_optical_flow(first_image, second_image)
    % Convert the images to grayscale
    first_image_gray = rgb2gray(first_image);
    second_image_gray = rgb2gray(second_image);

    % Find the optical flow of the pixels between the two images
    opticalFlow = opticalFlowLK('NoiseThreshold', 0.01);

    % The object stores the vectors from the first image to the second image
    estimateFlow(opticalFlow, first_image_gray);
    flow = estimateFlow(opticalFlow, second_image_gray);

    % Plot the optical flow on the second image
    figure;
    imshow(second_image);
    hold on;
    plot(flow, 'DecimationFactor', [5 5], 'ScaleFactor', 15);
    title('Optical Flow between the two images');
    hold off;

    % Plot the optical flow vectors
    figure;
    plot(flow);
    xlabel('X');
    ylabel('Y');
    legend('Optical Flow Vectors from the first image to the second image');
    title('Optical Flow Change');
end


% Function to find the corner points in an image
function find_corner_points(img, title_name)
    % Convert the image to grayscale
    img_gray = rgb2gray(img);

    % Find the corner points in the image
    corners = detectHarrisFeatures(img_gray);

    % Save the strongest corner points
    strongest_corners = corners.selectStrongest(50);

    % Plot the image with the corner points
    figure;
    imshow(img);
    hold on;
    plot(strongest_corners.Location(:, 1), strongest_corners.Location(:, 2), 'g+', 'MarkerSize', 15, 'LineWidth', 3);
    title("Corner Points in " + title_name);
    hold off;
end




