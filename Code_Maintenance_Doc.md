# 2D Shape Decomposition Code Maintenance Document
By: Articulation Group(Di, Chenghao, Jialin)  
Date: 11/24/2020

### MATLAB code files: 
- __BlumMedialAxis.m__: _#modified_
    + Added new function `prune_wWEDF(bma, wedfThreshold)`
    + Changed `prune(bma, etRatio, stThreshold)` to `prune_wETST(bma, etRatio, stThreshold)`
    + Debugged `findOrAdd` to include cases of multiple boundary points being on the same bma circle
- __medialaxis.m__: _#modified_, _#translated_
    + Added `disp()`s and `plot()`s for debugging 
- __branchesforbma.m__: _#modified_
    + Debugged indexing issues and corrected condition of an if-statement
- __calculateEDF.m__: _#modified_
    + Marked and commented out unresolved bug which does not seem to affect current output.
- __branchnew.m__: _#unmodified_ 
- __medialorder.m__: _#unmodified_ 
- __calculateWEDF.m__: _#unmodified_ 
- __dijkstra.m__: _#unmodified_ 
- __sparse_to_csr.m__: _#unmodified_ 
- __readbndry.m__: _#testcode_
    + Read images for performing shape analysis.
- __saveCatBMA.m__: _#testcode_
    + Perform shape analysis on a sample cat image and saves WEDF plot to a designated path.

### Python code files: 
- __medialaxis.py__: _#tested_
- __medialorder.py__: _#testing_
- __BlumMedialAxis.py__: _#translating_
- __calculateWEDF.py__: _#translating_
- __find_contour.py__: _#testcode_
    + Get boundary points of the biggest object in a binary image.