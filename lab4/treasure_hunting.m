% Copyright (c) 2024 Leander Stephen D'Souza

% Program to implement Treasure Hunting using Arrow Detection
clear; clc; close all;

%% Treasure Hunting
treasure_hunter(imread('Treasure_easy.jpg'));
treasure_hunter(imread('Treasure_medium.jpg'));
treasure_hunter(imread('Treasure_hard.jpg'));


% Function to implement Treasure Hunting
function treasure_hunter(img)
    figure;

    % Show image
    subplot(2, 3, 1);
    imshow(img);
    title('Original Image');

    % Binarisation
    bin_img = imbinarize(rgb2gray(img), 0.1);
    subplot(2, 3, 2);
    imshow(bin_img);
    title('Binary Image');


    % Extracting connected components
    con_com = logical(bwlabel(bin_img));
    subplot(2, 3, 3);
    imshow(label2rgb(con_com));
    title('Connected Components');

    % Computing objects properties
    props = regionprops(con_com);

    % Drawing bounding boxes
    n_objects = numel(props);
    subplot(2, 3, 4);
    imshow(img);
    hold on;
    for object_id = 1 : n_objects
        rectangle('Position', props(object_id).BoundingBox, 'EdgeColor', 'w');
    end
    hold off;
    title('Bounding Boxes');


    % Finding arrows
    [arrow_list, treasure_list] = arrow_finder(props, img);
    all_boxes_list = [arrow_list, treasure_list];

    % Finding red arrow (start point)
    n_arrows = numel(arrow_list);
    start_arrow_id = 0;
    % check each arrow until find the red one
    for arrow_num = 1 : n_arrows
        object_id = arrow_list(arrow_num);    % determine the arrow id

        % extract colour of the centroid point of the current arrow
        centroid_colour = img(round(props(object_id).Centroid(2)), round(props(object_id).Centroid(1)), :);

        red = centroid_colour(:, :, 1);
        green = centroid_colour(:, :, 2);
        blue = centroid_colour(:, :, 3);

        if red > 240 && green < 10 && blue < 10
        % the centroid point is red, memorise its id and break the loop
            start_arrow_id = object_id;
            break;
        end
    end

    % Hunting
    cur_object = start_arrow_id; % start from the red arrow
    path = cur_object; % memorise the path

    for treasure_idx = 1 : numel(treasure_list)
        % while the current object is an arrow, continue to search
        while ismember(cur_object, arrow_list)
            % find the next closest arrow
            prev_object = cur_object;
            cur_object = next_object_finder(cur_object, props, all_boxes_list, img, path);
            path(end + 1) = cur_object;
        end
        % Found treasure
        cur_object = prev_object;
        break;
    end

    % helper variable for drawing the treasure
    treasure_counter = 0;
    treasure_found = false;
    treasure_offset = 0;

    % visualisation of the path
    subplot(2, 3, 5);
    imshow(img);
    hold on;

    for path_element = 1 : numel(path)
        object_id = path(path_element); % determine the object id

        % reset for treasure
        if ismember(object_id, treasure_list)
            treasure_counter = treasure_counter + 1;
            treasure_found = true;
            rectangle('Position', props(object_id).BoundingBox, 'EdgeColor', 'g');
            str = num2str(treasure_counter);
            text(props(object_id).BoundingBox(1), props(object_id).BoundingBox(2), str, 'Color', 'g', 'FontWeight', 'bold', 'FontSize', 14);
            continue;
        end

        if treasure_found
            treasure_found = false;
            treasure_offset = 1;
            continue;
        end

        rectangle('Position', props(object_id).BoundingBox, 'EdgeColor', 'y');
        str = num2str(path_element - treasure_counter - treasure_offset);
        text(props(object_id).BoundingBox(1), props(object_id).BoundingBox(2), str, 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 14);
    end

    hold off;
    title('Treasure Path - Intermediate');
end

% Function to find the arrow objects
function [arrow_list, treasure_list] = arrow_finder(props, img)
    n_objects = numel(props);
    arrow_list = zeros(1, n_objects);
    treasure_list = zeros(1, n_objects);
    min_length = 5;
    treasure_min_area = 3014;
    arrow_count = 0;
    treasure_count = 0;

    % iterate over all objects
    for object_id = 1 : n_objects
        % extract the bounding box of the current object
        bbox = props(object_id).BoundingBox;

        % extract the length and breadth of the bounding box
        length = bbox(3);
        breadth = bbox(4);

        % check if the object is of sufficient size
        if breadth > min_length && length > min_length
            % extract the centroid of the current object, if the colour of the centroid is white, then it is an arrow
            centroid_colour = img(round(props(object_id).Centroid(2)), round(props(object_id).Centroid(1)), :);

            red = centroid_colour(:, :, 1);
            green = centroid_colour(:, :, 2);
            blue = centroid_colour(:, :, 3);

            % Use the fact that the arrow is red or white
            if (red > 240 && green > 240 && blue > 240) || (red > 240 && green < 10 && blue < 10)
                arrow_count = arrow_count + 1;
                arrow_list(arrow_count) = object_id;
            elseif props(object_id).Area > treasure_min_area
                treasure_count = treasure_count + 1;
                treasure_list(treasure_count) = object_id;
            end
        end
    end
    % remove unnecessary zeros
    arrow_list = arrow_list(1 : arrow_count);
    treasure_list = treasure_list(1 : treasure_count);
end

% Function to find the next object in the path
function [cur_object] = next_object_finder(cur_object, props, all_boxes_list, img, path)
    % get the bounding box of the current object
    bbox_cur_object = props(cur_object).BoundingBox;

    % calculate the current yellow centroid
    cur_yellow_centroid = get_yellow_centroid(img, bbox_cur_object);

    % find the closest object to the current object
    min_dist = inf;
    critical_dist = 100;
    treasure_area = 3014;
    cur_object = 0;

    for object_idx = 1 : numel(all_boxes_list)
        object = all_boxes_list(object_idx);
        % check if the object is not in the path
        if ~ismember(object, path)
            % get the centroid of the object
            object_centroid = props(object).Centroid;

            % get the distance between the current object and the object
            dist = norm(cur_yellow_centroid - object_centroid);

            % get area
            if props(object).Area > treasure_area
                % monitor intermediate treasure distance
                if dist < critical_dist
                    critical_dist = dist;
                    cur_object = object;
                end
            end

            % check if the object is the closest object
            if dist < min_dist
                min_dist = dist;
                cur_object = object;
            end
        end
    end
end

% Function to extract yellow centroid from a bounding box
function yellow_centroid = get_yellow_centroid(img, bbox)
    % extract the bounding box of the current object
    bbox = round(bbox);
    x = bbox(1);
    y = bbox(2);
    width = bbox(3);
    height = bbox(4);
    visualize = false;

    % extract the region of interest
    roi = img(y : y + height, x : x + width, :);

    % convert the region of interest to the HSV colour space
    hsv_roi = rgb2hsv(roi);

    % extract the hue, saturation and value channels
    hue = hsv_roi(:, :, 1);
    saturation = hsv_roi(:, :, 2);
    value = hsv_roi(:, :, 3);

    % threshold the hue channel to extract the yellow pixels
    yellow_mask = hue > 0.1 & hue < 0.2;

    % threshold the saturation channel to extract the yellow pixels
    yellow_mask = yellow_mask & saturation > 0.5;

    % threshold the value channel to extract the yellow pixels
    yellow_mask = yellow_mask & value > 0.5;

    % check if the yellow mask is empty
    if ~any(yellow_mask(:))
        yellow_centroid = [0, 0];
    else
        % find the centroid of the yellow pixels
        yellow_centroid = regionprops(yellow_mask, 'Centroid');
        yellow_centroid = yellow_centroid.Centroid;
        yellow_centroid = [yellow_centroid(1) + x, yellow_centroid(2) + y];

        % visualisation
        if visualize
            imshow(img);
            hold on;
            rectangle('Position', bbox, 'EdgeColor', 'r');
            plot(yellow_centroid(1), yellow_centroid(2), 'ro');
            hold off;
            pause(0.5);
        end
    end
end
