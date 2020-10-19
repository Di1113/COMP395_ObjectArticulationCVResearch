% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% %                 Testing Prof's Sample Data                  % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% bma = matfile("blumaxisoutput_apple-1.mat",'Writable',true).blumaxis;
% % whos('-file','blumaxisoutput_apple-1.mat')
% disp(bma.pointsArray)
% plotWithWEDF(bma)

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% %               Testing Sample Data - Heart                   % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% heartboundary = [4.-2.i   5.-1.i   6.-0.5i  7.-1.i   8.-2.i   8.5-3.i   8.-4.i 7.-6.i   5.-8.i   4.-9.i   3.-8.i   1-6.i   0.-4.i  -0.5-3.i 0.-2.i   1.-1.i   2.-0.5i  3.-1.i   4.-2.i]
% bma = BlumMedialAxis((heartboundary)')
% plotWithEDF(bma)


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% %            Testing Sample Data - Gingerbread                % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
gingerbread = [9j, (1+8j), (1.5+7j), (2+5j), (1.5+3j), (0.5+1.5j), (3+1j), (4+1j), (5+1.5j), (6+2j), (7+1.5j), (7.5+1j), (8+0j), (7-1.5j), (5-2.5j), (4-2.5j), (2.5-3j), (2-4j), (2-6.5j), (2-7.5j), (2-8j), (2.5-9.5j), (3.5-11j), (4-12j), (5-13.5j), (5-14.5j), (4.5-15.5j), (2-16j), (0.5-14.5j), (-0.5-13.5j), (-1.5-12j), (-2.5-9.5j), (-4-12j), (-4.5-13j), (-5-14j), (-6-15j), (-8-16j), (-9.5-15.5j), (-10.5-14j), (-10-13j), (-9-11.5j), (-8.5-11j), (-7.5-9j), (-7-8j), (-7-7j), (-7-6j), (-6.5-4j), (-7-3j), (-9.5-2.5j), (-10.5-2j), (-11.5-1.5j), (-13+0j), (-12.5+1j), (-12+2j), (-10+2j), (-9+1.5j), (-8+1.5j), (-7+1.5j), (-6+2j), (-7+4j), (-7+6j), (-6+8j), (-5+9j), (-2.5+9.5j), 9j];
bma = BlumMedialAxis((gingerbread)')
% plotWithEDF(bma)
% input('x');
plotWithWEDF(bma)
% input('x');
% plotWithST(bma)
% input('x');
% plotWithET(bma)
matrix = bma.adjacencyMatrix;