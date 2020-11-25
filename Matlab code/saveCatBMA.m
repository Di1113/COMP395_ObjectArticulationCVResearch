function catSkeImg = saveCatBMA(picpath, img_ind)
    % convert colored image to binary 
    img_folder = 'test_pics';
    % picpath = fullfile(img_folder, picname)
    cat = rgb2gray(imread(picpath)); 

    % use threshold to filter out the background 
    % revert the binary image so now that the cat is mainly white, filter out pixeles with lumination lower than 0.68
    cat = im2bw(imcomplement(cat), 0.68); 
    % resize image to 1/5 size for faster computation 
    cat = imresize(cat, 0.2) 
    % smooth the noisy boundary 
    se=strel('disk',2);
    cat=imerode(cat,se);

    imshow(cat);
    hold on 

    % get cat boundary 
    [B, L, n, A] = bwboundaries(cat, 'noholes');
    % imshow(label2rgb(L, @jet, [.5 .5 .5]))
    % hold on
    indexMax = 0;
    sizeMax = 0;
    for i = 1:length(B)
        if length(B{i}) > sizeMax
            sizeMax = length(B{i});
            indexMax = i;
        end
    end
    boundary = B{indexMax};
    % plot(boundary,'-b')

    z = complex(boundary(:, 1), boundary(:, 2));
    bmacat = BlumMedialAxis(z);
    wedfPrct = 50;
    wedfthld = prctile(bmacat.WEDFArray, wedfPrct);
    bmacat = prune_wWEDF(bmacat, wedfthld);
    plotWithWEDF(bmacat);
    camroll(-90)
    fname = fullfile(img_folder, sprintf('catwedf%d.png', img_ind));
    saveas(gcf, fname)
end