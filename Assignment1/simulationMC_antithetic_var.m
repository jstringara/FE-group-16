function Ftt=simulationMC_antithetic_var(F0,T,sigma,N)
% MonteCarlo simulations forward
%
%INPUT 
% F0:    forward price
% T:     time-to-maturity
% sigma: volatility
% N:     number of simulations

% extract N random numbers from a standard gaussian
g = randn(N,1);
h=1-g;
% Monte Carlo simulation (one time step)
% Compute the value of the forward at time T for each simulation
% Black Model: Ft = F0 * exp(-(sigma^2)*T*0.5 + sigma*sqrt(T)*g)
Ftt = 0.5*F0 * exp( -0.5 * sigma^2 * T  + sigma * sqrt(T) * g)+0.5*F0 * exp( -0.5 * sigma^2 * T  + sigma * sqrt(T) * h);
end