% expfit.m is a function that returns sse, the sum of squared errors which
% will be minimized with respect to parameters for an exponential fitted curve
function sse=expfit(params,Input,Actual_Output)

A=params(1);                        % first parameter is amplitude
lamda=params(2);                    % 2nd parameter is decay constant
Fitted_Curve=A.*exp(-lamda*Input);  % define the curve
Error_Vector=Fitted_Curve - Actual_Output;  % error is difference between curve and data
% When curvefitting, a typical quantity to
% minimize is the sum of squares error
sse=sum(Error_Vector.^2);
% You could also write sse as
% sse=Error_Vector(:)'*Error_Vector(:);