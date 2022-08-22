
A = imread("kanpur.jpg");

%...............................AA(:,:,1) = A(:,:,2);

% Step 1 - Converting RGB to grayscale image
I1 = rgb2gray(A);
figure, imshow(I1),title("Grayscaled image");

% Step 2 - Smooth image  with gaussian filter.
% fspecial was not recommended by mathworks
% sigma of 1.7

I2 = imgaussfilt(I1,1.7);
figure, imshow(I2),title("Image after gaussian filtering");

% Step 3 - Intensity gradient calculation

h = fspecial('sobel');

Gx = imfilter(I2,h');
Gy = imfilter(I2,h);
figure, imshow(Gx),title("Emphasize vertical edge, Intensity gradient calculation in x direction");
figure, imshow(Gy),title("Emphasize Horizontal edge, Intensity gradient calculation in y direction");

% Step 4 - Getting edge magnitude and edge direction matrices

Gxd = double(Gx);
Gyd = double(Gy);
[a,b] = size(Gxd);

for i=1:a
    for j=1:b
    
     Gd(i,j) = sqrt(Gxd(i,j)^2 + Gyd(i,j)^2);
     theta(i,j) = atan2(Gyd(i,j),Gxd(i,j));
        
    end
end

test = 0;

for i=1:a
    for j=1:b
    
     if (Gd(i,j) > test)
         test = Gd(i,j);
     end 
    end
end

    for i=1:a
    for j=1:b
    
     Gd(i,j) = ceil(Gd(i,j)*255/test);
        
    end
    end
 
    
G = uint8(Gd);
figure,imshow(G), title('Gradient Magnitude Image');


% Step 5 - Non-Maximum Suppression

Z = zeros(a,b); %Create a matrix initialized to 0 of the same size of the original gradient intensity matrix

Angle = 180*theta/pi ; % converting angle to degrees for convienience

for i=1:a
    for j=1:b
    
     if (Angle(i,j) < 0)
         Angle(i,j) = Angle(i,j) + 180;
     end 
    end
end


% a-1 and b-1 to take care  of edges

for i=2:a-1
    for j=2:b-1
    
     q = 255;
     r = 255;
     
      % angle 0
      if ( ( Angle(i,j) >= 0 && Angle(i,j) < 22.5) || (Angle(i,j) >= 157.5 && Angle(i,j) <= 180))
                    q = Gd(i, j+1);
                    r = Gd(i, j-1);
                % angle 45
                elseif ( Angle(i,j) >= 22.5 && Angle(i,j) < 67.5)
                    q = Gd(i+1, j-1);
                    r = Gd(i-1, j+1);
                % angle 90
                elseif ( Angle(i,j) >= 67.5 && Angle(i,j) < 112.5)
                    q = Gd(i+1, j);
                    r = Gd(i-1, j);
                %t angle 135
                elseif ( Angle(i,j) >= 112.5 && Angle(i,j) < 157.5)
                    q = Gd(i-1, j-1);
                    r = Gd(i+1, j+1);
                    
      end
                    
                    if (Gd(i,j) >= q) && (Gd(i,j) >= r)
                        
                        Z(i,j) = Gd(i,j);
                        
                    else
                        Z(i,j) = 0;
                    end
                       
      
    end 
end

Z = uint8(Z);
figure,imshow(Z), title('Image after Non maximum suppression');

% Double Thresholding

High_threshold_ratio = 0.09;
Low_threshold_ratio = 0.05;

max_img = max(Z, [], 'all');

High_threshold = max_img*High_threshold_ratio;
Low_threshold = High_threshold*Low_threshold_ratio;

weak = 25;
strong = 255;

res = zeros(a,b);

for i=1:a
    for j=1:b
   
     if ( Z(i,j) >= High_threshold )
         res(i,j) = strong;
     elseif ( Z(i,j) < Low_threshold )
         res(i,j) = 0;
     else
         res(i,j) = weak;
     end
        
    end
end

res = uint8(res);
figure,imshow(res), title('Image after Double thresholding');

% Starting edge tracking by hysteresis

for i=2:a-1
    for j=2:b-1
       
        if ( res(i,j) == weak )
            
            if ( res(i+1, j-1) == strong )
                res(i, j) = strong;
            elseif ( res(i+1, j) == strong )
                res(i, j) = strong;
                elseif ( res(i+1, j+1) == strong )
                    res(i, j) = strong;
                    elseif ( res(i, j-1) == strong )
                        res(i, j) = strong;
                        elseif ( res(i, j+1) == strong )
                            res(i, j) = strong;
                            elseif ( res(i-1, j-1) == strong )
                                res(i, j) = strong;
                                elseif ( res(i-1, j) == strong )
                                    res(i, j) = strong;
                                    elseif ( res(i-1, j+1) == strong )
                                        res(i, j) = strong;
            else
                res(i, j) = 0;
               
            end
            
            
        end
        
    end
end

figure,imshow(res), title('Image after Hysterisis edge tracking');



