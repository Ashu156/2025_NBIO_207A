function mat1=rast2mat(raster)

mat1=zeros(length(raster),1100);
for c=1:length(raster)
tmps = raster{c};
if ~isempty(tmps)
mat1(c,round(tmps+551))=1;
end
end 
mat1=mat1(:,51:1050);