% Copyright (c) 2024 Leander Stephen D'Souza

% Program to implement Treasure Hunting using Arrow Detection


%% Treasure Hunting
% treasure_hunter(imread('Treasure_easy.jpg'));
% treasure_hunter(imread('Treasure_medium.jpg'));
treasure_hunter(imread('Treasure_hard.jpg'));


% Function to implement Treasure Hunting
function treasure_hunter(img)
    % Show image
    % imshow(img);
    % pause(0.5);

    % Binarisation
    bin_img = imbinarize(rgb2gray(img), 0.1);
    % imshow(bin_img);
    % pause(0.5);

    % Extracting connected components
    con_com = logical(bwlabel(bin_img));
    % imshow(label2rgb(con_com));
    % pause(0.5);

    % Computing objects properties
    props = regionprops(con_com);

    % Drawing bounding boxes
    n_objects = numel(props);
    % imshow(img);
    % hold on;
    % for object_id = 1 : n_objects
    %     rectangle('Position', props(object_id).BoundingBox, 'EdgeColor', 'b');
    % end
    % hold off;
    % pause(0.5);

    % Finding arrows
    [arrow_list, treasure_list] = arrow_finder(props, img);
    disp(arrow_list);
    disp(treasure_list);
    all_boxes_list = [arrow_list, treasure_list];
    disp(all_boxes_list);


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

    % while the current object is an arrow, continue to search
    while ismember(cur_object, arrow_list)
        % find the next closest arrow
        cur_object = next_object_finder(cur_object, props, all_boxes_list, img, path);
        path(end + 1) = cur_object;
    end

    % visualisation of the path
    imshow(img);
    hold on;

    for path_element = 1 : numel(path) - 1
        object_id = path(path_element); % determine the object id
        rectangle('Position', props(object_id).BoundingBox, 'EdgeColor', 'y');
        str = num2str(path_element);
        text(props(object_id).BoundingBox(1), props(object_id).BoundingBox(2), str, 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 14);
    end
    % visualisation of the treasure
    treasure_id = path(end);
    rectangle('Position', props(treasure_id).BoundingBox, 'EdgeColor', 'g');

    hold off;
    pause(0.5);
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
function cur_object = next_object_finder(cur_object, props, all_boxes_list, img, path)
    % get the bounding box of the current object
    cur_bbox = props(cur_object).BoundingBox;

    % get the centroid of the current object
    cur_centroid = props(cur_object).Centroid;

    % find the closest object to the current object
    min_dist = inf;
    min_angle = inf;
    cur_object = 0;

    for object_idx = 1 : numel(all_boxes_list)
        object = all_boxes_list(object_idx);
        % check if the object is not in the path
        if ~ismember(object, path)
            % get the bounding box of the object
            bbox = props(object).BoundingBox;

            % get the centroid of the object
            centroid = props(object).Centroid;

            % compute the distance between the current object and the object
            dist = norm(cur_centroid - centroid);

            % check if the object is closer than the current closest object
            if dist < min_dist
                min_dist = dist;
                cur_object = object;
            end
        end
    end
end
