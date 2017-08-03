function my_index = choose_constrained_cluster(points,clusters)
% function to distribute points between cluster through kmeans constraint.
% Written by: Naeem Khoshnevis (nkhshnvs@memphis.edu)
% Center for Earthquake Research and Information (CERI)
% University of Memphis
% July 6, 2017. Last update (July 6, 2017)


if size(points,1) ~= size(clusters,1)
   error('Points and clusters should be the same size.') 
end

distance_mat = zeros(size(clusters,1),size(clusters,1));
my_index     = zeros(size(clusters,1),2);

for i=1:size(clusters,1)
    for j=1:size(clusters,1)
        
        distance_mat(i,j) = distanceM(points(j,1:2),clusters(i,1:2));
        
    end
end


link_mat = eye(size(clusters,1),size(points,1));

cost = 1000000;

for ff=1:2
for ii=1:size(clusters,1)
    for jj=1:size(clusters,1)
        tmp_link_mat=link_mat;
        tmp_i = tmp_link_mat(ii,:);
        tmp_j = tmp_link_mat(jj,:);
        tmp_link_mat(ii,:)=tmp_j;
        tmp_link_mat(jj,:)=tmp_i;
        cost1 = cluster_cost(distance_mat,tmp_link_mat);
        
        if cost1 < cost
            link_mat = tmp_link_mat;
            cost = cost1;
        end
        kk=1;
        for ik=1:size(points,1)
            for jk=1:size(clusters,1)
                
                if link_mat(jk,ik)==1
                    my_index(kk,1)=jk;
                    my_index(kk,2)=ik;
                    kk=kk+1;
                end
                
            end
        end

    end
    
end



end
end


function cost = cluster_cost(distance_mat,link_mat)
    new_dist = link_mat .* distance_mat;
    cost = sum(new_dist(:));
end

% function d = distanceM(point,cluster)
% d = sqrt((point(:,1)-cluster(:,1)).^2+(point(:,2)-cluster(:,2)).^2);
% end

function d = distanceM(point,cluster)
d1 = (point - cluster).^2;
d2 = sum(d1,2);
d  = sqrt(d2);
end

