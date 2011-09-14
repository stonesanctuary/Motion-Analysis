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
    
    int _count;
    
    double *_x;
    double *_y;
    double *_z;
    
    double *_gx;
    double *_gy;
    double *_gz;
}

- (IBAction)showOpenPanel:(id)sender;
- (IBAction)doStuff:(id)sender;

@end
