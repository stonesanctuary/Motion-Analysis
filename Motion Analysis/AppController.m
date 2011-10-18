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

@synthesize dataSourceLinePlot = _dataSourceLinePlot;
@synthesize url = _url;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        _x = NULL;
        _y = NULL;
        _z = NULL;
        
        _gx = NULL;
        _gy = NULL;
        _gz = NULL;

        _rx = NULL;
        _ry = NULL;
        _rz = NULL;
        
        _roll = NULL;
        _pitch = NULL;
        _yaw = NULL;
        
        _t = NULL;
        
        _count = 0;
    }
    
    return self;
}

-(void)dealloc
{
    if (_x != NULL) free(_x);
    if (_y != NULL) free(_y);
    if (_z != NULL) free(_z);
    
    if ( _gx != NULL) free(_gx);
    if ( _gy != NULL) free(_gy);
    if ( _gz != NULL) free(_gz);
    
    if ( _rx != NULL) free(_rx);
    if ( _ry != NULL) free(_ry);
    if ( _rz != NULL) free(_rz);
    
    if ( _t != NULL) free(_t);

    if ( _roll != NULL) free(_roll);
    if ( _pitch != NULL) free(_pitch);
    if ( _yaw != NULL) free(_yaw);
    
    self.url = nil;
    self.dataSourceLinePlot = nil;
    
    [graph release];
    
    [super dealloc];
}
     
#pragma mark - 
#pragma mark Graph Functions

-(double)minValue:(double*)data count:(NSUInteger)count
{
    double low = data[0];
    for ( NSUInteger i = 1; i < count; ++i ) {
        if ( data[i] < low ) {
            low = data[i];
        }
    }
    return low;
}


-(double)maxValue:(double*)data count:(NSUInteger)count
{
    double high = data[0];
    for ( NSUInteger i = 1; i < count; ++i ) {
        if ( data[i] > high ) {
            high = data[i];
        }
    }
    return high;
}

-(double*)arrayForColumn:(NSString*)column
{
    double* data = NULL;
    if ( [column isEqualToString:@"x"] ) {
        data = _x;
    } else if ( [column isEqualToString:@"y"] ) {
        data = _y;
    } else if ( [column isEqualToString:@"z"] ) {
        data = _z;
    } else if ( [column isEqualToString:@"gx"] ) {
        data = _gx;
    } else if ( [column isEqualToString:@"gy"] ) {
        data = _gy;
    } else if ( [column isEqualToString:@"gz"] ) {
        data = _gz;
    } else if ( [column isEqualToString:@"rx"] ) {
        data = _rx;
    } else if ( [column isEqualToString:@"ry"] ) {
        data = _ry;
    } else if ( [column isEqualToString:@"rz"] ) {
        data = _rz;
    } else if ( [column isEqualToString:@"roll"] ) {
        data = _roll;
    } else if ( [column isEqualToString:@"pitch"] ) {
        data = _pitch;
    } else if ( [column isEqualToString:@"ya"] ) {
        data = _yaw;
    } else {
        data = _x;
    }

    return data;
}

-(void)createPlot:(NSString*)column
{
    // clear old plot
    if ( _dataSourceLinePlot != nil ) {
        [graph removePlot:_dataSourceLinePlot];
        self.dataSourceLinePlot = nil;
    }
    
    // create new plot
    double* data = [self arrayForColumn:column];
    if ( data == NULL ) {
        return;
    }
    
    // Setup plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    double minT = [self minValue:_t count:_count];
    double maxT = [self maxValue:_t count:_count];
    double minX = [self minValue:data count:_count];
    double maxX = [self maxValue:data count:_count];
    
    double tRange = maxT - minT;
    double xRange = maxX - minX;
    
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minT - tRange/10.0) length:CPTDecimalFromFloat(1.2 * tRange)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minX - xRange/10.0) length:CPTDecimalFromFloat(1.2 * xRange)];
    
 	CPTMutableShadow *lineShadow = [CPTMutableShadow shadow];
	lineShadow.shadowOffset = CGSizeMake(3.0, -3.0);
	lineShadow.shadowBlurRadius = 4.0;
	lineShadow.shadowColor = [CPTColor redColor];
    
    self.dataSourceLinePlot = [[(CPTScatterPlot *)[CPTScatterPlot alloc] initWithFrame:graph.bounds] autorelease];
    _dataSourceLinePlot.identifier = column;
    _dataSourceLinePlot.shadow = nil; // lineShadow;
    
    CPTMutableLineStyle *lineStyle = [[_dataSourceLinePlot.dataLineStyle mutableCopy] autorelease];
    lineStyle.lineWidth = 1.f;
    lineStyle.lineColor = [CPTColor redColor];
    _dataSourceLinePlot.dataLineStyle = lineStyle;
    
    _dataSourceLinePlot.dataSource = self;
    
    [graph addPlot:_dataSourceLinePlot];
}

-(void)createGraph
{
    // Create graph
    graph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:NSRectToCGRect(hostView.bounds)];
    hostView.hostedGraph = graph;
	
 	// Remove axes
    // graph.axisSet = nil;
	
	// Background
	CGColorRef grayColor = CGColorCreateGenericGray(0.7, 1.0);
	graph.fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:grayColor]];
	CGColorRelease(grayColor);
	
	// Plot area
	grayColor = CGColorCreateGenericGray(0.2, 0.3);
	graph.plotAreaFrame.fill = [CPTFill fillWithColor:[CPTColor colorWithCGColor:grayColor]];
	CGColorRelease(grayColor);
    
    // Setup plot space
    [self createPlot:@"x"];
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    return _count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    id identifier = plot.identifier;
    double* data = [self arrayForColumn: identifier];
    
	NSNumber *num;
	
	switch (fieldEnum) {
		case CPTScatterPlotFieldX:
			num = [NSNumber numberWithDouble:_t[index]];
			break;
		case CPTScatterPlotFieldY:
			num = [NSNumber numberWithDouble:data[index]];
			break;
		default:
			num = [NSDecimalNumber zero];
	};
    return num;
}


-(double)doubleForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    id identifier = plot.identifier;
    double* data = [self arrayForColumn: identifier];
    
	double num;
	
	switch (fieldEnum) {
		case CPTScatterPlotFieldX:
			num = _t[index];
			break;
		case CPTScatterPlotFieldY:
			num = data[index];
			break;
		default:
			num = 0.0;
	};
    
    return num;
}

-(CPTPlotSymbol *)symbolForScatterPlot:(CPTScatterPlot *)plot recordIndex:(NSUInteger)index
{
	CPTGradient *gradientFill = [CPTGradient rainbowGradient];
	gradientFill.gradientType = CPTGradientTypeRadial;
	
	CPTMutableShadow *symbolShadow = [CPTMutableShadow shadow];
	symbolShadow.shadowOffset = CGSizeMake(3.0, -3.0);
	symbolShadow.shadowBlurRadius = 3.0;
	symbolShadow.shadowColor = [CPTColor blackColor];
	
	CPTPlotSymbol *symbol = [[[CPTPlotSymbol alloc] init] autorelease];
	symbol.symbolType = [(NSString *)plot.identifier intValue];
	symbol.fill = [CPTFill fillWithGradient:gradientFill];
	symbol.shadow = symbolShadow;
	
	return symbol;
}


#pragma mark - File Handling
-(void)exportToCsvFile:(id)sender
{
    NSString* path = [[[_url path] stringByDeletingPathExtension] stringByAppendingPathExtension:@"csv"];
    FILE* f = fopen([path UTF8String], "w");
    if ( f ) {
        fprintf(f, "timestamp, t, x, y, z, gx, gy, gz, rx, ry, rz, roll, pitch, yaw\n");
        for ( NSUInteger i = 0; i < _count; ++i ) {
            fprintf(f, "%f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f\n", _t[i], _x[i], _y[i], _z[i], _gx[i], _gy[i], _gz[i], _rx[i], _ry[i], _rz[i], _roll[i], _pitch[i], _yaw[i]);
        }
        fclose(f);
    }  
}

- (void)loadAndProcessData:(NSOpenPanel*)panel result:(NSInteger)result
{
    if ( result == NSOKButton ) {
        NSArray *urls = [panel URLs];
        if ( [urls count] > 0 ) {
            self.url = [urls objectAtIndex:0];
            NSArray *data = [[[NSArray alloc] initWithContentsOfURL:_url] autorelease];
            
            _count = [data count];
            _t = malloc(sizeof(double) * _count);
            _x = malloc(sizeof(double) * _count);
            _y = malloc(sizeof(double) * _count);
            _z = malloc(sizeof(double) * _count);
            _gx = malloc(sizeof(double) * _count);
            _gy = malloc(sizeof(double) * _count);
            _gz = malloc(sizeof(double) * _count);
            _rx = malloc(sizeof(double) * _count);
            _ry = malloc(sizeof(double) * _count);
            _rz = malloc(sizeof(double) * _count);
            _roll = malloc(sizeof(double) * _count);
            _pitch = malloc(sizeof(double) * _count);
            _yaw = malloc(sizeof(double) * _count);
            
            NSLog(@"There are %lu elements", _count);
            
            for ( NSUInteger i = 0; i < [data count]; ++i ) {
                double timestamp, timestamp0, t, x, y, z, gx, gy, gz, rx, ry, rz, roll, yaw, pitch;
                
                timestamp = [[[data objectAtIndex:i] valueForKey:@"timestamp"] doubleValue];
                if ( i == 0 ) {
                    timestamp0 = timestamp;
                }
                t = timestamp - timestamp0;
                _t[i] = t;
                
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
                
                _rx[i] = rx;
                _ry[i] = ry;
                _rz[i] = rz;
                
                roll = [[[data objectAtIndex:i] valueForKey:@"roll"] doubleValue];
                pitch = [[[data objectAtIndex:i] valueForKey:@"pitch"] doubleValue];
                yaw = [[[data objectAtIndex:i] valueForKey:@"yaw"] doubleValue];
                
                _roll[i] = roll;
                _pitch[i] = pitch;
                _yaw[i] = yaw;
                
            }
        }
    
//        NSUInteger index = [tableView columnWithIdentifier:@"t"];
//        NSTableColumn* tc = [tableView.tableColumns objectAtIndex:index] ;
        NSArray* columns = [[NSArray alloc] initWithObjects:@"x", @"y", @"z", @"gx", @"gy", @"gz", @"rx", @"ry", @"rz", nil];
        for ( NSString* identifier in columns ) {
            NSTableColumn* nc = [[[NSTableColumn alloc] initWithIdentifier:identifier] autorelease];
            NSTableHeaderCell* hc = [[[NSTableHeaderCell alloc] init] autorelease];
            hc.title = identifier;
            [nc setHeaderCell:hc];
            
            [tableView addTableColumn:nc];
        }
        NSLog(@"table has %ld columns", [tableView numberOfColumns]);
        
        [tableView setTarget:self];
        [tableView setAction:@selector(tableClicked:)];
    }
}

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
                      
                      [self loadAndProcessData:panel result:result];
                      [tableView reloadData];
                      [self createGraph];
                   }
    ];
}

#pragma mark Table Functions

-(NSInteger)numberOfRowsInTableView:(NSTableView*)tv
{
    return _count;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    double value = 0.0;
    
    if ( [tableColumn.identifier isEqualToString:@"t"] ) {
        value = _t[row];
    } else if ( [tableColumn.identifier isEqualToString:@"x"] ) {
        value = _x[row];
    } else if ( [tableColumn.identifier isEqualToString:@"y"] ) {
        value = _y[row];
    } else if ( [tableColumn.identifier isEqualToString:@"z"] ) {
        value = _z[row];
    } else if ( [tableColumn.identifier isEqualToString:@"gx"] ) {
        value = _gx[row];
    } else if ( [tableColumn.identifier isEqualToString:@"gy"] ) {
        value = _gy[row];
    } else if ( [tableColumn.identifier isEqualToString:@"gz"] ) {
        value = _gz[row];
    } else if ( [tableColumn.identifier isEqualToString:@"rx"] ) {
        value = _rx[row];
    } else if ( [tableColumn.identifier isEqualToString:@"ry"] ) {
        value = _ry[row];
    } else if ( [tableColumn.identifier isEqualToString:@"rz"] ) {
        value = _rz[row];
    }
    
    return [NSNumber numberWithDouble:value];
}

- (IBAction)tableClicked:(id)sender
{
    NSInteger col = [tableView clickedColumn];
    if ( col >= 0 && col < [tableView numberOfColumns] ) {
        NSIndexSet* set = [[[NSIndexSet alloc] initWithIndex:col] autorelease];
        [tableView selectColumnIndexes:set byExtendingSelection:NO];
    }    
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger col = [tableView selectedColumn];
    // NSInteger col = [tableView clickedColumn];
    if ( col >= 0 && col < [tableView numberOfColumns] ) {
        NSTableColumn* tc = [tableView.tableColumns objectAtIndex:col];
        [self createPlot:tc.identifier];
        return;
    }
}

@end
