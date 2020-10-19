function bma = calculateEDF(bma)
% CALCULATEEDF Calculates the extended distance function (EDF) at each bma.pointsArray(i), saves that value to bma.EDFArray(i), and sets bma.onMedialResidue(i) to 1 for all points on the medial residue of bma. bma should be an object of the BlumMedialAxis class with adjacencies set. Implements the discrete algorithm described in section 4.2 of Extended Grassfire Transform on Medial Axes of 2D Shapes (Liu, Chambers, Letscher, Ju).
% TODO: Handle the case in which bma as passed is a single point or a set of cycles.
	% We copy the value of bma and store it in temp so that we have a copy we can alter without changing the original.
	temp = bma;
	originalPoints = temp.pointsArray;

	% Each rTilde is initially set to Inf. Then each constrained end's rTilde is set to the boundary distance at that end. It is important to note that we must set the appropriate rTilde's in bma each time we set an rTilde in temp. The indices will no longer be the same as we begin to remove elements from temp.
	temp.EDFArray = Inf * ones(length(temp.pointsArray),1);
	bma.EDFArray = Inf * ones(length(temp.pointsArray),1);

	indicesOfConstrainedEnds = temp.findConstrainedEnds();

	temp.EDFArray(indicesOfConstrainedEnds) = temp.radiiArray(indicesOfConstrainedEnds);
	bma.EDFArray(indicesOfConstrainedEnds) = temp.radiiArray(indicesOfConstrainedEnds);

	% We find the value of the smallest rTilde, and its index in the arrays.
	[smallest, indexOfSmallest] = min(temp.EDFArray);

	endLoop = false;

	while (~endLoop)
		% We find the index of the only point adjacent to smallest. The assert ensures that smallest is a constrained end (else indexOfParent would have been assigned an array).
		indexOfParent = find(temp.adjacencyMatrix(indexOfSmallest,:), 1);
		assert(isscalar(indexOfParent), 'Zero or more than one parent at index %s.\n Make sure your graph is connected.', mat2str(indexOfSmallest));

		% We need to grab the point associated with smallest before we remove smallest in case we need to calculate rTilde for the parent
		tempPoint = temp.pointsArray(indexOfSmallest);
		temp = temp.removeAtIndex(indexOfSmallest);
		% disp(strcat('temp.length is ', num2str(length(temp.pointsArray))))

		% If indexOfSmallest is less than indexOfParent, then removing the row associated with it decrements the index of the row associated with the parent. Our variable needs to reflect this change.
		if (indexOfSmallest < indexOfParent)
			indexOfParent = indexOfParent - 1;
        end
        
        pinds = find(temp.adjacencyMatrix(indexOfParent,:)); 
        
        % check for two triangles with same center and remove closer point
        % if there is one

% % % % % % % % % % % % % % % % % % % % % % % % 
% %             BUG TO BE RESOLVED          % % 
% % % % % % % % % % % % % % % % % % % % % % % % 
%         if length(pinds)==2 && temp.pointsArray(pinds(1))==temp.pointsArray(pinds(2))
%             for jj=1:2
%                 bpts(jj) = length(find(ismember(temp.indexOfBndryPoints(pinds(jj),:), temp.indexOfBndryPoints(indexOfParent,:))));
%             end % for jj
%             [~,nearpt] = sort(bpts, 'descend');
%             temp = temp.removeAtIndex(pinds(nearpt(1)));
%             if (pinds(nearpt(1)) < indexOfParent)
%                 indexOfParent = indexOfParent - 1;
%             end
%         end
% % % % % % % % % % % % % % % % % % % % % % % %              
        
		% If removing smallest caused parent to become a constrained end, we set its rTilde to be rTilde of smallest + the distance from parent to smallest.
		if length(find(temp.adjacencyMatrix(indexOfParent,:))) == 1
			temp.EDFArray(indexOfParent) = smallest + norm(temp.pointsArray(indexOfParent) - tempPoint);

			% We need to find the index of parent in the original bma in order to set its rTilde.
			bma.EDFArray(bma.pointsArray == temp.pointsArray(indexOfParent)) = temp.EDFArray(indexOfParent);
		end

		% We find the new smallest
		[smallest, indexOfSmallest] = min(temp.EDFArray);
        
		% We end the loop when temp.points is a single point or a set of cycles.
		if (length(temp.pointsArray) == 1) || isempty(temp.findConstrainedEnds())
			bma.onMedialResidue = logical(zeros(length(bma.pointsArray),1));

			bma.onMedialResidue = ismember(bma.pointsArray, temp.pointsArray);

			endLoop = true;
		end
	end
end