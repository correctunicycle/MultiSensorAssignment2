





function [mdl,slicer] = slicer_plot_n(mdl,h,sol,col_map);
%function [mdl] = slicer_plot_n(mdl,h,sol);
%
%This function plots a 2D slice of the 3D solution vector BB at z=h.
%Requires Matlab version 6.1 or upgrate (R12 or newer). 
%
%
%h    = The height of the desired solution, max(vtx(:,3))>= h >= min(vtx(:,3)).
%sol  = The caclulated inverse solution
%vtx  = The vertices matrix
%simp = The simplices matrix
%fc   = The edges of the mesh. This is a 2 column matrix required for the 3D plotting. 
%       fc may take some time to be calculated so it is a good idea to save it and use 
%       it thereafter. Initially use [fc] = slicer_plot(h,BB,vtx,simp); to plot the slide 
%       and calculate fc.

if ~isfield(mdl,'vtx') | ~isfield(mdl,'simp')
    error('Need vtx and simp variables');
end
vtx=mdl.vtx;
simp=mdl.simp;

if nargin < 4
    col_map = [min(sol) max(sol)];
end

v = version;
if str2num(v(1)) < 6
   error('Sorry Matlab version 6.1 R(12) or update is required for the function')
end


if ~isfield(mdl,'faces')
    fc = [];
    %Develop the faces           

    for f=1:size(simp,1)
   
        fc1 = sort([simp(f,1),simp(f,2)]);
        fc2 = sort([simp(f,1),simp(f,3)]);
        fc3 = sort([simp(f,1),simp(f,4)]);
        fc4 = sort([simp(f,2),simp(f,3)]);
        fc5 = sort([simp(f,2),simp(f,4)]);
        fc6 = sort([simp(f,3),simp(f,4)]);
   
        fc = [fc;fc1;fc2;fc3;fc4;fc5;fc6];
   
    end
    fc = unique(fc,'rows');
    mdl.faces=fc;
end
fc=mdl.faces;

%(1) Generate the pseudo-triangulation at plane z=h
vtxp = []; %Nodes created for the plane
vap = []; %Value of the node in vtxp

for j=1:size(fc,1)
  this_ph = fc(j,:); %[nodeA nodeB]

  if max(vtx(this_ph(1),3),vtx(this_ph(2),3))> h & ...
    min(vtx(this_ph(1),3),vtx(this_ph(2),3))<= h 		

    %If the face is crossed through by the plane then 
    %create a plotable node on the plane.
    Pa = this_ph(1); Pb = this_ph(2);
    xa = vtx(Pa,1); ya = vtx(Pa,2); za = vtx(Pa,3);
    xb = vtx(Pb,1); yb = vtx(Pb,2); zb = vtx(Pb,3);

    xn = xa + (h-za)*(xb-xa)/(zb-za);
    yn = ya + (h-za)*(yb-ya)/(zb-za);
    vtxp = [vtxp;[xn,yn]];

  end %if
end %for
tri = delaunay(vtxp(:,1),vtxp(:,2));

[vtxp,tri] = delfix(vtxp,tri);
%The 2D mesh at h is (vtxp,tri)

%(2) Evaluate the geometric centers gCts of the new siplices tri
gCts = zeros(size(tri,1),2);
for y=1:size(tri,1)
    gCts(y,1) = mean(vtxp(tri(y,:),1));
    gCts(y,2) = mean(vtxp(tri(y,:),2));
end

%(3) Initialise the planar solution
sol2D = zeros(size(gCts,1),1);

%(4) Now trace which simps contain gCts 


TT = tsearchn(vtx,simp,[gCts,h*ones(size(gCts,1),1)]);       
nans=isnan(TT);
remove=[];
for loop1=1:size(nans,1)
    if nans(loop1)==1
       remove=[remove;loop1];
    end
end
TT(remove,:)=[];
tri(remove,:)=[];
sol2D = sol(TT);

%figure;
X = vtxp(:,1);
Y = vtxp(:,2);
Z = h*ones(length(vtxp),1);
slicer = trisurf(tri,X,Y,Z,sol2D,'EdgeColor','none');

axis([min(vtx(:,1)) max(vtx(:,1)) min(vtx(:,2)) max(vtx(:,2)) min(vtx(:,3)) max(vtx(:,3))]);
axis off
caxis(col_map);

axis image;
view(0,90);
cb = colorbar;
cb.Label.String = 'Conductivity S/m';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is part of the EIDORS suite.
% Copyright (c) N. Polydorides 2003
% Copying permitted under terms of GNU GPL
% See enclosed file gpl.html for details.
% EIDORS 3D version 2.0
% MATLAB version 6.1 R13
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

