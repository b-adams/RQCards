//
//  RQCDocument.m
//  Red Queen Cards - OS X
//
//  Created by Bryant Adams on 5/27/13.
//  Copyright (c) 2013 Bryant Adams. All rights reserved.
//

#import "RQCDocument.h"
#import "RQCmPlaymat.h"

@implementation RQCDocument
{
    id<RQC_MI_Playmatted> _theMat;
    NSMutableDictionary* _relevantHazards;
    NSMutableDictionary* _relevantDetectors;
}

- (id)init
{
    self = [super init];
    if (self) {
        _relevantDetectors = [NSMutableDictionary dictionaryWithCapacity:8];
        _relevantHazards = [NSMutableDictionary dictionaryWithCapacity:8];
        _theMat = [[RQCmPlaymat alloc] init];
        [(id)_theMat addObserver:self
                     forKeyPath:@"currentBoardState"
                        options:NSKeyValueObservingOptionNew
                        context:NULL];
        
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"RQCDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    [self updateBoardStateLabel];

}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return YES;
}

#pragma mark - conforming to NSWindowDelegate -

-(void)windowWillClose:(NSNotification *)notification
{
    [self invalidate];
}

#pragma mark Helpers

-(void) invalidate
{
    [_theMat invalidate];
    [(id)_theMat removeObserver:self
                     forKeyPath:@"currentBoardState"
                        context:NULL];
}

#pragma mark - Model responses -

#pragma mark Observation
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if(object!=_theMat || ![keyPath isEqualToString:@"currentBoardState"])
    {
        NSLog(@"WARNING: %p observed change in %p's %@ but didn't care.",
              self, object, keyPath);
        return;
    }

    [self updateBoardStateLabel];
}

#pragma mark Helpers

-(void)updateBoardStateLabel
{
    NSString* newLabel;
    switch([_theMat currentBoardState])
    {
        case RQC_e_ETI:
            newLabel = @"ETI";
            break;
        case RQC_e_Impotence:
            newLabel = @"Pathogen not viable";
            break;
        case RQC_e_MTI:
            newLabel = @"MTI";
            break;
        case RQC_e_Unviability:
            newLabel = @"Plant not viable";
            break;
        case RQC_e_Virulence:
            newLabel = @"Virulence";
            break;
    }
    [[self infoLabel] setStringValue:newLabel];
    
}

#pragma mark - View responses -

#pragma mark Helpers

-(void)pushHazard:(NSString*) colName
      usingButton:(id) theButton
{
    [_relevantHazards setObject:theButton forKey:colName];

    [_theMat playMAMP:colName];
    
    [[theButton cell] setBackgroundColor:[NSColor orangeColor]];
    [theButton setBordered:NO];
}

-(void)pushDetector:(NSString*) colName
      usingButton:(id) theButton
{
    [_relevantDetectors setObject:theButton forKey:colName];

    [_theMat playMAMPDetector:colName];
    
    [[theButton cell] setBackgroundColor:[NSColor brownColor]];
    [theButton setBordered:NO];
}

-(void)pushHazard:(NSString*) colName
        ofVariety:(NSUInteger) variant
      usingButton:(id) theButton
{
    NSString* fullName = [NSString stringWithFormat:@"%@%ld", colName, variant];
    [_relevantHazards setObject:theButton forKey:fullName];

    [_theMat playEffector:colName variantNumber:variant];
    
    [[theButton cell] setBackgroundColor:[NSColor redColor]];
    [theButton setBordered:NO];
}

-(void)pushDetector:(NSString*) colName
          ofVariety:(NSUInteger) variant
        usingButton:(id) theButton
{
    NSString* fullName = [NSString stringWithFormat:@"%@%ld", colName, variant];
    [_relevantDetectors setObject:theButton forKey:fullName];

    [_theMat playEffectorDetector:colName variantNumber:variant];
    
    [[theButton cell] setBackgroundColor:[NSColor greenColor]];
    [theButton setBordered:NO];
}

#pragma mark Actions

- (IBAction)pushedAMAMP:(id)sender { [self pushHazard:@"a"
                                          usingButton:sender]; }
- (IBAction)pushedBMAMP:(id)sender { [self pushHazard:@"b"
                                          usingButton:sender]; }
- (IBAction)pushedCMAMP:(id)sender { [self pushHazard:@"c"
                                          usingButton:sender]; }
- (IBAction)pushedDMAMP:(id)sender { [self pushHazard:@"d"
                                          usingButton:sender]; }

- (IBAction)pushedADetector:(id)sender { [self pushDetector:@"a"
                                                usingButton:sender]; }
- (IBAction)pushedBDetector:(id)sender { [self pushDetector:@"b"
                                                usingButton:sender]; }
- (IBAction)pushedCDetector:(id)sender { [self pushDetector:@"c"
                                                usingButton:sender]; }
- (IBAction)pushedDDetector:(id)sender { [self pushDetector:@"d"
                                                usingButton:sender]; }


- (IBAction)pushedA1Effector:(id)sender { [self pushHazard:@"a" ofVariety:1
                                               usingButton:sender]; }
- (IBAction)pushedA2Effector:(id)sender { [self pushHazard:@"a" ofVariety:2
                                               usingButton:sender]; }
- (IBAction)pushedB1Effector:(id)sender { [self pushHazard:@"b" ofVariety:1
                                               usingButton:sender]; }
- (IBAction)pushedB2Effector:(id)sender { [self pushHazard:@"b" ofVariety:2
                                               usingButton:sender]; }
- (IBAction)pushedC1Effector:(id)sender { [self pushHazard:@"c" ofVariety:1
                                               usingButton:sender]; }
- (IBAction)pushedC2Effector:(id)sender { [self pushHazard:@"c" ofVariety:2
                                               usingButton:sender]; }
- (IBAction)pushedD1Effector:(id)sender { [self pushHazard:@"d" ofVariety:1
                                               usingButton:sender]; }
- (IBAction)pushedD2Effector:(id)sender { [self pushHazard:@"d" ofVariety:2
                                               usingButton:sender]; }


- (IBAction)pushedA1Detector:(id)sender { [self pushDetector:@"a" ofVariety:1
                                                 usingButton:sender]; }
- (IBAction)pushedA2Detector:(id)sender { [self pushDetector:@"a" ofVariety:2
                                                 usingButton:sender]; }
- (IBAction)pushedB1Detector:(id)sender { [self pushDetector:@"b" ofVariety:1
                                                 usingButton:sender]; }
- (IBAction)pushedB2Detector:(id)sender { [self pushDetector:@"a" ofVariety:2
                                                 usingButton:sender]; }
- (IBAction)pushedC1Detector:(id)sender { [self pushDetector:@"c" ofVariety:1
                                                 usingButton:sender]; }
- (IBAction)pushedC2Detector:(id)sender { [self pushDetector:@"c" ofVariety:2
                                                 usingButton:sender]; }
- (IBAction)pushedD1Detector:(id)sender { [self pushDetector:@"d" ofVariety:1
                                                 usingButton:sender]; }
- (IBAction)pushedD2Detector:(id)sender { [self pushDetector:@"d" ofVariety:2
                                                 usingButton:sender]; }
@end
