pics=dir('/Users/di/Documents/Oxy/COMP395-398 CV/blackcat pics/24fps/*out*.png');
for k=1:length(pics)
   picname = pics(k).name
   picpath = fullfile("/Users/di/Documents/Oxy/COMP395-398 CV/blackcat pics/24fps", picname);
   saveCatBMA(picpath, k)
end