//
//  HeavyTableView.m
//  HeavyTableView
//
//  Created by leizi on 15/10/15.
//  Copyright © 2015年 leizi. All rights reserved.
//

#import "HeavyTableView.h"

//  下拉距离
CGFloat const TableViewRefreshHeaderViewH=50.0f;
CGFloat const deltaValue=40.0f;


@interface HeavyTableView()<UITableViewDelegate>

//  加载视图
@property (strong, nonatomic) LoadingView *loadView;

//  加载提示
@property (strong, nonatomic) UILabel *downLoadLable;

//  上拉刷新提示
@property (strong, nonatomic) UILabel *upLoadLable;

//  上拉加载视图
@property (strong, nonatomic) UIActivityIndicatorView *upIndicatorView;

//  是否正在刷新
@property (assign, nonatomic) BOOL isLoading;

@end

@implementation HeavyTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if(self){
        
        UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, -TableViewRefreshHeaderViewH, SCREEN_WIDTH, TableViewRefreshHeaderViewH)];
        headView.backgroundColor = [UIColor clearColor];
        [self addSubview:headView];
        
        _downLoadLable = [[UILabel alloc]initWithFrame:CGRectMake((headView.width - 120)/2 + 35, (headView.height-20)/2, 120, 20)];
        _downLoadLable.text = @"下拉刷新";
        _downLoadLable.textAlignment = NSTextAlignmentLeft;
        _downLoadLable.textColor = [UIColor grayColor];
        _downLoadLable.font = [UIFont boldSystemFontOfSize:14.0f];
        [headView addSubview:_downLoadLable];
        
        _loadView = [[LoadingView alloc]initWithFrame:CGRectMake(_downLoadLable.left - 35, (headView.height - 25)/2, 25, 25)];
        _loadView.layer.cornerRadius = _loadView.width/2;
        _loadView.layer.masksToBounds = YES;
        _loadView.backgroundColor = [UIColor clearColor];
        [headView addSubview:_loadView];
        
        self.delegate = self;
        
    }
    return self;
}

#pragma mark - 实现self 代理
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if([self.heavyDelegate respondsToSelector:@selector(scrollViewDidScroll:)]){
        [self.heavyDelegate scrollViewDidScroll:scrollView];
    }
    
    if(_isLoading){
        return;
    }
    
    CGFloat offsetY = scrollView.contentOffset.y+scrollView.contentInset.top;
    CGFloat currentOffsetY = ABS(offsetY);
    
    // 头部控件刚好出现的offsetY
    CGFloat happenOffsetY = TableViewRefreshHeaderViewH;
    [self progressSetWithCurrentOffsetY:currentOffsetY happenOffsetY:happenOffsetY];
    
    
    //  如果上拉加载刷新
    CGFloat scrollViewOffsetY = 0;
    if(scrollView.contentSize.height < scrollView.height){
        scrollViewOffsetY = scrollView.contentOffset.y;
    }
    else{
        scrollViewOffsetY = scrollView.contentOffset.y + self.height - scrollView.contentSize.height;
    }
    
    if(scrollViewOffsetY>10){
        _upLoadLable.text = @"松开即可加载更多";
    }
    else{
        _upLoadLable.text = @"上拉加载更多";
    }
    
}

-(void)progressSetWithCurrentOffsetY:(CGFloat)currentOffsetY happenOffsetY:(CGFloat)happenOffsetY{
    
    if(currentOffsetY<=happenOffsetY){
        _downLoadLable.text = @"下拉刷新";
        CGFloat deltaY=deltaValue;
        CGFloat nowY=currentOffsetY-deltaY;
        _loadView.progress=.00001f;
        if(nowY<=0) return;
        
        //计算进度
        CGFloat progress=nowY/(happenOffsetY-deltaY);
        
        //异常处理
        if(progress<=0) progress=0.f;
        if(progress>=1) progress=1.f;
        
        _loadView.progress=progress;
        
    }else{
        _loadView.progress=1.0f;
        _downLoadLable.text = @"松开刷新";
    }
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    if(_isLoading){
        return;
    }
    
    CGFloat offsetY = scrollView.contentOffset.y+scrollView.contentInset.top;
    CGFloat currentOffsetY = ABS(offsetY);
    
    if(scrollView.contentOffset.y<-50){
        
        if(currentOffsetY>TableViewRefreshHeaderViewH){
            _isLoading = YES;
            _downLoadLable.text = @"正在刷新...";
            _loadView.refreshing = YES;
            [UIView animateWithDuration:0.3 animations:^{
                scrollView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
            }];
            
            if(_downStartHeavyDataBlock){
                _downStartHeavyDataBlock(self);
            }
            
        }
    }
    
    //  如果存在加载更多
    if(_hasMore){
        CGFloat scrollViewOffSetY = 0;
        if(scrollView.contentSize.height < scrollView.height){
            scrollViewOffSetY = scrollView.contentOffset.y;
        }
        else{
            scrollViewOffSetY = scrollView.contentOffset.y + self.height - scrollView.contentSize.height;
        }
        
//        NSLog(@"scrollViewOffSetY si %F",scrollViewOffSetY);
        
        if(scrollViewOffSetY > 10){
            _isLoading = YES;
            
            _upLoadLable.text = @"正在加载...";
            _upIndicatorView.hidden = NO;
            [_upIndicatorView startAnimating];
            
            [UIView animateWithDuration:0.3 animations:^{
                scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
            }];
            
            //  回调上拉完成  开始加载数据
            if(_upStartHeavyDataBlock){
                _upStartHeavyDataBlock(self);
            }
            
        }
    }
}

//  停止刷新
-(void)stopHeavyData{
    
    [UIView animateWithDuration:0.3 animations:^{
        self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }];
    _isLoading = NO;
    _loadView.refreshing = NO;
    
}

//  上拉刷新存在
- (void)setHasMore:(BOOL)hasMore{
    
    _hasMore = hasMore;
    
    if(_hasMore){
        
        UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44.0f)];
        footerView.backgroundColor = [UIColor clearColor];
        self.tableFooterView = footerView;
        
        _upLoadLable = [[UILabel alloc]initWithFrame:CGRectMake((footerView.width - 120)/2 + 25, (footerView.height-20)/2, 120, 20)];
        _upLoadLable.text = @"上拉加载更多";
        _upLoadLable.textAlignment = NSTextAlignmentLeft;
        _upLoadLable.textColor = [UIColor grayColor];
        _upLoadLable.font = [UIFont boldSystemFontOfSize:14.0f];
        [footerView addSubview:_upLoadLable];
        
        _upIndicatorView = [ [ UIActivityIndicatorView alloc ]initWithFrame:CGRectMake(_upLoadLable.left - 25, (footerView.height - 25)/2, 25, 25)];
        _upIndicatorView.color = [UIColor grayColor];
        _upIndicatorView.hidesWhenStopped = NO;
        _upIndicatorView.hidden = YES;
        [footerView addSubview:_upIndicatorView];
        
    }
    else{
        self.tableFooterView = nil;
    }
}



@end
