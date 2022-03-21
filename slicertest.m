sfArray = [1,0.1,1e-2,1e-3,1e-5,1e-6,1e-7,1e-8];
for sf = 1:length(sfArray)

%     for it = 1:20
%     
%     [inverse_results, model_parameters] = inverse_solution(forward_results, model_parameters, forward_parameters, measurement_data,1e-8,it);
%     [mdl,slicer] = slicer_plot_n(model_parameters, 0.025,inverse_results.sol_nlgn);
% %     itstr = num2str(it);
% %     sfstr = num2str(sfArray(sf));
% %     filestr1 = '/Users/ollie/Documents/MultiSensorAdjFigures/';
% %     filestr2 = 'iterations';
% %     filestr3 = 'sf.png';
% %     filename = strcat(filestr1,itstr,filestr2,sfstr,filestr3);
% %     figtitle = strcat('Conductivity plot, Number of Iterations:',{' '},itstr,' Smoothing factor: ',{' '},sfstr);
% %     title(figtitle)
% %     saveas(slicer,filename)
% 
%     end
    it = 5;
    [inverse_results, model_parameters] = inverse_solution(forward_results, model_parameters, forward_parameters, measurement_data,sfArray(sf),it);
    [mdl,slicer] = slicer_plot_n(model_parameters, 0.025,inverse_results.sol_nlgn);
    itstr = num2str(it);
    sfstr = num2str(sfArray(sf));
    filestr1 = '/Users/ollie/Documents/msIP/OppNoisePlots/';
    filestr2 = 'iterations';
    filestr3 = 'sf.png';
    filename = strcat(filestr1,itstr,filestr2,sfstr,filestr3);
    figtitle = strcat('Opposite measurement strategy, noise at smoothing factor:',{' '},sfstr);
    title(figtitle)
    saveas(slicer,filename)
end



