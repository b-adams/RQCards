//
//  RQC_MI_Playmatted.h
//  Red Queen Cards - OS X
//
//  Created by Bryant Adams on 5/24/13.
//  Copyright (c) 2013 Bryant Adams. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RQC_e_Impotence,    //Virus has insufficient MAMPs
    RQC_e_MTI,          //Plant only detects MAMPs
    RQC_e_ETI,          //Plant detects Effectors
    RQC_e_Virulence,    //Pathogen infiltrates
    RQC_e_Unviability   //Plant has oversensitive ETI
} RQC_E_GameState;

@protocol RQC_MI_Playmatted <NSObject>
@property (readonly, assign) RQC_E_GameState currentBoardState;

-(void) playMAMP:(NSString*) colName;
-(void) playMAMPDetector:(NSString*) colName;
-(void) playEffector:(NSString*) colName
       variantNumber:(NSUInteger) variant;
-(void) playEffectorDetector:(NSString*) colName
               variantNumber:(NSUInteger) variant;


@end
