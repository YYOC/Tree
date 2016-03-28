//
//  BDDynamicTree.m
//
//  Created by Scott Ban (https://github.com/reference) on 14/07/30.
//  Copyright (C) 2011-2020 by Scott Ban

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "BDDynamicTree.h"
#import "BDDynamicTreeNode.h"
#import "BDDynamicTreeCell.h"

@interface BDDynamicTree () <UITableViewDataSource, UITableViewDelegate, BDDynamicTreeCellDelegate>
{
    UITableView *_tableView;
    NSMutableArray *_dataSource;
    NSMutableArray *_selectedArray;
}
@end

@implementation BDDynamicTree

- (instancetype)initWithFrame:(CGRect)frame nodes:(NSArray *)nodes
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _dataSource = [[NSMutableArray alloc] init];
        _nodesArray = [[NSMutableArray alloc] initWithArray:nodes];
        _selectedArray = [[NSMutableArray alloc] init];
        
        _isMultiSelect = NO;
        
        //tableview
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_tableView];
        
        if (nodes && nodes.count) {
            __weak typeof(self) weakSelf = self;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [weakSelf addRootNode];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                });
            });
        }
       
    }
    return self;
}

#pragma mark - private methods
- (BDDynamicTreeNode *)rootNode
{
    for (BDDynamicTreeNode *node in _nodesArray) {
        if ([node isRoot]) {
            return node;
        }
    }
    return nil;
}

-(void)addRootNode{
    for (int i=0;i<_nodesArray.count;i++){
        BDDynamicTreeNode *node=[_nodesArray objectAtIndex:i];
        if ([node isRoot]) {
            [_dataSource addObject:node];
        }
    }
}

//添加子节点
- (void)addSubNodesByFatherNode:(BDDynamicTreeNode *)fatherNode atIndex:(NSInteger )index
{
    if (fatherNode)
    {
        NSMutableArray *array = [NSMutableArray array];
        NSMutableArray *cellIndexPaths = [NSMutableArray array];
        
        NSUInteger count = index;
        for(BDDynamicTreeNode *node in _nodesArray) {
            if ([node.fatherNodeId isEqualToString:fatherNode.nodeId]) {
                if (!node.isDepartment) {
                    node.originX = fatherNode.originX + 15/*space*/;//成员累加空隙
                } else {
                    node.originX = fatherNode.originX + 15/*space*/;//部门累加空隙
                }
                [array addObject:node];
                [cellIndexPaths addObject:[NSIndexPath indexPathForRow:count inSection:0]];
                count++;
            }
        }
        
        if (array.count) {
            fatherNode.isOpen = YES;
            
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index,[array count])];
            [_dataSource insertObjects:array atIndexes:indexes];
            [_tableView insertRowsAtIndexPaths:cellIndexPaths withRowAnimation:UITableViewRowAnimationFade];
//            [_tableView reloadData];
        }
    }
}

//根据节点减去子节点
- (void)minusNodesByNode:(BDDynamicTreeNode *)node
{
    if (node) {
        
        NSMutableArray *cellIndexPaths = [NSMutableArray array];
        
        NSArray *array = [self fanhuizi:node data:_dataSource];
        
        for (BDDynamicTreeNode *nd in array) {
            NSUInteger index = [_dataSource indexOfObject:nd];
            [cellIndexPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
        }
        
        for (BDDynamicTreeNode *nd in array) {
            if (nd.isDepartment) nd.isOpen = NO;
            
            [_dataSource removeObject:nd];
        }
        
        
        node.isOpen = NO;
        [_tableView deleteRowsAtIndexPaths:cellIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSArray *)fanhuizi:(BDDynamicTreeNode *)node data:(NSArray *)data {
    NSMutableArray *array = [NSMutableArray array];
    for (BDDynamicTreeNode *nd in data) {
        if ([node.nodeId isEqualToString:nd.fatherNodeId]) {
            if (nd.isDepartment) {
                [array addObjectsFromArray:[self fanhuizi:nd data:data]];
            }
            [array addObject:nd];
            
        }
    }
    
    return array;
}

#pragma mark - 检索 所有当前fatherNodeId下的子类（包括子部门node和子部门下子node）
+ (NSArray *)filteredArrayWithFatherNodeId:(NSString *)fatherNodeId dataSource:(NSArray *)dataSource {
    NSMutableArray *filtered = [NSMutableArray array];
    
    for (BDDynamicTreeNode *node in dataSource) {
        if ([node.fatherNodeId isEqualToString:fatherNodeId]) {
            [filtered addObject:node];
            if (node.isDepartment) {
                NSArray *sonArr = [[self class] filteredArrayWithFatherNodeId:node.nodeId dataSource:dataSource];
                [filtered addObjectsFromArray:sonArr];
            }
        }
    }
    
    return filtered;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BDDynamicTreeNode *node = _dataSource[indexPath.row];
    CGFloat height = [BDDynamicTreeCell heightForCellWithIsDepartment:node.isDepartment];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BDDynamicTreeCell *cell = [BDDynamicTreeCell cellWithTableView:tableView delegate:self];
    
    BDDynamicTreeNode *node = _dataSource[indexPath.row];
    
    [cell fillWithNode:node isMultiSelect:self.isMultiSelect];
    
    if (self.isMultiSelect) {
        
        if (node.isSelected || !node.isOptional) {
            [cell setNodeSelected:YES];
        } else {
            [cell setNodeSelected:NO];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BDDynamicTreeNode *node = _dataSource[indexPath.row];
    
    if (node.isDepartment) {
        if (node.isOpen) {
            //减
            [self minusNodesByNode:node];
        } else {
            //加一个
            NSUInteger index=indexPath.row+1;
            
            [self addSubNodesByFatherNode:node atIndex:index];
        }
        [_tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(dynamicTree:didSelectedRowWithNode:)]) {
        [self.delegate dynamicTree:self didSelectedRowWithNode:node];
    }
}

#pragma mark - cell delegate
- (void)dynamicTreeCell:(BDDynamicTreeCell *)cell selectedBtnClick:(BDDynamicTreeNode *)node {
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    if (node.isDepartment) {
        [self departmentSelectedNode:indexPath];
    } else {
        [self memberSelectedNode:indexPath];
    }
}

- (void)departmentSelectedNode:(NSIndexPath *)indexPath {
    
    BDDynamicTreeNode *node = _dataSource[indexPath.row];
    if (!node.isOptional)
        return;
    
    node.isSelected = !node.isSelected;
    
    NSArray *filer = [[self class] filteredArrayWithFatherNodeId:node.nodeId dataSource:_nodesArray];;
    
    for (BDDynamicTreeNode *otherNode in filer) {
        if (otherNode.isOptional) {
            
            if (otherNode.isDepartment) {
                otherNode.isSelected = node.isSelected;
            } else {
                //当非部门时
                if (node.isSelected) {
                    //选中状态为YES，添加到选中数组中
                    otherNode.isSelected = YES;
                    if (![_selectedArray containsObject:otherNode]) {
                        [_selectedArray addObject:otherNode];
                    }
                } else {
                    //选中状态为NO，存在就移除出选中数组
                    if ([_selectedArray containsObject:otherNode]) {
                        [_selectedArray removeObject:otherNode];
                        otherNode.isSelected = NO;
                    }
                }
                
            }
            
        }
    }
    
    
    
    [_tableView reloadData];
}

- (void)memberSelectedNode:(NSIndexPath *)indexPath {
    
    BDDynamicTreeNode *node = _dataSource[indexPath.row];
    BDDynamicTreeCell *cell = (BDDynamicTreeCell *)[_tableView cellForRowAtIndexPath:indexPath];
    
    if (node.isOptional) {
        
        if (node.isSelected) {
            [_selectedArray removeObject:node];
            node.isSelected = NO;
        } else {
            node.isSelected = YES;
            [_selectedArray addObject:node];
        }
        
        if (node.isSelected) {
            [cell setNodeSelected:YES];
        } else {
            [cell setNodeSelected:NO];
        }
    }
}

#pragma mark - selected array
- (void)selectedArrayAddObject:(BDDynamicTreeNode *)node {
    if (![_selectedArray containsObject:node]) {
        [_selectedArray addObject:node];
    }
}

- (void)selectedArrayRemoveObject:(BDDynamicTreeNode *)node {
    if ([_selectedArray containsObject:node]) {
        [_selectedArray removeObject:node];
    }
}

#pragma mark - setter
- (void)setNodesArray:(NSArray *)nodesArray {
    _nodesArray = nil;
    [_dataSource removeAllObjects];
    _unoptionals = nil;
    _optionals = nil;
    
    _nodesArray = nodesArray;
    
    if (nodesArray && nodesArray.count) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [weakSelf addRootNode];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
        });
    } else {
        [_tableView reloadData];
    }
    
}

- (void)setIsMultiSelect:(BOOL)isMultiSelect {
    _isMultiSelect = isMultiSelect;
    [_tableView reloadData];
}

- (void)setUnoptionals:(NSArray *)unoptionals {
    _unoptionals = unoptionals;
    
    NSArray *fileter;
    for (BDDynamicTreeNode *node1 in unoptionals) {
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"dataId==%@",node1.dataId];
        fileter = [_nodesArray filteredArrayUsingPredicate:predicate];
        for (BDDynamicTreeNode *node2 in fileter) {
            node2.isOptional = NO;
            [self selectedArrayAddObject:node2];
        }
    }
    
    [_tableView reloadData];
}

- (void)setOptionals:(NSArray *)optionals {
    _optionals = optionals;
    
    NSArray *fileter;
    for (BDDynamicTreeNode *node1 in optionals) {
        NSPredicate *predicate=[NSPredicate predicateWithFormat:@"dataId==%@",node1.dataId];
        fileter = [_nodesArray filteredArrayUsingPredicate:predicate];
        for (BDDynamicTreeNode *node2 in fileter) {
            node2.isSelected = YES;
            [self selectedArrayAddObject:node2];
        }
    }
    
    [_tableView reloadData];
}

#pragma mark - getter
- (NSMutableArray *)selectedArray {
    if (_selectedArray) {
        return _selectedArray;
    }
    return nil;
}

@end
