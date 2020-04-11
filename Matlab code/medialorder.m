function[mord]=medialorder(medialdata)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MEDIALORDER takes in the output of medial axis and finds point          %
% adjacencies triangles, medial points, radii)                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

m2= medialdata(:,1);
r2= medialdata(:,2);
triin2= medialdata(:,3:5);

nt = size(triin2,1);                                %lines 52 through 56 order m2
B1 = sparse([1:nt 1:nt 1:nt], triin2(:), ones(1,3*nt));
[a1,b1,c1] = find(B1*B1'>1);
ind = a1>b1; a1 = a1(ind); b1 = b1(ind);
%figure(4)
%plot([transpose(m2(a1)); transpose(m2(b1))], 'r*')
mord =[transpose(m2(a1)); transpose(m2(b1))];
%hold on

