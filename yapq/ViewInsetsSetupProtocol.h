//
//  ViewInsetsSetupProtocol.h
//  yapq
//
//  Created by yapQ Ltd on 6/13/14.
//  Copyright (c) 2014 yapQ Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * During receiving any message about app running process(GPS signal, network signal, etc.)
 * need to calculate offset and inset of all tabel views in application.
 * This protocol notifi all children of MenuNavigationController about message displaying 
 * and each class will calculate inset and offset with it's needs
 */
@protocol ViewInsetsSetupProtocol <NSObject>

-(void)setupViewInsets:(UIEdgeInsets)inset andOffset:(int)offset;

@end
