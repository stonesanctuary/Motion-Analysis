//
//  AppController.h
//  Motion Analysis
//
//  Created by Kevin Loken on 11-07-22.
//  Copyright 2011 Stone Sanctuary Interactive Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CorePlot/CorePlot.h>

@interface AppController : NSObject<CPTScatterPlotDataSource, NSTableViewDataSource, NSTableViewDelegate> {
    IBOutlet NSView *view;
    IBOutlet CPTGraphHostingView *hostView;
    CPTXYGraph *graph;
    CPTScatterPlot *_dataSourceLinePlot;
    
    IBOutlet NSTableView *tableView;
    
    NSUInteger _count;
    
    double *_t;
    
    double *_x;
    double *_y;
    double *_z;
    
    double *_gx;
    double *_gy;
    double *_gz;
    
    double *_rx;
    double *_ry;
    double *_rz;    

    double *_roll;
    double *_pitch;
    double *_yaw;  
    
    NSURL* _url;
    
}

@property (nonatomic, retain) NSURL* url;
@property (nonatomic, retain)     CPTScatterPlot *dataSourceLinePlot;;

- (IBAction)showOpenPanel:(id)sender;
- (IBAction)exportToCsvFile:(id)sender;
- (IBAction)tableClicked:(id)sender;

@end
