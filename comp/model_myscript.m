tic
InitBreach;
%open_system('cruise_ctrl_RL')
open_system('model')
quad_vars;
%init_cc;
%mdl='cruise_ctrl_RL';
mdl='model';

% Parameters
max_rob = 100;              % initial robustness is between -max_rob, +max_rob
rob_up_lim = -max_rob;  % stops when rob_up is below 
rob_low_lim = max_rob; 
rob_diff_lim = -inf;

%phi_qsiso = 'Z[t]>5';
phi_qsiso = '(ev_[0,7] (Z[t] > 0.8*Zref[t])) and (ev_[0,15] (alw_[0,15](abs(Z[t]-Zref[t]) < 0.01))) and (alw_[0,30] (Z[t] < 1.01*Zref[t]))';
%phi_cc = '(ev_[0,1] (speed[t] > 0.9*ref_speed[t])) and (ev_[0,15] alw_[0,45] (abs(speed[t]-ref_speed[t]) < 0.1 )) and (alw_[0,60] (speed[t] < 1.05*ref_speed[t]))';

%obsInfo = rlNumericSpec([4 1],...
%    'LowerLimit',[-inf 0 -inf 0]',...
%    'UpperLimit',[inf inf inf inf]');
obsInfo = rlNumericSpec([1 1],...
    'LowerLimit',[-inf ]',...
    'UpperLimit',[inf ]');

obsInfo.Name = 'observations';
obsInfo.Description = ' error';
numObservations = obsInfo.Dimension(1);

actInfo = rlNumericSpec([1 1]);
actInfo.Name = 'Action';
numActions = actInfo.Dimension(1);

%env = rlSimulinkEnv('cruise_ctrl_RL','cruise_ctrl_RL/RL Agent',...
%    obsInfo,actInfo);
env = rlSimulinkEnv('model','model/RL Agent',...
    obsInfo,actInfo);

env.ResetFcn = @(in)localResetFcn(in);
%Ts = 1.0;
Ts = 1;
Tf = 60; %30
rng(0)

statePath = [
    sequenceInputLayer(numObservations,'Normalization','none','Name','State')
    fullyConnectedLayer(50,'Name','CriticStateFC1')
    reluLayer('Name','CriticRelu1')
    fullyConnectedLayer(25,'Name','CriticStateFC2')];
actionPath = [
    sequenceInputLayer(numActions,'Normalization','none','Name','Action')
    fullyConnectedLayer(25,'Name','CriticActionFC1')];
commonPath = [
    additionLayer(2,'Name','add')
    reluLayer('Name','CriticCommonRelu')
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
    featureInputLayer(numObservations,'Normalization','none','Name','State')
    %lstmLayer(5,'OutputMode','sequence')
    fullyConnectedLayer(3, 'Name','actorFC')
    tanhLayer('Name','actorTanh')
    fullyConnectedLayer(numActions,'Name','Action')
    ];

actorOptions = rlRepresentationOptions('LearnRate',1e-02,'GradientThreshold',1);
%actor = rlDeterministicActorRepresentation(actorNetwork,obsInfo,actInfo,'Observation',{'State'},'Action',{'Action'},actorOptions);

actor = rlDeterministicActorRepresentation(actornet,obsInfo,actInfo,'Observation',{'State'},'Action',{'Action'},actorOptions);
agentOpts = rlDDPGAgentOptions(...
    'SampleTime',Ts,...
    'TargetSmoothFactor',1e-1,...
    'DiscountFactor',1.0, ...
    'MiniBatchSize',64, ...
    'ExperienceBufferLength',1e6); 
%agentOpts.NoiseOptions.StandardDeviation = 0.3;
%agentOpts.NoiseOptions.StandardDeviationDecayRate = 1e-5;


agent = rlDDPGAgent(actor,critic,agentOpts);

maxepisodes = 30;
maxsteps = ceil(Tf/Ts);
trainOpts = rlTrainingOptions(...
    'MaxEpisodes',maxepisodes, ...
    'MaxStepsPerEpisode',maxsteps, ...
    'ScoreAveragingWindowLength',20, ...
    'Verbose',false, ...
    'Plots','training-progress',...
    'StopTrainingCriteria','AverageReward',...
    'StopTrainingValue',800);


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
for i=1:10
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
% 

plot(er,'-',...
'LineWidth',2,...
'MarkerSize',10,...
'MarkerEdgeColor','b',...
'MarkerFaceColor',[0.5,0.5,0.5])
hold on
plot(ar,'r',...
'LineWidth',2,...
'MarkerSize',10,...
'MarkerEdgeColor','b',...
'MarkerFaceColor',[0.5,0.5,0.5])

xlabel('Episode')
ylabel('Reward')

%trainingStats.SimulationInfo(1).logsout

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
