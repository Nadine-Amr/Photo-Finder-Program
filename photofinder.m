%user is prompted to enter the searching criteria
x=input('Please enter the date of saving the photo in the format Jun-2016:','s');
y=input('Please enter the number of people in the photo:');
z=input('Please specify whether the photo is colored or in greyscale (y/n):','s');
%checking if the date specified is in the wrong format
if ~isempty(x)
    if length(x)~=8
        disp('Please check the format of your specified date.');
        return;
    end
%checking if the number of people  specified is not an integer
elseif ~isempty(y)
    if rem(y,1)~=0 
        disp('Please check your entry for the number of people in the photo.');
        return;
    end
%checking if the third entry (whether the photo is colored or not) is not in the specified format
elseif ~isempty(z)
    if strcmp(z,'y')==0 && strcmp(z,'n')==0
        disp('Please check your third input.');
        return;
    end
end
%a starting folder is 
initialfolder= 'C:\Users\acer';
%user is prompted to choose a folder he/she wishes to search and its path is retrieved
folderchoice=uigetdir(initialfolder);
%if user did not select a folder, he is asked to, and the program ends
if folderchoice == 0
    disp('Please re-run the program and select a folder to search in.');
	return;
end
%we retrieve a string with the paths of folderchoice and all its subfolders
subfolders=genpath(folderchoice);
%the path of each folder/subfolder is placed in a cell in a cell array
list=textscan(subfolders,'%s','Delimiter',';');
list_of_folders=list{1}';
%we get the number of elements in the cell array
no_of_folders=length(list_of_folders);
% we loop on cell array to retrieve the photos in each folder and store all photos in another cell array
s=0;
for i=1:no_of_folders
    currentfolder=list_of_folders{i};
    images1=sprintf('%s/*.jpg', currentfolder);
    %we construct a structure array of attributes about all photos in this folder
    images2=dir(images1);
    no_of_photos=length(images2);
    %we loop on photos to transfer them to a cell array
    if no_of_photos >= 1
        for j=s+1:s+no_of_photos
            %array would contain paths with names and extensions of photos
            array{1,j}=fullfile(currentfolder, images2(j-s).name);
            %a would contain the matrix representation of photos
            a{1,j}=imread(array{1,j});
        end 
    else
        j=s;
    end
    s=j;
end
no_of_photos=s;
w=1;
index=[];
%we loop on all photos and transfer those satisfying the specified criteria into a cell array
while w<=no_of_photos
    flag=0;
    if ~isempty(x)
        %we check if the date of saving the photo is the same as specified
        photoinfo=imfinfo(array{w});
        if x==photoinfo.FileModDate(4:11)
            flag=flag+1;
        end
    else
        %if user did not specify this criteria, we assume all photos satisfy it
        flag=flag+1;
    end
    if ~isempty(y)
        %we define and set up our cascade object detector
        facedetection=vision.CascadeObjectDetector;
        %we obtain a matrix specifying coordinate points of where each face is located
        faces=step(facedetection,a{1,w});
        %we check if the number of coordinate sets is the same as the number of people specified by the user
        if y==size(faces,1)
            flag=flag+1;
        end
    else flag=flag+1;
    end
    if ~isempty(z)
        o=size(a{1,w});
        %if photo is colored, we check if its matrix representation has 3 pages
        if strcmp(z,'y')==1
            if length(o)==3
                flag=flag+1;
            end
            %if photo is not colored, we check if its matrix representation does not have 3 pages
        elseif strcmp(z,'n')==1
            if length(o)~=3
                flag=flag+1;
            end
        end
    else flag=flag+1;
    end
    %if photo satisfies al criteria, its index is stored in an array
    if flag==3
        index=[index w];
    end
    w=w+1;
end
for m=1:length(index)
    arrpics{m}=array{index(m)};
end
if isempty(index)==1
    disp('Sorry, no matching photos found.');
else disp(arrpics);
end

