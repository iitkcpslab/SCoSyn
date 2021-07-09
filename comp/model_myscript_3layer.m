tic
InitBreach;
open_system('model')
quad_vars;
mdl='model';

% Parameters
max_rob = 100;              % initial robustness is between -max_rob, +max_rob
rob_up_lim = -max_rob;  % stops when rob_up is below 
rob_low_lim = max_rob; 
rob_diff_lim = -inf;

%phi_qsiso = 'Z[t]>5';
phi_qsiso = '(ev_[0,7] (Z[t] > 0.8*Zref[t])) and (ev_[0,15] (alw_[0,15](abs(Z[t]-Zref[t]) < 0.01))) and (alw_[0,30] (Z[t] < 1.01*Zref[t]))';


obsInfo = rlNumericSpec([3 1],...
    'LowerLimit',[-inf -inf  0]',...
    'UpperLimit',[inf inf inf]');
obsInfo.Name = 'observations';
obsInfo.Description = 'integrated error, error, and measured Z';
numObservations = obsInfo.Dimension(1);

actInfo = rlNumericSpec([1 1]);
actInfo.Name = 'u1';
numActions = actInfo.Dimension(1);

env = rlSimulinkEnv('model','model/RL Agent',...
    obsInfo,actInfo);

env.ResetFcn = @(in)localResetFcn(in);
%Ts = 1.0;
Ts = 1;
Tf = 30;
rng(0)

statePath = [
    sequenceInputLayer(numObservations,'Normalization','none','Name','State')
    fullyConnectedLayer(50,'Name','CriticStateFC1')
    reluLayer('Name','CriticRelu1')
    fullyConnectedLayer(25,'Name','CriticStateFC2')];
actionPath = [
    sequenceInputLayer(numActions,'Normalization','none','Name','Action')
    reluLayer('Name','CriticCommonRelua1')
    fullyConnectedLayer(25,'Name','CriticActionFC1')];
commonPath = [
    additionLayer(2,'Name','add')
    reluLayer('Name','CriticCommonRelu')
    reluLayer('Name','CriticCommonReluc1')
    fullyConnectedLayer(1,'Name','CriticOutput')];

criticNetwork = layerGraph();
criticNetwork = addLayers(criticNetwork,statePath);
criticNetwork = addLayers(criticNetwork,actionPath);
criticNetwork = addLayers(criticNetwork,commonPath);
criticNetwork = connectLayers(criticNetwork,'CriticStateFC2','add/in1');
criticNetwork = connectLayers(criticNetwork,'CriticActionFC1','add/in2');

%figure
%plot(criticNetwork)

criticOpts = rlRepresentationOptions('LearnRate',1e-01,'GradientThreshold',1);
critic = rlQValueRepresentation(criticNetwork,obsInfo,actInfo,'Observation',{'State'},'Action',{'Action'},criticOpts);

actorNetwork = [
    sequenceInputLayer(numObservations,'Normalization','none','Name','State')
    fullyConnectedLayer(3, 'Name','actorFC')
    reluLayer('Name','CriticCommonRelu')
    tanhLayer('Name','actorTanh')
    fullyConnectedLayer(numActions,'Name','Action')
    ];

actorOptions = rlRepresentationOptions('LearnRate',1e-02,'GradientThreshold',1);

actor = rlDeterministicActorRepresentation(actorNetwork,obsInfo,actInfo,'Observation',{'State'},'Action',{'Action'},actorOptions);
agentOpts = rlDDPGAgentOptions(...
    'SampleTime',Ts,...
    'TargetSmoothFactor',1e-1,...
    'DiscountFactor',1.0, ...
    'MiniBatchSize',64, ...
    'ExperienceBufferLength',1e6); 
%agentOpts.NoiseOptions.StandardDeviation = 0.3;
%agentOpts.NoiseOptions.StandardDeviationDecayRate = 1e-5;


agent = rlDDPGAgent(actor,critic,agentOpts);

maxepisodes = 3000;
maxsteps = ceil(Tf/Ts);
trainOpts = rlTrainingOptions(...
    'MaxEpisodes',maxepisodes, ...
    'MaxStepsPerEpisode',maxsteps, ...
    'ScoreAveragingWindowLength',20, ...
    'Verbose',false, ...
    'Plots','training-progress',...
    'StopTrainingCriteria','AverageReward',...
    'StopTrainingValue',100);


doTraining = true;

if doTraining
    % Train the agent.
    trainingStats = train(agent,env,trainOpts);
    save("myAgent_model.mat","agent");
else
    % Load the pretrained agent for the example.
    load('myAgent_model.mat','agent')
end



dp=[];
for i=1:100
    simOpts = rlSimulationOptions('MaxSteps',maxsteps,'StopOnError','on');
    exp = sim(env,agent,simOpts);
    dp = [dp;exp.Reward.Data];
end
%plot(dp,'b-o');
figure
plot(dp,'b-o',...
    'LineWidth',2,...
    'MarkerSize',10,...
    'MarkerEdgeColor','b',...
    'MarkerFaceColor',[0.5,0.5,0.5])
    
toc
disp("rl time");
close_system('model')

function in = localResetFcn(in)

% randomize reference signal
blk = sprintf('model/Zref');
h = 3*randn + 5;
while h <= 0 || h >= 10
    h = 3*randn + 5;
end
in = setBlockParameter(in,blk,'Value',num2str(h));

% randomize initial height
h = 3*randn + 5;
while h <= 0 || h >= 10
    h = 3*randn + 5;
end
blk = 'model/QSISO/Translational/ZI';
in = setBlockParameter(in,blk,'InitialCondition',num2str(h));

end