function rename_electrode_labels(options)
    
    switch options.renameelectrodes.image
        case "Coregistered"
            ct_file = options.subj.postopAnat.(options.subj.postopModality).coreg; 
            modality = 'native'; 
        case "Normalized"
            ct_file = options.subj.postopAnat.(options.subj.postopModality).norm; 
            modality = 'mni'; 
    end 

    try 
       
        vol = niftiread(ct_file);
        elec_vol = niftiread(fullfile(options.subj.reconDir, ...
            [options.subj.subjId '_' modality '_electrodes_labels.nii']));

        volumeViewer(vol, elec_vol);

        f = figure('Name', 'Rename Electrode Labels', 'Position', [300, 300, 500, 400]);

        unique_labels = unique(elec_vol(:));
        unique_labels(unique_labels == 0) = []; 
        num_labels = numel(unique_labels);
        
        
        label_data = cell(num_labels, 2);
        for i = 1:num_labels
            label_data{i, 1} = unique_labels(i); 
            label_data{i, 2} = num2str(unique_labels(i));
        end

        uitable(f, 'Data', label_data, ...
                'ColumnName', {'Label Number', 'Electrode Name'}, ...
                'ColumnEditable', [false true], ...
                'Position', [20, 100, 460, 250], ...
                'Tag', 'label_table');
        
        uicontrol(f, 'Style', 'pushbutton', 'String', 'Save Labels', ...
                  'Position', [200, 40, 100, 30], ...
                  'Callback', @(src, event)save_renamed_labels(f, options, label_data));
    
    catch ME
        errordlg(['Error loading the CT scan or electrode labels: ' ME.message], 'File Error');
        return;
    end
end

function save_renamed_labels(fig, options, label_data)
    
    table_handle = findobj(fig, 'Tag', 'label_table');
    updated_data = get(table_handle, 'Data');
    
    num_labels = size(updated_data, 1);
    new_label_names = cell(num_labels, 1);
    for i = 1:num_labels
        new_label_names{i} = updated_data{i, 2};  % Electrode name
    end
    
    filename = fullfile(options.subj.reconDir, [options.subj.subjId '_renamed_electrodes_labels.txt']);
    
    fid = fopen(filename, 'w');
    if fid == -1
        errordlg('Unable to save the renamed labels.', 'File Error');
        return;
    end
    
    for i = 1:num_labels
        fprintf(fid, '%d: %s\n', updated_data{i, 1}, new_label_names{i});  % Save label number and new name
    end
    fclose(fid);
    
    msgbox(['Renamed labels saved to: ' filename], 'Save Successful');
end