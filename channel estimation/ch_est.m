clear;
clc;
close all;

truncated_bits=11;
min_sensed= 2^(-(truncated_bits+1));
new_zero= min_sensed;

rx = [(1234+j*3456) (1122-j*1732) (15567+j*1077) (15507+j*1097);...
       (1034+j*3496) (13322-j*1232) (11567+j*1007) (1527+j*1007)]
            
nrs= (1448)*[(1+j*1) (1+j*1) (1+j*1) (1+j*1);...
             (1+j*1) (1+j*1) (1+j*1) (1+ j*1)]
   
%rx_arranged= [rx_seq(1,1) rx_seq(1,3) rx_seq()]         

for v=1:1:8
    n=((v>4)+1); %1 or 2
    m=mod(v-1,4)+1; % 1 to 4
    h_r(n,m)= floor((real(rx(n,m))*real(nrs(n,m))+imag(rx(n,m))*imag(nrs(n,m)))/2048) %(1,1)>(1,3)>(2,1)>(2,3)>(1,2)>(1,4)...
    h_i(n,m)= floor((imag(rx(n,m))*real(nrs(n,m))-real(rx(n,m))*imag(nrs(n,m)))/2048)
end

%% Real
h_r_avg= floor(((h_r(1,:)+h_r(2,:))/2))
E1_r= h_r_avg(1)
E2_r= h_r_avg(2)
E3_r= h_r_avg(3)
E4_r= h_r_avg(4)

%for m=0:2:5
    v_shift=0
 if (v_shift==0 | v_shift==3)
    h0_r=  E1_r
    h1_r=  (2*E1_r+E3_r)*(21/64)
    h2_r=  (E1_r+2*E3_r)*(21/64)
    h3_r=  E3_r
    h4_r=  (2*E2_r+E3_r)*(21/64)
    h5_r=  (E2_r+2*E3_r)*(21/64)
    h6_r=  E2_r
    h7_r=  (2*E2_r+E4_r)*(21/64)
    h8_r=  (E2_r+2*E4_r)*(21/64)
    h9_r=  E4_r
    h10_r= (4*E4_r-E2_r)*(21/64)
    h11_r= (5*E4_r-2*E2_r)*(21/64)
 elseif (v_shift==1 | v_shift==4)
    h0_r=  (4*E1_r-E3_r)*(21/64)
    h1_r=  E1_r
    h2_r=  (2*E1_r+E3_r)*(21/64)
    h3_r=  (E1_r+2*E3_r)*(21/64)
    h4_r=  E3_r
    h5_r=  (E2_r+2*E3_r)*(21/64)
    h6_r=  (2*E2_r+E3_r)*(21/64)
    h7_r=  E2_r
    h8_r=  (2*E2_r+E4_r)*(21/64)
    h9_r=  (E2_r+2*E4_r)*(21/64)
    h10_r= E4_r
    h11_r= (4*E4_r-E2_r)*(21/64)
 else 
    h0_r=  (5*E1_r-2*E3_r)*(21/64)
    h1_r=  (4*E1_r-E3_r)*(21/64)
    h2_r=  E1_r
    h3_r=  (2*E1_r+E3_r)*(21/64)
    h4_r=  (E1_r+2*E3_r)*(21/64)
    h5_r=  E3_r
    h6_r=  (2*E3_r+E2_r)*(21/64)
    h7_r=  (E3_r+2*E2_r)*(21/64)
    h8_r=  E2_r
    h9_r=  (2*E2_r+E4_r)*(21/64)
    h10_r= (E2_r+2*E4_r)*(21/64)
    h11_r= E4_r
 end
%% Imag
h_i_avg= floor(((h_i(1,:)+h_i(2,:))/2))
E1_i= h_i_avg(1)
E2_i= h_i_avg(2)
E3_i= h_i_avg(3)
E4_i= h_i_avg(4)

%for m=0:2:5
 if (v_shift==0 | v_shift==3)
    h0_i=  E1_i
    h1_i=  (2*E1_i+E3_i)*(21/64)
    h2_i=  (E1_i+2*E3_i)*(21/64)
    h3_i=  E3_i
    h4_i=  (2*E2_i+E3_i)*(21/64)
    h5_i=  (E2_i+2*E3_i)*(21/64)
    h6_i=  E2_i
    h7_i=  (2*E2_i+E4_i)*(21/64)
    h8_i=  (E2_i+2*E4_i)*(21/64)
    h9_i=  E4_i
    h10_i= (4*E4_i-E2_i)*(21/64)
    h11_i= (5*E4_i-2*E2_i)*(21/64)
 elseif (v_shift==1 | v_shift==4)
    h0_i=  (4*E1_i-E3_i)*(21/64)
    h1_i=  E1_i
    h2_i=  (2*E1_i+E3_i)*(21/64)
    h3_i=  (E1_i+2*E3_i)*(21/64)
    h4_i=  E3_i
    h5_i=  (E2_i+2*E3_i)*(21/64)
    h6_i=  (2*E2_i+E3_i)*(21/64)
    h7_i=  E2_i
    h8_i=  (2*E2_i+E4_i)*(21/64)
    h9_i=  (E2_i+2*E4_i)*(21/64)
    h10_i= E4_i
    h11_i= (4*E4_i-E2_i)*(21/64)
 else 
    h0_i=  (5*E1_i-2*E3_i)*(21/64)
    h1_i=  (4*E1_i-E3_i)*(21/64)
    h2_i=  E1_i
    h3_i=  (2*E1_i+E3_i)*(21/64)
    h4_i=  (E1_i+2*E3_i)*(21/64)
    h5_i=  E3_i
    h6_i=  (2*E3_i+E2_i)*(21/64)
    h7_i=  (E3_i+2*E2_i)*(21/64)
    h8_i=  E2_i
    h9_i=  (2*E2_i+E4_i)*(21/64)
    h10_i= (E2_i+2*E4_i)*(21/64)
    h11_i= E4_i
 end



%% h_est_dec= h_est;
% 
%         real_long= real(h_est_dec)
%         real_long_int= floor(real_long)
% 
%         if (real_long_int==0)
%             real_approx= 0;
%         elseif (real_long_int>0)
%             real_approx= real_long - new_zero;
%         else 
%             real_approx= real_long + new_zero;
%         end
%         real_expec= floor(real_approx);
%         
%         imag_long= imag(h_est_dec);
%         imag_long_int= floor(imag_long);
% 
%         if (imag_long_int==0)
%             imag_approx= 0;
%         elseif (imag_long_int>0)
%             imag_approx= imag_long - new_zero;
%         else 
%             imag_approx= imag_long + new_zero;
%         end
% 
%         imag_expec= floor(imag_approx);
%         
%         h_est_expec= real_expec + j* imag_expec

%end


