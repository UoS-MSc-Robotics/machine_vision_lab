% Copyright (c) 2024 Leander Stephen D'Souza

% Program to implement Treasure Hunting using Arrow Detection


%% Treasure Hunting
treasure_hunter(imread('Treasure_easy.jpg'));


% Function to implement Treasure Hunting
function treasure_hunter(img)
    % Show image
    imshow(img);
    pause(0.5);

    % Binarisation
    bin_img = imbinarize(rgb2gray(img), 0.1);
    imshow(bin_img);
    pause(0.5);

    % Extracting connected components
    con_com = logical(bwlabel(bin_img));
    imshow(label2rgb(con_com));
    pause(0.5);

    % Computing objects properties
    props = regionprops(con_com);

    % Drawing bounding boxes
    n_objects = numel(props);
    imshow(img);
    hold on;
    for object_id = 1 : n_objects
        rectangle('Position', props(object_id).BoundingBox, 'EdgeColor', 'b');
    end
    hold off;
    pause(0.5);

    % Finding arrows
    arrow_ind = arrow_finder(props, img);

    disp(arrow_ind);

    % Finding red arrow (start point)
    n_arrows = numel(arrow_ind);
    start_arrow_id = 0;
    % check each arrow until find the red one
    for arrow_num = 1 : n_arrows
        object_id = arrow_ind(arrow_num);    % determine the arrow id

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
    path = cur_object;

    % while the current object is an arrow, continue to search
    while ismember(cur_object, arrow_ind)
        if cur_object == arrow_ind(end)
            break;
        end
        % find the next closest arrow
        cur_object = next_object_finder(cur_object, props, arrow_ind, img);
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
function arrow_ind = arrow_finder(props, img)
    n_objects = numel(props);
    arrow_ind = zeros(1, n_objects);
    min_length = 5;
    arrow_count = 0;

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
                arrow_ind(arrow_count) = object_id;
            end
        end
    end
    % remove unnecessary zeros
    arrow_ind = arrow_ind(1 : arrow_count);
end

% Function to find the next object in the path
function cur_object = next_object_finder(cur_object, props, arrow_ind, img)
    % find the index of the current object in the arrow_ind array
    cur_object_idx = find(arrow_ind == cur_object);

    % get the bounding box of the current object
    cur_bbox = props(cur_object).BoundingBox;

    % get the centroid of the current object
    cur_centroid = props(cur_object).Centroid;

    % get the yellow point inside the bounding box using masking
    red = img(:,:,1);
    green = img(:,:,2);
    blue = img(:,:,3);

    top_left_x = round(cur_bbox(1));
    top_left_y = round(cur_bbox(2));
    length = round(cur_bbox(3));
    breadth = round(cur_bbox(4));

    mask = (red > 200) & (green > 200) & (blue < 100);  % Create a mask for the yellow point
    mask = mask(top_left_y : top_left_y + breadth, top_left_x : top_left_x + length);  % Crop the mask to the bounding box

    % find the centroid of the yellow point
    stats = regionprops('table', mask, 'Centroid');
    if isempty(stats)
        error('No yellow point found in the bounding box');
    end
    yellow_centroid = stats.Centroid(1, :);
    yellow_centroid = yellow_centroid + [cur_bbox(1), cur_bbox(2)];  % Translate the centroid to the image coordinates

    % Construct a vector using the centroid of the yellow point and the centroid of the current object
    cur_vector = yellow_centroid - cur_centroid;

    min_distance = inf;
    start_point = false;

    % iterate over all items of arrow_ind, taking the current object as the starting point
    for arrow_num = cur_object_idx + 1 : numel(arrow_ind)
        object_id = arrow_ind(arrow_num); % determine the object id

        % get the bounding box of the current object
        bbox = props(object_id).BoundingBox;

        % get the centroid of the current object
        centroid = props(object_id).Centroid;

        distance = norm(centroid - cur_centroid); % calculate the distance between the centroids

        % if the distance is less than the minimum distance, update the minimum distance and the current object
        if distance < min_distance
            min_distance = distance;
            cur_object = object_id;
        end
    end


end
