function options = save_coordinates(reco, options)

    electrode_number = [];
    excisting_modality = fieldnames(reco); 

    for i = [1:length(reco.props)]
        electrode_number = [electrode_number; repmat(i, length(reco.(excisting_modality{2}).coords_mm{i}), 1)];
    end
    
    coords_excel = [electrode_number];
    varNames = ["Electrode"]; 
    
    spacenames={'native','scrf','mni','acpc'};
    for spacenm=1:length(spacenames)
        try 
            coords = cat(1, reco.(spacenames{spacenm}).coords_mm{:});
            coords_excel = [coords_excel, coords];
            varNames = [varNames, strcat(spacenames{spacenm}, '_x'), strcat(spacenames{spacenm}, '_y'), strcat(spacenames{spacenm}, '_z')];
        end 
    end
    
    coords_excel = array2table( ...
                    coords_excel, ...
                    'VariableNames', varNames ...
                    );
    
    options.subj.electrodeCoords = fullfile(options.subj.reconDir, [options.subj.subjId '_electrode_coordinates.xlsx']); 
    
    disp(['Saved coordinates in ' options.subj.electrodeCoords]);
    writetable(coords_excel, options.subj.electrodeCoords);
    
end 