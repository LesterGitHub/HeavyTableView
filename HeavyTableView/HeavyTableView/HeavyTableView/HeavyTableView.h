//
//  HeavyTableView.h
//  HeavyTableView
//
//  Created by leizi on 15/10/15.
//  Copyright © 2015年 leizi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"
#import "UIViewExt.h"

//  设备bounds
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height


@protocol HeavyTableViewDelegate <NSObject>

@optional
-(void)scrollViewDidScroll:(UIScrollView *)scrollView;

@required

@end

@interface HeavyTableView : UITableView

@property (assign, nonatomic) id<HeavyTableViewDelegate>heavyDelegate;

//  下拉完成,开始重载数据
@property (copy, nonatomic) void(^downStartHeavyDataBlock)(HeavyTableView *tableView);

//  上拉完成,开始重载数据
@property (copy, nonatomic) void(^upStartHeavyDataBlock)(HeavyTableView *tableView);

//  是否存在下拉刷新
@property (assign, nonatomic) BOOL hasMore;

/** 停止刷新 **/
- (void)stopHeavyData;



@end
