/**
 * Created with JetBrains WebStorm.
 * User: badams
 * Date: 5/31/13
 * Time: 9:34 PM
 * To change this template use File | Settings | File Templates.
 */
//Require InteractionColumn

var MAMP_MATCHES_TO_TRIGGER_MTI = 2;
var MAMP_COUNT_TO_TRIGGER_VIRULENCE = 2;
var MAX_RPROTEINS_BEFORE_UNVIABILITY_RISK = 4;
var KEY_ALARM_MAMP = "mampAlarmDidChange";
var KEY_ALARM_EFFECTOR = "effectorAlarmDidChange";


function PlayMat()
{
    this._columns = [];
    for(var i=0; i<8; i+=1)
    {
        this._columns[i] = new InteractionColumn();
    }
    document.addEventListener(KEY_ALARM_MAMP, this.onMampAlarmDidChange);
    document.addEventListener(KEY_ALARM_EFFECTOR, this.onEffectorAlarmDidChange);
    this._MAMPsMatched = 0;
    this._MAMPsPlayed = 0;
    this._RProteinsPlayed = 0;
    this.setCurrentBoardState("RQC_e_Impotence");

    /* Playmay methods */
    this.playMAMP = function(colIndex)
    {
        var theColumn = this._columns[colIndex];
        if(theColumn._MAMP) return; //Already been played

        this._MAMPsPlayed += 1;

        if(this._MAMPsPlayed = MAMP_COUNT_TO_TRIGGER_VIRULENCE)
            this.triggerVirulence();
    }
}



#pragma mark - conforming to RQC_MI_Playmatted

- (void)playMAMP:(NSString *)colName
{
    id<RQC_MI_Columnar> theColumn = [self getColumnNamed:colName];

    _MAMPsPlayed+=1; //Will need to be improved for duplicate MAMPs?
    if(_MAMPsPlayed == MAMP_COUNT_TO_TRIGGER_VIRULENCE)
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
