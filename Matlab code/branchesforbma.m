function bma = branchesforbma(bma)

bma.branchNumber = zeros(length(bma.pointsArray));

% % put point type values into bma arrays based on adjacency matrix
bma.pointType(find(sum(bma.adjacencyMatrix,2)>=3)')=3;
bma.pointType(find(sum(bma.adjacencyMatrix,2)==1)')=1; 
bma.pointType(find(sum(bma.adjacencyMatrix,2)==2)')=0;

[~,tripadjacents] = find(bma.adjacencyMatrix(find(bma.pointType==3),:));
bma.pointType(tripadjacents(find(bma.pointType(tripadjacents)==0)))=2;
bma.pointType(tripadjacents(find(bma.pointType(tripadjacents)==1)))=4;

triplepoint = find(ismember(bma.pointType, [3]));
singlepoint = find(ismember(bma.pointType, [1]));
nubpoint = find(ismember(bma.pointType, [2]));

singlestub = tripadjacents(find(ismember(bma.pointType(tripadjacents), [4])));
triplestub = tripadjacents(find(ismember(bma.pointType(tripadjacents), [3])));

nubcount = ones(size(nubpoint));

branch = {};

% case 0: single branch (no triple points)
if length(triplepoint)==0
    branchno=1;
    [d, pred] = dijkstra(bma.adjacencyMatrix, singlepoint(1));
    predpath= pred;  
    bpath = singlepoint(2);
    u =singlepoint(2);
    while u~=singlepoint(1)
        u = predpath(u);
        bpath = [bpath u];
    end %while  
    branch{branchno} = bpath;
end % if

% case 1: single points adjacent to triple points

[startpt1, endpt1] = find(bma.adjacencyMatrix(triplepoint, singlestub));
for branchno = 1:length(startpt1)
    branch{branchno} = [triplepoint(startpt1(branchno)) singlestub(endpt1(branchno))];
end % for, case 1


% case 2: triple points adjacent to triple points
[startpt2, endpt2] = find(bma.adjacencyMatrix(triplepoint, triplepoint));
ind = find(startpt2<endpt2);
startpt2 = startpt2(ind);
endpt2 = endpt2(ind);
startind = length(branch);
for branchno = startind+1:length(startpt2)+startind
    branch{branchno} = [triplepoint(startpt2(branchno-startind)) triplepoint(endpt2(branchno-startind))];
end % for, case 2

% case 3: single points not adjacent to triple points
predpath = {};

dists = Inf*ones(length(triplepoint), length(singlepoint));

for ll = 1:length(singlepoint)
    [d, pred] = dijkstra(bma.adjacencyMatrix, singlepoint(ll));
    dists(:,ll) = d(triplepoint);
    predpath{ll} = pred;
end % for ll
badinds = find(any(isinf(dists),1));
dists(:, badinds)=[];
singlepoint(badinds)=[];
predpath(badinds) = [];

[~,endpts3] = min(dists,[],1);

branchstarts = triplepoint(endpts3);
bpath =[];
startind = length(branch);

for branchno = startind+1:length(endpts3)+startind
    bpath = [branchstarts(branchno-startind)];
    u =branchstarts(branchno-startind);
    while u~=singlepoint((branchno-startind))
        u = predpath{branchno-startind}(u);
        bpath = [bpath u];
    end %while
    
    branch{branchno} = bpath;
    nubcount(find(ismember(nubpoint, bpath)))=0;
    
end % for, case 3


% case 4: triple point to triple point via multiple regular points

predpath = {};
nubpoint2 = nubpoint(find(nubcount));
longbranch=0;

tempadjacency = bma.adjacencyMatrix;
tempadjacency(find(bma.pointType==3),:)=0;
tempadjacency(:,find(bma.pointType==3))=0;


% subcase a: triple, regular, triple branch
for ll = 1:length(nubpoint2)
    if ~length(find(tempadjacency(nubpoint2(ll),:)))
        longbranch(ll) = 0;
        tripnbrs = find(bma.adjacencyMatrix(nubpoint2(ll),:));
        branch{length(branch)+1} = [tripnbrs(1), nubpoint2(ll), tripnbrs(2)];
        nubcount(find(ismember(nubpoint, branch{length(branch)})))=0; 
    else
        longbranch(ll) = 1;
    end % if
end % for ll

% subcase b: triple, multiple regulars, triple
if length(find(longbranch))
    nubpoint2 = nubpoint(find(nubcount));
    dists = Inf*ones(length(nubpoint2), length(nubpoint2));
    
    for ll = 1:length(nubpoint2)
        [d, pred] = dijkstra(tempadjacency, nubpoint2(ll));
        dists(:,ll) = d(nubpoint2);
        predpath{ll} = pred;
    end % for ll
        
    dists(~dists) = Inf;
    [dists4,endpts4] = min(dists);
    idx=find([1:length(endpts4)]>endpts4);

    branchstarts = nubpoint2(endpts4(idx));
    branchends = nubpoint2(idx);
    bpath =[];
    startind=length(branch);

    for branchno = startind+1:length(branchstarts)+startind
        triplestart = triplepoint(find(ismember(triplepoint, find(bma.adjacencyMatrix(branchends(branchno-startind),:)))));
        if length(triplestart)==1
            bpath = [triplepoint(find(ismember(triplepoint, find(bma.adjacencyMatrix(branchstarts(branchno-startind),:))))) branchstarts(branchno-startind)];
            u =branchstarts(branchno-startind);
            while u~=branchends(branchno-startind)
                tempu = predpath{idx(branchno-startind)}(u);
                if tempu > 0
                    u = tempu;
                else
                    break
                end 
                bpath = [bpath u];
            end %while
            bpath = [bpath triplepoint(find(ismember(triplepoint, find(bma.adjacencyMatrix(u,:)))))];
        elseif length(triplestart)==2
            bpath = [triplestart(1) branchends(branchno-startind) triplestart(2)];
        end % if length
        branch{branchno} = bpath;    
    end %for branchno       
end % if longbranch, case 4
 
% insert branch point order number into column with index = branchno

for branchno=1:length(branch)
    orderind = [1:length(branch{branchno})];
    bma.branchNumber(branch{branchno},branchno)=orderind;

end %for branchno

%remove extra columns from bma.branchNumber
bma.branchNumber(:,find(sum(bma.branchNumber,1)==0))=[];

%create branch adjacency matrix
bma.branchAdjacency=zeros(size(bma.branchNumber,2));
for ind=1:length(bma.pointsArray)
    [~, branchind] = find(bma.branchNumber(ind,:));
    if length(branchind)>=2
        adjind = nchoosek(branchind, 2); 
        for ind2=1:size(adjind,1)
            bma.branchAdjacency(adjind(ind2,1), adjind(ind2,2))=1;
            bma.branchAdjacency(adjind(ind2,2), adjind(ind2,1))=1;
        end % if for ind2
    end % if length
end % for ind





