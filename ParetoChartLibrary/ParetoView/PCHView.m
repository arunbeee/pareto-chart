//
//  PCHView.m
//  ParetoChart
//
//  Created by Arun Balakrishnan on 03/02/14.
//  Copyright (c) 2014 Arun Balakrishnan. All rights reserved.



#import "PCHView.h"
#import "PCHModel.h"
#import "NSString+Rotated.h"
#include <QuartzCore/QuartzCore.h>

#define PI 3.14159265359
#define   DEGREES_TO_RADIANS(degrees)  ((PI * degrees)/ 180)

@implementation PCHView

//NSMutableSet *values;
NSMutableArray *percentValues;
NSMutableArray *bars;
NSMutableArray *barPaths;
NSMutableArray *barStartPaths;
NSMutableArray *barLabels;
NSMutableArray *yPoints;
NSMutableArray *y2Points;
NSArray *sortedArray;
NSString *plotTitle;
NSString *xTitle;
UIBezierPath *barTagPath;
NSInteger barIndex;
NSString *percentTitle;
NSString *yTitle;
UIBezierPath *lastTouchedPath;
NSMutableDictionary *barDictionary;
NSMutableArray *circlePath;
UIBezierPath *lastTouchedCirclePath;
UIBezierPath *circleTagPath;
NSInteger circleIndex;
CGPoint linePoint;
float offset;
float yValue;
float yInterval;
int blocks ;
int xgap;
float divider ;
int lineType;
float pointRadius;
NSInteger barsgap;
NSInteger barsize;
NSInteger lineWidth;

BOOL showGridLines;
BOOL areLegendsEnabled;
BOOL chartMode;

//Colors
NSArray *barFillColor;
NSArray *barStrokeColor;
UIColor *lineColor;
UIColor *pointFillColor;
UIColor *xTitleColor;
UIColor *pointStrokeColor;
UIColor *plotTitleColor;
UIColor *textLabelColor;
UIColor *axesColor;
UIColor *paretoFillColor;
UIColor *paretoStrokeColor;

CGPoint x1;

/**@brief This method used to initialize the view with the frame size.
 * @param nil
 * @return nil
 **/
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        offset = 2.0f;
        //[self initialize];
        
        chartMode = kParetoChart;
    }
    return self;
}

/**@brief This method used to customize the UIView.
 * @param nil
 * @return nil
 **/
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    [self initialize];
    
    [self setDelegates];
    [self setProperties];
    
    if ([bars count] > 0) {
        
        
        [self drawAxes];
        [self drawMarkers];
        [self drawPlotLabel];
        NSArray *array ;
        if (chartMode == kParetoChart) {
            array = sortedArray;
        }else{
            array = [bars copy];
        }
        for (int i = 0; i < [array count]; i++) {
            float value = [[array objectAtIndex:i] floatValue];
            
            [self drawBar:value index:i];
        }
        if (chartMode == kParetoChart) {
            [self drawLines];
        }
        
    }
    [self createLegends];
    
    [self drawRotatedText:yTitle point:CGPointMake(self.bounds.size.width * 0.03, self.bounds.size.height / 2) angle:-90];
    if (chartMode == kParetoChart) {
        [self drawRotatedText:percentTitle point:CGPointMake(self.bounds.size.width * 0.95, self.bounds.size.height / 2) angle:90];
    }
    if (barTagPath) {
        [self setTagOnBar:barTagPath index:barIndex];
    }else{
        [self setTagOnBar:lastTouchedPath index:-1];
    }
    if (circleTagPath) {
        [self setTagOnCircle:circleTagPath index:circleIndex];
    }else
    {
        [self setTagOnCircle:lastTouchedCirclePath index:-1];
    }
//    //Animation Block
//
//// Create the shape layer to display and animate the line.
//CAShapeLayer * myLineShapeLayer = [[CAShapeLayer alloc] init];
//for(int i = 0 ; i < [barPaths count]; i++)
//{
//    
//CABasicAnimation * pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
//pathAnimation.fromValue = (__bridge id)[[barStartPaths objectAtIndex:i] CGPath];
//pathAnimation.toValue = (__bridge id)[[barPaths objectAtIndex:i] CGPath];
//pathAnimation.duration = 5.0f;
//[myLineShapeLayer addAnimation:pathAnimation forKey:[NSString stringWithFormat:@"animationKey%d",i]];
//}
}
/**@brief This method used to initialize.
 * @param nil
 * @return nil
 **/
- (void)initialize
{
    //bars = [[NSMutableSet alloc]init];
    yValue = 0;
    yInterval = 0;
    plotTitle = @" ";
    xTitleColor = [UIColor whiteColor];
    xTitle = @" ";
    bars = [[NSMutableArray alloc]init];//WithObjects:@"100",@"200",@"400",@"500",@"300",@"1000", nil];
    barLabels = [[NSMutableArray alloc]init ];//WithObjects:@"100",@"200",@"300 ",@"400",@"500",@"1000", nil];
    barPaths = [[NSMutableArray alloc]init];
    barsgap = 10;
    barsize = 30;
    yPoints = [[NSMutableArray alloc]init];
    y2Points = [[NSMutableArray alloc]init];
    linePoint = CGPointMake(0, 0);
    lineType = kLineFromCenter;
    pointRadius = 4.0f;
    pointStrokeColor = [UIColor orangeColor];
    pointFillColor = [UIColor redColor];
    lineColor = [UIColor magentaColor];
    plotTitleColor = [UIColor brownColor];
    textLabelColor = [UIColor brownColor];
    axesColor = [UIColor yellowColor];
    paretoFillColor = [UIColor cyanColor];
    paretoStrokeColor = [UIColor whiteColor];
    showGridLines = YES;
    lineWidth = 2.0;
    areLegendsEnabled = YES;
    yTitle = @"yTitle";
    percentTitle = @"percentTitle";
    circlePath = [[NSMutableArray alloc]init];
    percentValues = [[NSMutableArray alloc] init];
    barStartPaths = [[NSMutableArray alloc] init];
}

/**@brief This method used to set properties after initialization.
 * @param nil
 * @return nil
 **/
- (void)setProperties
{
    for (NSNumber *num in [bars copy]) {
        yValue += [num floatValue];
    }
    
    if (chartMode == kParetoChart) {
        
        if (lineType == kLineFromOrigin) {
             [percentValues addObject:[NSNumber numberWithFloat:0.0f]];
        }
        sortedArray = [[bars copy]sortedArrayUsingFunction:intSort context:NULL];
        
        if (yValue > 0) {
            
        
        for (int i = 0; i < [sortedArray count]; i++) {
            NSNumber *theNumber = [sortedArray objectAtIndex:i];
            float numerator = [theNumber floatValue];
            float percent = (numerator *100)/ yValue;
            NSNumber *percentNumber = [NSNumber numberWithFloat:percent];
            [percentValues addObject:percentNumber];
        }
    
        }
    }
    
   
    blocks = yValue / yInterval; //Total number of blocks
    divider = (self.bounds.size.height * 0.75 - 100)/ blocks ;//height for each block
    
    
    
}

/**@brief This c-function used to sort the values
 * @param num1 The id type num1
 * @param num2 The id type num2
 * @param context The context object
 * @return nil
 **/
NSInteger intSort(id num1, id num2, void *context)
{
    int v1 = [num1 intValue];
    int v2 = [num2 intValue];
    if (v1 > v2)
        return NSOrderedAscending;
    else if (v1 < v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

/**@brief This method used to draw markers /gridlines
 * @param value The float value for drawing the bars
 * @param index The int index for drawing the bars
 * @return nil
 **/
- (void)drawBar: (float) value index:(int)index
{
    float factor = value / yValue;
    //NSLog(@"%f",factor);
    int size = barsize;
    int gap = barsgap;
    int start = 100 + (index * (size + gap));
    if (start < self.bounds.size.width - 200 || start == self.bounds.size.width -200 ) {
        if (chartMode == kBarChart) {
            if ([barFillColor count] > 0 && [barStrokeColor count] > 0) {
                [[barFillColor objectAtIndex:index] setFill];
                [[barStrokeColor objectAtIndex:index] setStroke];
            }
            
        }
        else
        {
            [paretoFillColor setFill];
            [paretoStrokeColor setStroke];
        }
        UIBezierPath *path = [[UIBezierPath alloc]init];
        
        CGPoint x1 = CGPointMake(100 +xgap+ (index * (size + gap)), self.bounds.size.height * 0.75);
        CGPoint x2 = CGPointMake(x1.x + size,self.bounds.size.height * 0.75 );
        // float height = (self.bounds.size.height * 0.75) - ((self.bounds.size.height * 0.75) * factor) + 5;
        float height = self.bounds.size.height * 0.75 - (divider * factor * blocks);
        CGPoint y1 = CGPointMake(x1.x, height);
        CGPoint y2 = CGPointMake(x2.x, height);
        
        [path moveToPoint:x1];
        [path addLineToPoint:x2];
        //[path moveToPoint:x2];
        [path addLineToPoint:y2];
        // [path moveToPoint:y2];
        [path addLineToPoint:y1];
        //  [path moveToPoint:y1];
        [path addLineToPoint:x1];
        
        
        UIBezierPath *startPath = [[UIBezierPath alloc]init];
        [startPath moveToPoint:x1];
        [startPath addLineToPoint:x2];
        [startPath closePath];
        [barStartPaths addObject:startPath];
        [path closePath];
        [path fill];
        [path stroke];
        if ([barLabels count] > 0) {
            if (chartMode == kParetoChart) {
                
                
                if ([barDictionary count] > 0) {
                    for (int i = 0; i < [barLabels count]; i++) {
                        NSString *text = [[barLabels copy] objectAtIndex:i];
                        if ([[barDictionary valueForKey:text] floatValue] == value) {
                            [self drawText:text point:x1];
                        }
                    }
                }
            }else{
                NSString *text = [[barLabels copy] objectAtIndex:index];
                [self drawText:text point:x1];
            }
            
            
            
        }
        [barPaths addObject:path];
        [yPoints addObject:[NSValue valueWithCGPoint:y2]];
        [y2Points addObject:[NSValue valueWithCGPoint:y1]];
    }
    
}


/**@brief This method used to draw X and Y Axes.
 * @param nil
 * @return nil
 **/
- (void)drawAxes
{
    // values = [[NSMutableSet alloc]initWithObjects:@"0",@"1",@"6",@"2",@"4", nil];
    
    //X- Axes
    x1 = CGPointMake(0 + 100, self.bounds.size.height * 0.75);
    
    //[axesColor setFill];
    [axesColor setStroke];
    UIBezierPath *pathX = [[UIBezierPath alloc]init];
    [pathX moveToPoint:x1];
    [pathX addLineToPoint:CGPointMake(self.bounds.size.width - 100,self.bounds.size.height * 0.75 )];
    //    [pathX addLineToPoint:CGPointMake(self.bounds.size.width - 100,0 + 100 )];
    //    [pathX addLineToPoint:CGPointMake(0 + 100 ,0 + 100)];
    //    [pathX addLineToPoint:CGPointMake(self.bounds.size.width - 100 ,0 + 100)];
    [pathX addLineToPoint:x1];
    [pathX closePath];
    [pathX stroke];
    // [pathX fill];
    if (lineType == kLineFromOrigin) {
        [self drawCircle:x1];
    }
    
    
    
    
    // [[UIColor orangeColor] setFill];
    //  [[UIColor orangeColor] setStroke];
    UIBezierPath *pathX2 = [[UIBezierPath alloc]init];
    [pathX2 moveToPoint:CGPointMake(0 + 100, 0 + 100)];
    [pathX2 addLineToPoint:CGPointMake(self.bounds.size.width - 100,0 + 100 )];
    [pathX2 closePath];
    [pathX2 stroke];
    [pathX2 fill];
    
    
    //Y-Axes
    
    // [[UIColor brownColor] setFill];
    // [[UIColor brownColor] setStroke];
    UIBezierPath *pathY = [[UIBezierPath alloc]init];
    [pathY moveToPoint:CGPointMake(0 + 100, self.bounds.size.height * 0.75)];
    [pathY addLineToPoint:CGPointMake(0 + 100 ,0 + 100)];
    [pathY closePath];
    [pathY stroke];
    [pathY fill];
    
    
    // [[UIColor blueColor] setFill];
    // [[UIColor blueColor] setStroke];
    UIBezierPath *pathY2 = [[UIBezierPath alloc]init];
    [pathY2 moveToPoint:CGPointMake(self.bounds.size.width - 100, self.bounds.size.height * 0.75)];
    [pathY2 addLineToPoint:CGPointMake(self.bounds.size.width - 100 ,0 + 100)];
    [pathY2 closePath];
    [pathY2 stroke];
    [pathY2 fill];
    
    
}

/**@brief This method used to draw markers /gridlines
 * @param nil
 * @return nil
 **/
- (void)drawMarkers
{
    if (showGridLines) {
        
        
        
        
        float percentOffset = 100.0f / blocks;
        
        for (int i = 0 ; i < blocks || i ==blocks; i++) {
            [[UIColor greenColor] setFill];
            [[UIColor greenColor] setStroke];
            CGPoint movePoint = CGPointMake(100 , self.bounds.size.height * 0.75 - (i * divider));
            CGPoint y1Point = CGPointMake(40 , self.bounds.size.height * 0.75 - (i * divider) - 10);
            CGPoint y2Point = CGPointMake(self.bounds.size.width - 90,self.bounds.size.height * 0.75 - (i * divider) - 10 );
            CGPoint linePoint = CGPointMake(self.bounds.size.width - 100,self.bounds.size.height * 0.75 - (i * divider) );
            
            
            
            UIBezierPath *pathX = [[UIBezierPath alloc]init];
            
            
            [pathX moveToPoint:movePoint];
            [pathX addLineToPoint:linePoint];
            [pathX closePath];
            [pathX stroke];
            [pathX fill];
            if (chartMode == kParetoChart) {
                [self drawText:[NSString stringWithFormat:@"%0.1f%%",(percentOffset * i)] point:y2Point];
            }
            
            [self drawText:[NSString stringWithFormat:@"%0.2f",(yInterval * i)] point:y1Point];
        }
        
    }
    
}

/**@brief This method used to draw text at a particular point.
 * @param text The NSString object to be drawn.
 * @param point The CGPoint point where the text is to be drawn.
 * @return nil
 **/
- (void)drawText: (NSString *)text point:(CGPoint)point
{
    if (text) {
        
        
        UIFont* font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:14];
        
        UIColor* textColor = textLabelColor;
        NSDictionary* stringAttrs = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : textColor };
        
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:text attributes:stringAttrs];
        
        [attrStr drawAtPoint:point];
    }
}

/**@brief This method used to draw text at a particular angle.
 * @param text The NSString object to be drawn.
 * @param point The CGPoint point where the text is to be drawn.
 * @param angle The NSInteger angle at which the text is to be rotated.
 * @return nil
 **/
- (void)drawRotatedText: (NSString*)text point:(CGPoint)point angle:(NSInteger)angle
{
    UIFont* font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:14];
    [text drawWithBasePoint:point andAngle:DEGREES_TO_RADIANS(angle) andFont:font];
}

/**@brief This method draws the label at the Top/Title.
 * @param nil
 * @return nil
 **/

- (void)drawPlotLabel
{
    CGPoint center = CGPointMake(self.bounds.size.width / 2.5, self.bounds.size.height * 0.05);
    UIFont* font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:17];
    
    UIColor* textColor = plotTitleColor;
    NSDictionary* stringAttrs = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : textColor };
    
    NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:plotTitle attributes:stringAttrs];
    
    [attrStr drawAtPoint:center];
}
/**@brief This method draws the Label at the Bottom
 * @param nil
 * @return nil
 **/
- (void)drawXLabel
{
    CGPoint center = CGPointMake(self.bounds.size.width / 2.5, self.bounds.size.height * 0.78);
    UIFont* font = [UIFont fontWithName:@"AppleSDGothicNeo-Bold" size:17];
    
    UIColor* textColor = xTitleColor;
    NSDictionary* stringAttrs = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : textColor };
    
    NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:xTitle attributes:stringAttrs];
    
    [attrStr drawAtPoint:center];
}

/**@brief This method draws lines for the cummulative line chart.
 * @param nil
 * @return nil
 **/
- (void)drawLines
{
    
    
    if (lineType == kLineFromOrigin) {
        
        NSValue *theval = [yPoints objectAtIndex:0];
        CGPoint thepoint = [theval CGPointValue];
        [self drawCircle:thepoint];
        [[UIColor whiteColor] setStroke];
        
        UIBezierPath *thePath = [UIBezierPath bezierPath];
        thePath.lineWidth = lineWidth;
        [thePath moveToPoint:x1];
        [thePath addLineToPoint:thepoint];
        
        for (int i = 1; i < [yPoints count]; i++)
        {
            NSValue *val = [yPoints objectAtIndex:i];
            CGPoint point = [val CGPointValue];
            
            thepoint.x  = point.x;
            thepoint.y -= self.bounds.size.height * 0.75 - point.y;
            // UIBezierPath *thePath = [barPaths objectAtIndex:i];
            [thePath addLineToPoint:thepoint];
            [self drawCircle:thepoint];
        }
        [lineColor setStroke];
        [thePath stroke];
    }else
    {
        /*
         NSValue *theVal = [yPoints objectAtIndex:0];
         NSValue *theVal2 =[y2Points objectAtIndex:0];
         
         CGPoint thePoint = [theVal CGPointValue];
         CGPoint thePoint2 = [theVal2 CGPointValue];
         
         thePoint.x = (thePoint.x + thePoint2.x) / 2;
         thePoint.y = (thePoint.y + thePoint2.y) / 2;
         
         [self drawCircle:thePoint];
         */
        NSValue *theVal = [yPoints objectAtIndex:0];
        NSValue *theVal2 =[y2Points objectAtIndex:0];
        
        CGPoint thePoint = [theVal CGPointValue];
        CGPoint thePoint2 = [theVal2 CGPointValue];
        
        thePoint.x = (thePoint.x + thePoint2.x) / 2;
        thePoint.y = (thePoint.y + thePoint2.y) / 2;
        [self drawCircle:thePoint];
        
        [lineColor setStroke];
        
        UIBezierPath *thePath = [UIBezierPath bezierPath];
        thePath.lineWidth = lineWidth;
        [thePath moveToPoint:thePoint];
        // [thePath addLineToPoint:thePoint];
        
        for (int i = 1; i < [yPoints count]; i++)
        {
            NSValue *val = [yPoints objectAtIndex:i];
            NSValue *val2 = [y2Points objectAtIndex:i];
            CGPoint point = [val CGPointValue];
            CGPoint point2 = [val2 CGPointValue];
            
            point.x = (point.x + point2.x) / 2;
            point.y = (point.y + point2.y) / 2;
            
            thePoint.x  = point.x;
            thePoint.y -= self.bounds.size.height * 0.75 - point.y;
            // UIBezierPath *thePath = [barPaths objectAtIndex:i];
            [thePath addLineToPoint:thePoint];
            [self drawCircle:thePoint];
        }
        [lineColor setStroke];
        [thePath stroke];
    }
}

/**@brief This method sets the delegates
 * @param thePoint A CGPoint literal for drawing circle at the given point.
 * @return nil
 **/
- (void)drawCircle:(CGPoint)thePoint
{
    [pointStrokeColor setStroke];
    [pointFillColor setFill];
    UIBezierPath *circle = [UIBezierPath bezierPathWithArcCenter:thePoint radius:pointRadius startAngle:0 endAngle:360 clockwise:YES];
    [circle fill];
    [circle stroke];
    [circle closePath];
    [circlePath addObject:circle];
}

/**@brief This method reloads the View
 * @param nil
 * @return nil
 **/
- (void)reload
{
    [self setNeedsDisplay];
}


/**@brief This method creates the legends for the chart
 * @param nil
 * @return nil
 **/
- (void)createLegends
{
    if (areLegendsEnabled) {
        
        
        
        int total = [barFillColor count];
        if (total < 1) {
            total = 3;
        }
        UIBezierPath *path ;
        UIColor *theColor = [UIColor colorWithRed:123.0f/250.0f green:110.0f/250.0f blue:170.0f/250.0f alpha:0.5];
        if (chartMode == kParetoChart) {
            path= [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.bounds.size.width / 3, self.bounds.size.height * 0.85 ,300 , (20 * 3) + 20) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(2.0, 2.0)];
            
        }else
        {
            path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.bounds.size.width - 180, self.bounds.size.height *0.80 ,150 , (20 * total) + 20) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(2.0, 2.0)];
        }
        [theColor setFill];
        [theColor setStroke];
        [path fill];
        [path stroke];
        
        
        int y = 0;
        if (chartMode == kParetoChart) {
            
            
            NSArray *arrayText = [NSArray arrayWithObjects:yTitle,percentTitle, nil];
            BOOL bar = YES;
            for ( int i = 0 ; i < 2 ; i++) {
                UIColor *color;
                NSString *text = [arrayText objectAtIndex:i];
                
                int x = self.bounds.size.width / 2.7;
                CGRect rect;
                if (bar) {
                    color = paretoFillColor ;
                    rect = CGRectMake(x, self.bounds.size.height * 0.86 + y , 40, 20);
                    bar = NO;
                }else
                {
                    color = lineColor;
                    rect = CGRectMake(x, self.bounds.size.height * 0.87 + y , 40, lineWidth);
                }
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(2.0, 2.0)];
                [color setFill];
                [color setStroke];
                [path fill];
                [path stroke];
                [path closePath];
                
                
                [self drawText:text point:CGPointMake(x + 50, self.bounds.size.height * 0.86 + y)];
                y +=40;
                
                
            }
        }else{
            for ( int i = 0 ; i < total ; i++) {
                UIColor *color = [barFillColor objectAtIndex:i];
                NSString *text = [barLabels objectAtIndex:i];
                [color setFill];
                [color setStroke];
                int x = self.bounds.size.width - 176;
                CGRect rect = CGRectMake(x, (self.bounds.size.height * 0.81)+y , 40, 20);
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(2.0, 2.0)];
                [path fill];
                [self drawText:text point:CGPointMake(x + 50, (self.bounds.size.height * 0.81)+y)];
                y +=20;
            }
        }
    }
}

#pragma mark - Set Delegates

/**@brief This method sets the delegates 
 * @param nil
 * @return nil
 **/
- (void)setDelegates
{
    if (self.delegate) {
        if ([self.delegate chartMode]) {
            chartMode = [self.delegate chartMode];
        }
        if (chartMode == kBarChart) {
            if ([self.delegate respondsToSelector:@selector( paretoChartValues)]) {
                bars = [[self.delegate paretoChartValues] mutableCopy];
                // sortedArray = [[bars copy]sortedArrayUsingFunction:intSort context:NULL];
            }
        }
        
        //        if ([self.delegate yValue]) {
        //            yValue = [[self.delegate yValue] floatValue];
        //        }
        if ([self.delegate respondsToSelector:@selector(intervalBetweenBars)]) {
            barsgap = [[self.delegate intervalBetweenBars] floatValue];
        }
        if ([self.delegate respondsToSelector:@selector(barLabels)]) {
            barLabels = [[self.delegate barLabels] mutableCopy];
        }
        if ([self.delegate respondsToSelector:@selector(plotTitle)]) {
            plotTitle = [self.delegate plotTitle];
        }
        if ([self.delegate respondsToSelector:@selector(showGridLines)]) {
            showGridLines = [self.delegate showGridLines];
        }
        if ([self.delegate respondsToSelector:@selector(linePlotType)]) {
            lineType = [self.delegate linePlotType];
        }
        if ([self.delegate respondsToSelector:@selector(barFillColor)]) {
            barFillColor = [self.delegate barFillColor];
        }
        if ([self.delegate respondsToSelector:@selector(barStrokeColor)]) {
            barStrokeColor = [self.delegate barStrokeColor];
        }
        if ([self.delegate respondsToSelector:@selector(lineColor)]) {
            lineColor = [self.delegate lineColor];
        }
        if ([self.delegate respondsToSelector:@selector(pointFillColor)]) {
            pointFillColor = [self.delegate pointFillColor];
        }
        if ([self.delegate respondsToSelector:@selector(pointStrokeColor)]) {
            pointStrokeColor = [self.delegate pointStrokeColor];
        }
        if ([self.delegate respondsToSelector:@selector(pointRadius)]) {
            pointRadius = [self.delegate pointRadius];
        }
        if ([self.delegate respondsToSelector:@selector(plotTitleColor)]) {
            plotTitleColor = [self.delegate plotTitleColor];
        }
        if ([self.delegate respondsToSelector:@selector(gapBetweenBars)]) {
            barsgap = [self.delegate gapBetweenBars];
        }
        if ([self.delegate respondsToSelector:@selector(barSize)]) {
            barsize = [self.delegate barSize];
        }
        if ([self.delegate respondsToSelector:@selector(textLabelColor)]) {
            textLabelColor = [self.delegate textLabelColor];
        }
        if ([self.delegate respondsToSelector:@selector(plotTitleColor)]) {
            plotTitleColor = [self.delegate plotTitleColor];
        }
        if ([self.delegate respondsToSelector:@selector(axesColor)]) {
            axesColor = [self.delegate axesColor];
        }
        if ([self.delegate respondsToSelector:@selector(lineWidth)]) {
            lineWidth = [self.delegate lineWidth];
        }
        if ([self.delegate respondsToSelector:@selector(yTitle)]) {
            yTitle = [self.delegate yTitle];
        }
        if ([self.delegate respondsToSelector:@selector(percentTitle)]) {
            percentTitle = [self.delegate percentTitle];
        }
        if (chartMode == kParetoChart) {
            if ([self.delegate respondsToSelector:@selector(paretoFillColor)]) {
                paretoFillColor = [self.delegate paretoFillColor];
            }
            
            
            if ([self.delegate respondsToSelector:@selector(paretoStrokeColor)]) {
                paretoStrokeColor = [self.delegate paretoStrokeColor];
            }
            
            if ([self.delegate respondsToSelector:@selector(keyValuePairs)]) {
                bars = [[[self.delegate keyValuePairs] allValues] mutableCopy];
                sortedArray = [[bars copy]sortedArrayUsingFunction:intSort context:NULL];
                
                barLabels = [[[self.delegate keyValuePairs]allKeys]mutableCopy];
                barDictionary = [[self.delegate keyValuePairs] mutableCopy];
                
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(xTitle)]) {
            xTitle = [self.delegate xTitle];
            [self drawXLabel];
        }
        if ([self.delegate respondsToSelector:@selector(xTitleColor)]) {
            xTitleColor = [self.delegate xTitleColor];
        }
        if ([self.delegate respondsToSelector:@selector(xgap)]) {
            xgap = [self.delegate xgap];
        }
        if ([self.delegate yInterval]) {
            yInterval = [[self.delegate yInterval] floatValue];
        }
    }
}


#pragma mark - Handle Touch and Tap Events

/**@brief This method handles touch events.
 * @param event - The touch event.
 * @param touches - Set of touches.
 * @return nil
 **/
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // NSLog(@"Circles:%@",circlePath);
    
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:self];
    // CGContextRef ctx = UIGraphicsGetCurrentContext();
    for ( int i = 0 ; i < [barPaths count] ; i++) {
        UIBezierPath *path = [barPaths objectAtIndex:i];
        if ([path containsPoint:location]) {
            //NSLog(@"Found!");
            barTagPath = path;
            barIndex = i;
            [self reload];
        }else
        {
            [self reload];
        }
    }
    
    for ( int i = 0 ; i < [circlePath count] ; i++) {
        UIBezierPath *path = [circlePath objectAtIndex:i];
        
        if ([path containsPoint:location]) {
            NSLog(@"Found Circle!");
            circleTagPath = path;
            // barIndex = i;
            circleIndex = i;
            [self reload];
            break;
        }else
        {
            
            [self reload];
        }
    }
    
    
}

- (void)setTagOnBar: (UIBezierPath *)path index:(NSInteger)index
{
    if (path) {
        int x = path.bounds.origin.x + 2.5;
        int y = path.bounds.origin.y *0.97;//- path.bounds.size.height ;
        //        if (index == -2) {
        //            x += 20;
        //            float percent =(100 - (path.bounds.origin.y * 100) / x1.y);
        //            [self drawText:[NSString stringWithFormat:@"%0.1f",percent] point:CGPointMake(x, y)];
        //            [self setTagOnBar:lastTouchedPath index:-1];
        //            circleTagPath = path;
        //        }
        if (index == -1) {
            [self drawText:@" " point:CGPointMake(x, y)];
            // [self setTagOnCircle:circleTagPath index:-1];
            
        }else if (index < [bars count]){
            lastTouchedPath = path;
            if (chartMode == kParetoChart) {
                [self drawText:[NSString stringWithFormat:@"%0.1f",[[sortedArray objectAtIndex:index]floatValue]] point:CGPointMake(x, y)];
            }else{
                [self drawText:[NSString stringWithFormat:@"%d",[[bars objectAtIndex:index]intValue]] point:CGPointMake(x, y)];
            }
            
        }
    }
    barTagPath = nil;
    barIndex = 0;
}

- (void)setTagOnCircle: (UIBezierPath *)path index:(int)index
{
    if (path) {
        lastTouchedCirclePath = path;
        int x = path.bounds.origin.x + 2.5;
        int y = path.bounds.origin.y *0.97;//- path.bounds.size.height ;
        
        x += 20;
        if (index == -1) {
            [self drawText:@" " point:CGPointMake(x, y)];
            //
        }else if(index < [percentValues count])
        {
            float percent = 0;
            for (int j = 0; j < index + 1; j++) {
                percent += [[percentValues objectAtIndex:j] floatValue];
            }
            [self drawText:[NSString stringWithFormat:@"%0.1f%%",percent] point:CGPointMake(x, y)];
            [self setTagOnBar:lastTouchedPath index:-1];
            circleTagPath = path;
            circleIndex = index;
        }
    }
    circleTagPath = nil;
    circleIndex = 0;
    
}
@end



