clc
clear all 
close all 

% Figure  1 of the paper
points = [
1.9 3
2 3.5
2.5 3
3 4
];

clusters = [
0.5 0.5
0.6 5
2.4 3.5
5.5 3.5
];


my_index = choose_constrained_cluster(points,clusters);


figure
subplot(2,1,2)
        scatter(points(:,1),points(:,2))
        hold on
        scatter(clusters(:,1),clusters(:,2),'rs')
        
        for i=1:size(points,1)
            ss = sprintf('%s%s','p',num2str(i));
            text(points(i,1)+0.1,points(i,2)+0.1,ss)
        end
        
        for j=1:size(clusters,1)
            ss = sprintf('%s%s','c',num2str(j));
            text(clusters(j,1)+0.1,clusters(j,2)+0.1,ss)
        end
        
        
        for i=1:size(my_index,1)
            plot([clusters(my_index(i,1),1) points(my_index(i,2),1)],[clusters(my_index(i,1),2) points(my_index(i,2),2)])
            hold on
            
        end
        
 xlim([0 6])
 ylim([0 6])
 xlabel('X')
 ylabel('Y')
 
my_index = [
    3 1
    3 2
    3 3
    3 4

] ;
 
subplot(2,1,1)


        scatter(points(:,1),points(:,2))
        hold on
        scatter(clusters(:,1),clusters(:,2),'rs')
        
        for i=1:size(points,1)
            ss = sprintf('%s%s','p',num2str(i));
            text(points(i,1)+0.1,points(i,2)+0.1,ss)
        end
        
        for j=1:size(clusters,1)
            ss = sprintf('%s%s','c',num2str(j));
            text(clusters(j,1)+0.1,clusters(j,2)+0.1,ss)
        end
        
        
        for i=1:size(my_index,1)
            plot([clusters(my_index(i,1),1) points(my_index(i,2),1)],[clusters(my_index(i,1),2) points(my_index(i,2),2)])
            hold on
            
        end
        
 xlim([0 6])
 ylim([0 6])
 xlabel('X')
 ylabel('Y')

