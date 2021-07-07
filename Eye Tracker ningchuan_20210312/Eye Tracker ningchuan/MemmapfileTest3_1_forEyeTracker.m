% Clear the workspace and the screen
sca;
close all;
clear all; %#ok<CLALL>

Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebuglevel', 3);% disable the startup screen, replace it by a black display until calibration is finished


cd 'C:\ASDROOT\STUDY\Matlab Scripts'

mmfilename = 'eyeState2.dat';
fileID =  fopen(mmfilename,'r+');  
mm = memmapfile(mmfilename, 'Writable', true, 'Format', 'double'); 
raw_eyeState2 = mm.Data;
vector_pupilSubtractCornea = reshape(raw_eyeState2(1:2) - raw_eyeState2(3:4), 1, 2);

% coeff_x
% coeff_y
coeff_filename = 'cali_coeff_x_y.bin';
coeff_fileID =  fopen(coeff_filename,'w+'); 

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Make a base Rect of 200 by 200 pixels
baseRect = [0 0 20 20];

% Define red and blue
red = [1 0 0];
blue = [0 0 1];

escapeKey = KbName('ESCAPE');
leftaltKey = KbName('LeftAlt');

qKey = KbName('q');%show 1st calibration screen point
wKey = KbName('w');%show 2nd calibration screen point
eKey = KbName('e');%show 3rd calibration screen point
rKey = KbName('r');%show 4th calibration screen point
tKey = KbName('t');%show 5th calibration screen point
zKey = KbName('z');%show 6th calibration screen point
xKey = KbName('x');%show 7th calibration screen point
cKey = KbName('c');%show 8th calibration screen point
vKey = KbName('v');%show 9th calibration screen point

sKey = KbName('s');%save calibration vector of current screen point
dKey = KbName('d');%compute, fit, map, the vary calibration itself



% Here we set the initial position of the mouse to be in the centre of the
% screen
SetMouse(xCenter, yCenter, window);

% Sync us and get a time stamp
vbl = Screen('Flip', window);
shortShowTime = 16.6667;
shortWaitFrames = shortShowTime * 60 /1000;

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);

exitProgram = 0;
isCalibrating = 0;
isValidating = 0;
lastKeyCode = 0;

cali_screenPoint_count = 0;
cali_num = 9;
cali_screenPoint_state = zeros(1, cali_num);
% cali_screenPoint_x = [3/12*screenXpixels 1/2*screenXpixels 9/12*screenXpixels ...
%     1/2*screenXpixels 1/2*screenXpixels];
% cali_screenPoint_y = [1/2*screenYpixels 1/2*screenYpixels 1/2*screenYpixels ...
%     3/12*screenYpixels 9/12*screenYpixels];

% cali_screenPoint_x = [3/12*screenXpixels 1/2*screenXpixels 9/12*screenXpixels ...
%     3/12*screenXpixels 1/2*screenXpixels 9/12*screenXpixels ...
%     3/12*screenXpixels 1/2*screenXpixels 9/12*screenXpixels];
% cali_screenPoint_y = [3/12*screenYpixels 3/12*screenYpixels 3/12*screenYpixels ...
%     1/2*screenYpixels 1/2*screenYpixels 1/2*screenYpixels ...
%     9/12*screenYpixels 9/12*screenYpixels 9/12*screenYpixels];

% cali_screenPoint_x = [2/12*screenXpixels 1/2*screenXpixels 10/12*screenXpixels ...
%     2/12*screenXpixels 1/2*screenXpixels 10/12*screenXpixels ...
%     2/12*screenXpixels 1/2*screenXpixels 10/12*screenXpixels];
% cali_screenPoint_y = [2/12*screenYpixels 2/12*screenYpixels 2/12*screenYpixels ...
%     1/2*screenYpixels 1/2*screenYpixels 1/2*screenYpixels ...
%     10/12*screenYpixels 10/12*screenYpixels 10/12*screenYpixels];

cali_screenPoint_x = [1/12*screenXpixels 1/2*screenXpixels 11/12*screenXpixels ...
    1/12*screenXpixels 1/2*screenXpixels 11/12*screenXpixels ...
    1/12*screenXpixels 1/2*screenXpixels 11/12*screenXpixels];
cali_screenPoint_y = [1/12*screenYpixels 1/12*screenYpixels 1/12*screenYpixels ...
    1/2*screenYpixels 1/2*screenYpixels 1/2*screenYpixels ...
    11/12*screenYpixels 11/12*screenYpixels 11/12*screenYpixels];

% rand1 = rand(1, length(cali_screenPoint_x)) * 300 - 150;
% rand2 = rand(1, length(cali_screenPoint_y)) * 300 - 150;
% 
% rand1(5) = 0;
% rand2(5) = 0;
% 
% cali_screenPoint_x = cali_screenPoint_x + rand1;
% cali_screenPoint_y = cali_screenPoint_y + rand2;



% cali_vector_x = zeros(1, cali_num);
% cali_vector_y = zeros(1, cali_num);
cali_vector_x = cell(1, cali_num);
cali_vector_y = cell(1, cali_num);
coeff_x = 0;
coeff_y = 0;
% bufferSize = 15;
bufferSize_forCali = 40;
vector_pupilSubtractCornea = cell(1, bufferSize_forCali);
loop_count = 0;
% Make our rectangle coordinates
showRects = nan(4, cali_num);
for i = 1:cali_num
    showRects(:, i) = CenterRectOnPointd( baseRect, cali_screenPoint_x(i), cali_screenPoint_y(i) );
end

% Maximum priority level
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);
% Loop the animation until a key is pressed
isCalibrating = 1;
while exitProgram == 0
    [keyIsDown,secs, keyCode] = KbCheck;          
    
    if keyCode(leftaltKey) == 1 && keyCode(qKey) == 1 && lastKeyCode(qKey) == 0
        cali_screenPoint_count = 1;
    end
    if keyCode(leftaltKey) == 1 && keyCode(wKey) == 1 && lastKeyCode(wKey) == 0
        cali_screenPoint_count = 2;
    end    
    if keyCode(leftaltKey) == 1 && keyCode(eKey) == 1 && lastKeyCode(eKey) == 0
        cali_screenPoint_count = 3;
    end
    if keyCode(leftaltKey) == 1 && keyCode(rKey) == 1 && lastKeyCode(rKey) == 0
        cali_screenPoint_count = 4;
    end
    if keyCode(leftaltKey) == 1 && keyCode(tKey) == 1 && lastKeyCode(tKey) == 0
        cali_screenPoint_count = 5;
    end  
    if keyCode(leftaltKey) == 1 && keyCode(zKey) == 1 && lastKeyCode(zKey) == 0
        cali_screenPoint_count = 6;
    end 
    if keyCode(leftaltKey) == 1 && keyCode(xKey) == 1 && lastKeyCode(xKey) == 0
        cali_screenPoint_count = 7;
    end 
    if keyCode(leftaltKey) == 1 && keyCode(cKey) == 1 && lastKeyCode(cKey) == 0
        cali_screenPoint_count = 8;
    end 
    if keyCode(leftaltKey) == 1 && keyCode(vKey) == 1 && lastKeyCode(vKey) == 0
        cali_screenPoint_count = 9;
    end     
    
    
    if keyCode(leftaltKey) == 1 && keyCode(sKey) == 1 && lastKeyCode(sKey) == 0
        if cali_screenPoint_count ~= 0
            
%             temp_x_buffer = zeros(1, bufferSize_forCali);
%             for i=1:bufferSize_forCali
%                 temp_x_buffer(i) = vector_pupilSubtractCornea{i}(1);
%             end
%             sorted_temp_x_buffer = sort(temp_x_buffer);            
%             temp1 = floor(bufferSize_forCali/3);
%             low_bufferThreshold = sorted_temp_x_buffer(temp1);
%             high_bufferThreshold = sorted_temp_x_buffer(bufferSize_forCali-temp1);
            %valid_bufferSize = bufferSize_forCali - temp1*2;
            
%             temp_x = 0;
%             temp_y = 0;
%             valid_bufferSize = 0;
%             for i=1:bufferSize_forCali
%                 if vector_pupilSubtractCornea{i}(1) >= low_bufferThreshold &&...
%                         vector_pupilSubtractCornea{i}(1) <= high_bufferThreshold
%                     
%                     temp_x = temp_x + vector_pupilSubtractCornea{i}(1);
%                     temp_y = temp_y + vector_pupilSubtractCornea{i}(2);
%                     valid_bufferSize = valid_bufferSize + 1;
%                    
%                 end
% %                 temp_x = temp_x + vector_pupilSubtractCornea{i}(1);
% %                 temp_y = temp_y + vector_pupilSubtractCornea{i}(2);
%             end
% %             mean_vector_x = temp_x/bufferSize_forCali;
% %             mean_vector_y = temp_y/bufferSize_forCali;
%             mean_vector_x = temp_x/valid_bufferSize;
%             mean_vector_y = temp_y/valid_bufferSize;


            temp_x_buffer = zeros(1, bufferSize_forCali);
            for i=1:bufferSize_forCali
                temp_x_buffer(i) = vector_pupilSubtractCornea{i}(1);
            end
            temp_y_buffer = zeros(1, bufferSize_forCali);
            for i=1:bufferSize_forCali
                temp_y_buffer(i) = vector_pupilSubtractCornea{i}(2);
            end
            
%             windowSize = 1;
            windowSize = 20;
            dataSize_forCali = bufferSize_forCali - windowSize + 1;
            b = (1/windowSize)*ones(1,windowSize);
            a = 1;
            temp2_x_buffer = filter(b,a,temp_x_buffer);
            temp2_y_buffer = filter(b,a,temp_y_buffer);
            
%             mean_vector_x = temp2_x_buffer(windowSize);
%             mean_vector_y = temp2_y_buffer(windowSize);

%             mean_vector_x = mean(temp2_x_buffer(windowSize:windowSize+10));
%             mean_vector_y = mean(temp2_y_buffer(windowSize:windowSize+10));
            
%             mean_vector_x = temp2_x_buffer(1);
%             mean_vector_y = temp2_y_buffer(1);
            
%             cali_vector_x(cali_screenPoint_count) = mean_vector_x;
%             cali_vector_y(cali_screenPoint_count) = mean_vector_y;
            cali_vector_x{cali_screenPoint_count} = temp2_x_buffer(windowSize:end);
            cali_vector_y{cali_screenPoint_count} = temp2_y_buffer(windowSize:end);
            cali_screenPoint_state(cali_screenPoint_count) = 1;
            cali_screenPoint_count = 0;
        end
    end
    if keyCode(leftaltKey) == 1 && keyCode(dKey) == 1 && lastKeyCode(dKey) == 0
%         if sum(cali_vector_x == 0) == 0
            temp = cali_screenPoint_state;
%             coeff_x = polyfit(cali_vector_x(temp==1),cali_screenPoint_x(temp==1),3);
%             coeff_y = polyfit(cali_vector_y(temp==1),cali_screenPoint_y(temp==1),3);
            %dataSize_forCali
            total_cali_vector_x = [];
            total_cali_vector_y = [];
            total_cali_screenPoint_x = [];
            total_cali_screenPoint_y = [];
            for tempi=1:length(cali_screenPoint_state)
                if cali_screenPoint_state(tempi) == 1
                    total_cali_vector_x = [total_cali_vector_x cali_vector_x{tempi}]; %#ok<AGROW>
                    total_cali_vector_y = [total_cali_vector_y cali_vector_y{tempi}]; %#ok<AGROW>

                    total_cali_screenPoint_x = [ total_cali_screenPoint_x ...
                        cali_screenPoint_x(tempi) * ones(1, dataSize_forCali)]; %#ok<AGROW>
                    total_cali_screenPoint_y = [ total_cali_screenPoint_y ...
                        cali_screenPoint_y(tempi) * ones(1, dataSize_forCali)]; %#ok<AGROW>
                end
            end
            [coeff_x, coeff_y] = least_sq_calibration(total_cali_vector_x, total_cali_vector_y, ...
                total_cali_screenPoint_x, total_cali_screenPoint_y);

%             [coeff_x,coeff_y]=least_sq_calibration(cali_vector_x(temp==1),cali_vector_y(temp==1),...
%                 cali_screenPoint_x(temp==1),cali_screenPoint_y(temp==1));
            
            
%             exitProgram = 1;
            isCalibrating = 0;
            isValidating = 1;
            start_time = clock;
%         end
    end    
    
    if keyCode(escapeKey)
        exitProgram = 1;
    end
    lastKeyCode = keyCode;
    
    
    raw_eyeState2 = mm.Data;

    for i=bufferSize_forCali:-1:1
        if i > 1
            vector_pupilSubtractCornea{i} = vector_pupilSubtractCornea{i-1};
        elseif i == 1
            vector_pupilSubtractCornea{i} = reshape(raw_eyeState2(1:2) - raw_eyeState2(3:4), 1, 2);
            
        end
    end
    %     vector_pupilSubtractCornea = reshape(raw_eyeState2(1:2) - raw_eyeState2(3:4), 1, 2);
    
    
    %task state machine
    %isCalibrating-->isValidating
    %---------------------------------------------------------------------------------------------    
    if isCalibrating == 1

        if cali_screenPoint_count >= 1 && cali_screenPoint_count <= cali_num
            Screen('FillRect', window, [1 0 0], showRects(:, cali_screenPoint_count));
        end
    
    elseif isValidating == 1
        if cali_screenPoint_count == 0
            Screen('FillRect', window, [1 0 0], showRects(:, 5));
        else
            if cali_screenPoint_count >= 1 && cali_screenPoint_count <= cali_num
                Screen('FillRect', window, [1 0 0], showRects(:, cali_screenPoint_count));
            end
        end
        
        
        temp_x_buffer = zeros(1, bufferSize_forCali);
        for i=1:bufferSize_forCali
            temp_x_buffer(i) = vector_pupilSubtractCornea{i}(1);
        end
        temp_y_buffer = zeros(1, bufferSize_forCali);
        for i=1:bufferSize_forCali
            temp_y_buffer(i) = vector_pupilSubtractCornea{i}(2);
        end
        
%         fs=100;
%         wp=2*10/fs; ws=2*20/fs;
%         Rp=1; As=30;
%         [N,wc]=buttord(wp,ws,Rp,As);
%         [B,A]=butter(N,wc);       
%         temp2_x_buffer=filter(B,A,temp_x_buffer);
%         temp2_y_buffer=filter(B,A,temp_y_buffer);
%         
%         mean_vector_x = mean(temp2_x_buffer(10:14));
%         mean_vector_y = mean(temp2_y_buffer(10:14));


        windowSize = 1;%8-->6-->5-->1
%         windowSize = 1;
        b = (1/windowSize)*ones(1,windowSize);
        a = 1;
        temp2_x_buffer = filter(b,a,temp_x_buffer);
        temp2_y_buffer = filter(b,a,temp_y_buffer);
        mean_vector_x = temp2_x_buffer(windowSize);
        mean_vector_y = temp2_y_buffer(windowSize);
        
%         mean_vector_x = mean(temp2_x_buffer(windowSize:windowSize+4));
%         mean_vector_y = mean(temp2_y_buffer(windowSize:windowSize+4));

%         mean_vector_x = temp2_x_buffer(1);
%         mean_vector_y = temp2_y_buffer(1);
%         mean_vector_x = mean(temp2_x_buffer(windowSize+1));
%         mean_vector_y = mean(temp2_y_buffer(windowSize+1));
        
        
%         temp_x = 0;
%         temp_y = 0;
%         
%         for i=1:bufferSize
%             temp_x = temp_x + vector_pupilSubtractCornea{i}(1);
%             temp_y = temp_y + vector_pupilSubtractCornea{i}(2);
%         end
%         mean_vector_x = temp_x/bufferSize;
%         mean_vector_y = temp_y/bufferSize;
        
%         infer_screenPoint_x = polyval(coeff_x,mean_vector_x);
%         infer_screenPoint_y = polyval(coeff_y,mean_vector_y);
        [infer_screenPoint_x, infer_screenPoint_y] = get_gaze_point(mean_vector_x, mean_vector_y, ...
            coeff_x, coeff_y);
        eyeState2 = [infer_screenPoint_x infer_screenPoint_y];    
        
        if eyeState2(1) > screenXpixels - 30 
            eyeState2(1) = screenXpixels - 30;
        elseif eyeState2(1) < 30
            eyeState2(1) = 30;
        end
        if eyeState2(2) > screenYpixels - 30 
            eyeState2(2) = screenYpixels - 30;
        elseif eyeState2(2) < 30
            eyeState2(2) = 30;
        end        
        
        mx = eyeState2(1);
        my = eyeState2(2);
%         mx = screenXpixels * rand;
%         my = screenYpixels * rand;
        
        Screen('DrawDots', window, [mx my], 20, white, [], 2);
        loop_count = loop_count + 1;
    end
    
    
    vbl  = Screen('Flip', window, vbl + (shortWaitFrames - 0.5) * ifi); 

    

end
Priority(0);
if sum(coeff_x) ~= 0
    fwrite(coeff_fileID, coeff_x, 'double');
    fwrite(coeff_fileID, coeff_y, 'double');
end
fclose(coeff_fileID);

total_time = etime(clock, start_time);
fps = loop_count/total_time
% Clear the screen
sca;