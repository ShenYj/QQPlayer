//
//  NSDateFormatter+Shared.m
//  MusicPlayer
//
//  Created by ShenYj on 16/7/20.
//  Copyright © 2016年 ___ShenYJ___. All rights reserved.
//

#import "NSDateFormatter+Shared.h"

static NSDateFormatter *_instanceType = nil;
@implementation NSDateFormatter (Shared)

+ (instancetype)sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instanceType = [[NSDateFormatter alloc]init];
    });
    return _instanceType;
}

@end
