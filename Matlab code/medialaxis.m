function [z, medialdata] = medialaxis(z)
% AXIS outputs a matrix medial data: medial points, radii and triangles 
%   The input zz is a vector of sorted complex valued boundary points. The output
%   matrix medialdata = [m r triin] where m is the collection of points on
%   the medial axis, r is the associated radii, and triin is the delaunay
%   triangulation of the boundary corresponding to triangles entirely
%   inside the boundary.
 

    if sum((real(z) - circshift(real(z),-1)).*(imag(z)+circshift(imag(z),-1))) >0
        z = flipud(z);
    end

tri =sort(delaunay(real(z),imag(z))')';
% visualization for debugging 
% plot(real(z),imag(z),'.b')
% DT = delaunay(real(z),imag(z));
% triplot(DT,real(z),imag(z));
% hold on

% dt = delaunayTriangulation(real(z),imag(z))';
% dtt(:,1) = dt(:,1);
% dtt(:,2) = dt(:,2);
% dtt(:,3) = dt(:,3);
% tri =sort(dtt);

u = z(tri(:,1)); v = z(tri(:,2)); w = z(tri(:,3));  %separates each column of the triagulation

dot = (u-w).*conj(v-w);                             %multiplies coordinatewise column1-column3 by 2-3

m = (u+v+i*(u-v).*real(dot)./imag(dot))/2;          %(real(m),image(m)) centers circles created in tri

r = abs(u-m);                                       %r radii of circles created in tri

% abc


inside = imag(dot) > 0;                             %gives 0 if center outside, 1 if inside
triin = tri(inside,:);                              %removes outside information

m = m(inside); r = r(inside);                       %(real(m),imag(m)) centers inside circles

% visualization for debugging 
% disp("m")
% disp(size(m))
% disp("r")
% disp(size(r))
% plot(real(m),imag(m),'*r')

medialdata = [m r triin];

end

