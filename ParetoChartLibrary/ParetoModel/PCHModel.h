//
//  PCHModel.h
//  ParetoChart
//
//  Created by Arun Balakrishnan on 03/02/14.
//  Copyright (c) 2014 Arun Balakrishnan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCHModel : NSObject

@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *label;
@property (nonatomic,strong)NSNumber *width;
@property (nonatomic,strong)NSNumber *value;

@end
