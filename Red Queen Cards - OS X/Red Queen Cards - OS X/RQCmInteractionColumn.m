//
//  RQCmInteractionColumn.m
//  Red Queen Cards - OS X
//
//  Created by Bryant Adams on 5/27/13.
//  Copyright (c) 2013 Bryant Adams. All rights reserved.
//

#import "RQCmInteractionColumn.h"

const int erSlots = 10;

@implementation RQCmInteractionColumn
{
    NSUInteger _MAMP;
    NSUInteger _PRR;
    NSUInteger _Effectors[erSlots];
    NSUInteger _RProteins[erSlots];
}

- (id)init
{
    self = [super init];
    if (self) {
        _MAMP=0;
        _PRR=0;
        for(int i=0; i<erSlots; i+=1)
        {
            _Effectors[i]=0;
            _RProteins[i]=0;
        }
    }
    return self;
}


#pragma mark - conforming to RQC_MI_Columnar

- (void)enableMAMP
{
    _MAMP += 1;
    [self updateMAMPAlarm];
}

- (void)enablePRR
{
    _PRR += 1;
    [self updateMAMPAlarm];
}

- (void)enableEffector:(NSUInteger)variant
{
    if([self checkLegalityOfVariant:variant])
    {
        _Effectors[variant] += 1;
        [self updateMAMPAlarm]; //Possible disabling
        [self updateEffectorAlarm]; 
    }
}

- (void)enableRProtein:(NSUInteger)variant
{
    if([self checkLegalityOfVariant:variant])
    {
        _RProteins[variant] += 1;
        [self updateEffectorAlarm];
    }
}

#pragma mark - Alarm methods

- (void)updateEffectorAlarm
{
    int matches=0;
    for(int i=0; i<erSlots; i+=1)
    {
        if(_Effectors[i] && _RProteins[i]) matches+=1;
    }
    BOOL triggered = (matches>0);
    if(triggered != [self isEffectorAlarmTriggered])
        [self setIsEffectorAlarmTriggered:triggered];
}

- (void)updateMAMPAlarm
{
    BOOL disabled = NO;
    for(int i=0; i<erSlots; i+=1)
    {
        if(_Effectors[i]) disabled = YES;
    }
    BOOL triggered = (_MAMP && _PRR && !disabled);
    if(triggered != [self isMAMPAlarmTriggered])
        [self setIsMAMPAlarmTriggered:triggered];
}

#pragma mark - Other helper methods

-(BOOL) checkLegalityOfVariant:(NSUInteger) variant
{
    BOOL legal = variant<erSlots;

    if(!legal)
    {
        NSException* ex = nil;
        NSString* rsn = nil;
        
        rsn = [NSString stringWithFormat:@"Index %ld exceeds %d available slots",
               (unsigned long)variant, erSlots];
        ex = [NSException exceptionWithName:@"Out of Bounds"
                                     reason:rsn
                                   userInfo:nil];
        @throw ex;
    }

    return legal;
}
-(void) reportBadVariant:(NSUInteger) variant
{
    NSLog(@"Warning: Attempting to access out-of-bounds variant %ld",
          (unsigned long)variant);
}

@end
