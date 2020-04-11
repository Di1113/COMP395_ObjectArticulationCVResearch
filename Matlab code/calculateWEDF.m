function bma = calculateWEDF(bma)
% CALCULATWEEDF Calculates the WEIGTHED extended distance function (EDF) at each bma.pointsArray(i), 
% saves that value to bma.WEDFArray(i), and sets bma.onMedialResidue(i) to 1 for all points 
% on the medial residue of bma. bma should be an object of the BlumMedialAxis class with adjacencies set. 
% Implements the discrete algorithm described in section 4.2 of Extended Grassfire Transform on Medial Axes of 2D Shapes (Liu, Chambers, Letscher, Ju).
% TODO: Handle the case in which bma as passed is a single point or a set of cycles.

%display('here')

    function d = myDet(c1,c2)
        d=det([real(c1), imag(c1); real(c2), imag(c2)]);
    end

    function A = tri_area(c1,c2,c3)
         A=abs(myDet(c3-c1,c2-c1))/2;
    end
	% We copy the value of bma and store it in temp so that we have a copy
	% we can alter without changing the original.
	temp = bma;
	%%%originalPoints = temp.pointsArray;

	% Each WEDF is initially set to Inf. Then each constrained end's WEDF is set to the cap area at that end. 
    % It is important to note that we must set the appropriate WEDF's in bma each time we set an WEDF in temp. 
    % The indices will no longer be the same as we begin to remove elements from temp.
	temp.WEDFArray = Inf * ones(length(temp.pointsArray),1);
	bma.WEDFArray = Inf * ones(length(temp.pointsArray),1);

	indicesOfConstrainedEnds = temp.findConstrainedEnds();
    
    % their closest points on the boundary
    indicePtsBoundary = temp.indexOfBndryPoints(indicesOfConstrainedEnds,:);
    numIndicesOCE = length(indicesOfConstrainedEnds);
    for i=1:numIndicesOCE
         pt1 = temp.boundary(indicePtsBoundary(i,1));
         pt2 = temp.boundary(indicePtsBoundary(i,2));
         pt3 = temp.boundary(indicePtsBoundary(i,3));
         temp.WEDFArray(indicesOfConstrainedEnds(i)) = tri_area(pt1,pt2,pt3);
    end
    
	bma.WEDFArray(indicesOfConstrainedEnds) = temp.WEDFArray(indicesOfConstrainedEnds);

	% We find the value of the smallest WEDF, and its index in the arrays.
	[smallest, indexOfSmallest] = min(temp.WEDFArray);

	endLoop = false;
	while (~endLoop)
		% We find the index of the only point adjacent to smallest. The assert ensures that smallest is a constrained end 
        % (else indexOfParent would have been assigned an array).
		indexOfParent = find(temp.adjacencyMatrix(indexOfSmallest,:), 1);
		assert(isscalar(indexOfParent), 'Zero or more than one parent at index %s.\n Make sure your graph is connected.', mat2str(indexOfSmallest));

		temp = temp.removeAtIndex(indexOfSmallest);
		% disp(strcat('temp.length is ', num2str(length(temp.pointsArray))))

		% If indexOfSmallest is less than indexOfParent, then removing the row associated with it decrements the index 
        % of the row associated with the parent. Our variable needs to reflect this change.
		if (indexOfSmallest < indexOfParent)
			indexOfParent = indexOfParent - 1;
		end

		% If removing smallest caused parent to become a constrained end, we set its WEDF 
        % to be WEDF of smallest + the area of the triangle given by its 3
        % boudary points
		if length(find(temp.adjacencyMatrix(indexOfParent,:))) == 1
           
            pt1 = temp.boundary(temp.indexOfBndryPoints(indexOfParent,1));
            pt2 = temp.boundary(temp.indexOfBndryPoints(indexOfParent,2));
            pt3 = temp.boundary(temp.indexOfBndryPoints(indexOfParent,3));
            temp.WEDFArray(indexOfParent) = smallest + tri_area(pt1,pt2,pt3);
			% We need to find the index of parent in the original bma in order to set its WEDF.
			bma.WEDFArray(bma.pointsArray == temp.pointsArray(indexOfParent)) = temp.WEDFArray(indexOfParent);
		end

		% We find the new smallest
		[smallest, indexOfSmallest] = min(temp.WEDFArray);

		% We end the loop when temp.points is a single point or a set of cycles.
		if (length(temp.pointsArray) == 1) || isempty(temp.findConstrainedEnds())
			bma.onMedialResidue = logical(zeros(length(bma.pointsArray),1));

			bma.onMedialResidue = ismember(bma.pointsArray, temp.pointsArray);

			endLoop = true;
		end
	end
end