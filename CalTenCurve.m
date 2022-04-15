%==========================================================================
% This matlab code is used to process strandard stress-strain curve. It can
% calculate Young's modulus, strength, breaking strain and toughness.
% Author: Qichen Zhou, Queen Mary University of London, SEMS
% Date: 8/April/2022
% Update: 15/April/2022
% Notes: 
%        (1)Please put this program and data in one folder and the version
%           of MATLAB is at least R2019a;
%        (2)The name of files must be pure number, such as 1, 2, 3. And you
%           will enter the start and end number at the begining of program;
%        (3)You will enter the column number of strain(stress) in files;   
%        (4)You will enter the start and end strain values to calculate the
%           Youngs modulus;
%        (5)This program is ONLY suitable for sudden breaking. 
%==========================================================================

clear all;
clc;

%--------------------------------------------------------------------------
% get the start and end number of files
%--------------------------------------------------------------------------
startNum = input('Please enter the number of START file:');
endNum = input('Please enter the number of END file:');
strain_column = input('Please enter the column number of strain in data:');
stress_column = input('Please enter the column number of stress in data:');
ini_strain = input('Please enter the START strain value to calculate Youngs modulus:');
end_strain = input('Please enter the END strain value to calculate Youngs modulus:');

for file=startNum:1:endNum 
    
%--------------------------------------------------------------------------    
% read data
%--------------------------------------------------------------------------
    data = readmatrix(num2str(file));
    strain_Raw = data(:,strain_column);
    %remove NAN in data
    strain = strain_Raw(~isnan(strain_Raw));
    stress_Raw = data(:,stress_column);
    stress = stress_Raw(~isnan(stress_Raw));
    
%--------------------------------------------------------------------------
% calculate Young's modulus (unit:MPa)
% The data points from start strain point to end strain point are fitted by
% the least squares method. The slope of fitted curve is seemed as the 
% Youngs moludus of this material.
%--------------------------------------------------------------------------
    index = 0;
    E_strain = [];
    E_stress = [];
    for i = 1:length(strain)
        if strain(i) > ini_strain && strain(i) < end_strain 
            index = index + 1;
            %strain and stress data is used to cal E
            E_strain(index,1) = strain(i);
            E_stress(index,1) = stress(i);
        end
    end
    %using the least squares to fit data
    coefficient = polyfit(E_strain,E_stress,1); 
    Total_Youngs(file,1) = coefficient(1); 
    
%--------------------------------------------------------------------------   
% calculate strength
% The maximum value in stress data is seemed as strength.
%--------------------------------------------------------------------------
    [strength,spos] = max(stress);
    Total_strength(file,1) = strength;
    
%--------------------------------------------------------------------------   
% calculate breaking strain
% The breaking strain piont is the same as strength point. The breaking
% strain is modified by zero strain point value.
%--------------------------------------------------------------------------
    modi_ini_strain = -coefficient(2)/coefficient(1);
    breaking_strain = strain(spos);
    Total_breaking_strain(file,1) = breaking_strain-modi_ini_strain;
    
%--------------------------------------------------------------------------   
% calculate toughness
% The area under the stress-strain curve is considered the toughness.
%--------------------------------------------------------------------------
    toughness = 0;
    for k = 1:length(strain)-1
        toughness = toughness + ((stress(k)+stress(k+1))*(strain(k+1)-strain(k)))/2;
    end
    Total_toughness(file,1) = toughness;
    
end
