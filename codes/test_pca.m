function [im_r,im_g,im_b]=test_pca(R,G,B)
% 主成分分析
%im = imread('原图.jpg'); 
%figure(1),subplot(2,1,1);imshow(im);title('原图'); 
r=rgb2gray(R);
g=rgb2gray(G);
b=rgb2gray(B);
[im_R] = double(r); 
[im_G] = double(g); 
[im_B] = double(b); 
[M,N,color] = size(r); 
RGB(:,:,1)=zeros(M,N); 
RGB(:,:,2)=zeros(M,N); 
RGB(:,:,3)=zeros(M,N);  
im_Mx = 0; 
for i = 1:M 
    for j = 1:N 
        im_S = [im_R(i,j),im_G(i,j),im_B(i,j)]; 
        im_Mx = im_Mx + im_S; 
    end
end
im_Mx = im_Mx/(M * N); 
im_Cx = 0; 
for i = 1:M 
    for j = 1:N 
        im_S = [im_R(i,j),im_G(i,j),im_B(i,j)]';  
        im_Cx = im_Cx + im_S * im_S'; 
    end
end
im_Cx = im_Cx/(M * N) - im_Mx * im_Mx'; 
[im_A,im_latent] = eigs(im_Cx);  
for i = 1 : M 
    for j = 1 : N 
        im_X = [im_R(i,j),im_G(i,j),im_G(i,j)]';
        im_Y = im_A'*im_X; 
        im_Y = im_Y'; 
        im_R(i,j) = im_Y(1); 
        im_G(i,j) = im_Y(2); 
        im_B(i,j) = im_Y(3); 
    end
end
for i = 1 : M 
    for j = 1 : N 
        im_Y = [im_R(i,j),im_G(i,j),im_B(i,j)]'; 
        im_X = im_A*im_Y;  
        im_X = im_X'; 
        im_r(i,j) = im_X(1); 
        im_g(i,j) = im_X(2); 
        im_b(i,j) = im_X(3); 
    end
end
figure();imshow(uint8(im_r));
figure();imshow(uint8(im_g));
figure();imshow(uint8(im_b));
RGB(:,:,1)=im_r; 
RGB(:,:,2)=im_g; 
RGB(:,:,3)=im_b; 
RGB=uint8(RGB);
imwrite(RGB,'PCA.PNG');
figure();imshow(RGB);title('PCA.PNG');
end
