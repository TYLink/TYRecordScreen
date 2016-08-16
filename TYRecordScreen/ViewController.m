//
//  ViewController.m
//  TYRecordScreen
//
//  Created by TianYang on 16/8/16.
//  Copyright © 2016年 TianYang. All rights reserved.
//

#import "ViewController.h"


#define VEDIOPATH @"vedioPath"
#define LNSCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define LNSCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

static int count = 0;

@interface ViewController ()
{
    UIView * doodleView;
    
    UIButton * _startButton;
    
    UIButton * _stopButton;
    
    UILabel  * _timeLabel;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
      [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerCallBack) userInfo:nil repeats:YES];
    
    [self setUpUI];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)timerCallBack
{
    
    if (!_timeLabel.hidden) {
        count++;
        _timeLabel.text = [NSString stringWithFormat:@"%3d",count];
    } else {
        NSLog(@"哔了狗  你先自己玩着点");
    }
}
-(void) setUpUI{
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    CGRect frame = CGRectMake(0, 0, LNSCREEN_WIDTH,LNSCREEN_HEIGHT);
    //    doodleView = [[BlazeiceDooleView alloc] initWithFrame:frame];
    
    doodleView = [[UIView alloc] initWithFrame:frame];
    
    doodleView.backgroundColor = [UIColor whiteColor];
    
    
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    imageView.image = [UIImage imageNamed:@"LALALA"];
    [doodleView addSubview:imageView];
    
    
    [self.view addSubview:doodleView];
    
    
    ////   开始
    _startButton = [[UIButton alloc] init];
    _startButton.frame = CGRectMake(0, 100, LNSCREEN_WIDTH/2, 40);
    [_startButton addTarget:self action:@selector(startButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_startButton];
    [_startButton setTitle:@"开始录制" forState:UIControlStateNormal];
    [_startButton setBackgroundColor:[UIColor blueColor]];
    
    //    结束
    _stopButton = [[UIButton alloc] init];
    _stopButton.frame = CGRectMake(LNSCREEN_WIDTH/2, 100, LNSCREEN_WIDTH/2, 40);
    [_stopButton addTarget:self action:@selector(stopButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_stopButton];
    [_stopButton setTitle:@"结束录制" forState:UIControlStateNormal];
    [_stopButton setBackgroundColor:[UIColor redColor]];
    
    
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.frame = CGRectMake(0, 200, LNSCREEN_WIDTH, 40);
    [_timeLabel setHidden:YES];
    _timeLabel.text = @"0000";
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.backgroundColor = [UIColor blueColor];
    _timeLabel.textColor = [UIColor blackColor];
    [doodleView addSubview:_timeLabel];
    
    
}


-(void)startButtonClick:(UIButton *)sender{
    [_timeLabel setHidden:NO];
     [_startButton setTitle:@"正在录制" forState:UIControlStateNormal];
    [self recordMustSuccess];
}

-(void) stopButtonClick:(UIButton *)sender{
    [_timeLabel setHidden:YES];
    [_startButton setTitle:@"开始录制" forState:UIControlStateNormal];

    [self StopRecord];
}

//
- (void)recordMustSuccess {
    if(capture == nil){
        capture=[[THCapture alloc] init];
    }
    capture.frameRate = 35;
    capture.delegate = self;
    capture.captureLayer = doodleView.layer;
    if (!audioRecord) {
        audioRecord = [[BlazeiceAudioRecordAndTransCoding alloc]init];
        audioRecord.recorder.delegate=self;
        audioRecord.delegate=self;
    }
    
    [capture performSelector:@selector(startRecording1)];
    NSString* path=[self getPathByFileName:VEDIOPATH ofType:@"wav"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]){
        [fileManager removeItemAtPath:path error:nil];
    }
    [self performSelector:@selector(toStartAudioRecord) withObject:nil afterDelay:0.1];
    
}
//
#pragma mark -
#pragma mark audioRecordDelegate
/**
 *  开始录音
 */
-(void)toStartAudioRecord
{
    [audioRecord beginRecordByFileName:VEDIOPATH];
}
/**
 *  音频录制结束合成视频音频
 */
-(void)wavComplete
{
    //视频录制结束,为视频加上音乐
    if (audioRecord) {
        NSString* path=[self getPathByFileName:VEDIOPATH ofType:@"wav"];
        [THCaptureUtilities mergeVideo:opPath andAudio:path andTarget:self andAction:@selector(mergedidFinish:WithError:)];
    }
}

#pragma mark -
#pragma mark THCaptureDelegate
- (void)recordingFinished:(NSString*)outputPath
{
    opPath=outputPath;
    if (audioRecord) {
        [audioRecord endRecord];
    }
    //[self mergedidFinish:outputPath WithError:nil];
}

- (void)recordingFaild:(NSError *)error
{
}

#pragma mark -
#pragma mark CustomMethod

- (void)video: (NSString *)videoPath didFinishSavingWithError:(NSError *) error contextInfo: (void *)contextInfo{
    if (error) {
        NSLog(@"---%@",[error localizedDescription]);
    }
}

- (void)mergedidFinish:(NSString *)videoPath WithError:(NSError *)error
{
    NSDateFormatter* dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
    NSString* currentDateStr=[dateFormatter stringFromDate:[NSDate date]];
    
    NSString* fileName=[NSString stringWithFormat:@"RecordScreeb,%@.mov",currentDateStr];
    
    NSString* path=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",fileName]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath])
    {
        NSError *err=nil;
        [[NSFileManager defaultManager] moveItemAtPath:videoPath toPath:path error:&err];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"allVideoInfo"]) {
        NSMutableArray* allFileArr=[[NSMutableArray alloc] init];
        [allFileArr addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"allVideoInfo"]];
        [allFileArr insertObject:fileName atIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:allFileArr forKey:@"allVideoInfo"];
    }
    else{
        NSMutableArray* allFileArr=[[NSMutableArray alloc] init];
        [allFileArr addObject:fileName];
        [[NSUserDefaults standardUserDefaults] setObject:allFileArr forKey:@"allVideoInfo"];
    }
    
    //音频与视频合并结束，存入相册中
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path)) {
        UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
    }
}
//
//
- (void)StopRecord{
    
    [capture performSelector:@selector(stopRecording)];
}
//
- (NSString*)getPathByFileName:(NSString *)_fileName ofType:(NSString *)_type
{
    NSString* fileDirectory = [[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:_fileName]stringByAppendingPathExtension:_type];
    return fileDirectory;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
