//
//  DemoViewController.m
//  BezierPath
//
//  Created by 苏沫离 on 2020/9/21.
//

#import "DemoViewController.h"
#import "MovePointInBezierView.h"

@interface DemoViewController ()

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    MovePointInBezierView *view = [[MovePointInBezierView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame) * 57 / 75.0 )];
    [self.view addSubview:view];
}

@end
