load coast %this comes with matlab
coastlon=long;
coastlat=lat;
clear long lat;

filename   = '/Users/rlohman/Documents/Classes/EAS4050/homeworks/plotting/GPS_vectors_after_rotation_NNR.dat.txt';
startRow   = 3;
formatSpec = '%9f%8f%9f%9f%[^\n\r]';

% Open the text file.
fileID    = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);

% Allocate imported array to column variable names
GPSLon = dataArray{:, 1};
GPSLat = dataArray{:, 2};
GPSdx  = dataArray{:, 3};
GPSdy  = dataArray{:, 4};


minlon = 80;
maxlon = 120;
minlat = 10;
maxlat = 50;

inpoly = find((GPSLon>=minlon) & (GPSLon <=maxlon) & (GPSLat>=minlat) & (GPSLat <= maxlat));
GPSLon = GPSLon(inpoly);
GPSLat = GPSLat(inpoly);
GPSdx  = GPSdx(inpoly);
GPSdy  = GPSdy(inpoly);

GPSdx  = GPSdx-mean(GPSdx);
GPSdy  = GPSdy-mean(GPSdy);

baseurl  = 'https://earthquake.usgs.gov/fdsnws/event/1/query?';
geometry = ['minlatitude=' num2str(minlat) '&maxlatitude=' num2str(maxlat) '&minlongitude=' num2str(minlon) '&maxlongitude=' num2str(maxlon)];
url      = [baseurl 'starttime=1900-01-01&minmagnitude=4&' geometry '&limit=5000&format=geojson'];
data     = webread(url);

numquakes = length(data.features);

for i=1:numquakes
    EQlon(i) = data.features(i).geometry.coordinates(1);
    EQlat(i) = data.features(i).geometry.coordinates(2);
    EQz(i)   = data.features(i).geometry.coordinates(3);
    EQmag(i) = data.features(i).properties.mag;
end

figure
plot(coastlon,coastlat)
axis image
hold on
quiver(GPSLon,GPSLat,GPSdx,GPSdy,'k')
sc=scatter(EQlon,EQlat,18,EQz,'filled');
sc.SizeData = 2.^EQmag;
axis([minlon maxlon minlat maxlat])
colormap('jet')
colorbar('h')
grid on
