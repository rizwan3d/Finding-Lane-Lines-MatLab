clear all;
clc
obj = VideoReader('test_videos\solidWhiteRight.mp4','Tag','robj');

nFrames = obj.NumberOfFrames;

for t = 2:2:nFrames-1
    frame = read(obj,1);
    gray = rgb2gray(frame);
    garay = fspecial('gaussian', [5 5], .0000001);
    h_th = 150;
    l_th = (h_th / 3)/255;
    h_th = h_th / 255;
    bound = edge(gray,'canny',[l_th h_th]);
    zerom = zeros(size(gray));
    c = [150 479 900];
    r = [540 300 540];
    triangle = roipoly(bound,c,r);
    mask = regionfill(zerom,triangle);
    roi = bitand(bound,triangle);
    [H,T,R] = hough(roi);
    P  = houghpeaks(H,50,'threshold',ceil(0.1*max(H(:))));
    lines = houghlines(roi,T,R,P,'FillGap',5,'MinLength',40);

    left_fit = [];
    right_fit = [];
    %figure, imshow(frame),imagesc(frame), hold on
    for k = 1:length(lines)
        line = lines(k);
        x1 = line.point1(1);
        y1 = line.point1(2);
        x2 = line.point2(1);
        y2 = line.point1(2);
        pf = polyfit([x1 x2],[y1 y2],1);
        slop = pf(1);
        intersept = pf(2);
        if slop < 0
            left_fit = [left_fit;line];
        else
            right_fit = [right_fit;line];
        end
    end

    figure, imshow(frame),imagesc(frame), hold on
    max_len = 0;

    for k = 1:length(left_fit)   
       xy = [left_fit(k).point1; left_fit(k).point2];
       if  xy(2) < 500
            xy(1) = 150;
            xy(3) = 540;
       else
           xy(2) = 880;
           xy(4) = 540; 
       end
       plot(xy(:,1),xy(:,2),'LineWidth',5,'Color','green');
    end
end