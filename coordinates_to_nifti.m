function coordinates_to_nifti(options)

disp('Saving electrode masks as nifti files')

excel_coords = readtable(options.subj.electrodeCoords); 
column_names = excel_coords.Properties.VariableNames; 

for i = (2:3:length(column_names))

    column_name = split(column_names{i}, '_'); 
    modality = column_name{1}; 
    
    electrode_coords = table2array(excel_coords(:, i:i+2)); 
    electrode_numbers = table2array(excel_coords(:, 1)); 

    switch modality 
       case 'mni'
            mri_path = options.subj.preopAnat.(options.subj.AnchorModality).norm; 
            
       case 'native'
            mri_path = options.subj.preopAnat.(options.subj.AnchorModality).coreg; 
    end 
    
    volume = spm_vol(mri_path);
    nifti_info = niftiinfo(mri_path);
 
    radius = 5; 

    nifti_filename = fullfile(options.subj.reconDir, ...
                  [options.subj.subjId '_' modality '_electrodes_coordinates.nii']); 

    write_electrode_mask_nifti(volume, electrode_coords, radius, nifti_info, nifti_filename, 0); 

    nifti_filename = fullfile(options.subj.reconDir, ...
                  [options.subj.subjId '_' modality '_electrodes_labels.nii']); 
    write_electrode_mask_nifti(volume, electrode_coords, radius, nifti_info, nifti_filename, 1, electrode_numbers); 

    for elec_num = unique(electrode_numbers)'

        elec_coord_inds = electrode_numbers == elec_num; 
        elec_coords = electrode_coords(elec_coord_inds, :); 

        nifti_filename = fullfile(options.subj.reconDir, ...
                  [options.subj.subjId '_' modality '_electrode_' char(string(elec_num)) '.nii']);

        write_electrode_mask_nifti(volume, elec_coords, radius, nifti_info, nifti_filename, 0); 

    end 
end 

end 