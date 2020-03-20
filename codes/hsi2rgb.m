function rgb=hsi2rgb(h,s,i)
%输入图像
%几何推导法
%提取分量
% hsi=im2double(hsi);

% h=f(:,:,1)*2*pi;
% s=f(:,:,2);
% i=f(:,:,3);

%定义Ｒ，Ｇ，Ｂ三个矩阵的大小
r=zeros(size(h)); %size返回h的行列数，返回两个向量，一个是行数，一个是列数
g=zeros(size(h));
b=zeros(size(h));

%h在【0,120°）区间
sy=find((0<=h)&(h<2*pi/3));
b(sy)=i(sy).*(1-s(sy));
r(sy)=i(sy).*(1+s(sy).*cos(h(sy))./cos(pi/3-h(sy)));
g(sy)=3*i(sy)-(r(sy)+b(sy));

%h在【120°,240°）区间
sy=find((2*pi/3<=h)&(h<2*pi*2/3));
r(sy)=i(sy).*(1-s(sy));
g(sy)=i(sy).*(1+s(sy).*cos(h(sy)-2*pi/3)./cos(pi-h(sy)));
b(sy)=3*i(sy)-(r(sy)+b(sy));

%h在【240°,360°）区间
sy=find((2*pi*2/3<=h)&(h<2*pi));
g(sy)=i(sy).*(1-s(sy));
b(sy)=i(sy).*(1+s(sy).*cos(h(sy)-2*pi*2/3)./cos(5*pi/3-h(sy)));
r(sy)=3*i(sy)-(r(sy)+b(sy));

%将结果合并到rgb图像中
rgb=cat(3,r,g,b);

end
