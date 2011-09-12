//
//  AppController.h
//  Motion Analysis
//
//  Created by Kevin Loken on 11-07-22.
//  Copyright 2011 Stone Sanctuary Interactive Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppController : NSObject {
    IBOutlet NSView *view;
}

- (IBAction)showOpenPanel:(id)sender;

@end
