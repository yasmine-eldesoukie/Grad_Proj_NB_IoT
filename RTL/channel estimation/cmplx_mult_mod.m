clear;
clc;
close all; 
 
max= 2^15-1;
 
fid_r_p_p =fopen('F:\grad proj\matlab\h_r_bin_pos_pos.txt' , 'w');
fid_i_p_p =fopen('F:\grad proj\matlab\h_i_bin_pos_pos.txt' , 'w');

nrs= (1448)*(1+j*1); %its true value not integer value (1448)

for m=-max-1:32:max+1 
    if (m==(-max-1)) 
        rx_r=-m-2^15-1;
    elseif (m==(max+1))
        rx_r=0;
    elseif (m<0)
        rx_r=-m-2^15;
    elseif (m==0)
        rx_r=2^15-m-1;
    else
        rx_r=2^15-m;
    end       
    for n=-max-1:32:max+1
        if (n==(-max-1)) 
            rx_i=-n-2^15-1;
        elseif (n==(max+1))
            rx_i=0;
        elseif (n<0)
            rx_i=-n-2^15;
        elseif (n==0)
            rx_i=2^15-n-1;
        else
            rx_i=2^15-n;
        end 
       
        %% real part
        h_r= floor((rx_r*real(nrs)+rx_i*imag(nrs))/2048); %sqrt(1448^2+1448^2) * true value to be able to represent it in binary, this value is approx 2048
        h_r_bin= char(extractBetween(dec2bin(h_r,32),32-16,32));
        fprintf(fid_r_p_p, '%s\n', h_r_bin);

        %% imag part
        h_i= floor((rx_i*real(nrs)-rx_r*imag(nrs))/2048);
        h_i_bin= char(extractBetween(dec2bin(h_i,32),32-16,32));
        fprintf(fid_i_p_p , '%s\n', h_i_bin);
    end
 end
fclose(fid_r_p_p);
fclose(fid_i_p_p);

%% %%%%%%%%%%%%%%%%%%%% pos_neg %%%%%%%%%%%%%%%%%%%%%

max= 2^15-1;

fid_r_p_n =fopen('F:\grad proj\matlab\h_r_bin_pos_neg.txt' , 'w');
fid_i_p_n =fopen('F:\grad proj\matlab\h_i_bin_pos_neg.txt' , 'w');

nrs= (1448)*(1-j*1); %its true value not integer value (1448)

for m=-max-1:32:max+1 
    if (m==(-max-1)) 
        rx_r=-m-2^15-1;
    elseif (m==(max+1))
        rx_r=0;
    elseif (m<0)
        rx_r=-m-2^15;
    elseif (m==0)
        rx_r=2^15-m-1;
    else
        rx_r=2^15-m;
    end       
    for n=-max-1:32:max+1
        if (n==(-max-1)) 
            rx_i=-n-2^15-1;
        elseif (n==(max+1))
            rx_i=0;
        elseif (n<0)
            rx_i=-n-2^15;
        elseif (n==0)
            rx_i=2^15-n-1;
        else
            rx_i=2^15-n;
        end 
        h_r=floor((rx_r*real(nrs)+rx_i*imag(nrs))/2048); %sqrt(1448^2+1448^2) * true value to be able to represent it in binary, this value is approx 2048
        h_r_bin= char(extractBetween(dec2bin(h_r,32),32-16,32));
        fprintf(fid_r_p_n, '%s\n', h_r_bin);

        %% imag part
        h_i=floor((rx_i*real(nrs)-rx_r*imag(nrs))/2048);
        h_i_bin= char(extractBetween(dec2bin(h_i,32),32-16,32));
        fprintf(fid_i_p_n , '%s\n', h_i_bin);

    end
end
fclose(fid_r_p_n);
fclose(fid_i_p_n);

%% %%%%%%%%%%%%%%%%%%%% neg_pos %%%%%%%%%%%%%%%%%%%%%

max= 2^15-1;

fid_r_n_p =fopen('F:\grad proj\matlab\h_r_bin_neg_pos.txt' , 'w');
fid_i_n_p =fopen('F:\grad proj\matlab\h_i_bin_neg_pos.txt' , 'w');

nrs= (1448)*(-1+j*1); %its true value not integer value (1448)

for m=-max-1:32:max+1 
    if (m==(-max-1)) 
        rx_r=-m-2^15-1;
    elseif (m==(max+1))
        rx_r=0;
    elseif (m<0)
        rx_r=-m-2^15;
    elseif (m==0)
        rx_r=2^15-m-1;
    else
        rx_r=2^15-m;
    end       
    for n=-max-1:32:max+1
        if (n==(-max-1)) 
            rx_i=-n-2^15-1;
        elseif (n==(max+1))
            rx_i=0;
        elseif (n<0)
            rx_i=-n-2^15;
        elseif (n==0)
            rx_i=2^15-n-1;
        else
            rx_i=2^15-n;
        end 
        h_r=floor((rx_r*real(nrs)+rx_i*imag(nrs))/2048); %sqrt(1448^2+1448^2) * true value to be able to represent it in binary, this value is approx 2048
        h_r_bin= char(extractBetween(dec2bin(h_r,32),32-16,32));
        fprintf(fid_r_n_p, '%s\n', h_r_bin);

        %% imag part
        h_i=floor((rx_i*real(nrs)-rx_r*imag(nrs))/2048);
        h_i_bin= char(extractBetween(dec2bin(h_i,32),32-16,32));
        fprintf(fid_i_n_p , '%s\n', h_i_bin);

    end
end
fclose(fid_r_n_p);
fclose(fid_i_n_p);

% %%%%%%%%%%%%%%%%%%%% neg_neg %%%%%%%%%%%%%%%%%%%%%

max= 2^15-1;

fid_r_n_n =fopen('F:\grad proj\matlab\h_r_bin_neg_neg.txt' , 'w');
fid_i_n_n =fopen('F:\grad proj\matlab\h_i_bin_neg_neg.txt' , 'w');

nrs= (1448)*(-1-j*1); %its true value not integer value (1448)

for m=-max-1:32:max+1 
    if (m==(-max-1)) 
        rx_r=-m-2^15-1;
    elseif (m==(max+1))
        rx_r=0;
    elseif (m<0)
        rx_r=-m-2^15;
    elseif (m==0)
        rx_r=2^15-m-1;
    else
        rx_r=2^15-m;
    end       
    for n=-max-1:32:max+1
        if (n==(-max-1)) 
            rx_i=-n-2^15-1;
        elseif (n==(max+1))
            rx_i=0;
        elseif (n<0)
            rx_i=-n-2^15;
        elseif (n==0)
            rx_i=2^15-n-1;
        else
            rx_i=2^15-n;
        end 
        h_r=floor((rx_r*real(nrs)+rx_i*imag(nrs))/2048); %sqrt(1448^2+1448^2) * true value to be able to represent it in binary, this value is approx 2048
        h_r_bin= char(extractBetween(dec2bin(h_r,32),32-16,32));
        fprintf(fid_r_n_n, '%s\n', h_r_bin);

        %% imag part
        h_i=floor((rx_i*real(nrs)-rx_r*imag(nrs))/2048);
        h_i_bin= char(extractBetween(dec2bin(h_i,32),32-16,32));
        fprintf(fid_i_n_n , '%s\n', h_i_bin);

    end
end
fclose(fid_r_n_n);
fclose(fid_i_n_n);






