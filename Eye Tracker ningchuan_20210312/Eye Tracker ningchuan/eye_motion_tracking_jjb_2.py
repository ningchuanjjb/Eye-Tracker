import cv2
import numpy as np
import time
# import mmap

def OnMouseAction(event, x, y, flags, param):
    global img, position1, position2     
    if event == cv2.EVENT_LBUTTONDOWN:                                          #按下左键
        position1 = (x,y)
        position2 = None
 
    elif event == cv2.EVENT_MOUSEMOVE and flags == cv2.EVENT_FLAG_LBUTTON:      #按住左键拖曳不放开
        position2 = (x,y)
        
    elif event == cv2.EVENT_LBUTTONUP:                                          #放开左键
        position2 = (x,y)  


if __name__ == '__main__':
    # cap = cv2.VideoCapture("eye_recording.flv")
    # cap = cv2.VideoCapture("myEye_720p.mp4")
    # cap = cv2.VideoCapture('rtsp://admin:NINGCHUAN1@192.168.1.105/h264/ch1/main/av_stream')
    # cap = cv2.VideoCapture("monkeyEye_1_720p.mp4")
    cap = cv2.VideoCapture(0, cv2.CAP_DSHOW)
    # cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
    # cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    # cap.set(cv2.CAP_PROP_FPS, 210)
    
    # cap.set(cv2.CAP_PROP_BRIGHTNESS, 64)
    
    para_threshold_pupil = 90
    para_threshold_cornea = 200
    # para_threshold_pupil = 30
    # para_threshold_cornea = 200    
    
    cap.isOpened()
    
    cv2.namedWindow('Full video')
    # cv2.namedWindow('Full video', 0)
    # cv2.resizeWindow('Full video', (1920//3, 1080//3));
    cv2.setMouseCallback('Full video', OnMouseAction)
    position1 = None
    position2 = None
    frame = None
    
    
    loop_totalNum = 1000
    loop_count = 0
    time_start=time.time()
    
    filename = 'C:\ASDROOT\STUDY\Matlab Scripts\eyeState2.dat'
    mm = np.memmap(filename, dtype='float64', mode='r+', shape=(1, 4))
    
    pupil_x = 0
    pupil_y = 0
    cornea_x = 0
    cornea_y = 0
    
    # for i in range(1, loop_totalNum+1):
    while True:
        loop_count = loop_count + 1
        if round(loop_count/50)*50 == loop_count:
            print('loop_count = %d' % (loop_count))
        ret, frame = cap.read()
        if ret is False:  
            break
    
        # roi = frame[360: 720, 100: 360]
        # roi = frame[269: 795, 537: 1416]#[y, x]
        # roi = frame[0: 795, 0: 1416]#[y, x]
        # roi = frame[600: 700, 880: 1000]#[y, x]
        default_roi = frame[269: 795, 537: 1416]#[y, x]
        # default_roi = frame
        roi = default_roi
        rows, cols, _ = roi.shape
        gray_roi = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)
        gray_roi = cv2.GaussianBlur(gray_roi, (7, 7), 0)
        
   
        if position1 != None and position2 != None:
            # cv2.rectangle(frame, position1, position2, (0,0,255), 1,4)
            
            tempx1 = min(position1[1],position2[1])
            tempx2 = max(position1[1],position2[1])
            tempy1 = min(position1[0],position2[0])
            tempy2 = max(position1[0],position2[0])
            # roi = frame[position1[1]: position2[1], position1[0]: position2[0]]
            if tempx1 != tempx2:
                roi = frame[tempx1:tempx2, tempy1:tempy2]
                rows, cols, _ = roi.shape
                gray_roi = cv2.cvtColor(roi, cv2.COLOR_BGR2GRAY)
                gray_roi = cv2.GaussianBlur(gray_roi, (7, 7), 0)
        # cv2.imshow("Full video", frame)
    
        _, threshold_pupil = cv2.threshold(gray_roi, para_threshold_pupil, 255/2, cv2.THRESH_BINARY)
        _, threshold_pupil_temp = cv2.threshold(gray_roi, para_threshold_pupil, 255, cv2.THRESH_BINARY_INV)

        _, threshold_cornea = cv2.threshold(gray_roi, para_threshold_cornea, 255, cv2.THRESH_BINARY)
        # threshold_cornea[threshold_cornea == 0] = 255/2
        threshold_all = threshold_pupil + threshold_cornea
        threshold_all[threshold_all == 127] = 255
        
        
        
        contours_pupil, _ = cv2.findContours(threshold_pupil_temp, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
        contours_pupil = sorted(contours_pupil, key=lambda x: cv2.contourArea(x), reverse=True)
    

        for cnt in contours_pupil:
            (x, y, w, h) = cv2.boundingRect(cnt)
            
            h = w
    
            cv2.drawContours(roi, [cnt], -1, (0, 0, 255), 2)
            cv2.rectangle(roi, (x, y), (x + w, y + h), (255, 255, 255), 1)
            cv2.line(roi, (x + int(w/2), 0), (x + int(w/2), rows), (0, 255, 0), 1)
            cv2.line(roi, (0, y + int(h/2)), (cols, y + int(h/2)), (0, 255, 0), 1)
            
            # _, tempFrame_pupil = cv2.threshold(gray_roi, para_threshold_pupil, 255, cv2.THRESH_BINARY_INV)
            # # tempFrame_pupil = cv2.medianBlur(tempFrame_pupil, 7)  # 进行中值模糊，去噪点
            # cv2.imshow("tempFrame_pupil", tempFrame_pupil)
            # circles = cv2.HoughCircles(tempFrame_pupil, cv2.HOUGH_GRADIENT, 1, 500, param1=50, param2=1, minRadius=12, maxRadius=12)  
            # pupilCentriod = [0, 0]
            # if not circles is None:
            #     circles = np.uint16(np.around(circles))
            #     for i in circles[0,:]:
            #         # draw the outer circle
            #         cv2.circle(roi,(i[0],i[1]),i[2],(0,255,0),2)
            #         # draw the center of the circle
            #         cv2.circle(roi,(i[0],i[1]),2,(0,0,255),3)
            #         # print(len(circles[0,:]))
            #         pupilCentriod = [i[0], i[1]]
            
            
            # if len(cnt) > 5:
            #     ellipse = cv2.fitEllipse(cnt)
            #     cv2.ellipse(roi,ellipse,(0,255,0),2)
            

                
            
            pupilCentriod = [ x + w/2, y + h/2]

            pupil_x = pupilCentriod[0]
            pupil_y = pupilCentriod[1]
            
            print('pupilCentriod = %.1f, %.1f, ' % (pupilCentriod[0], pupilCentriod[1]), end='')
            print('pupilCentriod = %.1f, %.1f, ' % (pupilCentriod[0], pupilCentriod[1]))
            break
        
    
        contours_cornea, _ = cv2.findContours(threshold_cornea, cv2.RETR_TREE, cv2.CHAIN_APPROX_SIMPLE)
        contours_cornea = sorted(contours_cornea, key=lambda x: cv2.contourArea(x), reverse=True)
    

        for cnt in contours_cornea:
            (x, y, w, h) = cv2.boundingRect(cnt)
    
            cv2.drawContours(roi, [cnt], -1, (0, 0, 255), 2)
            cv2.rectangle(roi, (x, y), (x + w, y + h), (255, 255, 255), 1)
            cv2.line(roi, (x + int(w/2), 0), (x + int(w/2), rows), (255, 0, 255), 1)
            cv2.line(roi, (0, y + int(h/2)), (cols, y + int(h/2)), (255, 0, 255), 1)
                     
                        
            corneaCentriod = [ x + w/2, y + h/2]
            
            cornea_x = corneaCentriod[0]
            cornea_y = corneaCentriod[1]
            
            print('                \
                  corneaCentriod = %.1f, %.1f' % (corneaCentriod[0], corneaCentriod[1]))
            break    
        

        
        # cv2.imshow("Threshold_pupil", threshold_pupil)
        # cv2.imshow("threshold_cornea", threshold_cornea)
        cv2.imshow("threshold_all", threshold_all)
        # cv2.imshow("gray roi", gray_roi)
        cv2.imshow("Roi", roi)
        cv2.imshow("Full video", frame)
        
        
                
        # mm[0,0:2] = [pupil_x-cornea_x, pupil_y-cornea_y]
        # mm[0,0:4] = [pupil_x, pupil_y, cornea_x, cornea_y]
        mm[0,0:4] = [pupil_x, pupil_y, 0, 0]
        if round(loop_count/5)*5 == loop_count:
            key = cv2.waitKey(1)
            if key == 27:
                break
        
    time_end=time.time()
    print('totally cost = %.2f, loop_count = %d' % (time_end-time_start, loop_count))
    print('Single loop cost = %.2f' % ((time_end-time_start)/loop_count))
    print('FPS = %.2f' % (1/((time_end-time_start)/loop_count)) )

    
    cv2.destroyAllWindows()