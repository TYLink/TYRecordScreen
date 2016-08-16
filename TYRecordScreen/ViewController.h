//
//  ViewController.h
//  TYRecordScreen
//
//  Created by TianYang on 16/8/16.
//  Copyright © 2016年 TianYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "THCapture.h"
#import "BlazeiceAudioRecordAndTransCoding.h"
@interface ViewController : UIViewController<THCaptureDelegate,AVAudioRecorderDelegate,BlazeiceAudioRecordAndTransCodingDelegate>

{
    THCapture *capture;
    BlazeiceAudioRecordAndTransCoding*audioRecord;
    NSString* opPath;
    
}


@end

