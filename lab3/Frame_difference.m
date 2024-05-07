% Copyright (c) 2024 Leander Stephen D'Souza

% Program to analyze background subtraction using frame difference

close all; clear; clc; % clear the workspace

% read the video
source = VideoReader('car-tracking.mp4');

% set the threshold
thresh_arr = [10, 25];
n_cols = 2;
n_rows = 1 + length(thresh_arr) / n_cols;

figure
set(gcf,'WindowState','maximized');

for i = 1:length(thresh_arr)
    % call the function to subtract the background
    source.CurrentTime = 0; % reset the video to the beginning
    frame_difference(source, thresh_arr(i), n_rows, n_cols, i); % call the function to subtract the background
end


% function to subtract the background
function frame_difference(source, thresh, n_rows, n_cols, i)
    % read the first frame of the video as a background model
    bg = readFrame(source);
    bg_bw = rgb2gray(bg);           % convert background to greyscale

    frame_counter = 0;              % initialize the frame counter
    frame_break = 140;

    % --------------------- process frames -----------------------------------
    % loop all the frames
    while hasFrame(source)
        frame_counter = frame_counter + 1; % increment the frame counter

        if frame_counter > frame_break
            break;
        end

        fr = readFrame(source);     % read in frame
        fr_bw = rgb2gray(fr);       % convert frame to grayscale
        fr_diff = abs(double(fr_bw) - double(bg_bw));  % cast operands as double to avoid negative overflow

        % if fr_diff > thresh pixel in foreground
        fg = uint8(zeros(size(bg_bw)));
        fg(fr_diff > thresh) = 255;

        % update the background model
        bg_bw = fr_bw;

        % visualise the results and label the frame number with titles
        subplot(n_rows, n_cols, 1), imshow(fr), title('Original Frame')
        subplot(n_rows, n_cols, i + 2), imshow(fg), title('Foreground Pixels at Frame: ' + string(frame_counter) + ' with threshold: ' + string(thresh))
        drawnow;
    end
end
