function segmented = ImgSegDB(image);
colorImage = imread(image);
I = rgb2gray(colorImage);

% Detect MSER regions.
[mserRegions, mserConnComp] = detectMSERFeatures(I, ...
    'RegionAreaRange',[200 80000],'ThresholdDelta',4);

% Use regionprops to measure MSER properties
mserStats = regionprops(mserConnComp, 'BoundingBox', 'Eccentricity', ...
    'Solidity', 'Extent', 'Euler', 'Image');

% Compute the aspect ratio using bounding box data.
bbox = vertcat(mserStats.BoundingBox);
w = bbox(:,3);
h = bbox(:,4);
aspectRatio = w./h;

% Get bounding boxes for all the regions
bboxes = vertcat(mserStats.BoundingBox);

% Convert from the [x y width height] bounding box format to the [xmin ymin
% xmax ymax] format for convenience.
xmin = bboxes(:,1);
ymin = bboxes(:,2);
xmax = xmin + bboxes(:,3) - 1;
ymax = ymin + bboxes(:,4) - 1;

% Expand the bounding boxes by a small amount.
expansionAmount = 0.02;
xmin = (1-expansionAmount) * xmin;
ymin = (1-expansionAmount) * ymin;
xmax = (1+expansionAmount) * xmax;
ymax = (1+expansionAmount) * ymax;

% Clip the bounding boxes to be within the image bounds
xmin = max(xmin, 1);
ymin = max(ymin, 1);
xmax = min(xmax, size(I,2));
ymax = min(ymax, size(I,1));

% Show the expanded bounding boxes
expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
IExpandedBBoxes = insertShape(colorImage,'Rectangle',expandedBBoxes,'LineWidth',3);
recog = [ ];

if length(mserStats) > 1
    i=length(mserStats);
    subImage{i} = imcrop(colorImage,expandedBBoxes(i,:));
    detect = [feature_extractor_2d(subImage{i});feature_extractor(subImage{i})];
    load networknumber
    output = sim( net , detect );
    detect = vec2ind(output)-1;
else
    i=1;
    subImage{i} = imcrop(colorImage,expandedBBoxes(i,:));
    detect = [feature_extractor_2d(subImage{i});feature_extractor(subImage{i})];
    load networknumber
    output = sim( net , detect );
    detect = vec2ind(output)-1;
end

segmented= detect;