function plot_mlc(MLC,JAW,mlc_width,num_seg,beam_num,goal_path)
mlc_width = 7;
leaf_on_plot = round(mlc_width/0.3906,2);
num_seg = size(Unity_PLN_INFO.Unity_Pros3625U2ADT02.CP_info_unity_,1);
new_folder = 'C:\GitFolder\VMAT-QA-metrics\UnityPlanComplexity\test_cases\UMCU\Unity_Pros3625U2ADT02\';
mkdir(new_folder);
for j = 1:num_seg
    MLC_ = reshape(Unity_PLN_INFO.Unity_Pros3625U2ADT02.CP_info_unity_{j, 4},[80,2]);
    JAW = Unity_PLN_INFO.Unity_Pros3625U2ADT02.CP_info_unity_{j, 3}; 
    Gantry = Unity_PLN_INFO.Unity_Pros3625U2ADT02.CP_info_unity_{j, 1};
    MLC_2_ = MLC_./0.3906;
    figure(j);
    plot(716.8,512,'g+');
    for i=1:size(MLC_2_,1)
        % iterate num of mlc pair
        % x : 0, [0 y_position MLC_length MLC_leaf_width]
        rectangle('Position',[(i-1)*leaf_on_plot 512+MLC_2_(i,2) leaf_on_plot  512-MLC_2_(i,2)],'FaceColor', [0 0 1 0.5])
        hold on;
        % y: 512
        if MLC_2_(i,1) >= 0
            rectangle('Position',[(i-1)*leaf_on_plot 0 leaf_on_plot  512+MLC_2_(i,1)],'FaceColor', [0 0 1 0.5])
        else
            rectangle('Position',[(i-1)*leaf_on_plot 0 leaf_on_plot  512+MLC_2_(i,1)],'FaceColor', [0 0 1 0.5])
        end
        hold on;
        
    end
    line([716.8+JAW(1)/0.3906,716.8+JAW(1)/0.3906],[0,1024],'Color','r');
    hold on;
    line([716.8+JAW(2)/0.3906,716.8+JAW(2)/0.3906],[0,1024],'Color','r');
    axis off;
    title(['segment',int2str(j),'Gantry',int2str(Gantry)]);
    saveas(gcf,[new_folder,'\segment',int2str(j),'.png']);
    close(figure(j));
end
end