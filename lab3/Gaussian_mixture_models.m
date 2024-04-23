% Copyright (c) 2024 Leander Stephen D'Souza

% Program to analyze background subtraction using Gaussian mixture models

% read the video
source = VideoReader('car-tracking.mp4');

% create and open the object to write the results
output = VideoWriter('gmm_output.mp4', 'Motion JPEG 2000');

% variable parameters
n_frames = 10;
n_gaussians = 6;

% call the function to subtract the background
gaussian_mixture_models(source, output, n_frames, n_gaussians);



% Function to implement Gaussian Mixture Models
function gaussian_mixture_models(source, output, n_frames, n_gaussians)
    open(output); % open the output video

    detector = vision.ForegroundDetector('NumTrainingFrames', n_frames, 'NumGaussians', n_gaussians);

    % --------------------- process frames -----------------------------------
    % loop all the frames
    while hasFrame(source)
        fr = readFrame(source);     % read in frame

        fgMask = step(detector, fr);    % compute the foreground mask by Gaussian mixture models

        % create frame with foreground detection
        fg = uint8(zeros(size(fr, 1), size(fr, 2)));
        fg(fgMask) = 255;

        % visualise the results
        figure(1),subplot(2,1,1), imshow(fr)
        subplot(2,1,2), imshow(fg)
        drawnow

        writeVideo(output, fg);           % save frame into the output video
    end


    close(output); % save video
end
