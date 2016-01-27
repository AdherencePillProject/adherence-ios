//
//  DeviceCommunicateViewController.h
//  AdherenceApp
//
//  Created by Shikhar Mohan on 1/27/16.
//  Copyright © 2016 Shana Azria Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BLECommanderiOS;
@protocol DeviceCommunicateViewControllerDelegate;

@interface DeviceCommunicateViewController : UIViewController
@property (nonatomic, weak)BLECommanderiOS *mBleCommanderiOS;
@property (nonatomic, strong)NSString *deviceName;
@property (nonatomic, weak) id <DeviceCommunicateViewControllerDelegate> delegate;

@end

@protocol DeviceCommunicateViewControllerDelegate <NSObject>
- (void)deviceConnectionDidTimeOut;
@end



