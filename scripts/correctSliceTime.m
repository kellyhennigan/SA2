% slice time correction
function slice_time_corrected_epi = correctSliceTime(epi,episliceorder,mux)


y = calcposition(episliceorder,1:max(episliceorder));

if ~notDefined('mux') 
    y = repmat(y,1,mux);
end


slice_time_corrected_epi = sincshift(epi,repmat(reshape((1-y)/max(y),1,1,[]),[size(epi,1) size(epi,2)]),4);



