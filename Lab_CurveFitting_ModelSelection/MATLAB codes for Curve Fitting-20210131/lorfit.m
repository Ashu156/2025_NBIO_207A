% lorfit.m is a function that returns sse, the sum of squared errors which
% will be minimized with respect to parameters for a Lorentzian fitted curve
function sse=lorfit(params,Input,Actual_Output)
A=params(1);
b=params(2);
x0=params(3);
Fitted_Curve=A./(b*b+(Input-x0).*(Input-x0));
Error_Vector=Fitted_Curve - Actual_Output;
% When curvefitting, a typical quantity to
% minimize is the sum of squares error
sse=sum(Error_Vector.^2);
% You could also write sse as
% sse=Error_Vector(:)'*Error_Vector(:);