% Copyright (c) 2024 Leander Stephen D'Souza

% Program to analyze Optical Flow in a Video Sequence

% Task 1: Find Corner Points
find_corner_points(imread('red_square_static.jpg'), 'Red Square');
find_corner_points(imread('GingerBreadMan_first.jpg'), 'Ginger Bread Man');

% Task 2: Optical Flow
first_image = imread('GingerBreadMan_first.jpg');
second_image = imread('GingerBreadMan_second.jpg');
estimate_optical_flow(first_image, second_image);

% Task 3: Optical Flow in Video Sequence
video = VideoReader('red_square_video.mp4');
optical_flow_video(video);


% Function to analyze the optical flow in a video sequence
function optical_flow_video(video)
    % Read the video frames
    video_frames = read(video);
    num_frames = video.NumFrames;

    % Create an optical flow object
    opticalFlow = opticalFlowLK('NoiseThreshold', 0.009);

    % Load the actual corner trajectory
    actual_trajectory = load('red_square_gt.mat');

    % Save all the estimated trajectory of the corner points
    corner_trajectory = [[], []];

    % Initialize the corner points
    corner_x = 0;
    corner_y = 0;

    % Initialize the RMSE
    individual_rmse = [];
    combined_rmse = 0;

    % Iterate through the video frames
    for i = 1:num_frames-1
        if i == 1
            % Convert the frames to grayscale
            first_frame = rgb2gray(video_frames(:,:,:,i));

            % Get all the corner points in the first frame
            corners = corner(first_frame, 'Harris');

            % get the top left corner point - manual selection
            corner_x = corners(1, 1);
            corner_y = corners(1, 2);

            % Estimate the optical flow
            estimateFlow(opticalFlow, first_frame);

            % Update the RMSE
            individual_rmse = [individual_rmse; sqrt((corner_x - actual_trajectory.gt_track_spatial(i, 1))^2 + (corner_y - actual_trajectory.gt_track_spatial(i, 2))^2)];
            combined_rmse = combined_rmse + individual_rmse(i)^2;
        end

        % Convert the next frame to grayscale
        next_frame = rgb2gray(video_frames(:,:,:,i+1));

        % Find the corner points in the next frame
        corners = corner(next_frame, 'Harris');

        % Get the corner point closest to the previous corner point
        min_dist = 1000000;

        for j = 1:4
            dist = sqrt((corners(j, 1) - corner_x)^2 + (corners(j, 2) - corner_y)^2);
            if dist < min_dist
                min_dist = dist;
                nearest_corner_x = corners(j, 1);
                nearest_corner_y = corners(j, 2);
            end
        end

        % assign the nearest corner point
        corner_x = nearest_corner_x;
        corner_y = nearest_corner_y;

        % Estimate the optical flow for this point
        flow = estimateFlow(opticalFlow, next_frame);

        % Update the corner position
        x_new = corner_x + flow.Vx(round(corner_y), round(corner_x));
        y_new = corner_y + flow.Vy(round(corner_y), round(corner_x));

        % update the corner position
        corner_x = x_new;
        corner_y = y_new;

        % Update the corner trajectory
        corner_trajectory = [corner_trajectory; [corner_x, corner_y]];

        % Update the RMSE
        individual_rmse = [individual_rmse; sqrt((corner_x - actual_trajectory.gt_track_spatial(i+1, 1))^2 + (corner_y - actual_trajectory.gt_track_spatial(i+1, 2))^2)];
        combined_rmse = combined_rmse + individual_rmse(i+1)^2;

    end

    % Plot the estimated corner trajectory and the actual corner trajectory in a single plot in the final frame of the video
    figure;
    plot(corner_trajectory(:, 1), corner_trajectory(:, 2), 'r');
    hold on;
    plot(actual_trajectory.gt_track_spatial(:, 1), actual_trajectory.gt_track_spatial(:, 2), 'b');
    title('Estimated vs Actual Corner Trajectory');
    xlabel('X');
    ylabel('Y');
    legend('Estimated Trajectory', 'Actual Trajectory');
    hold off;

    % Write the RMSE to a file
    fileID = fopen('RMSE.txt', 'w');
    fprintf(fileID, '%f\n', individual_rmse);
    fclose(fileID);

    % Print the combined RMSE
    disp("Combined RMSE: " + sqrt(mean(combined_rmse)));

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
    plot(flow, 'DecimationFactor', [5 5], 'ScaleFactor', 8);
    title('Optical Flow between the two images');
    hold off;

    % Plot the optical flow vectors
    figure;
    plot(flow);
    title('Optical Flow Vectors');
end


% Function to find the corner points in an image
function find_corner_points(img, title_name)
    % Convert the image to grayscale
    img_gray = rgb2gray(img);

    % Find the corner points in the image
    corners = detectHarrisFeatures(img_gray);

    % Plot the image with the corner points
    figure;
    imshow(img);
    hold on;
    plot(corners.selectStrongest(50));
    title("Corner Points in " + title_name);
    hold off;
end




