%% Eating Cake
% Utility: c_t^(1-eta)/(1-eta), eta=2
% Cake size: W_t
% Discount factor: beta
% Transition: W_t+1 = W_t - c_t
% 0 <= c_t <= W_t

clear

%% Value Function Iteration

% Parameterize the model
initial_cake = 100;
beta = .90;
tolerance = 1e-7;

% Initialize the domain
cakemax = initial_cake;
cakemin = 0;

% Define function space
degree = 10;
fspace = fundefn('cheb', degree, cakemin, cakemax);
grid = funnode(fspace);
grid = gridmake(grid);

% Set initial guess
consumption = grid/2;

% Initialize coeffs, value, iteration, error, and plotting grid
coeffs = zeros(size(grid));
val_old = coeffs;
its = 1;
error = 50000;
value_grid = 0:1:cakemax;

% Perform value function iteration
while (error > tolerance) && its < 1000
    % Plot value function
    value_plot(:,its) = funeval(coeffs, fspace, value_grid');
    % Maximize bellman
    for pt = 1:length(grid)
        [cons_new(pt,:), val_new(pt,:)] = maxbell(consumption(pt), grid(pt), beta, coeffs, fspace);
    end
    % Update initial control guess
    consumption = cons_new;
    % Fit new approximant and recover coefficients
    coeffs = funfitxy(fspace, grid, -val_new);
    % Calculate error
    error = max(abs(val_new-val_old));
    % Store old value function
    val_old = val_new;
    
    % Increment counter
    its = its+1;
    
    % Display information
    display(['Iteration ' num2str(its-1) ' solved with error ' num2str(error)]);
end

% Plot value function over iterations
for i = 1:10:size(value_plot,2)
    plot(1:size(value_plot,1),value_plot(:,i));
    hold on;
    pause(3)
end
xlabel('Cake size')
ylabel('Discounted sum of infinite horizon utilities (utils)')


% Simulate a solution, any error is because you have reached 0 (numerical
% not analytic) cake
time_horizon = 25;
cons_trajectory = zeros(time_horizon,1);
cons_start = cakemax/2;
cake_level = zeros(time_horizon+1,1);
cake_level(1) = initial_cake;

% Simulate by solving the Bellman, calculating next period's state and
% looping
for t = 1:time_horizon
    cons_trajectory(t,1) = maxbell(cons_start, cake_level(t), beta, coeffs, fspace);
    cake_level(t+1) = cake_level(t) - cons_trajectory(t,1);
    cons_start = cake_level(t+1)/2;
end
plot(1:time_horizon,cons_trajectory); hold on;
plot(1:time_horizon+1,cake_level);
xlabel('Time');
ylabel('Consumption and remaining cake size');
% Euler error calculation
for t = 1:time_horizon-1
    euler_error(t) = log10(abs(sqrt(1/(beta*(1/cons_trajectory(t+1)^2)))/cons_trajectory(t)-1)); 
end

disp(['Mean and max Euler error: (' num2str(mean(euler_error)), ',' num2str(max(euler_error)), ').']);

disp(['This implies our average loss from numerical error is $1 for every: $' num2str(10^-mean(euler_error),8), ' dollars spent.']);


%% Euler plots
% Simulate a solution, any error is because you have reached 0 (numerical
% not analytic) cake
time_horizon = 2;
cons_trajectory = zeros(cakemax,2);
cons_start = cakemax/2;
cake_level = zeros(cakemax,2);
cake_level(:,1) = 1:cakemax;

% Simulate by solving the Bellman, calculating next period's state and
% looping
for cake = 1:cakemax
    for t = 1:time_horizon
        cons_trajectory(cake,t) = maxbell(cons_start, cake_level(cake,t), beta, coeffs, fspace);
        cake_level(cake,2) = cake_level(cake,1) - cons_trajectory(cake,1);
        cons_start = cake_level(t+1)/2;
    end
end
plot(1:time_horizon,cons_trajectory); hold on;
plot(1:time_horizon+1,cake_level);
xlabel('Time');
ylabel('Consumption and remaining cake size');
% Euler error calculation
for cake = 1:cakemax
    euler_error(cake) = log10(abs(sqrt(1/(beta*(1/cons_trajectory(cake,2)^2)))/cons_trajectory(cake,1)-1));
end

plot(1:cakemax,euler_error)

%% Fixed Point Iteration
% Suppose you have mutant cake that now grows over time:
% W_t+1 = W_t - c_t + W_t^alpha
% xxxxx

% Set production function parameter
alpha = 0.36;

% Re-use function space above for W_t
coeffs = zeros(size(grid));
initial_cake = cakemax;

