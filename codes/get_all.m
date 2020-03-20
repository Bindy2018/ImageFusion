%%%--------main-------------------------
close all;
clear;
clc;
%%%%%%%%获取偏振信息--------------------------------------------------------
imgR = imread('630.jpg');
imgG = imread('550.jpg');
imgB = imread('470.jpg');

num = 8;  %邻域处理规格

i0 = double(rgb2gray(imread('偏振\0.jpg'))); 
i90 = double(rgb2gray(imread('偏振\90.jpg')));
i45 = double(rgb2gray(imread('偏振\45.jpg')));
i135 = double(rgb2gray(imread('偏振\135.jpg')));
iI = double(rgb2gray(imread('原图.jpg')));
[mm,nn] = size(i0);
I = zeros(mm,nn);
Q = zeros(mm,nn);
U = zeros(mm,nn);
dolp = zeros(mm,nn);
pI = zeros(mm,nn);
pI = i0+i90;
Q = i0 - i90;
U = i45 - i135;
dolp = sqrt(Q.^2+U.^2)./pI;    
dolp(dolp>=1) = 0;
       filename = sprintf('dolp.png');
       imwrite(dolp,filename);
dolp = test_normal(dolp);

aop = (1/2)*atan(U./Q);
       filename = sprintf('aop.png');
       imwrite(aop,filename);
%计算orin
tan_a = zeros(mm,nn);
cos_c = zeros(mm,nn);
tan_b = zeros(mm,nn);
tan_2a = zeros(mm,nn);
orin = zeros(mm,nn);

tan_a = sqrt((pI-Q)./(pI+Q));
cos_c = cos(U./((pI+Q).*tan_a));
tan_b = tan_a.*tan_a;
tan_2a = (2.*tan_a)./(1-tan_b);
orin = 0.5.*atan(cos_c.*tan_2a);
      filename = sprintf('orin.png');
      imwrite(orin,filename);
%归一化orin
pOrin = test_normal(orin);
%       imagesc(pOrin);title('pOrin');colorbar;

fprintf('偏振分量获取完成，开始获取多光谱信息……\n');
%%%%%%获取多光谱信息--------------------------------------------------------
[outR,outG,outB] = test_pca(imgR,imgG,imgB);
      filename = sprintf('pca_R.png');
      imwrite(uint8(outR),filename);

      filename = sprintf('pca_G.png');
      imwrite(uint8(outG),filename);

      filename = sprintf('pca_B.png');
      imwrite(uint8(outB),filename);                                                                                                                                                                                              

%RGB分量转换到his空间

mH = zeros(mm,nn);
mS = zeros(mm,nn);
mI = zeros(mm,nn);
[mH,mS,mI] = rgb2his(outR,outG,outB);
% figure();imshow(mH);
%       filename=sprintf('mH.jpg');
%       imwrite(mH,filename);
% figure();imshow(mS);colorbar();
%       filename=sprintf('mS.jpg');
%       imwrite(mS,filename);
% figure();imshow(mI);colorbar();
%       filename=sprintf('mI.jpg');
%       imwrite(mI,filename);
 fprintf('多光谱分量获取完成，开始融合I分量……\n');     
%%%%获得融合的偏振图像-----------------------------------------------------
% outI=zeros(mm,nn);
outS = zeros(mm,nn);
outH = zeros(mm,nn);
mout_H = zeros(mm,nn);
%基于区域特征的小波变换，融合I分量
%归一化I
pI = test_normal(pI);
%        filename=sprintf('pI.jpg');
%        imwrite(pI,filename);
mI = test_normal(mI);
imwrite(pI,'pI.png');
imwrite(mI,'mI.png');

outI = fuBIOR(mI,pI,6,'coif2');
% figure();
% imagesc(outI);title('NPI');colorbar;
      filename = sprintf('fuse_I.png');
      imwrite(outI,filename);
%基于加权平均的图像融合,获得NDoLPI
fprintf('开始融合S分量……\n');  
outS = fuA(dolp,mS);
% figure();imagesc(outS);title('NDoLPI');colorbar;
      filename = sprintf('fuse_dolp.png');
      imwrite(outS,filename);
%基于加权平均的图像融合,获得Norin
fprintf('开始融合H分量……\n'); 
pOrin = pOrin.*2;
outH = fuA(pOrin,mH);
% figure();imagesc(outH);title('Norin');colorbar;
      filename = sprintf('fuse_orin.png');
      imwrite(outH,filename);
      
%%%%%获得最终的融合图像---------------------------------------------------
% %%%计算orin（即outH)均方根
%归一化
mout_H = test_normal(outH);
%%%采取滑块的领域处理方式
fun = @(x)rms(x(:));
area = nlfilter(mout_H,[num num],fun);
 m_outH = 1./area;
% m_outH = area;
        figure();
        imagesc(m_outH);title('area');colorbar;
% % ORIN=1./ORIN;
%归一化ORIN
m_outH = test_normal(m_outH);
        figure();
        imagesc(m_outH);title('ORIN');colorbar;
        imwrite(m_outH,'fuse_orin经邻域处理.png');
fprintf('开始算法一……\n'); 
%归一化I
m_P1 = zeros(mm,nn);
m_P2 = zeros(mm,nn);
co = zeros(mm,nn);
P1u = zeros(mm,nn);
P2u = zeros(mm,nn);
P3u = zeros(mm,nn);
P1uu = zeros(mm,nn);
P2uu =  zeros(mm,nn);
P3uu =  zeros(mm,nn);
ff = zeros(mm,nn);
%         figure();
%         imagesc(m_P1);title('I');colorbar;
%归一化DoLP
m_P1 = test_normal(outI);
m_P2 = test_normal(outS);
%    figure();
%    imagesc(m_P2);title('DoLP');colorbar;
%co为三幅图像共有的信息
co = min(m_P1,m_P2);
co = min(co,m_outH);
    % figure();
    % imagesc(co);title('co');colorbar;
%计算三幅的独有信息
P1u = m_P1-co; %I
P2u = m_P2-co; %DoLP
P3u = m_outH-co;
    % figure();
    % imagesc(P1u);title('P1u');colorbar;
    % figure();
    % imagesc(P2u);title('P2u');colorbar;
    % figure();
    % imagesc(P3u);title('P3u');colorbar;  
 P1uu = m_P1-P2u-P3u;
 P2uu = m_P2-P1u-P3u;
 P3uu = m_outH-P1u-P2u;
 %第一种变换到rgb方法
 f = hsi2rgb(P3uu,P2uu,P1uu);
     figure();
     imagesc(f);title('f');colorbar;
%  第二种直接融合的方法
 ff = cat(3,P1uu,P3uu,P2uu);
     figure();
     imagesc(ff);title('ff');colorbar;
%考虑是否采用偏振度调制
%  M_dolp = m_P2.*log(1+m_P2);
% %  M_dolp = Dolp.*log(1+Dolp);
%  f = f.*M_dolp;
%  ff = ff.*M_dolp;
%      figure();
%      imagesc(uint8(f));title('f');colorbar;
%      figure();
%      imagesc(abs(ff));title('ff');colorbar;

fprintf('运行结束！\n'); 
