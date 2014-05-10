//
//  PCHView.h
//  ParetoChart
//
//  Created by Arun Balakrishnan on 03/02/14.
//  Copyright (c) 2014 Arun Balakrishnan. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kLineFromOrigin 0
#define kLineFromCenter 1
#define kBarChart 2
#define kParetoChart 3

@protocol PCHDelegates <NSObject>

@required
//- (NSNumber*)yValue;
- (NSNumber*)yInterval;
- (NSInteger)chartMode;

@optional
- (NSArray*)paretoChartValues;
- (NSNumber*)intervalBetweenBars;
- (NSArray *)barLabels;
- (NSInteger)barSize; // Recommeded to start with 20
- (NSInteger)gapBetweenBars;
- (NSString *)plotTitle;
- (NSString *)xTitle;
- (BOOL)showGridLines;
- (int)linePlotType;
- (UIColor*)paretoFillColor; // Implement this to color all the bars with one color
- (UIColor*)paretoStrokeColor;
- (NSArray*)barFillColor;
- (NSArray*)barStrokeColor;
- (UIColor*)lineColor;
- (UIColor*)pointFillColor;
- (UIColor*)pointStrokeColor;
- (UIColor*)textLabelColor;
- (UIColor*)plotTitleColor;
- (UIColor*)xTitleColor;
- (UIColor*)axesColor;
- (float)pointRadius;
- (NSInteger)lineWidth;
- (NSString *)yTitle;
- (NSString *)percentTitle;
- (NSDictionary*)keyValuePairs;
- (NSInteger)xgap;
@end


@interface PCHView : UIView

@property(nonatomic,weak) id<PCHDelegates> delegate;

- (void)reload;
@end
