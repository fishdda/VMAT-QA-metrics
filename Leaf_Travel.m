function VMAT_PLN_INFO = Leaf_Travel(VMAT_PLN_INFO,BLD_type)
%Leaf_Travel calculate the average leaf travel in VMAT
%   For each leaf, the entire travel over the VMAT arc was computed, 
%   and this value was averaged over all in-field moving
%   leaves of the considered plan. Leaves that remained closed
%   during treatment were not considered

MLC =VMAT_PLN_INFO.CP_info(:,3);
JAW = VMAT_PLN_INFO.CP_info(:,4);
MLC_mat = zeros(size(MLC{1,1},1),size(MLC,1));
JAW_mat = zeros(2,size(MLC,1));
for k =1:size(MLC,1)
    MLC_mat(:,k) = MLC{k,1};
    JAW_mat(:,k) = JAW{k,1};
end

VMAT_PLN_INFO.leaf_travel_mat = abs(MLC_mat(:,2:end)-MLC_mat(:,1:end-1));

%% to judge if leaf is with the field or aperture
leaf_travel_updated = zeros(size(VMAT_PLN_INFO.leaf_travel_mat,1),...
    size(VMAT_PLN_INFO.leaf_travel_mat,2));
if BLD_type == 'agility'
    mlc_width = 5;
end
for k =1:size(JAW,1)-1
    mlc_leaf = reshape(VMAT_PLN_INFO.leaf_travel_mat(:,k),[80,2]);
    start_point = ((200+JAW{k+1,1}(1))/mlc_width)+1;
    end_point = size(mlc_leaf,1)-(200-JAW{k+1,1}(1))/mlc_width;
    
    if rem(start_point,1) == 0 && rem(end_point,1) == 0
        
        mlc_leaf([1:start_point-1,end_point+1:end],:) = 0;
        
        
    elseif rem(start_point,1) ~= 0 && rem(end_point,1) == 0

        start_point = floor((200+JAW{k+1,1}(1))/mlc_width)+1;
        mlc_leaf([1:start_point,end_point+1:end],:) = 0;
        
    elseif rem(start_point,1) == 0 && rem(end_point,1) ~= 0

        end_point = size(mlc_leaf,1)/2 + floor(JAW{k+1,1}(2)/mlc_width);
        mlc_leaf([1:start_point-1,end_point+1:end],:) = 0;
        
    elseif rem(start_point,1) ~= 0 && rem(end_point,1) ~= 0

        start_point = floor((200+JAW{k+1,1}(1))/mlc_width)+1;
        end_point = size(mlc_leaf,1)/2 + floor(JAW{k+1,1}(2)/mlc_width);
        
        mlc_leaf([1:start_point,end_point+1:end],:) = 0;
    end
    
    leaf_travel_updated(:,k) = mlc_leaf(:);

end

VMAT_PLN_INFO.leaf_travel_within_aperture = leaf_travel_updated;
VMAT_PLN_INFO.LT = mean(sum(leaf_travel_updated,2));



end

