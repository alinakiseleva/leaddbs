function write_electrode_mask_nifti(volume, electrode_coords, radius, nifti_info, ...
    nifti_filename, separate_elecs_flag, electrode_nums)

dim = volume.dim; 

MRI_matrix = zeros(dim); 

% Convert MNI coordinates to voxel coordinates
N = size(electrode_coords, 1); 
voxel_coords = zeros(N, 3);  

for i = 1:N
    tmp_coord = round((volume.mat \ [electrode_coords(i, :) 1]')); 
    voxel_coords(i, :) = tmp_coord(1:3);  
end

[x_grid, y_grid, z_grid] = ndgrid(1:dim(1), 1:dim(2), 1:dim(3)); 

for i = 1:N
    center_voxel = voxel_coords(i, 1:3);
       
    distances = sqrt((x_grid - center_voxel(1)).^2 + ...
                     (y_grid - center_voxel(2)).^2 + ...
                     (z_grid - center_voxel(3)).^2);

    sphere_mask = distances <= radius;

    if separate_elecs_flag
        MRI_matrix(sphere_mask) = electrode_nums(i);  
    else
        MRI_matrix(sphere_mask) = 1;  
    end
    
end

nifti_info.Filename = nifti_filename; 
nifti_info.Description = 'electrode localization';
nifti_info.Datatype = 'double'; 

niftiwrite(MRI_matrix, nifti_filename, nifti_info); 
disp(['NIfTI file with electrodes saved as: ', nifti_filename]); 

end