% Assignment_1
%  Group 16, AA2023-2024
%

%% Clear the workspace
clear
close all
clc

%% Fix the random seed
rng(42);

%% Pricing parameters
S0=1;
K=1;
r=0.03;
TTM=1/4; 
sigma=0.22;
flag=1; % flag:  1 call, -1 put
d=0.06;

%% Quantity of interest
B=exp(-r*TTM); % Discount

%% Pricing 
F0=S0*exp(-d*TTM)/B;     % Forward in G&C Model

%% Point a
M=100; % M = simulations for MC, steps for CRR;

optionPrice = zeros(3,1);

for i=1:3
    pricingMode = i; % 1 ClosedFormula, 2 CRR, 3 Monte Carlo
    optionPrice(i) = EuropeanOptionPrice(F0,K,B,TTM,sigma,pricingMode,M,flag);
end

fprintf(['\nOPTION PRICE \n' ...
        'BlackPrice :   %.4f \n'],optionPrice(1));
fprintf('CRRPrice   :   %.4f \n',optionPrice(2));
fprintf('MCPrice    :   %.4f \n',optionPrice(3));

%% Point b

% spread is 1 bp
spread = 10^-4;

% plot Errors for CRR varing number of steps
[nCRR,errCRR]=PlotErrorCRR(F0,K,B,TTM,sigma);
% plot Errors for MC varing number of simulations N 
[nMC,stdEstim]=PlotErrorMC(F0,K,B,TTM,sigma); 

% find the optimal M for CRR and MC
M_CRR = nCRR(find(errCRR < spread,1));
M_MC = nMC(find(stdEstim < spread,1));

fprintf(['\nOPTIMAL M FOR CRR \n' ...
        'Number of intervals CRR :   %.d \n'],M_CRR);
fprintf(['\nOPTIMAL M FOR MC \n' ...
        'Number of intervals CRR :   %.d \n'],M_MC);

%% Point c


% Plot the results of CRR
figure
loglog(nCRR,errCRR)
title('CRR')
hold on
loglog(nCRR, 1./nCRR)
% cutoff
loglog(nCRR, spread * ones(length(nCRR),1))
legend('CRR','1/nCRR','cutoff')

% Plot the results of MC
figure
loglog(nMC,stdEstim)
title('MC')
hold on 
loglog(nMC,1./sqrt(nMC))
% cutoff
loglog(nMC, spread * ones(length(nMC),1))
legend('MC','1/sqrt(nMC)','cutoff')

%% Point d

% set the barrier
KI = 1.3;

M = 1000;  

% store the prices
optionPriceKI = zeros(3,1);

% closed formula
optionPriceKI(1) = EuropeanOptionKIClosed(F0,K,KI,B,TTM,sigma);
% CRR
optionPriceKI(2) = EuropeanOptionKICRR(F0,K,KI,B,TTM,sigma,M);
% monte carlo
optionPriceKI(3) = EuropeanOptionKIMC(F0,K,KI,B,TTM,sigma,M);

fprintf(['\nOPTION PRICE KI \n' ...
        'ClosedPriceKI  :   %.4f \n'],optionPriceKI(1));
fprintf('CRRPriceKI     :   %.4f \n',optionPriceKI(2));
fprintf('MCPriceKI      :   %.4f \n',optionPriceKI(3));

%% Point e

S_start = 0.7;
S_end = 1.5;

rangeS0 = linspace(S_start,S_end,100);
% compute the corresponding forward prices
rangeF0 = rangeS0*exp(-d*TTM)/B;

M = 10000;

% closed formula vegas
vegasClosed = zeros(length(rangeS0),1);
for i = 1:length(rangeS0)
    vegasClosed(i) = VegaKI(rangeF0(i),K,KI,B,TTM,sigma,M,3);
end

% MC vegas
vegasMC = zeros(length(rangeS0),1);
for i = 1:length(rangeS0)
    vegasMC(i) = VegaKI(rangeF0(i),K,KI,B,TTM,sigma,M,2);
end

% CRR vegas
vegasCRR = zeros(length(rangeS0),1);
for i = 1:length(rangeS0)
    vegasCRR(i) = VegaKI(rangeF0(i),K,KI,B,TTM,sigma,M,1);
end

% plot the results
figure
subplot(1,2,1)
plot(rangeS0,vegasClosed)
title('Vega Closed Formula')
xlabel('S0')
ylabel('Vega')
hold on
plot(rangeS0,vegasMC)
title('Vega Monte Carlo')
xlabel('S0')
ylabel('Vega')

legend('Closed','MC')


subplot(1,2,2)
plot(rangeS0,vegasClosed)
title('Vega Closed Formula')
xlabel('S0')
ylabel('Vega')
hold on 
plot(rangeS0,vegasCRR)
title('Vega CRR')
xlabel('S0')
ylabel('Vega')

legend('Closed','CRR')

%% MC trick

vegasTrick = zeros(length(rangeS0),1);
for i = 1:length(rangeS0)
    vegasTrick(i) = VegaMCTrick(rangeF0(i),K,KI,B,TTM,sigma,M);
end

figure
plot(rangeS0,vegasTrick)
hold on
plot(rangeS0,vegasClosed)
title('Vega Monte Carlo Trick')
xlabel('S0')
ylabel('Vega')

legend('Trick','Closed')

%% Point f


[nMCAV,stdEstimAV]=PlotErrorMCAV(F0,K,B,TTM,sigma);

% Plot the results of MC
figure
loglog(nMCAV,stdEstimAV)
title('MC antithetic variable')
hold on 
loglog(nMCAV,1./sqrt(nMCAV))
% cutoff
loglog(nMCAV, spread * ones(length(nMCAV),1))
loglog(nMC,stdEstim)

legend('MC AV','1/sqrt(nMC)','cutoff','MC')