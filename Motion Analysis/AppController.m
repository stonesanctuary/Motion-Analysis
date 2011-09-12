//
//  AppController.m
//  Motion Analysis
//
//  Created by Kevin Loken on 11-07-22.
//  Copyright 2011 Stone Sanctuary Interactive Inc. All rights reserved.
//

#import "AppController.h"

@implementation AppController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark - File Handling

- (IBAction)showOpenPanel:(id)sender
{
    NSLog(@"showOpenPanel");
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setDirectoryURL:nil];
    [panel setAllowedFileTypes:[[NSArray alloc] initWithObjects:@"xml", nil]];
    
    [panel beginSheetModalForWindow:[view window]  
                  completionHandler:^(NSInteger result) {        
                      if ( result == NSOKButton ) {
                          NSArray *urls = [panel URLs];
                          if ( [urls count] > 0 ) {
                              NSURL* url = [urls objectAtIndex:0];
                              NSArray *data = [[NSArray alloc] initWithContentsOfURL:url];
                              NSLog(@"data has %lu elements", [data count]);
                              
                              NSString* path = [[[url path] stringByDeletingPathExtension] stringByAppendingPathExtension:@"csv"];
                              // FILE* f = fopen("/Users/kevinloken/Desktop/test.csv", "w");
                              NSLog(@"outputting to %@", path);
                              
                              FILE* f = fopen([path UTF8String], "w");
                              if ( f ) {
                                  fprintf(f, "timestamp, t, x, y, z, gx, gy, gz, rx, ry, rz, roll, pitch, yaw\n");
                                  
                                  for ( NSUInteger i = 0; i < [data count]; ++i ) {
                                      double timestamp, timestamp0, t, x, y, z, gx, gy, gz, rx, ry, rz, roll, yaw, pitch;
                                      
                                      timestamp = [[[data objectAtIndex:i] valueForKey:@"timestamp"] doubleValue];
                                      if ( i == 0 ) {
                                          timestamp0 = timestamp;
                                      }
                                      t = timestamp - timestamp0;
                                      
                                      x = [[[data objectAtIndex:i] valueForKey:@"x"] doubleValue];
                                      y = [[[data objectAtIndex:i] valueForKey:@"y"] doubleValue];
                                      z = [[[data objectAtIndex:i] valueForKey:@"z"] doubleValue];
                                      
                                      gx = [[[data objectAtIndex:i] valueForKey:@"gx"] doubleValue];
                                      gy = [[[data objectAtIndex:i] valueForKey:@"gy"] doubleValue];
                                      gz = [[[data objectAtIndex:i] valueForKey:@"gz"] doubleValue];
                                      
                                      rx = [[[data objectAtIndex:i] valueForKey:@"rx"] doubleValue];
                                      ry = [[[data objectAtIndex:i] valueForKey:@"ry"] doubleValue];
                                      rz = [[[data objectAtIndex:i] valueForKey:@"rz"] doubleValue];
                                      
                                      roll = [[[data objectAtIndex:i] valueForKey:@"roll"] doubleValue];
                                      pitch = [[[data objectAtIndex:i] valueForKey:@"pitch"] doubleValue];
                                      yaw = [[[data objectAtIndex:i] valueForKey:@"yaw"] doubleValue];

                                      fprintf(f, "%f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f\n", timestamp, t, x, y, z, gx, gy, gz, rx, ry, rz, roll, pitch, yaw);
                                              
                                  }
                                  fclose(f);
                                           
                              }
                          }
                      }
                  }
    ];
}

@end
