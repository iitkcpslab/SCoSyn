# SCoSyn (pronounced "esco-syn")  
a tool for **S**pecification Guided Automated **Co**ntroller **Syn**thesis  


*** Requirements ***  
Matlab2020a  
BREACH1.5.2  
python3.6  
libraries: networkx, matplotlib, py-xml, graphviz  
(The author uses Ubuntu16.04 OS)  
  
  
**** STEPS ****  
1. Download breach and run script InstallBreach.m and InitBreach.m.   
2. run the script main_script.m in src folder  
3. In the command prompt, select the model number and
specification number.  
  
    
This repo contains two folders:  
src/ contains the source code of SCSyn.  
models/ contains the Simulink models used for experiments.   
utils/ folder contains some auxiliary scripts.    
logs/ folder contains logs generation during execution.  
images/ contains some plots generated during experiments.  
breach/ contains the BREACH toolbox.  
stl/ contains the specifications used in experiments.    
comp/ contains the experiments done for comparison.  
Also comparison with [18] is embedded within the main script 
with modelno 16. For more details look at code init_demo.m 
within src/ folder.

