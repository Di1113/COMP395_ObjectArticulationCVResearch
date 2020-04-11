function [ branches, branchnubs] = branchnew(mord,medialdata)
%BRANCHNEW takes in linked points on the medial axis and puts them into
%branches
%
%  Inputs are mord, a 2xn complex vector of adjacent points on the medial
%  axis (in other words, mord(1,k) and mord(2,k) are adjacent points on the
%  ma. branches is a matrix where each row
%  of nonzero entries gives points on a branch of the medial axis The first
%  entry in each row will correspond to an axis point with three or more
%  branches coming out from it.
%  

% check that mord is a 2xn vector
if size(mord, 1)>2, mord = transpose(mord); end %if

% initialize some variables. Note that all finite entries of rows in branches will
% be the branches. The rest of the matrix will be filled out with Infs.
% Yes, it's a hack. Why do you ask?
%

regnodes=[];
trinodes=[];
branches = {};

% get rid of points that connect to themselves in mord (ie, mord(1,k)=mord(2,k)).

i2 = find(mord(1,:)-mord(2,:)==0);
mord(:,i2)=[];
mord2=mord; 

% get rid of point pairs that occur more than once
for k=1:size(mord2,2)
    [dd] = find(sum(abs(mord-mord2(:,k)*ones(1,size(mord,2))),1)==0);
    if size(dd,2)>=2
            mord(:,dd(2:size(dd,2)))=[];
    end %if size
    [dd] = find(sum(abs(flipud(mord)-mord2(:,k)*ones(1,size(mord,2))),1)==0);
    if size(dd,2)>=2
            mord(:,dd(2:size(dd,2)))=[];
    end %if size
end %for k

% loop through mord to extract the points that occur three times,trinodes, from the
% others, regnodes. The entries in trinodes will be the branch points of the medial axis. 

list=unique(mord);                      %gives list of unique values in mord
for c1=1:size(list, 1)
    [i1,i2] = find(mord==list(c1));     %find all entries of mord = current point in list
    if size(i1,1)>=3
        for c2=1:size(i1,1)
            if i1(c2)==2                 % arrange in trinodes so that branch point is in 1st row 
                mord2= flipud(mord(:, i2(c2))); 
            else
                mord2= mord(:, i2(c2));
            end %if
            trinodes=[trinodes mord2];
        end %for c2
    else                                % put other points into regnodes
        for c3=1:size(i1,1)
            regnodes=[regnodes mord(:,i2(c3))];
        end %for c2
    end %if size
end %for c1

% This next part is a hack to make up for the above hack. We need to remove
% point pairs that appear in trinodes from the regnodes list.

for count=1:size(trinodes,2)
    [i1, i2] = find(regnodes==trinodes(1,count));
    regnodes(:,i2)=[];
end %for count

% extra check for regnodes having double point pairs. It's a long story.

regnodes2=regnodes;
for k=1:size(regnodes,2)
    [dd] = find(sum(abs(regnodes-regnodes2(:,k)*ones(1,size(regnodes,2))),1)==0);
    if size(dd,2)>=2
            regnodes(:,dd(2:size(dd,2)))=[];
    end %if size
end %for k

% now trinodes should contain all branch points and regnodes should contain
% all regular points. We will take each point in trinodes and use it as
% a starting point for a branch, stepping through regnodes until we reach
% the end of a branch.

branchnubs = trinodes;

for d1=1:size(trinodes,2)
    if trinodes(1,d1)~=0 || trinodes(2,d1)~=0
        current = trinodes(:, d1);
        [j1 j2] = find(regnodes==current(size(current,1)));
        while size(j1)~=0 
            if j1==1
                current = [current; regnodes(2, j2)];
            else
                current = [current; regnodes(1, j2)];
            end  %if j1

            regnodes(:,j2)= [];
            [j1 j2] = find(regnodes==current(size(current,1)));
        end %while 
        % find the last segment if going from trinode to trinode
        [ii1 ii2] = find(trinodes==current(size(current, 1)));
        if size(ii1)
            current = [current; trinodes(2,ii2(1)); trinodes(1,ii2(1))];
            trinodes(:,ii2(1))=[0;0];
        end % if 
        if length(current)>=2
            currentindex = [];
            branches{d1} = transpose(current);
        end
    end %if trinodes
end %for d1

% remove any empty branches from cell array
branches = branches(~cellfun('isempty',branches));

% remove any duplicate branches of length 2 from branchnubs
dups=[];
normnubs = sum(branchnubs.*branchnubs,1);
[u,ii,jj] = unique(normnubs', 'rows');
duprows = setdiff(1:size(normnubs',1), ii);
% loop through duprows looking for point pair matches to confirm norm
% matches are more than coincidental
for dupind = 1:length(duprows)
    duptest = branchnubs-repmat(flipud(branchnubs(:,duprows(dupind))),1, length(branchnubs));    
    duptestnorm = find(sum(duptest.*duptest,1)==0);
    if length(duptest)
        dups = duprows(dupind);
    end % if length
end % for dupind
if size(dups)
    branchnubs(:,dups)=[];
end % if size