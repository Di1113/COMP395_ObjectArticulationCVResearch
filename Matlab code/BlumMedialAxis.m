classdef BlumMedialAxis
% BLUMMEDIALAXIS Defines a class to represent a Blum Medial Axis. Let bma be an object of the BlumMedialAxis class. 
% Then bma.boundary(i) is a point on the boundary curve that gives the axis. bma. bma.pointsArray(j) is the location of a point on the medial axis, 
% bma.radiiArray(j) is the radius associated with that point, bma.EDFArray(j) is the EDF associated with the point, 
% bma.indexOfBndryPoints(j) is a 3x1 array of which each element is the index in bma.boundary of one of the boundary points that defined the point, 
% and bma.onMedialResidue(j) is a boolean assigned true if the point at j is on the medial residue of bma. bma.adjacencyMatrix is a square matrix 
% such that bma.adjacencyMatrix(m,n) and bma.adjacencyMatrix(n,m) are both true when there exists an adjacency between the two points at m and n.
% TODO: Write pruning function. Integrate into the rest of the toolchain.
    properties
        boundary
        pointsArray
        radiiArray
        EDFArray
        WEDFArray
        indexOfBndryPoints
        onMedialResidue   
        adjacencyMatrix
        erosionThickness
        shapeTubularity
        pointType
        branchNumber
        branchAdjacency
    end

    properties %(Hidden)
        medialData
    end

    methods
        % CONSTRUCTOR
        function bma = BlumMedialAxis(boundary)
        % BLUMMEDIALAXIS Returns an object of the BlumMedialAxis class. boundary should be an array of sorted complex-valued points 
        % describing a boundary curve.
            if nargin > 0
                [bma.boundary,bma.medialData] = BlumMedialAxis.medialAxis(boundary); 
                bma = buildPoints(bma, bma.medialData);
                bma = branchesforbma(bma);
                bma = calculateEDF(bma); 
                bma = calculateWEDF(bma);
                bma = calculateETandST(bma); 
            end
        end

        % METHODS
        % debug assigned to Di 
        function bma = prune(bma, etRatio, stThreshold)
            % We'll calculate area of the shape
            area = polyarea(real(bma.boundary), imag(bma.boundary));
            etThreshold = etRatio * sqrt(area);

            indicesToRemove = find(bma.EDFArray < etThreshold | bma.EDFArray < stThreshold);

            bma = bma.removeAtIndex(indicesToRemove);
        end

        function bma = calculateETandST(bma)
            bma.erosionThickness = bma.EDFArray - bma.radiiArray;
            bma.shapeTubularity = 1 - bma.radiiArray ./ bma.EDFArray;
        end

        function length = getLength(bma)
        % GETLENGTH Returns the length of bma.pointsArray, the same as the
        % numer of points on our medial axis.
            length = length(bma.pointsArray);
        end

        function bma = removePoint(bma, point)
        % REMOVEPOINT Removes point from bma. point should be a complex-valued
        % point on the medial axis.
            index = find(bma.pointsArray == point);
            BlumMedialAxis.removeAtIndex(bma, index);
        end

        function bma = removeAtIndex(bma, index)
        % REMOVEATINDEX Removes the point at the given index from bma.index
        % can be a scalar or an array. Any time we add properties to the class,
        % we have to ensure we remove them here to keep the rows aligned.
            point = bma.pointsArray(index);
            bma = removeFromMedialData(bma, point);

            bma.pointsArray(index) = [];
            bma.radiiArray(index) = [];
            bma.EDFArray(index) = [];
            bma.WEDFArray(index) = [];
            bma.indexOfBndryPoints(index,:) = [];
            bma.onMedialResidue(index) = [];
            bma.erosionThickness(index) = [];
            bma.shapeTubularity(index) = [];

            bma.adjacencyMatrix(index,:) = [];
            bma.adjacencyMatrix(:,index) = [];

            bma.pointType(index) = [];
            bma.branchNumber(index,:) = [];

        end

% pyed
        function bma = buildPoints(bma, medialData)
        % BUILDPOINTS Sets up our medial axis based on the information in
        % medialData. medialData should be an nx5 matrix where medialData(n,1)
        % is the location of a point on the axis, medialData(n,2) is the radius
        % to boundary at that point, and medialData(n,3:5) are the boundary
        % points associated with that point. If it is the return value of the
        % medialaxis function, then some points may be given by more than one
        % set of boundary points and will then have multiple entried in medialData.
            % Get the set of adjacencies.
            mord = BlumMedialAxis.medialOrder(medialData);

            % For each entry in mord, we check to see if we already have that
            % point in bma, and add it if not. We do not yet set adjacencies
            % because we do not know how many unique points are in mord.
            for i = 1:length(mord)
                pointA = mord(1,i);
                pointB = mord(2,i);
                if pointA==pointB
                    [indexA, bma] = bma.findOrAdd(medialData, pointA);
                else
                    [indexA, bma] = bma.findOrAdd(medialData, pointA);
                    [indexB, bma] = bma.findOrAdd(medialData, pointB);
                end
            end

            % Now that we know how many unique points we have, we make our
            % adjacency matrix and set the adjacencies given by mord.
            bma.adjacencyMatrix = logical(zeros(length(bma.pointsArray), length(bma.pointsArray)));
            for i = 1:length(mord)
                indexM = find(bma.pointsArray == mord(1,i));
                indexN = find(bma.pointsArray == mord(2,i));
                %if indexM~=indexN
                if length(indexM)==1 && length(indexN)==1
                    bma.adjacencyMatrix(indexM, indexN) = true;
                    bma.adjacencyMatrix(indexN, indexM) = true;
                else
                    % look at bdry pts for each pt in indexM and indexN to
                    % find the pair that shares two points (and therefore
                    % an edge)
                    for jj=1:length(indexM)
                        for kk=1:length(indexN)
                            if length(find(ismember(bma.indexOfBndryPoints(indexM(jj),:),bma.indexOfBndryPoints(indexN(kk),:)))) >=2 && indexM(jj)~= indexN(kk)
                                bma.adjacencyMatrix(indexM(jj), indexN(kk)) = true;
                                bma.adjacencyMatrix(indexN(kk), indexM(jj)) = true;
                            end %if
                        end%for
                    end%for
                end 
            end

            % Initialize the rest of the properties.
            bma.onMedialResidue = Inf * ones(length(bma.pointsArray), 1);
            bma.EDFArray = Inf * ones(length(bma.pointsArray), 1);
            bma.WEDFArray = Inf * ones(length(bma.pointsArray), 1);
            bma.erosionThickness = Inf * ones(length(bma.pointsArray), 1);
            bma.shapeTubularity = Inf * ones(length(bma.pointsArray), 1);

        end

        function [index, bma] = findOrAdd(bma, medialData, point)
        % FINDORADD Attempts to find the index of point in bma.pointsArray. If the point is not in bma.pointsArray, then it adds the point with the appropriate information from medialData.
            index = find(bma.pointsArray == point);  
            indexInMD = find(medialData(:,1) == point);
            dbp1=0;
            dbp2=0;
             
            if (length(index)==1) % check if they have the same boundary points
                indexInMD = find(medialData(:,1) == point);
                bp1 = sort(medialData(indexInMD(1),3:5));
                bp2 = sort(bma.indexOfBndryPoints(index,:));
                dbp1 = ~isempty(find(~(bp1 == bp2))); %they have different boundary points
                if length(indexInMD)>=2
                     bp3 = sort(medialData(indexInMD(2),3:5));
                     dbp2 = ~isempty(find(~(bp3 == bp2))); %they have different boundary points
                end
            end
            
            if (isempty(index)|| dbp1 || dbp2)                
                 %if they have different boundary points: keep point
                  bma.pointsArray = [bma.pointsArray; point];
                  bma.radiiArray = [bma.radiiArray; medialData(indexInMD(1),2)];
                  if isempty(index) || dbp1
                    bma.indexOfBndryPoints = [bma.indexOfBndryPoints; medialData(indexInMD(1),3:5)];
                  else
                    bma.indexOfBndryPoints = [bma.indexOfBndryPoints; medialData(indexInMD(2),3:5)];
                  end
                  index = length(bma.pointsArray);
            end
        end

        function figure1 = plotWithEdges(bma) 
        % PLOTWITHEDGES Plots the points and the edges (adjacencies) of bma.
            figure1 = figure;
            hold on;

            plot(bma.pointsArray, 'r*'), axis equal;
            gplot(bma.adjacencyMatrix, [real(bma.pointsArray), imag(bma.pointsArray)]);

            hold off;
        end
        
        function figure1 = plotWithEDF(bma)
        % PLOTWITHEDF Plots the points and the edges (adjacencies) of bma
        % and colours the point relative to the EDF value
            figure1 = figure;
            hold on;
            l=length(bma.pointsArray)
            mymin= min(bma.EDFArray);
            mymax= max(bma.EDFArray);
            for i=1:l
                c1 = bma.boundary(bma.indexOfBndryPoints(i,1));
                 c2 = bma.boundary(bma.indexOfBndryPoints(i,2));
                 c3 = bma.boundary(bma.indexOfBndryPoints(i,3));

                r= (bma.EDFArray(i)-mymin)/(mymax-mymin);
                patch([real(c1),real(c2),real(c3)],[imag(c1),imag(c2),imag(c3)],...
                     'b','FaceAlpha',1,'FaceColor',[r 0 1-r])
%                 plot(bma.pointsArray(i), '-o', 'MarkerEdgeColor','k',...
%                     'MarkerFaceColor',[r 0 1-r],...
%                  'MarkerSize',15), axis equal;
            end
            gplot(bma.adjacencyMatrix, [real(bma.pointsArray), imag(bma.pointsArray)]);
            axis equal
            hold off;
        end

        function figure1 = plotWithWEDF(bma)
        % PLOTWITHEDF Plots the delaunay triangles and the edges (adjacencies) of bma
        % and colors the triangles relative to the WEDF value (blue for
        % low, red for high)
        % and adds medial axis in green on top
            figure1 = figure;
            hold on;
            %bma = calculateWEDF(bma); 
            l=length(bma.pointsArray);
            mymin= min(bma.WEDFArray);
            mymax= max(bma.WEDFArray);
            for i=1:l
                 c1 = bma.boundary(bma.indexOfBndryPoints(i,1));
                 c2 = bma.boundary(bma.indexOfBndryPoints(i,2));
                 c3 = bma.boundary(bma.indexOfBndryPoints(i,3));

                 r= (bma.WEDFArray(i)-mymin)/(mymax-mymin);
                 patch([real(c1),real(c2),real(c3)],[imag(c1),imag(c2),imag(c3)],...
                     'b','FaceAlpha',1,'FaceColor',[r 0 1-r])
                 %plot(bma.pointsArray(i), 'v', 'MarkerEdgeColor','k',...
                 %   'MarkerFaceColor',,...
                 %'MarkerSize',15), axis equal;
            end
            gplot(bma.adjacencyMatrix, [real(bma.pointsArray), imag(bma.pointsArray)],'g-');
            axis equal
            hold off;
        end

        function figure1 = plotWithST(bma)
        % PLOTWITHEDF Plots the delaunay triangles and the edges (adjacencies) of bma
        % and colors the triangles relative to the WEDF value (blue for
        % low, red for high)
        % and adds medial axis in green on top
            figure1 = figure;
            hold on;
            %bma = calculateWEDF(bma); 
            l=length(bma.pointsArray);
            mymin= min(bma.shapeTubularity);
            mymax= max(bma.shapeTubularity);
            for i=1:l
                 c1 = bma.boundary(bma.indexOfBndryPoints(i,1));
                 c2 = bma.boundary(bma.indexOfBndryPoints(i,2));
                 c3 = bma.boundary(bma.indexOfBndryPoints(i,3));

                 r= (bma.shapeTubularity(i)-mymin)/(mymax-mymin);
                 patch([real(c1),real(c2),real(c3)],[imag(c1),imag(c2),imag(c3)],...
                     'b','FaceAlpha',1,'FaceColor',[r 0 1-r])
                 %plot(bma.pointsArray(i), 'v', 'MarkerEdgeColor','k',...
                 %   'MarkerFaceColor',,...
                 %'MarkerSize',15), axis equal;
            end
            gplot(bma.adjacencyMatrix, [real(bma.pointsArray), imag(bma.pointsArray)],'g-');
            axis equal
            hold off;
        end
        
        function figure1 = plotWithET(bma)
        % PLOTWITHEDF Plots the delaunay triangles and the edges (adjacencies) of bma
        % and colors the triangles relative to the WEDF value (blue for
        % low, red for high)
        % and adds medial axis in green on top
            figure1 = figure;
            hold on;
            %bma = calculateWEDF(bma); 
            l=length(bma.pointsArray);
            mymin= min(bma.erosionThickness);
            mymax= max(bma.erosionThickness);
            for i=1:l
                 c1 = bma.boundary(bma.indexOfBndryPoints(i,1));
                 c2 = bma.boundary(bma.indexOfBndryPoints(i,2));
                 c3 = bma.boundary(bma.indexOfBndryPoints(i,3));

                 r= (bma.erosionThickness(i)-mymin)/(mymax-mymin);
                 patch([real(c1),real(c2),real(c3)],[imag(c1),imag(c2),imag(c3)],...
                     'b','FaceAlpha',1,'FaceColor',[r 0 1-r])
                 %plot(bma.pointsArray(i), 'v', 'MarkerEdgeColor','k',...
                 %   'MarkerFaceColor',,...
                 %'MarkerSize',15), axis equal;
            end
            gplot(bma.adjacencyMatrix, [real(bma.pointsArray), imag(bma.pointsArray)],'g-');
            axis equal
            hold off;
        end
        

        function indicesOfConstrainedEnds = findConstrainedEnds(bma)
        % FINDCONSTRAINEDENDS Returns an array of the indices in bma.pointsArray that give a constrained end.
            indicesOfConstrainedEnds = find(sum(bma.adjacencyMatrix, 1) == 1);
        end
    end


    methods (Static)
        function boundary = calculateBoundary(circle)
        % CALCULATEBOUNDARY Takes a string giving the name of a JPG on the path
        % and constructs a boundary curve. This function is a wrapper for the 
        % parts of the imperative functions that output a boundary.
            [I1, I2, I3] = KMeansBerry(circle);
            isolatedStrawberry = GetBerries(I1, I2, I3);
            singleStrawberry = SeparateBerries(isolatedStrawberry);
            boundary = BorderBiggestArea(singleStrawberry);
            boundary = sortpointsnew(boundary);
            boundary = boundary(:,2);
        end

        function boundary = calculateConvHull(circle)
            [I1, I2, I3] = KMeansBerry(circle);
            isolatedStrawberry = GetBerries(I1, I2, I3);
            singleStrawberry = SeparateBerries(isolatedStrawberry);
            boundary = BorderBiggestArea(singleStrawberry);
            k = convhull(real(boundary), imag(boundary));
            boundary = boundary(k);
            boundary(1) = []
        end

% pyed 
        function [z, medialData] = medialAxis(boundary)
        % MEDIALAXIS Takes an nx1 complex-valued boundary curve and outputs z, the boundary curve (I don't know if it is changed or not), and medialData, an mx5 matrix. medialData(i,1) is a complex-valued point on the medial axis, medialData(i,2) is the radius associated with the point medialData(i,1), and each medialData(i,3:5) is an index in z of one of three points on the boundary associated with medialData(i,1). This function is a wrapper for the medialaxis imperative function.
            [z, medialData] = medialaxis(boundary);
        end
% pyed
        function mord = medialOrder(medialData)
        % MEDIALORDER Takes medialData (described in medialAxis()) and returns a 2xn matrix where mord(:,i) denotes an edge from the point given by mord(1,i) to the point given by mord(2,i).
            mord = medialorder(medialData);

            % get rid of points that connect to themselves in mord (ie, mord(1,k)=mord(2,k)).
            i2 = find(mord(1,:)-mord(2,:)==0);
            if ~isempty(i2)
                for kk=1:length(i2)
                    indexInMD = find(medialData(:,1) == mord(1,i2(kk)));
                    bp1 = sort(medialData(indexInMD(1),3:5));
                    bp2 = sort(medialData(indexInMD(2),3:5));
                    dbp = ~isempty(find(~(bp1 == bp2))); %they have different boundary points
                    if dbp 
                        %display 'we kept a point2';
                             %      mord(1,i2(kk))
                              %     mord(2,i2(kk))
                    else
                        mord(:,i2)=[];
                    end %if dbp
                end %for
            end %if isempty
            
            

            % get rid of point pairs that occur more than once
%           mord2 = mord;
%           for k=size(mord2,2)
%                 if (mord2(1,k)-mord2(2,k)~=0)
%                 [dd] = find(sum(mord-mord2(:,k)*ones(1,size(mord,2)),1)==0);
%                 if size(dd,2)>=2
%                   mord(:,dd(2:size(dd,2)))=[]
%                 end %if size
%                 else
%                     display 'we pass here'
%                     mord(1,k)
%                     mord(2,k)
%                 end %if mord2(1,k) ...
%           end %for k
        end
    end

    methods (Access = private) 
        function bma = removeFromMedialData(bma, point)
            % This is logical indexing. Faster than calling find().
            bma.medialData(ismember(bma.medialData(:,1), point),:) = [];
        end
    end
    
end
