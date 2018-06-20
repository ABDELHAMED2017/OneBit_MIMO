%% developed by Lei Chu and Fei Wen

function [x, beta] = ADMM_Leo(par,s,H,N0)

    HR0 = [ real(H) -imag(H) ; imag(H) real(H) ];
    sR = [real(s) ; imag(s)];
%     par.L = 4;
    if par.L == 2
        C = eye(2*par.B);  bps = 2; %Q = bps/2; N0 = N0*Q; % 这里没有 虚拟向量扩充，所以信噪比没有变化！！
    elseif par.L == 3
        Q1 = sqrt(5);    
%         Q1 = 2;  
%         Q = 20*log10(Q1);
        C = [2*eye(2*par.B) eye(2*par.B)]/Q1; bps = 4; %N0 = N0*Q1; % ((bps/2)^2+1)
%         C = [eye(2*par.B) eye(2*par.B)]/Q1; bps = 4; %N0 = N0*Q1; % ((bps/2)^2+1)
    elseif par.L == 4
        Q1 = sqrt(21);
%         Q = 20*log10(Q1);
        C = [4*eye(2*par.B) 2*eye(2*par.B) eye(2*par.B)]/Q1; bps = 6; %N0 = N0*Q1;
    else
        disp('Not supportted at current version!!!');
    end
    HR = HR0*C;

%         2*norm(HR'*HR,2)
    
    v = zeros(par.B*bps,1);
    z = zeros(par.B*bps,1);
    w = zeros(par.B*bps,1);
    
    iter = 1e2; c = par.U*N0; epsilon = 1e-6;

%     hv =  inv(2*HR'*HR + (2*c+rho)*eye(par.B*bps)); 
   vr=[]; zr = [];
   rho_0=1;
   rho = rho_0;
   rho_t = 2.1*norm(HR'*HR,2); 
   [uu,ss,~] = svd(HR'*HR);
   Hs = HR'*sR;
% rho = rho_t;
    for k = 1:iter
          vm1 = v;
          zm1 = z; 
          if rho<rho_t
                rho = rho_0*1.15^k;
          end
          gg = 2*diag(ss) + (2*c+rho);
%           v = uu*(diag(1./gg)*(uu'*(2*Hs + rho*z + w)));
          v = uu*((uu'*(2*Hs + rho*z + w))./gg);

          %v =  inv(2*HR'*HR + (2*c+rho)*eye(par.B*bps))*(2*HR'*sR + rho*z + w);  
          %v =  (2*HR'*HR + (2*c+rho)*eye(par.B*bps))\(2*HR'*sR + rho*z + w);  

          z = sign(v - w/rho)*norm(v - w/rho,1)/(par.B*bps);
          w = w - rho*(v - z);
          
          vr = [vr, norm(v-vm1)];
          zr = [zr, norm(z-zm1)];
          if norm(v-vm1)<epsilon
                break;
          end         
    end

     quantizer = @(z) (sign(real(z)) + 1i*sign(imag(z)))/sqrt(2*par.B);
     xRest = quantizer(v); 

     x0 = C*xRest; 

     x = (x0(1:par.B,1)+1i*x0(par.B+1:2*par.B,1)); %*Q  *Q*par.B  1/sqrt(2*par.B)*
    
    beta = real(x'*H'*s)/(norm(H*x,2)^2+par.U*N0); 

end




