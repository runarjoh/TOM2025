    
    %-----------------------------------------------------------------------------------------------------------
    %Simulation of search on a NK landscape
    
    %You have 100 periods and can try one choice configuration
    %in each period. You will then be told the performance of this choice
    %configuration.
    
    %Your score is the maximum performance
    %of the choice configurations you tried during the 100 periods
    
    %You can change the search algorithm - look for a segment starting with
    
    %=======================
    %SEARCH ALGORITHM
    %=======================
    
    %That segment specifies the choice configuration tested in any
    %given period, t. The choice can depend on the period (t), on n,k,
    %and also on the choices and performance observed so far.
    %Your goal is to find a search strategy that maximizes the average
    %final performance (which will be based on, at least, 100 000 simulations)
    
    %You can change that segment in any way
    %But the choice can only depend on t,n,k,choices and performances
    %t = period
    %choices = choices vectors so far:
    % choice(1)= choice vector in period 1, choice(2)= choice vector in period 2, etc
    % performances = performances so far
    % performances(1) = performance in period 1, performances(2)= performance in period 2 etc
    
    %-----------------------------------------------------------------------------------------------------------
    
    
    clear all
    clc
    
    % Fixed parameters
    n = 10; % N in NK
    k = 3; % K in NK
    number_of_periods  = 100; % Number of periods (keep this at 100)
    number_of_simulations = 100000; % Number of simulations/iterations (you can vary this at your will)
    scores = zeros(number_of_simulations,1); % array to store final scores (max performance of a single simulation)
    
    tic %start clock
    
    % repeat the simulation for many runs
    for ns = 1:number_of_simulations
        if(mod(ns,1000)==0)
            ns %prints, every 1000 simulations, the number of simulations completed so far
        end
    
        choices = zeros(number_of_periods,n);
        performances = zeros(number_of_periods,1);
    
        % Here select fitness values and dependencies
        fitness_values = rand(n,2^(k+1)); % fitness components
        dependencies = depend(n,k);
    
        % loop from period 1 to period "per"
        for t = 1:number_of_periods
    
      %===================================================================
            % THE SEARCH ALGORITHM: This is the only part you can edit
      %====================================================================
    
    % Algorithm created by Runar J. Solberg, Ali Pourentezari and Shikhar Bhardwaj as part of TOM PhD Summer School 2025 Group Project
    % Started out as a genetic algorithm, but ended in simplified evolutionary
    % algorithm with mutation only and parameters for probability of long jumps
    % as well as the number of bits to flip if a long jump is performed.
    
    % initialisation on the very first period of a run
    if t == 1
        LongJumpProb  = 0.6;   % Parameter 1: probability to do a multi-bit "long jump"
        LongJumpBits  = 7;      % Parameter 2: number of bits flipped in a long jump
    
        % persistent state across the 100 periods
        visitedChoice   = false(1, 2^n);    % duplicate filter (size 1024)
        bestPerf      = -Inf;             % best fitness so far
        bestConfig    = randi([0 1], 1, n); % will be overwritten below
    end
    
    % Helper which label every 10-bit string in an index with a serial number from 0 - 1023
    vec2int = @(v) v * (2.^(n-1:-1:0))';
    
    % choose configuration for this period
    if t == 1
        choice_configuration = randi([0 1], 1, n);
        visitedChoice(vec2int(choice_configuration)+1) = true;
    else
        % 1) update best-so-far record with last period's result
        lastPerf = performances(t-1);
        if lastPerf > bestPerf
            bestPerf   = lastPerf;
            bestConfig = choices(t-1,:);
        end
    
        %  2) generate candidate by mutation only
        if rand < LongJumpProb
            % long jump: flip LongJumpBits random positions
            cand = bestConfig;
            cand(randperm(n, LongJumpBits)) = 1 - cand(randperm(n, LongJumpBits));
        else
            % local 1-bit mutation; retry until unseen
            retry = 0;
            while true
                cand = bestConfig;
                cand(randi(n)) = 1 - cand(randi(n));
                if ~visitedCoice(vec2int(cand)+1) || retry > n
                    break
                end
                retry = retry + 1;
            end
        end
    
        %  3) final duplicate check
        key = vec2int(cand)+1;
        if visitedChoice(key)
            unseen       = find(~visitedChoice, 1);          % guaranteed to exist
            cand         = bitget(unseen-1, n:-1:1);       % convert int → vector
            key          = unseen;
        end
    
        % -------- 4) save choice and mark visited -------------------
        choice_configuration     = cand;
        visitedChoice(key)         = true;
    end
    
    
       %===================================================================
            % THE SEARCH ALGORITHM ENDS HERE
      %====================================================================
           
            % we calculate performance of the selected choice vector
            current_performance = perffunc(choice_configuration,k,n,dependencies,fitness_values); % calculate the performance of this choice
    
            % we save performance and choices to the respective vectors
            choices(t,:) = choice_configuration;
            performances(t) = current_performance;
    
        end % end of all periods
    
        % after all time periods (t) we calculate the score
        scores(ns) = max(performances); %  the score is the max of this run
    
    end %end of all simulations
    
    avg_score = mean(scores); %calculate average score
    
    toc %end clock and print time it took
    
    fprintf('\n Average score is %0.4f',avg_score)
    fprintf('\n ')
    
    %-----------------------------------------------------------------------------------------------------------
    
    %% BELOW ARE FUNCTIONS SPEFICYING THE DEPENDENCIES AND THE FITNESSES
    
    function dep = depend(n,k)
    
    % Here select interdependencies: which k others does a given dimension depend on?
    % 1) nu = list of integers 1,2,..,n.
    % 2) setdiff(A,B) returns the data in A that is not in B.
    % We delete the number i (because dimension i should not be selected)
    % 3) randsample: now we select k values from the resulting list
    
    nu = 1:n;
    dep = zeros(n,k);
    for i = 1:n
        vs=setdiff(nu,i);
        dep(i,:) = randsample(vs,k);
    end
    end
        
    function perf = perffunc(choice,k,n,dependencies,fitness_values)
    ll = 0:1:(k+1)-1;
    binv = 2.^ll;
    % binv = 2^0,2^1,...,2^k
    % this is used to index the different choice vectors
    % each choice vector has a number associated with it
    % using the binary representation
    
    % Next
    % create a matrix "mat" with n rows and k+1 columns
    % The matrix specifies which dimensions the fitness contribution
    % of a given dimension depends on
    
    mat = zeros(n, k + 1);
    mat(:,1) = choice';
    mat(:,2:end) = choice(dependencies);
    % Compute binary numbers for each row using matrix multiplication
    nos = sum(mat.*binv,2);
    % this gives each choice vector in the rows a unique number
    % for example 0101 = 5 since (starting from the right): 1*2^0 + 0*2^1 + 1*2^2 + 0*2^3 = 1+0+4+0 = 5
    % then I know that the fitness contribution of 0101 for row i (corresponding to dimension i) is fitness_values(i,5)
    nos = nos+1; % add one since index starts at 1
    %Compute fitness: just find relevant value in fitness_values matrix
    perf = mean(fitness_values(sub2ind(size(fitness_values), (1:n)', nos)));
    end
    

