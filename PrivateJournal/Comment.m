//
//  Comment.m
//  PrivateJournal
//
//  Created by ALIREZA TABRIZI on 7/3/16.
//  Copyright © 2016 AR-T.com, Inc. All rights reserved.
//

#import "Comment.h"
#import "Hashtag.h"
#import "Picture.h"
#import "User.h"

@implementation Comment

-(NSString *)agoString {
    //    NSLog(@"[%@ %@]", self.class, NSStringFromSelector(_cmd));
    Comment *c = self;
    NSDate *time = c.time;
    NSDate *now = [NSDate date];
    NSTimeInterval n = [now timeIntervalSinceDate:time];
    //    NSLog(@"%.0lf sec ago", n);
    
    // 604,800 sec/wk
    // 86,400 sec/day
    // 3600 sec/hr
    // 60 sec/min
    if (n >= 604800) {
        return [self secsAgoString:n div:604800 unit:@"wk" plural:YES];
    } else if (n >= 86400) {
        return [self secsAgoString:n div:86400 unit:@"day" plural:YES];
    } else if (n >= 3600) {
        return [self secsAgoString:n div:3600 unit:@"hr" plural:YES];
    } else if (n >= 60) {
        return [self secsAgoString:n div:60 unit:@"min" plural:NO];
    }
    return [self secsAgoString:n div:1 unit:@"sec" plural:NO];
}
-(NSString *)secsAgoString:(int)nSecs div:(int)div unit:(NSString *)unit plural:(BOOL)plural {
    int x = (int)(nSecs/div);
    NSString *unitStr = unit;
    if (plural && x != 1) { unitStr = [NSString stringWithFormat:@"%@s", unitStr]; }
    return [NSString stringWithFormat:@"%i %@ ago", x, unitStr];
}
@end
