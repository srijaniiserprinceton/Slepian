%To read the input files provided by Dr Gubbins. A new file is created
%excluding the top lines containing the header.
%
%Last modified by sbdas-at-princeton.edu, 29/10/2018

if 1
    load mag_256_trimmed.in;
else
    fid = fopen('mag_256.in', 'r') ;              % Open source file.
    fgetl(fid) ;                                  % Read/discard line.
    fgetl(fid) ;                                  % Read/discard line.
    buffer = fread(fid, Inf) ;                    % Read rest of the file.
    fclose(fid)

    fid = fopen('mag_256_trimmed.in', 'w')  ;   % Open destination file.
    fwrite(fid, buffer) ;                         % Save to file.
    fclose(fid) ;
    load mag_256_trimmed.in;
end

%choosing the component of magnetization to be plotted
data = mag_256_trimmed(:,3);
data = reshape(data,1440,720);  %nrows=nlon and ncol=nlat

% Where are the data kept? Create a directory $IFILES/COASTS
% with $IFILES set as an environment variable...
%similar to plotcont.m
defval('ddir',fullfile(getenv('IFILES'),'COASTS'))

%reading the outine of the continents in lat lon format
%we shall use the geoshow function and hence using lat-lon convention
fid=fopen(fullfile(ddir,'cont.mtl'),'r','b');
cont=fread(fid,[5217 2],'uint16');
fclose(fid);

% Recast data in good form
cont=cont/100-90;
cont(cont==max(max(cont)))=NaN;

%Plot in mollweide projection as in Gubbins' results
lon = linspace(0,2*pi,size(data,1));
lat = linspace(pi/2,-pi/2,size(data,2));
% Need to make special provisions for PCOLOR compared to IMAGESC
% The input values are PIXEL centered
dlat=(lat(1)-lat(2))/2;
dlon=(lon(2)-lon(1))/2;
lat=[lat(1) lat(2:end)+dlat lat(end)];
lon=[lon(1) lon(2:end)-dlon lon(end)];
[lon,lat]=meshgrid(lon,lat);
[xgr,ygr]=mollweide(lon,lat,pi);

load(fullfile(ddir,'conm'));

[ph,XY2]=plotplates([],[],1);   %extracting the lat-lon coordinates for plates
close(gcf); %plotplates() routine plots by default. We dont want the plot

cbar_range = [-25000 18000 -2000 15000 -5000 3500];
cbar_ind=1;

for i=3:5
    subplot(3,1,i-2);
    if(i~=3) 
        data = mag_256_trimmed(:,i);
        data = reshape(data,1440,720);  %nrows=nlon and ncol=nlat
    end
    axm2 = axesm('mollweid','Origin',[0 0]);

    pcolor(axm2,xgr,ygr,adrc(circshift(-data,720,1)')); shading flat

    geoshow(axm2,cont(:,2),cont(:,1),'displaytype','line','Color','black', 'LineWidth', 1.3); %the continents
    geoshow(axm2,XY2(:,2),XY2(:,1),'displaytype','line','Color','black', 'LineWidth', 1.3); %the plate boundaries

    plot(xbox,ybox,'k'); %the enclosing ellipse

    axis image;
    kelicol(1);
    caxis([cbar_range(cbar_ind) cbar_range(cbar_ind+1)]);
    %caxis([-10000 20000]);
    colorbar;
    cbar_ind = cbar_ind + 2;
end

print('Gubbins_compare','-dpdf','-fillpage','-r500');



