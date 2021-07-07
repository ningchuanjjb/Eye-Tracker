function [coeff_x, coeff_y] = least_sq_calibration(vector_x, vector_y, screen_x, screen_y)


x=vector_x;
y=vector_y;
px=screen_x;
py=screen_y;
n = length(x);

xy=x.*y;
x2=x.*x;
y2=y.*y;

x2y=x2.*y;
xy2=x.*y2;
x3=x.*x2;
y3=y.*y2;

x3y=x.*x2y;
xy3=xy2.*y;
x2y2=x2.*y2;
x4=x2.*x2;
y4=y2.*y2;

pxx=px.*x;
pxy=px.*y;
pxxy=px.*x.*y;
pxx2=px.*x2;
pxy2=px.*y2;

pyx=py.*x;
pyy=py.*y;
pyxy=py.*x.*y;
pyx2=py.*x2;
pyy2=py.*y2;

M = [n, sum(x), sum(y), sum(xy), sum(x2), sum(y2);...
    sum(x), sum(x2), sum(xy), sum(x2y), sum(x3), sum(xy2);...
    sum(y), sum(xy), sum(y2), sum(xy2), sum(x2y), sum(y3);...
    sum(xy), sum(x2y), sum(xy2), sum(x2y2), sum(x3y), sum(xy3);...
    sum(x2), sum(x3), sum(x2y), sum(x3y), sum(x4), sum(x2y2);...
    sum(y2), sum(xy2), sum(y3), sum(xy3), sum(x2y2), sum(y4)];


N_x = [sum(px), sum(pxx), sum(pxy), sum(pxxy), sum(pxx2), sum(pxy2)];

N_y = [sum(py), sum(pyx), sum(pyy), sum(pyxy), sum(pyx2), sum(pyy2)];

% coeff_x = inv(M)*N_x';
% coeff_y = inv(M)*N_y';
coeff_x = M\N_x';
coeff_y = M\N_y';

end

