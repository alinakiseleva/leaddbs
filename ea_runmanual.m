function [coords_mm,trajectory,markers]=ea_runmanual(options)

load([ea_getearoot,'templates',filesep,'electrode_models',filesep,options.elspec.matfname,'.mat'], 'electrode');

normdist = pdist([electrode.head_position;electrode.tail_position]);

switch options.subj.postopModality
    case 'MRI'
        vol = spm_vol(options.subj.coreg.anat.postop.ax_MRI);
    case 'CT'
        vol = spm_vol(options.subj.coreg.anat.postop.CT);
end

spm('defaults', 'fmri');
Fgraph = spm_figure('GetWin', 'Graphics');
Finter = spm('FnUIsetup','Select Trajectory', 0);

figure(Fgraph); clf;

for side=options.sides
    
    if side == 1
        spm_orthviews('Reset');
        h = spm_orthviews('Image', vol);
        colormap('gray');
        cameratoolbar('resetcamera')
        cameratoolbar('close')
        rotate3d off;
    end 

    if side==1 && spm_input('Adjust contrast', 1.5, 'y/n', [1,0],2)
        pc = spm_input('Percentiles', 1.5, 'w', '3 97', 2, 100);
        wn = spm_summarise(vol, 'all', @(X) spm_percentile(X, pc));
    end

    if exist('wn', 'var')
        spm_orthviews('window', h, wn);
    end

    if spm_input('Select tip and click' , 1.5, 'OK|Retry', [1,0], 1)
       
        markers(side).head = spm_orthviews('Pos')';

        pos = markers(side).head(:); 
        voxel_coords = vol.mat \ [pos; 1];
        voxel_coords = round(voxel_coords(1:3)); 
        
        [x, y, z] = ndgrid(-1:1, -1:1, -1:1); 
        padded_voxel_coords = bsxfun(@plus, voxel_coords, [x(:), y(:), z(:)]'); 
        XYZ = padded_voxel_coords;         

        spm_orthviews('AddColouredBlobs', 1, XYZ, 5 * ones(1, size(XYZ, 2)), vol.mat, [1 0 0], 'Marker');

    end

    if spm_input('Select point on trajectory and click', 1.5, 'OK|Retry', [1,0], 1)
        markers(side).tail = spm_orthviews('Pos')';
        
        pos = markers(side).tail(:); 
        voxel_coords = vol.mat \ [pos; 1];
        voxel_coords = round(voxel_coords(1:3)); 
        
        [x, y, z] = ndgrid(-1:1, -1:1, -1:1); 
        padded_voxel_coords = bsxfun(@plus, voxel_coords, [x(:), y(:), z(:)]'); 
        XYZ = padded_voxel_coords;         

        spm_orthviews('AddColouredBlobs', 1, XYZ, 5 * ones(1, size(XYZ, 2)), vol.mat, [1 0 0], 'Marker');

    end

    markers(side).tail=markers(side).head+...
        (markers(side).tail-markers(side).head)*...
        normdist/norm(...
        (markers(side).tail-markers(side).head));

    % add x and y
    [xunitv, yunitv] = ea_calcxy(markers(side).head, markers(side).tail);
    markers(side).x = markers(side).head + xunitv*(options.elspec.lead_diameter/2);
    markers(side).y = markers(side).head + yunitv*(options.elspec.lead_diameter/2);

end


[coords_mm,trajectory,markers] = ea_resolvecoords(markers,options,0);

close(Fgraph);
close(Finter);

