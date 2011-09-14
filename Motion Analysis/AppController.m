//
//  AppController.m
//  Motion Analysis
//
//  Created by Kevin Loken on 11-07-22.
//  Copyright 2011 Stone Sanctuary Interactive Inc. All rights reserved.
//

#import "AppController.h"
#import <Accelerate/Accelerate.h>
#import "Vec3.h"

@implementation AppController

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _x = NULL;
        _y = NULL;
        _z = NULL;
        
        _count = 0;
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
                                  
                                  _count = [data count];
                                  _x = malloc(sizeof(double) * [data count]);
                                  _y = malloc(sizeof(double) * [data count]);
                                  _z = malloc(sizeof(double) * [data count]);
                                  _gx = malloc(sizeof(double) * [data count]);
                                  _gy = malloc(sizeof(double) * [data count]);
                                  _gz = malloc(sizeof(double) * [data count]);
                                  
                                  NSLog(@"There are %d elements", _count);
                                  
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
                                      
                                      _x[i] = x;
                                      _y[i] = y;
                                      _z[i] = z;
                                      
                                      gx = [[[data objectAtIndex:i] valueForKey:@"gx"] doubleValue];
                                      gy = [[[data objectAtIndex:i] valueForKey:@"gy"] doubleValue];
                                      gz = [[[data objectAtIndex:i] valueForKey:@"gz"] doubleValue];
                                      
                                      _gx[i] = gx;
                                      _gy[i] = gy;
                                      _gz[i] = gz;
                                      
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

-(void)doStuff:(id)sender
{
    // [self RealFFTUsageAndTiming];
    for ( int i = 0; i < _count; ++i ) {
        Vec3* gravity = [[[Vec3 alloc] initWithX:_gx[i] Y:_gy[i] Z:_gz[i]] autorelease];
        Vec3* user = [[[Vec3 alloc] initWithX:_x[i] Y:_y[i] Z:_z[i]] autorelease];
        Vec3* y_up = [[[Vec3 alloc] initWithX:0 Y:1 Z:0] autorelease];
        
        Vec3* rot = [gravity cross:y_up];
        double angle = acos([gravity dot:y_up]);
        
        double sa = sin(-angle);
        double ca = cos(-angle);
        
        Vec3* oriented = [[[Vec3 alloc] init] autorelease];
        double x = user.x;
        double y = user.y;
        double z = user.z;
        double u = rot.x;
        double v = rot.y;
        double w = rot.z;
        
        double ux = u * x;
        double uy = u * y;
        double uz = u * z;
        double vx = v * x;
        double vy = v * y;
        double vz = v * z;
        double wx = w * x;
        double wy = w * y;
        double wz = w * z;
        
        double a = 0;
        double b = 0;
        double c = 0;
        
        // #WRONG!
        oriented.x = (a * (v*v + w*w) - u * (b * v + c * w - ux - vy -wz)) * (1 - ca) + x * ca + (-c*v + b * w - wy + vz) * sa;
        oriented.y = (b * (u*u + w*w) - v * (a * u + c * w - ux - vy - wz)) * (1 - ca) + y * ca + (c*u - a*w + wx - uz) * sa; 
        oriented.z = (c * (u*u + v*v) - w * (a * u + b * v - ux - vy - wz)) * (1 - ca) + z * ca + (-b*u + a*v - vx + uy) * sa;
        
        NSLog(@"oriented: %f, %f, %f, magnitude %f => %f",oriented.x,oriented.y,oriented.z, [user dot:user], [oriented dot:oriented]);
    }
    
}

-(void)dealloc
{
    if (_x != NULL) free(_x);
    if (_y != NULL) free(_y);
    if (_z != NULL) free(_z);
    
    [super dealloc];
}
@end
