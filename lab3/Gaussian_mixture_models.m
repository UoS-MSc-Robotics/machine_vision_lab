% Copyright (c) 2024 Leander Stephen D'Souza

% Program to analyze background subtraction using Gaussian mixture models

close all; clear; clc; % clear the workspace

% read the video
source = VideoReader('car-tracking.mp4');

% variable parameters
n_frames = [1, 10];
n_gaussians = [2, 20];

n_rows = length(n_frames);
n_cols = length(n_gaussians);

figure
set(gcf,'WindowState','maximized');

for i = 1:n_rows
    for j = 1:n_cols
        % call the function to subtract the background
        source.CurrentTime = 0; % reset the video to the beginning
        gaussian_mixture_models(source, n_frames(i), n_gaussians(j), n_rows + 1, n_cols, i, j); % call the function to subtract the background
    end
end


% Function to implement Gaussian Mixture Models
function gaussian_mixture_models(source, n_frames, n_gaussians, n_rows, n_cols, i, j)
    frame_counter = 0;              % initialize the frame counter
    frame_break = 140;

    detector = vision.ForegroundDetector('NumTrainingFrames', n_frames, 'NumGaussians', n_gaussians);
    % make new figure window

    % --------------------- process frames -----------------------------------
    % loop all the frames
    while hasFrame(source)
        frame_counter = frame_counter + 1; % increment the frame counter

        if frame_counter > frame_break
            break;
        end

        fr = readFrame(source);     % read in frame

        fgMask = step(detector, fr);    % compute the foreground mask by Gaussian mixture models

        % create frame with foreground detection
        fg = uint8(zeros(size(fr, 1), size(fr, 2)));
        fg(fgMask) = 255;

        % visualise the results after labelling the frame number with titles
        subplot(n_rows, n_cols, 1), imshow(fr), title('Original Frame')
        subplot(n_rows, n_cols, i * n_cols + j), imshow(fg), title('Foreground at Frame: ' + string(frame_counter) + ' with ' + string(n_frames) + ' training frames & ' + string(n_gaussians) + ' Gaussians')

        drawnow
    end
end
