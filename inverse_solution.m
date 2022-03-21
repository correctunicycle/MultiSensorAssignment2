function [inverse_results,model_parameters] = inverse_solution(forward_results,model_parameters,forward_parameters,measurement_data,SmoothingFactor,nOfIterations);

if nargin < 5
    inverse_results.a=[];
end

% Controler function to find the inverse solution of the problem

if isfield(model_parameters,'Reg')
    reg_calc='Y';
else
    reg_calc='Y';
end

if reg_calc=='Y'
    deg=1;
    w=1;
end

disp('[G]SVD, [T]GSVD, [L]BP, L[A]NW, [N]nonlin, [p]cg');
type='N';

if type == 'G'
    %need to check to see if the gsvd is present and if it is ask if they
    %want to recalcualte it.
    
    if isfield(inverse_results,'tfac')
        tfac_calc=upper(input('Do you want a new value of the smoothing factor? [Y/N] ','s'));
    else
        tfac_calc='Y';
    end
    data_driven='N';
    if tfac_calc=='Y'
        a=upper(input('Do you want to use the [o]ptimum smoothing factor or [y]our own value? ','s'));
   
        if a ~='O'
            inverse_results.tfac=input('What is the smoothing factor? ');
        else
            data_driven=upper(input('Do you want to carry out data driven smoothing? [Y/N] ','s'));
        end
    end
    
    if ~isfield(inverse_results,'U') | ~isfield(inverse_results,'svs') | ~isfield(inverse_results,'X') | ~isfield(inverse_results,'V')
        gsvd_calc='Y';
    else
        gsvd_calc=upper(input('Do you want to recalculate the gsvd parameters? [Y/N] ','s'));
    end
        
    
    if reg_calc=='Y'
        [model_parameters] = iso_f_smooth(model_parameters,deg,w);
    end
    
    if gsvd_calc=='Y'
        [U,sm,X,V] = cgsvd(forward_results,model_parameters);
        inverse_results.U=U;
        inverse_results.svs=sm;
        inverse_results.X=X;
        inverse_results.V=V;
    end
    
    if tfac_calc=='Y' & a =='O' 
        [alpha1,num_sv]=data_driven_picard(inverse_results,measurement_data.v_meas,0.95);
        inverse_results.tfac=alpha1;
    end  
    
    [inverse_results]=gsvd_solver(forward_parameters,inverse_results,measurement_data,inverse_results.tfac,data_driven);
    
elseif type == 'T'
    %need to check to see if the gsvd is present and if it is ask if they
    %want to recalcualte it.
     
    if isfield(inverse_results,'num_sv')
        num_sv_calc=upper(input('Do you want a new value of the number of singular values? [Y/N] ','s'));
    else
        num_sv_calc='Y';
    end
    data_driven='N';
    if num_sv_calc=='Y'
        a=upper(input('Do you want to use the [o]ptimum number or [y]our own value? ','s'));
    
        if a ~='O'
            inverse_results.tfac=input('What is the number of singular values? ');
        else
            data_driven=upper(input('Do you want to carry out data driven smoothing? [Y/N] ','s'));
        end
    end
    
    if ~isfield(inverse_results,'U') | ~isfield(inverse_results,'svs') | ~isfield(inverse_results,'X') | ~isfield(inverse_results,'V')
        gsvd_calc='Y';
    else
        gsvd_calc=upper(input('Do you want to recalculate the gsvd parameters? [Y/N] ','s'));
    end
    
    if reg_calc=='Y'
        [model_parameters] = iso_f_smooth(model_parameters,deg,w);
    end
    
   if gsvd_calc=='Y'
        [U,sm,X,V] = cgsvd(forward_results,model_parameters);
        inverse_results.U=U;
        inverse_results.svs=sm;
        inverse_results.X=X;
        inverse_results.V=V;
    end
    
     if num_sv_calc=='Y' & a =='O' 
        [alpha1,num_sv]=data_driven_picard(inverse_results,measurement_data.v_meas,0.95);
        inverse_results.num_sv=num_sv;
    end
    
    [inverse_results]=tgsvd_solver(forward_parameters,measurement_data,inverse_results,num_sv,data_driven);
    
elseif type == 'L'
    
    if isfield(inverse_results,'tfac')
        tfac_calc=upper(input('Do you want a new value of the smoothing factor? [Y/N] ','s'));
    else
        tfac_calc='Y';
    end
    
    if tfac_calc=='Y'
        tfac=input('What is the smoothing factor? ');
        inverse_results.tfac=tfac;
    else
        tfac=inverse_results.tfac;
    end
    
    if reg_calc=='Y'
        [model_parameters] = iso_f_smooth(model_parameters,deg,w);
    end
    
    inverse_results.sol_lbp=[];
    h=waitbar(0,'Calculating solutions...');
    
    operator = (forward_results.J'*forward_results.J + tfac*model_parameters.Reg'*model_parameters.Reg)\(forward_results.J.');

        for loop1=1:size(measurement_data.v_meas,2)
            %sols(:,loop1) = operator * (measurement_data.v_meas(:,loop1)-measurement_data.v_ref);
             [sols] = operator * (measurement_data.v_meas(:,loop1)-measurement_data.v_ref);
             sols = sols + forward_parameters.mat_ref;
           % inverse_results.sol_lbp=sols + forward_parameters.mat_ref;
            %waitbar(loop1/size(measurement_data.v_meas,2))
            [inverse_results.sol_lbp]=[inverse_results.sol_lbp,sols];
        end
    close(h)
   % inverse_results.sol_lbp=sols + forward_parameters.mat_ref;

elseif type == 'A'
    
    relaxation_parameter=2/(max(forward_results.J'.*forward_results.J));
    maxit=input('How many iterations do you want? [normally 500 will do] ');
    
    if reg_calc=='Y'
        [model_parameters] = iso_f_smooth(model_parameters,deg,w);
    end
    
    [inverse_results.sol_landweber]=landweber_solver(forward_results,forward_parameters,measurement_data,relaxation_parameter,maxit);
    
elseif type == 'N'
    
    tfac=SmoothingFactor;
    it=nOfIterations;
    % is this the right amount?
    [model_parameters] = iso_f_smooth(model_parameters,deg,w);
    inverse_results.sol_nlgn=[];
    inverse_model.tfac=tfac;
    for f=1:size(measurement_data.v_meas,2)
        [sol]=nonlinearGN2(model_parameters,inverse_model,measurement_data,forward_parameters,forward_results,f,it);
        [inverse_results.sol_nlgn]=[inverse_results.sol_nlgn,sol];
    end
%    [inverse_results] = inverse_solver(forward_parameters,model_parameters,measurement_data,tfac,it);
    
elseif type == 'P'
    
    tol=input('What is the tolerance? ');
    maxit=input('What is the maximum number of iterations? [normally 50 will do] ');
    %is that the right number?
    
    [inverse_results.sol_pcg]=cg_solver(forward_results,measurement_data,forward_parameters,tol,maxit);
    
% elseif type == 'B'
%     
%     l=input('What is the lower bound? ');
%     u=input('What is the upper bound? ');
%     tfac=input('What is the smoothing factor? ');
%     tol_for=input('What is the tolerance? ');
%     
%     [inverse_results]=barrier_constrained(measurement_data,forward_parameters,model_parameters,l,u,tfac,tol_for)
    
else
    
    disp('muppet, try again!');
    
end

clear inverse_results.a