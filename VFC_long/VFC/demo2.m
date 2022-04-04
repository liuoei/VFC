%   This is a demo for reoving outliers. In this demo, we only have two
%   images for test. If possible, the homography is given to estimate the
%   correct matches.
%   The homography of an image has this form: bikes_H1to2p.

clear all; 
close all; 

if 1
    oldcd = cd;
    cd vlfeat/toolbox
    vl_setup;
    cd(oldcd);
end
% Read images
ImgName1 = 'church1.jpg' ;
ImgName2 = 'church2.jpg' ;
I1 = imread(ImgName1) ;
I2 = imread(ImgName2) ;

[X, Y] = sift_match(I1, I2, 1.5);

% Data normalization
[nX, nY, normal]=norm2(X,Y);

% Initialization
conf.method = 'SparseVFC';
if ~exist('conf', 'var'), conf = []; end
conf = VFC_init(conf);

% Ourlier removal
tic;
switch conf.method
    case 'VFC'
        VecFld=VFC(nX, nY-nX, conf);
    case 'FastVFC'
        VecFld=FastVFC(nX, nY-nX, conf);
    case 'SparseVFC'
        VecFld=SparseVFC(nX, nY-nX, conf);
end
toc;

% Denormalization
VecFld.V=(VecFld.V+nX)*normal.yscale+repmat(normal.ym,size(Y,1),1)-X;

% Evaluation
if ~exist('CorrectIndex', 'var'), CorrectIndex = VecFld.VFCIndex; end
[precise, recall, corrRate] = evaluate(CorrectIndex, VecFld.VFCIndex, size(X,1));

% Plot results
plot_matches(I1, I2, X, Y, VecFld.VFCIndex, CorrectIndex);