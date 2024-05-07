% Copyright (c) 2024 Leander Stephen D'Souza

% Program to analyze background subtraction using frame difference

close all; clear; clc; % clear the workspace

% read the video
source = VideoReader('car-tracking.mp4');

% set the threshold
thresh = 25;

% call the function to subtract the background
frame_difference(source, thresh); % call the function to subtract the background



% function to subtract the background
function frame_difference(source, thresh)
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
        figure(1), subplot(1,2,1), imshow(fr), title('Original Frame')
        subplot(1,2,2), imshow(fg), title('Foreground Pixels at Frame: ' + string(frame_counter) + ' with threshold: ' + string(thresh))
        drawnow;
    end
end
