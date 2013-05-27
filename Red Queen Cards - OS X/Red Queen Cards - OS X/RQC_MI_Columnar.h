//
//  RQC_MI_Columnar.h
//  Red Queen Cards - OS X
//
//  Created by Bryant Adams on 5/24/13.
//  Copyright (c) 2013 Bryant Adams. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RQC_MI_Columnar <NSObject>
@property (readonly, assign) BOOL isMAMPAlarmTriggered;
@property (readonly, assign) BOOL isEffectorAlarmTriggered;

-(void)enableMAMP;
-(void)enablePRR;
-(void)enableEffector:(NSUInteger) variant;
-(void)enableRProtein:(NSUInteger) variant;

@end
