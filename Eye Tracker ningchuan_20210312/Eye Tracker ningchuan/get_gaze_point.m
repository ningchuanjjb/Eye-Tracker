function [infer_screenPoint_x, infer_screenPoint_y] = get_gaze_point(vector_x, vector_y, coeff_x, coeff_y)

x=vector_x;
y=vector_y;

xy=x.*y;
x2=x.*x;
y2=y.*y;

infer_screenPoint_x=coeff_x(1)+coeff_x(2).*x+coeff_x(3).*y+...
    coeff_x(4).*xy+coeff_x(5).*x2+coeff_x(6).*y2;

infer_screenPoint_y=coeff_y(1)+coeff_y(2).*x+coeff_y(3).*y+...
    coeff_y(4).*xy+coeff_y(5).*x2+coeff_y(6).*y2;
% infer_screenPoint_x=coeff_x(6)+coeff_x(5).*x+coeff_x(4).*y+...
%     coeff_x(3).*xy+coeff_x(2).*x2+coeff_x(1).*y2;
% 
% infer_screenPoint_y=coeff_y(6)+coeff_y(5).*x+coeff_y(4).*y+...
%     coeff_y(3).*xy+coeff_y(2).*x2+coeff_y(1).*y2;

end

