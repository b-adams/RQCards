//
//  RQCmPlaymat.h
//  Red Queen Cards - OS X
//
//  Created by Bryant Adams on 5/27/13.
//  Copyright (c) 2013 Bryant Adams. All rights reserved.
//

#import "RQC_MI_Playmatted.h"
#import <Foundation/Foundation.h>

@interface RQCmPlaymat : NSObject <RQC_MI_Playmatted>
@property (readwrite, assign) RQC_E_GameState currentBoardState;

@end
