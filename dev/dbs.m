function [stiff,rhs] = dbs(stiff,rhs,dirinodes,dirival)

dia = diag(stiff);
stiff = stiff - diag(dia);
[indexi indexj s] = find(stiff);
clear stiff;
dind = dirinodes;
indi = find(ismember(indexi,dind));
indj = find(~ismember(indexj,dind));
indij = intersect(indi,indj);
rhs(indexj(indij)) = rhs(indexj(indij)) - dirival(indexi(indij)).*s(indij);
s(indi) = 0;
dia(indexi(indi)) = 1;
rhs(indexi(indi)) = dirival(indexi(indi));
indij = find(ismember(indexj,dind)&~ismember(indexi,dind));
rhs(indexi(indij)) = rhs(indexi(indij)) - dirival(indexj(indij)).*s(indij);
s(indij) = 0;
stiff = sparse(indexi,indexj,s,length(dia),length(dia));
stiff = stiff + diag(dia);
end
