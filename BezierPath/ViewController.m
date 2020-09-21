//
//  ViewController.m
//  BezierPath
//
//  Created by 苏沫离 on 2020/9/21.
//

#import "ViewController.h"
#import "AudioViewController.h"
#import "DemoViewController.h"

@interface ViewController ()
<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong) NSMutableArray<NSString *> *dataArray;
@property (nonatomic ,strong) UITableView *tableView;
@end

@implementation ViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *item = self.dataArray[indexPath.row];
    if ([item isEqualToString:@"音谱"]) {
        AudioViewController *audioVC = [[AudioViewController alloc] init];
        audioVC.navigationItem.title = item;
        [self.navigationController pushViewController:audioVC animated:YES];
    }else if ([item isEqualToString:@"贝塞尔曲线上的点移动"]) {
        DemoViewController *audioVC = [[DemoViewController alloc] init];
        audioVC.navigationItem.title = item;
        [self.navigationController pushViewController:audioVC animated:YES];
    }
}

#pragma mark - setter and getters

- (NSMutableArray<NSString *> *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [NSMutableArray array];
        [_dataArray addObject:@"音谱"];
        [_dataArray addObject:@"贝塞尔曲线上的点移动"];

    }
    return _dataArray;
}

- (UITableView *)tableView{
    if (_tableView == nil){
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(UIScreen.mainScreen.bounds),CGRectGetHeight(UIScreen.mainScreen.bounds)) style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.tableFooterView = UIView.new;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.separatorColor = [UIColor colorWithRed:232/255.0 green:232/255.0 blue:232/255.0 alpha:1.0];
        tableView.rowHeight = 45;
        tableView.sectionFooterHeight = 0.1f;
        [tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"UITableViewCell"];
        _tableView = tableView;
    }
    return _tableView;
}
@end
