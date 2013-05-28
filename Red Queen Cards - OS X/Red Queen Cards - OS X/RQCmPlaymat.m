//
//  RQCmPlaymat.m
//  Red Queen Cards - OS X
//
//  Created by Bryant Adams on 5/27/13.
//  Copyright (c) 2013 Bryant Adams. All rights reserved.
//

#import "RQCmInteractionColumn.h"
#import "RQCmPlaymat.h"

const NSUInteger MAMP_MATCHES_TO_TRIGGER_MTI = 2;
const NSUInteger MAMP_COUNT_TO_TRIGGER_VIRULENCE = 2;
const NSUInteger MAX_RPROTEINS_BEFORE_UNVIABILITY_RISK = 3;
NSString *const KEY_ALARM_MAMP = @"alarmMAMP";
NSString *const KEY_ALARM_EFFECTOR = @"alarmEffector";

@implementation RQCmPlaymat
{
    NSMutableDictionary* _columns;
    NSUInteger _MAMPsMatched;
    NSUInteger _MAMPsPlayed;
    NSUInteger _RProteinsPlayed;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self setCurrentBoardState:RQC_e_Impotence];
        _MAMPsMatched=0;
        _MAMPsPlayed=0;
        _RProteinsPlayed=0;
        
        _columns = [NSMutableDictionary dictionary];
        
    }
    return self;
}

-(NSString *)description
{
    NSString* boardStateString;
    switch([self currentBoardState])
           {
               case RQC_e_Unviability:  boardStateString=@"Patho (Unviable)"; break;
               case RQC_e_Virulence:    boardStateString=@"Patho (Virulent)"; break;
               case RQC_e_Impotence:    boardStateString=@"Plant (Impotent)"; break;
               case RQC_e_MTI:          boardStateString=@"Plant (MTI)"; break;
               case RQC_e_ETI:          boardStateString=@"Plant (ETI)"; break;
           }
    return [NSString stringWithFormat:@"PLAYMAT: State[%d] %@ MAMPS %ld/%ld RPros %ld DATA: %@",
            [self currentBoardState],
            boardStateString, (unsigned long)_MAMPsMatched,
            (unsigned long)_MAMPsPlayed, (unsigned long)_RProteinsPlayed, _columns];
}
-(id<RQC_MI_Columnar>)getColumnNamed:(NSString*) name
{
    id<RQC_MI_Columnar> aColumn = nil;
    aColumn = [_columns objectForKey:name];
    if(!aColumn) aColumn = [self addColumnNamed:name];
    return aColumn;
}

-(id<RQC_MI_Columnar>)addColumnNamed:(NSString*) name
{
    id aColumn = [[RQCmInteractionColumn alloc] init];
    [aColumn addObserver:self
              forKeyPath:KEY_ALARM_EFFECTOR
                 options:NSKeyValueObservingOptionNew
                 context:NULL];
    [aColumn addObserver:self
              forKeyPath:KEY_ALARM_MAMP
                 options:NSKeyValueObservingOptionNew
                 context:NULL];
    [_columns setObject:aColumn
                forKey:name];
    return aColumn;
}

#pragma mark - conforming to RQC_MI_Playmatted

- (void)playMAMP:(NSString *)colName
{
    id<RQC_MI_Columnar> theColumn = [self getColumnNamed:colName];

    _MAMPsPlayed+=1; //Will need to be improved for duplicate MAMPs?
    if(_MAMPsPlayed >= MAMP_COUNT_TO_TRIGGER_VIRULENCE)
        [self triggerVirulence];
    
    [theColumn enableMAMP];
}
- (void)playMAMPDetector:(NSString *)colName
{
    id<RQC_MI_Columnar> theColumn = [self getColumnNamed:colName];
    [theColumn enablePRR];
}

- (void)playEffector:(NSString *)colName
       variantNumber:(NSUInteger)variant
{
    id<RQC_MI_Columnar> theColumn = [self getColumnNamed:colName];
    [theColumn enableEffector:variant];
}

- (void)playEffectorDetector:(NSString *)colName
               variantNumber:(NSUInteger)variant
{
    id<RQC_MI_Columnar> theColumn = [self getColumnNamed:colName];

    _RProteinsPlayed+=1;
    NSInteger riskLevel;
    riskLevel = _RProteinsPlayed - MAX_RPROTEINS_BEFORE_UNVIABILITY_RISK;
    if(riskLevel>0 && (rand()%10 < riskLevel))
        [self triggerUnviability];

    [theColumn enableRProtein:variant];
}

#pragma mark - Alarm listeners

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if([keyPath isEqualToString:KEY_ALARM_MAMP])
    {
        NSNumber* newValue = [change objectForKey:@"new"];
        [self onMAMPAlarmUpdateInColumn:object
                                toState:[newValue boolValue]];
    }
    else if([keyPath isEqualToString:KEY_ALARM_EFFECTOR])
    {
        NSNumber* newValue = [change objectForKey:@"new"];
        newValue = [change objectForKey:@"new"];
        [self onEffectorAlarmUpdateInColumn:object
                                    toState:[newValue boolValue]];
    }
    else
    {
        NSLog(@"Warning: Observed change in %p's %@ but did not handle it",
              object, keyPath);
    }
}

-(void)onMAMPAlarmUpdateInColumn:(id<RQC_MI_Columnar>)theColumn
                         toState:(BOOL) alarmIsActive
{
    if(alarmIsActive)
    {
        _MAMPsMatched+=1;
        if(_MAMPsMatched >= MAMP_MATCHES_TO_TRIGGER_MTI)
        {
            [self triggerMTI];
        }
    }
    else
    {
        _MAMPsMatched-=1;
        if(_MAMPsMatched < MAMP_MATCHES_TO_TRIGGER_MTI)
            [self triggerLowMAMPDetection];
    }
}

-(void)onEffectorAlarmUpdateInColumn:(id<RQC_MI_Columnar>)theColumn
                             toState:(BOOL) alarmIsActive
{
    if(alarmIsActive)
        [self triggerETI];
    else
        NSLog(@"WARNING: Attempt to UNtrigger ETI!?");
}

#pragma mark - Board state transitions

//Note: No need to trigger impotence:
//Virulence and MTI both imply potence, and MAMPs cannot be removed,
//ETI and Unviability happens regardless of potence, and cannot be escaped
-(void)triggerETI
{
    switch([self currentBoardState])
    {
        case RQC_e_Unviability: break;  //You're broken, sorry!
        case RQC_e_ETI:         
        case RQC_e_MTI:
        case RQC_e_Virulence:
        case RQC_e_Impotence:
            [self setCurrentBoardState:RQC_e_ETI];
    }
}
-(void)triggerMTI
{
    switch([self currentBoardState])
    {
        case RQC_e_Unviability: break;  //You're broken, sorry!
        case RQC_e_ETI:         break;  //ETI trumps all other normal states
        case RQC_e_MTI:
        case RQC_e_Virulence:
        case RQC_e_Impotence:
            [self setCurrentBoardState:RQC_e_MTI];
    }
}
-(void)triggerLowMAMPDetection
{
    switch([self currentBoardState])
    {
        case RQC_e_Unviability: break;  //You're broken, sorry!
        case RQC_e_ETI:         break;  //ETI trumps all other normal states
        case RQC_e_Virulence:   break;  //Less detection is still virulent
        case RQC_e_Impotence:   break;  //Less detection does not help
        case RQC_e_MTI:                 //Stand down alarms
            [self setCurrentBoardState:RQC_e_Virulence];
    }
}

-(void)triggerVirulence
{
    switch([self currentBoardState])
    {
        case RQC_e_Unviability: break;  //You're broken, sorry!
        case RQC_e_ETI:         break;  //ETI trumps all other normal states
        case RQC_e_Virulence:   
        case RQC_e_MTI:
        case RQC_e_Impotence:
        default:
            [self setCurrentBoardState:RQC_e_Virulence];
    }
}

-(void)triggerUnviability
{
    switch([self currentBoardState])
    {
        case RQC_e_Unviability:
        case RQC_e_ETI:                 //Even breaks ETI!
        case RQC_e_Virulence:
        case RQC_e_MTI:
        case RQC_e_Impotence:
        default:
            [self setCurrentBoardState:RQC_e_Unviability];
    }
}


@end
