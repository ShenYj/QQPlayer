//
//  JSMusicModel.m
//  MusicPlayer
//
//  Created by ShenYj on 16/7/19.
//  Copyright © 2016年 ___ShenYJ___. All rights reserved.
//

#import "JSMusicModel.h"

@implementation JSMusicModel

- (instancetype)initWithDict:(NSDictionary *)dict {
    
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+ (instancetype)musicWithDict:(NSDictionary *)dict {
    
    return [[self alloc] initWithDict:dict];
}

+ (NSArray *)loadMusicListWithFileName:(NSString *)fileName {
    
    NSArray *arr = [NSArray arrayWithContentsOfFile: [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"]];
    
    NSMutableArray *mArr = [NSMutableArray array];
    for (NSDictionary *dict in arr) {
        JSMusicModel *model = [JSMusicModel musicWithDict:dict];
        [mArr addObject:model];
    }
    return mArr.copy;
}

@end
