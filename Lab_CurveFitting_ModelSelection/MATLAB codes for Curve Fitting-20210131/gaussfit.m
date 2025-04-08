function sse=gaussfit(params,Input,Actual_Output)
A=params(1);
x0=params(2);
sigmax=params(3);
Fitted_Curve=A*exp(-(Input-x0).*(Input-x0)/(2*sigmax*sigmax));
Error_Vector=Fitted_Curve - Actual_Output;
% When curvefitting, a typical quantity to
% minimize is the sum of squares error
sse=sum(Error_Vector.^2);
% You could also write sse as
% sse=Error_Vector(:)'*Error_Vector(:);