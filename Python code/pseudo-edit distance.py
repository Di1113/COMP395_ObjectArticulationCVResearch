# This is a pseudocode for edit distance which include the operation contract
# We are comparing the shape similarity between 2 image, and we can obtain their bma.

1. Find the highest WEDF value point in each bma. This will be served as root in each tree.
# Edit-distance contains two part: edit cost by each edit and Euclidean distance of ET and ST.
2. A recursive function EditCost(nodeidx1,nodeidx2,bma1,bma2): 
	Base case: when both nodeidx1 and nodeidx2 have no childnode, return 0. 
				(Since the WEDF value on each endpoint of bma is 0).
	Recursive case: first, find child nodes for both nodeidx1 and nodeidx2.
					second, consider three edit we can do at this point, delete, contract, stay:
						case delete: we sort the WEDF value for each child node 
									(which represent the edit cost of delete one subtree at this child node)
									pair the child nodes on bma1 and bma2
									delete the child nodes that are not paired and their subtree 
									edit-cost = WEDF values for deleted nodes + sum of EditCost(other child node)
						case contract: we contract each child node with current node, which is link child node's child node
									to current node. The difference between current node and the contracted child node is 
									the cost of this edit.  
									edit-cost_child = the arclength of child node and current node + 
									delta WEDF between child node and a node which is on the branch of curent node and 
									the chosen child node and very close to current node + sum of EditCost(other child node)
									we can get a list of edit-costs, and the smallest one represent the best child node to be contracted
									edit-cost = min[edit-cost_child]
						case stay: we do no edit in this case
									edit-cost = sum of EditCost(all child node)
					third, compare edit-cost we get in the three case, the smallest one is the operation we want to do at this moment.
					fourth, recursively considering the three case, until:
						1. the number of child nodes in bma1 and bma2 are the same
						2. the cost of choosing case stay is the smallest
	return EditCost(root1, root2, bma1, bma2)
3. Calculate the Euclidean distance of ET and ST between each pair of points, named EucDis
4. Sum up edit-cost and EucDis, we have the edit distance to measure shape similarity between two graphs.

