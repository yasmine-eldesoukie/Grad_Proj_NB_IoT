clear;
clc;
close all;

fid_r_long =fopen('F:\grad proj\matlab\real_long_bin.txt' , 'w');
fid_r =fopen('F:\grad proj\matlab\real_bin.txt' , 'w');
fid_i_long =fopen('F:\grad proj\matlab\imag_long_bin.txt' , 'w');
fid_i =fopen('F:\grad proj\matlab\imag_bin.txt' , 'w');


max= 2^15-1;
max_bits= 16+11+1;
truncated_bits=11;
min_sensed= 2^(-(truncated_bits+1));
new_zero= min_sensed;

nrs= (1448*(2^(-11)))*(1+j*1); %its true value not integer value (1448)
%real_long= zeros(1,(2^16/32)^2);
%real_long_bin= zeros((2^16/32)^2,1);
%real_bin= zeros((2^16/32)^2,1);

%imag_long= zeros(1,(2^16/32)^2);
%imag_long_bin= zeros((2^16/32)^2,1);
%imag_bin= zeros((2^16/32)^2,1);

for m=0:64:max+1 
    if (m~=max+1) 
        rx_r=m;
    else
        rx_r=max;
    end
    for n=0:64:max+1
        if (n~=max+1)
            rx_i=n;
        else
            rx_i=max;
        end    
        rx= (rx_r+j*rx_i);
        h_est= rx/nrs; %true value
        h_est_dec= h_est;

        real_long= real(h_est_dec);
        real_long_int= floor(real_long);
        real_long_bin= dec2bin(real_long_int,28);
        fprintf(fid_r_long, '%s\n', real_long_bin);

        if (real_long_int==0)
            real_approx= 0;
        elseif (real_long_int>0)
            real_approx= real_long - new_zero;
        else 
            real_approx= real_long + new_zero;
        end

        real_expec= floor(real_approx);
        real_bin= dec2bin(real_expec,17);
        fprintf(fid_r, '%s\n', real_bin);


        %% imag part
        imag_long= imag(h_est_dec);
        imag_long_int= floor(imag_long);
        imag_long_bin_32= dec2bin(imag_long_int,32); 
        %get the 28 lSB bits in a 1x1 cell
        imag_long_bin_28= extractBetween(imag_long_bin_32, 4,31);
        %convert to char
        imag_long_bin= char(imag_long_bin_28);
        fprintf(fid_i_long, '%s\n', imag_long_bin);


        if (imag_long_int==0)
            imag_approx= 0;
        elseif (imag_long_int>0)
            imag_approx= imag_long - new_zero;
        else 
            imag_approx= imag_long + new_zero;
        end

        imag_expec= floor(imag_approx);
        imag_bin= dec2bin(imag_expec,17);
        fprintf(fid_i, '%s\n', imag_bin);

    end
end

fclose(fid_r_long);
fclose(fid_r);
fclose(fid_i_long);
fclose(fid_i);
%writematrix(real_long_bin,'F:\grad proj\matlab\real_long.txt')
%writematrix(real_bin,'F:\grad proj\matlab\real_long(counter)_bin.txt')
%writematrix(imag_long_bin,'F:\grad proj\matlab\imag_long.txt')
%writematrix(imag_bin,'F:\grad proj\matlab\imag_long_bin.txt')
