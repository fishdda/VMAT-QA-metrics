function plot_mlc_pinnacle_static(MLC,JAW,mlc_width,num_seg,beam_num,goal_path,machine_type)

leaf_on_plot = round(mlc_width/0.3906,2);  % on plot mlc width
new_folder = [goal_path,int2str(beam_num)];
mkdir(new_folder);

if machine_type == "unity"
    for j = 1:num_seg
        MLC_ = MLC{1,j};
        MLC_2_ = MLC_./0.3906;
        figure(j);
        plot(512,512,'g+');
        for i=1:size(MLC_2_,1)
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
        line([512+JAW{1,j}(1)/0.3906,512+JAW{1,j}(1)/0.3906],[0,1024],'Color','r');
        hold on;
        line([512+JAW{1,j}(2)/0.3906,512+JAW{1,j}(2)/0.3906],[0,1024],'Color','r');
        axis off;
        title(['segment',int2str(j)])
        saveas(gcf,[new_folder,'\segment',int2str(j),'.png']);
        close(figure(j));
    end
elseif machine_type == "Agility"
    for j = 1:num_seg
        MLC_ = MLC{1,j};
        MLC_2_ = MLC_./0.3906;
        figure(j);
        plot(512,512,'g+');
        for i=1:size(MLC_2_,1)
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
        line([512+JAW{1,j}(1)/0.3906,512+JAW{1,j}(1)/0.3906],[0,1024],'Color','r');
        hold on;
        line([512+JAW{1,j}(2)/0.3906,512+JAW{1,j}(2)/0.3906],[0,1024],'Color','r');
        axis off;
        title(['segment',int2str(j)])
        saveas(gcf,[new_folder,'\segment',int2str(j),'.png']);
        close(figure(j));
    end
    
    
end

end