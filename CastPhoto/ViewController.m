//
//  ViewController.m
//  CastPhoto
//
//  Created by Tina Lee on 2018/8/20.
//  Copyright © 2018年 Tina Lee. All rights reserved.
//

#import "ViewController.h"
#import <GoogleCast/GoogleCast.h>

@interface ViewController ()<GCKSessionManagerListener, GCKRemoteMediaClientListener, GCKRequestDelegate>

@property (nonatomic, retain) GCKCastContext *castContext;
@property (nonatomic, retain) GCKRemoteMediaClient *mediaClient;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.castContext = [GCKCastContext sharedInstance];
    
    GCKSessionManager *sessionManager = [GCKCastContext sharedInstance].sessionManager;
    [sessionManager addListener:self];


    GCKUICastButton *castButton = [[GCKUICastButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    castButton.center = CGPointMake(CGRectGetMidX(self.view.frame), CGRectGetMidX(self.view.frame));
    
    [self.view addSubview:castButton];
    
    UIImage *image = [UIImage imageNamed:@"google.png"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, CGRectGetMaxY(castButton.frame)+100, image.size.width*0.5, image.size.height*0.5);
    button.center = CGPointMake(CGRectGetMidX(self.view.frame), button.frame.origin.y+button.frame.size.height/2);
    [button setImage:image forState:UIControlStateNormal];
    [button setTitle:@"Start Cast" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    button.titleEdgeInsets = UIEdgeInsetsMake(100.0, -image.size.width, 0.0, 0.0);
    button.imageEdgeInsets = UIEdgeInsetsMake(-20.0, 0.0, 0.0,-button.titleLabel.bounds.size.width);
    [button addTarget:self action:@selector(castPhoto) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
}


- (void)castPhoto
{
    GCKMediaQueueItem *item = [self getItem];
    
    GCKRequest *request = [self.mediaClient queueLoadItems:@[item] startIndex:0 playPosition:0 repeatMode:GCKMediaRepeatModeOff customData:nil];
    request.delegate = self;

    NSLog(@"queueLoadItems [request id = %ld]", request.requestID);
}

- (GCKMediaQueueItem *)getItem
{
    NSString *urlString = [[NSBundle mainBundle] pathForResource:@"IMG_4611" ofType:@"JPG"];
    
    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc] initWithMetadataType:GCKMediaMetadataTypePhoto];
    [metadata setString:@"IMG_4611" forKey:kGCKMetadataKeyTitle];
    
    NSString *mime = @"image/jpeg";
    
    GCKMediaInformation *chromecastMediaInfo = [[GCKMediaInformation alloc] initWithContentID:@"https://www.google.com.tw/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"
                                                                                   streamType:GCKMediaStreamTypeNone
                                                                                  contentType:mime
                                                                                     metadata:metadata
                                                                                     adBreaks:nil
                                                                                 adBreakClips:nil
                                                                               streamDuration:0
                                                                                  mediaTracks:nil
                                                                               textTrackStyle:nil
                                                                                   customData:nil];
    
    GCKMediaQueueItemBuilder *builder = [[GCKMediaQueueItemBuilder alloc] init];
    builder.mediaInformation = chromecastMediaInfo;
    builder.playbackDuration = 0;
    builder.autoplay = YES;
    builder.preloadTime = 0;
    builder.startTime = 0;
    
    GCKMediaQueueItem *queueItem = [builder build];
    
    return queueItem;
}

#pragma mark - GCKRequestDelegate

- (void)requestDidComplete:(GCKRequest *)request;
{
    NSLog(@"requestDidComplete [request id = %ld]", request.requestID);
}

- (void)request:(GCKRequest *)request didFailWithError:(GCKError *)error
{
    NSLog(@"didFailWithError [request id = %ld] [error:%@]", request.requestID, error.description);
}

- (void)request:(GCKRequest *)request didAbortWithReason:(GCKRequestAbortReason)abortReason
{
    NSLog(@"didAbortWithReason [request id = %ld] [reason:%ld]", request.requestID, (long)abortReason);
}

#pragma mark - GCKSessionManagerListener
// Called when a Cast session is about to be started.
- (void)sessionManager:(GCKSessionManager *)sessionManager willStartCastSession:(GCKCastSession *)session
{
    NSLog(@"sessionManager willStartCastSession %@", session);
}

// Called when a Cast session has been successfully started.
- (void)sessionManager:(GCKSessionManager *)sessionManager didStartCastSession:(GCKCastSession *)session;
{
    NSLog(@"sessionManager didStartCastSession %@", session);
    
    self.mediaClient = session.remoteMediaClient;
    [self.mediaClient addListener:self];
}

// Called when a Cast session is about to be ended, either by request or due to an error.
- (void)sessionManager:(GCKSessionManager *)sessionManager willEndCastSession:(GCKCastSession *)session
{
    NSLog(@"sessionManager willEndCastSession %@", session);
}

// Called when a Cast session has ended, either by request or due to an error.
- (void)sessionManager:(GCKSessionManager *)sessionManager didEndCastSession:(GCKCastSession *)session withError:(NSError *GCK_NULLABLE_TYPE)error
{
    NSLog(@"sessionManager didEndCastSession with error %@", error);
    
    self.mediaClient = nil;
    [self.mediaClient removeListener:self];
}

// Called when a Cast session has failed to start.
- (void)sessionManager:(GCKSessionManager *)sessionManager didFailToStartCastSession:(GCKCastSession *)session withError:(NSError *)error
{
    NSLog(@"sessionManager didFailToStartCastSession with error %@", error);
}

// Called when a Cast session has been suspended.
- (void)sessionManager:(GCKSessionManager *)sessionManager didSuspendCastSession:(GCKCastSession *)session withReason:(GCKConnectionSuspendReason)reason
{
    NSLog(@"sessionManager didSuspendCastSession with reason: %ld", (long)reason);
}

// Called when a Cast session is about to be resumed.
- (void)sessionManager:(GCKSessionManager *)sessionManager willResumeCastSession:(GCKCastSession *)session;
{
    NSLog(@"sessionManager willResumeCastSession %@", session);
}

// Called when a Cast session has been successfully resumed.
- (void)sessionManager:(GCKSessionManager *)sessionManager didResumeCastSession:(GCKCastSession *)session
{
    NSLog(@"sessionManager didResumeCastSession %@", session);
    
    self.mediaClient = session.remoteMediaClient;
    [self.mediaClient addListener:self];
}

// Called when the device associated with this session has changed in some way (for example, the friendly name has changed).
- (void)sessionManager:(GCKSessionManager *)sessionManager session:(GCKSession *)session didUpdateDevice:(GCKDevice *)device;
{
    NSLog(@"sessionManager didUpdateDevice ID: %@", device.deviceID);
}

// Called when updated device volume and mute state for a Cast session have been received.
- (void)sessionManager:(GCKSessionManager *)sessionManager castSession:(GCKCastSession *)session didReceiveDeviceVolume:(float)volume muted:(BOOL)muted
{
    NSLog(@"sessionManager castSession didReceiveDeviceVolume: %f, ismuted: %d", volume, muted);
}

// Called when updated device status for a Cast session has been received.
- (void)sessionManager:(GCKSessionManager *)sessionManager castSession:(GCKCastSession *)session didReceiveDeviceStatus:(NSString *GCK_NULLABLE_TYPE)statusText
{
    NSLog(@"sessionManager castSession didReceiveDeviceStatus: %@", statusText);
}

// Called when the default session options have been changed for a given device category.
- (void)sessionManager:(GCKSessionManager *)sessionManager didUpdateDefaultSessionOptionsForDeviceCategory:(NSString *)category
{
    NSLog(@"sessionManager didUpdateDefaultSessionOptionsForDeviceCategory: %@", category);
}

#pragma mark - GCKRemoteMediaClientListener

// Called when a new media session has started on the receiver.
- (void)remoteMediaClient:(GCKRemoteMediaClient *)client didStartMediaSessionWithID:(NSInteger)sessionID
{
    NSLog(@"remoteMediaClient succeed to load media[session id:%ld]\n", (long)sessionID);
}

// Called when updated media status has been received from the receiver.
- (void)remoteMediaClient:(GCKRemoteMediaClient *)client didUpdateMediaStatus:(GCKMediaStatus *GCK_NULLABLE_TYPE)mediaStatus
{
    NSString *stateString = @"unknown";
    if (mediaStatus.playerState == GCKMediaPlayerStateIdle)
    {
        stateString = @"idle";
    }
    else if (mediaStatus.playerState == GCKMediaPlayerStatePlaying)
    {
        stateString = @"playing";
    }
    else if (mediaStatus.playerState == GCKMediaPlayerStatePaused)
    {
        stateString = @"paused";
    }
    else if (mediaStatus.playerState == GCKMediaPlayerStateBuffering)
    {
        stateString = @"buffering";
    }
    else if (mediaStatus.playerState == GCKMediaPlayerStateLoading)
    {
        stateString = @"loading";
    }
    
    NSLog(@"remoteMediaClient status changed [state:%@]\n", stateString);
}

// Called when updated media metadata has been received from the receiver.
- (void)remoteMediaClient:(GCKRemoteMediaClient *)client didUpdateMediaMetadata:(GCKMediaMetadata *GCK_NULLABLE_TYPE)mediaMetadata
{
    NSLog(@"remoteMediaClient media metadate updated");
}

// Called when the media playback queue has been updated on the receiver.
- (void)remoteMediaClientDidUpdateQueue:(GCKRemoteMediaClient *)client
{
    NSLog(@"remoteMediaClient DidUpdateQueue");
}

// Called when the media preload status has been updated on the receiver.
- (void)remoteMediaClientDidUpdatePreloadStatus:(GCKRemoteMediaClient *)client
{
    NSLog(@"remoteMediaClient DidUpdatePreloadStatus");
}

// Called when a contiguous sequence of items has been inserted into the media queue.
- (void)remoteMediaClient:(GCKRemoteMediaClient *)client didInsertQueueItemsWithIDs:(NSArray<NSNumber *> *)queueItemIDs beforeItemWithID:(GCKMediaQueueItemID)beforeItemID
{
    NSLog(@"remoteMediaClient didInsertQueueItemsWithIDs");
}

// Called when existing items has been updated in the media queue.
- (void)remoteMediaClient:(GCKRemoteMediaClient *)client didUpdateQueueItemsWithIDs:(NSArray<NSNumber *> *)queueItemIDs
{
    NSLog(@"remoteMediaClient didUpdateQueueItemsWithIDs");
}

// Called when a contiguous sequence of items has been removed from the media queue.
- (void)remoteMediaClient:(GCKRemoteMediaClient *)client didRemoveQueueItemsWithIDs:(NSArray<NSNumber *> *)queueItemIDs
{
    NSLog(@"remoteMediaClient didRemoveQueueItemsWithIDs");
}

// Called when the list of media queue item IDs has been received. <queueFetchItemIDs>
- (void)remoteMediaClient:(GCKRemoteMediaClient *)client didReceiveQueueItemIDs:(NSArray<NSNumber *> *)queueItemIDs
{
    NSLog(@"remoteMediaClient didReceiveQueueItemIDs [queueItemIDs count: %d]", (int)queueItemIDs.count);
}

// Called when detailed information has been received for one or more items in the queue. <queueFetchItemsForIDs>
- (void)remoteMediaClient:(GCKRemoteMediaClient *)client didReceiveQueueItems:(NSArray<GCKMediaQueueItem *> *)queueItems
{
    NSLog(@"remoteMediaClient didReceiveQueueItems");
}


@end
