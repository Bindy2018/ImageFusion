function [out]=test_normal(a)
% 归一化函数
 m = min(a(:));
 range = max(a(:)) - m;
 out = (a - m) ./ range;
% disp(out);
end
