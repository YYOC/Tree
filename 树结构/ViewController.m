//
//  ViewController.m
//  树结构
//
//  Created by 杨 on 15/4/22.
//  Copyright (c) 2015年 杨元. All rights reserved.
//

#import "ViewController.h"
#import "BDDynamicTree.h"
#import "BDDynamicTreeNode.h"

#define NSLogRect(rect) NSLog(@"%s x:%.4f, y:%.4f, w:%.4f, h:%.4f", #rect, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)
#define NSLogSize(size) NSLog(@"%s w:%.4f, h:%.4f", #size, size.width, size.height)
#define NSLogPoint(point) NSLog(@"%s x:%.4f, y:%.4f", #point, point.x, point.y)

@interface ViewController ()
{
    BDDynamicTree* dynamicTree;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLogRect(self.view.frame);
    
    // Do any additional setup after loading the view, typically from a nib.
    BDDynamicTreeNode *root = [[BDDynamicTreeNode alloc] init];
    root.originX = 10;
    root.isDepartment = YES;
    root.nodeId = @"1";
    root.dataId = @"1";
    root.data = @{@"name":@"总部"};
    root.showName = @"总部";
    
    BDDynamicTreeNode *root1 = [[BDDynamicTreeNode alloc] init];
    root1.isDepartment = YES;
    root1.fatherNodeId = @"1";
    root1.nodeId = @"2";
    root1.dataId = @"2";
    root1.data = @{@"name":@"1分部1"};
    root1.showName = @"1分部1";
    
    BDDynamicTreeNode *root2 = [[BDDynamicTreeNode alloc] init];
    root2.isDepartment = YES;
    root2.fatherNodeId = @"1";
    root2.nodeId = @"3";
    root2.dataId = @"3";
    root2.data = @{@"name":@"2分部"};
    root2.showName = @"2分部";
    
    BDDynamicTreeNode *root3 = [[BDDynamicTreeNode alloc] init];
    root3.isDepartment = NO;
    root3.fatherNodeId = @"2";
    root3.nodeId = @"4";
    root3.dataId = @"4";
    root3.data = @{@"name":@"1分部人-1"};
    root3.showName = @"1分部人-1";
    
    BDDynamicTreeNode *root4 = [[BDDynamicTreeNode alloc] init];
    root4.isDepartment = NO;
    root4.fatherNodeId = @"2";
    root4.nodeId = @"5";
    root4.dataId = @"5";
    root4.data = @{@"name":@"1分部人-2"};
    root4.showName = @"1分部人-2";
    
    BDDynamicTreeNode *root5 = [[BDDynamicTreeNode alloc] init];
    root5.isDepartment = NO;
    root5.fatherNodeId = @"3";
    root5.nodeId = @"6";
    root5.dataId = @"6";
    root5.data = @{@"name":@"2分部人-1"};
    root5.showName = @"2分部人-1";
    
    BDDynamicTreeNode *root6 = [[BDDynamicTreeNode alloc] init];
    root6.isDepartment = NO;
    root6.fatherNodeId = @"3";
    root6.nodeId = @"7";
    root6.dataId = @"7";
    root6.data = @{@"name":@"2分部人-2"};
    root6.showName = @"2分部人-2";
    
    BDDynamicTreeNode *root7 = [[BDDynamicTreeNode alloc] init];
    root7.isDepartment = NO;
    root7.fatherNodeId = @"3";
    root7.nodeId = @"8";
    root7.dataId = @"8";
    root7.data = @{@"name":@"2分部人-3"};
    root7.showName = @"2分部人-3";
    
    BDDynamicTreeNode *root8 = [[BDDynamicTreeNode alloc] init];
    root8.isDepartment = NO;
    root8.fatherNodeId = @"1";
    root8.nodeId = @"9";
    root8.dataId = @"9";
    root8.data = @{@"name":@"总部人-1"};
    root8.showName = @"总部人-1";
    
    dynamicTree = [[BDDynamicTree alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) nodes:nil];
//    dynamicTree.delegate = self;
    dynamicTree.nodesArray = @[root,root1,root2,root3,root4,root5,root6,root7,root8];
    dynamicTree.unoptionals = @[root3,root7];
    dynamicTree.optionals = @[root5,root7];
//    dynamicTree.isMultiSelect = YES;
    [self.view addSubview:dynamicTree];
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor redColor];
    button.titleLabel.text = @"选中的";
    button.frame = CGRectMake(0, 0, self.view.bounds.size.width, 60);
    [self.view addSubview:button];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonClick {
    if ([dynamicTree selectedArray] && [[dynamicTree selectedArray] count]) {
        
    } else {
        NSLog(@"没有选中的");
    }
    for (BDDynamicTreeNode *node in [dynamicTree selectedArray]) {
        NSLog(@"%@",node);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
