A=imread('1.jpg');   %¶ÁÈ¡µ½Ò»ÕÅÍ¼Æ¬
%p1 = imcomplement(A);    % ºÚ°×µßµ¹ °×Ã¨
p1=imcomplement(A);
p = rgb2gray(p1);
se=strel('square',2);
se1=strel('disk',2);
bw=imerode(p,se);

[L,N]=bwlabel(bw,4);
s = regionprops(L,'Area');
bw1=ismember(L,find([s.Area]>=10000 & [s.Area]<=50000  ));
bw2=imerode(bw1,se);
%bw2=imdilate(bw2,se1);
bw2=imerode(bw2,se);
bw2=imdilate(bw2,se1);
%bw2 = bwmorph(bw2,'thin',Inf); 
%bw2 = imclearborder(bw2);
%bw2=imerode(bw2,se1);
[B,L]=bwboundaries(bw2);
bw3=bwperim(bw2);%boundaries 
%figure;subplot(2,3,1);imshow(p);title('binaryinvert');
%subplot(2,3,2);imshow(bw);title('beforeimeroderegionpops');
%subplot(2,3,3);imshow(bw1);title('afterimerodese>10000<50000');
%subplot(2,3,4);imshow(bw2);title('imdilatese');
%subplot(2,3,5);imshow(bw3);title('boundaries');

%add a line using regionprops to extract connected component with largest
%area



catboundary = B{1};
catboundary = complex(catboundary(:,1), catboundary(:,2));
bmacat = BlumMedialAxis(catboundary);
