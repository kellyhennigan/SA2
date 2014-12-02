% slice time correction
function slice_time_corrected_epi = correctSliceTime(epi,episliceorder,mux)


y = calcposition(episliceorder,1:max(episliceorder));

if ~notDefined('mux') 
    y = repmat(y,1,mux);
end

scaled_y = (1-y)/max(y); % I think this makes it so that the slice timing 
% is corrected to the first slice time 

slice_time_corrected_epi = sincshift(epi,repmat(reshape(scaled_y,1,1,[]),[size(epi,1) size(epi,2)]),4);



