//
//  ViewController.m
//  HeavyTableView
//
//  Created by leizi on 15/10/15.
//  Copyright © 2015年 leizi. All rights reserved.
//

#import "ViewController.h"
#import "HeavyTableView.h"

@interface ViewController ()<UITableViewDataSource,HeavyTableViewDelegate>

//  tableView
@property (strong, nonatomic)HeavyTableView *heavyTableView;

//  测试数据
@property (strong, nonatomic) NSMutableArray *testData;

//  是否删除全部
@property (assign, nonatomic) BOOL removeAll;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
    }
    
    _heavyTableView = [[HeavyTableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    _heavyTableView.dataSource = self;
    _heavyTableView.heavyDelegate = self;
    [self.view addSubview:_heavyTableView];
    
    __weak ViewController *my = self;
    
    [_heavyTableView setDownStartHeavyDataBlock:^(HeavyTableView *tableView) {
        _removeAll = YES;
        [my heavyData];
        
    }];
    
    [_heavyTableView setUpStartHeavyDataBlock:^(HeavyTableView *tableView) {
         _removeAll = NO;
        [my heavyData];
    }];
    
}
- (IBAction)cleanAction:(id)sender {
    [_testData removeAllObjects];
     _heavyTableView.hasMore = NO;
    [_heavyTableView reloadData];
}

int count;
- (void)heavyData{
   
    if(!_testData){
        _testData = [[NSMutableArray alloc]initWithCapacity:0];
    }
    
    if(_removeAll){
        [_testData removeAllObjects];
        for(int i = 0; i < 20; i ++){
            [_testData addObject:@""];
        }
        count = 0;
    }
    else{
        for(int i = 0; i < 20; i ++){
            [_testData addObject:@""];
        }
        count++;
    }
    
    [self performSelector:@selector(stopHeavy) withObject:nil afterDelay:1.0f];
}


-(void)stopHeavy{
    [_heavyTableView reloadData];
    [_heavyTableView stopHeavyData];
    if(count<3){
        _heavyTableView.hasMore = YES;
    }
    else{
        
        _heavyTableView.hasMore = NO;
    }
}

#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _testData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"identifier"];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"identifier"];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"刷新数据:%li",indexPath.row];
    
    return cell;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
