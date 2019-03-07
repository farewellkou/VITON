DATA_ROOT = '../data';
WOMEN_DIR = '../data/women_top/';
SEGMENT_DIR = '../data/segment/';
TPS_DIR = '../data/tps/';

addpath('../shape_context/')

% Caffe Setting
% change to path of your caffe python
caffepath = '/home/kouta/caffe_ssl/matlab';

disp(caffepath);
addpath(caffepath);
caffe.reset_all();

caffemodel = '../model/segment/attention+ssl.caffemodel';
deployFile = '../model/segment/deploy.prototxt';
net = caffe.Net(deployFile, caffemodel, 'test');

image_list = fullfile(DATA_ROOT, 'test_image_list.txt');
fileID = fopen(image_list, 'r');
images = textscan(fileID, '%s %s');
human_images = string(cell2mat(images{1}))
product_images = string(cell2mat(images{2}))
sz = size(human_images, 1)

% for create tps
n_control = 10;
h = 256/2
w = 192/2

for id = 1:sz;
    disp(['Generating segment: ', human_images{id}])
    human_image = imread([WOMEN_DIR, human_images{id}]);
    im_data = human_image(:, :, [3, 2, 1]);  % permute channels from RGB to BGR
    im_data = permute(im_data, [2, 1, 3]);  % flip width and height
    im_data = single(im_data);  % convert from uint8 to single

    m = size(im_data, 1);
    n = size(im_data, 2);
    if m > n
        im_data = imresize(im_data, [640, floor(640 * n / m)], 'bilinear');  % resize im_data
    else
        im_data = imresize(im_data, [floor(640 * m / n), 640], 'bilinear');  % resize im_data
    end

    im_data(:,:,1) = im_data(:,:,1) - 104.008;  % subtract mean_data (already in W x H x C, BGR)
    im_data(:,:,2) = im_data(:,:,2) - 116.669;  % subtract mean_data (already in W x H x C, BGR)
    im_data(:,:,3) = im_data(:,:,3) - 122.675;  % subtract mean_data (already in W x H x C, BGR)

    input_data = zeros(640, 640, 3, 1, 'single');
    input_data(1:size(im_data,1),1:size(im_data,2),:,1) = im_data;
    input_data = {input_data};

    maps = net.forward(input_data);
    segment = maps{1};
    save([SEGMENT_DIR, human_images{id}(1:end-4), '.mat'], 'segment');

    product_image = imread([WOMEN_DIR, product_images{id}]); 
    disp(['Generating TPS: ', product_images{id}])
    [h0,w0,~] = size(product_image);
    %disp(h0)
    %disp(w0)
    orig_im = imresize(im2double(product_image), [h,w]);
    product_image = imresize(double(product_image(:,:,1) ~= 255 & product_image(:,:,2) ~= 255 & product_image(:,:,3) ~= 255), [h,w], 'nearest');
    product_image = imfill(product_image);
    product_image = medfilt2(product_image);

    segment_data = load([SEGMENT_DIR, human_images{id}(1:end-4), '.mat']);
    segment_data = segment_data.segment;
    %segment_data = segment_data(:, :, 1);
    [h1,w1,~] = size(segment_data)
    %if h0 > w0
    %  segment_data = segment_data(:, 1: round(641 * w0 / h0));
    %else
    %  segment_data = segment_data(1:round(641 * h0 / w0), :);
    %end
    if h0 > w0
      round(641 * w0 / h0)
      if (641 * w0 / h0) <  w1
        segment_data = segment_data(:, 1: round(641 * w0 / h0));
      end
    else
      if (641 * w0 / h0) <  h1
        segment_data = segment_data(1:round(641 * h0 / w0), :);
      end
    end
    segment_data = imresize(segment_data, [h, w], 'nearest');
    segment_data = double(segment_data == 5);
    %disp(size(segment_data))

    try
        [keypoints1, keypoints2, warp_points0, warp_im] = tps_main(product_image, segment_data, n_control, orig_im, 0);
    catch ME
        disp(ME)
        continue
    end
    keypoints1 = [keypoints1(:,2) / h, keypoints1(:,1) / w];
    keypoints2 = [keypoints2(:,2) / h, keypoints2(:,1) / w];

    warp_points = [warp_points0(1,:); warp_points0(2,:)];

    [gx,gy]=meshgrid(linspace(1,w,n_control),linspace(1,h,n_control));
    gx=gx(:); gy=gy(:);
    [x,y]=meshgrid(linspace(-2*w,2*w,4*w+1),linspace(-2*h,2*h,4*h+1));
    x=x(:); y=y(:);
    % nn of each point
    point_distance = dist2([gx,gy], warp_points');
    [~, point_index] = min(point_distance, [], 2);
    control_points = [x(point_index), y(point_index)]';
    control_points = [control_points(1,:) / w; control_points(2,:) / h];
    control_points = reshape(control_points, [2,n_control,n_control]);
    save([TPS_DIR, product_images{id}(1:end-4), '.mat'], 'keypoints1', 'keypoints2', 'control_points');

end;

fclose(fileID);
