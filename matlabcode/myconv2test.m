%myconv2test

A = [0,0,0,0,0,1,1,1,0,0;
    0,1,0,0,0,2,3,2,0,0;
    0,0,0,0,0,1,0,0,0,0;
    0,0,0,0,0,0,0,0,0,0;
    0,0,1,0,0,0,0,0,0,0;
    0,0,0,0,0,0,0,0,0,9;
    0,0,0,0,1,0,0,0,0,6;
    0,0,0,0,0,0,0,0,0,3;
    0,0,0,0,0,1,0,0,0,0;
    0,0,0,0,0,0,0,0,0,0];

kernal = zeros(3,3);
for u=1:9;kernal(u)=u;end
testkernal = kernal

convolution = myconv2(A,kernal)

correlation = myconv2(A,kernal, 'corr')

A = zeros(10,10);
A (5,5) = 1;

convolution = myconv2(A,kernal)

correlation = myconv2(A,kernal, 'corr')