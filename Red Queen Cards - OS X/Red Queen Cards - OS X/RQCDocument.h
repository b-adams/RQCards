//
//  RQCDocument.h
//  Red Queen Cards - OS X
//
//  Created by Bryant Adams on 5/27/13.
//  Copyright (c) 2013 Bryant Adams. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface RQCDocument : NSDocument <NSWindowDelegate>

- (IBAction)pushedAMAMP:(id)sender;
- (IBAction)pushedADetector:(id)sender;
- (IBAction)pushedA1Effector:(id)sender;
- (IBAction)pushedA2Effector:(id)sender;
- (IBAction)pushedA1Detector:(id)sender;
- (IBAction)pushedA2Detector:(id)sender;

- (IBAction)pushedBMAMP:(id)sender;
- (IBAction)pushedBDetector:(id)sender;
- (IBAction)pushedB1Effector:(id)sender;
- (IBAction)pushedB2Effector:(id)sender;
- (IBAction)pushedB1Detector:(id)sender;
- (IBAction)pushedB2Detector:(id)sender;

- (IBAction)pushedCMAMP:(id)sender;
- (IBAction)pushedCDetector:(id)sender;
- (IBAction)pushedC1Effector:(id)sender;
- (IBAction)pushedC2Effector:(id)sender;
- (IBAction)pushedC1Detector:(id)sender;
- (IBAction)pushedC2Detector:(id)sender;

- (IBAction)pushedDMAMP:(id)sender;
- (IBAction)pushedDDetector:(id)sender;
- (IBAction)pushedD1Effector:(id)sender;
- (IBAction)pushedD2Effector:(id)sender;
- (IBAction)pushedD1Detector:(id)sender;
- (IBAction)pushedD2Detector:(id)sender;

@property (weak) IBOutlet NSTextField *infoLabel;


@end
