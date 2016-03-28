//
//  BDDynamicTreeCell.m
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

#import "BDDynamicTreeCell.h"
#import "BDDynamicTreeNode.h"

static const CGFloat BDDYSpace              = 10.f;
static const CGFloat BDDYSelectedBtnHeight  = 22.f;

static NSString *CellIdentifier = @"bddynamictreecell";


@interface BDDynamicTreeCell ()

@property (nonatomic, assign) id <BDDynamicTreeCellDelegate> delegate;

@property (nonatomic, strong) BDDynamicTreeNode *node;
@property (nonatomic, assign) BOOL isMultiSelect;

@property (nonatomic, strong) UIView *detaileView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *labelTitle;

@property (nonatomic, strong) UIView *underLine;
@property (nonatomic, strong) UIImageView *plusImageView;
@property (nonatomic, strong) UIButton *selectedButton;

@end

@implementation BDDynamicTreeCell

#pragma mark - life cycle
+ (instancetype)cellWithTableView:(UITableView *)tableView delegate:(id <BDDynamicTreeCellDelegate>)delegate {
    BDDynamicTreeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[BDDynamicTreeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = delegate;
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.detaileView addSubview:self.avatarImageView];
        [self.detaileView addSubview:self.labelTitle];
        [self.contentView addSubview:self.detaileView];
        
        [self.contentView insertSubview:self.plusImageView aboveSubview:self.detaileView];
        [self.contentView insertSubview:self.selectedButton belowSubview:self.detaileView];
        
        [self.contentView addSubview:self.underLine];
    }
    return self;
}

#pragma mark - cell height
+ (CGFloat)heightForCellWithIsDepartment:(BOOL)isDepartment
{
    if (isDepartment) {
        return DepartmentCellHeight;
    }
    return EmployeeCellHeight;
}

#pragma mark - 逻辑处理
- (void)fillWithNode:(BDDynamicTreeNode*)node isMultiSelect:(BOOL)isMultiSelect
{
    self.node = node;
    self.isMultiSelect = isMultiSelect;
    if (node) {
        
        self.labelTitle.text = node.showName;
        
        self.selectedButton.hidden = !self.isMultiSelect;
        
        if (node.isOpen) {
            self.plusImageView.highlighted = YES;
        } else {
            self.plusImageView.highlighted = NO;;
        }
        
        [self updateAllFrame];
        
    }
}

#pragma mark - 
- (void)updateAllFrame {
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [[self class] heightForCellWithIsDepartment:self.node.isDepartment];
    
    self.bounds = CGRectMake(0, 0, width, height);
    
    
    CGFloat spHeight = CGRectGetHeight(self.bounds)-BDDYSpace*2;
    
    self.selectedButton.frame = CGRectMake(BDDYSpace+self.node.originX, (CGRectGetHeight(self.bounds)-BDDYSelectedBtnHeight)*.5f, BDDYSelectedBtnHeight, BDDYSelectedBtnHeight);
    self.plusImageView.frame = CGRectMake(CGRectGetWidth(self.bounds)-spHeight-BDDYSpace, BDDYSpace, spHeight, spHeight);
    
    
    if (self.node.isDepartment) {
        [self isDepartmentToYES];
    } else {
        [self isDepartmentToNO];
    }
    
    self.underLine.frame = CGRectMake(0, CGRectGetHeight(self.bounds)-0.5, CGRectGetWidth(self.bounds), 0.5);
    
}

- (void)isDepartmentToYES {
    self.contentView.backgroundColor = [UIColor colorWithRed:231/255.f green:231/255.f blue:231/255.f alpha:1];
    
    //头像
    self.avatarImageView.hidden = YES;
    //右边箭头
    self.plusImageView.hidden = NO;
    
    CGRect detailViewFrame = self.bounds;
    detailViewFrame.size.width = detailViewFrame.size.width-CGRectGetMinX(self.plusImageView.frame);
    if (_isMultiSelect) {
        detailViewFrame.origin.x = CGRectGetMaxX(self.selectedButton.frame)+BDDYSpace;
        detailViewFrame.size.width = CGRectGetMinX(self.plusImageView.frame)-detailViewFrame.origin.x;
    } else {
        detailViewFrame.origin.x = CGRectGetMinX(self.selectedButton.frame);
        detailViewFrame.size.width = CGRectGetMinX(self.plusImageView.frame)-detailViewFrame.origin.x;
    }
    
    self.detaileView.frame = detailViewFrame;
    
    self.labelTitle.frame = CGRectMake(0, (CGRectGetHeight(detailViewFrame)-20)*.5f, CGRectGetWidth(detailViewFrame), 20);
    
}

- (void)isDepartmentToNO {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    //头像
    self.avatarImageView.hidden = NO;
    //右边箭头
    self.plusImageView.hidden = YES;
    
    CGFloat spHeight = CGRectGetHeight(self.bounds)-BDDYSpace*2;
    
    CGRect detailViewFrame = self.bounds;
    if (_isMultiSelect) {
        detailViewFrame.origin.x = CGRectGetMaxX(self.selectedButton.frame)+BDDYSpace;
    } else {
        detailViewFrame.origin.x = CGRectGetMinX(self.selectedButton.frame);;
    }
    
    detailViewFrame.size.width = detailViewFrame.size.width-detailViewFrame.origin.x;
    
    self.detaileView.frame = detailViewFrame;
    
    self.avatarImageView.frame = CGRectMake(0, BDDYSpace, spHeight, spHeight);
//    self.labelTitle.frame = CGRectMake(CGRectGetMaxX(self.avatarImageView.frame)+BDDYSpace, (CGRectGetHeight(detailViewFrame)-20)*.5f, CGRectGetWidth(detailViewFrame)-CGRectGetMaxX(self.avatarImageView.frame)-BDDYSpace, 20);
    self.labelTitle.frame = CGRectMake(0, (CGRectGetHeight(detailViewFrame)-20)*.5f, CGRectGetWidth(detailViewFrame)-CGRectGetMaxX(self.avatarImageView.frame)-BDDYSpace, 20);
}

#pragma mark - action
- (void)selectedButtonClick:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dynamicTreeCell:selectedBtnClick:)]) {
        [self.delegate dynamicTreeCell:self selectedBtnClick:self.node];
    }
}

#pragma mark - setter
- (void)setNodeSelected:(BOOL)nodeSelected {
    _nodeSelected = nodeSelected;
    
    self.selectedButton.selected = nodeSelected;
}

#pragma mark - getter
- (UIImageView *)plusImageView {
    if (!_plusImageView) {
        UIImageView *plusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BDDynamicTree.bundle/adderss_rightArrow.png"] highlightedImage:[UIImage imageNamed:@"BDDynamicTree.bundle/address_downArrow.png"]];
        plusImageView.contentMode = UIViewContentModeCenter;
        _plusImageView = plusImageView;
    }
    return _plusImageView;
}

- (UIButton *)selectedButton {
    if (!_selectedButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"BDDynamicTree.bundle/group_check_box_circle_unselect.png"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"BDDynamicTree.bundle/group_check_box_circle_select.png"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(selectedButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _selectedButton = button;
    }
    return _selectedButton;
}

- (UIView *)detaileView {
    if (!_detaileView) {
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor clearColor];
        _detaileView = view;
    }
    return _detaileView;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
        _avatarImageView = imageView;
    }
    return _avatarImageView;
}

- (UILabel *)labelTitle {
    if (!_labelTitle) {
        UILabel *labelTitle=[[UILabel alloc] init];
        labelTitle.adjustsFontSizeToFitWidth = YES;
        labelTitle.backgroundColor=[UIColor clearColor];
        labelTitle.textColor=[UIColor blackColor];
        labelTitle.numberOfLines = 0;
        _labelTitle = labelTitle;
    }
    return _labelTitle;
}

- (UIView *)underLine {
    if (!_underLine) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *underLine = [[UIView alloc] init];
        underLine.backgroundColor = [UIColor colorWithRed:228/255.f green:226/255.f blue:229/255.f alpha:1];
        _underLine = underLine;
    }
    return _underLine;
}

@end
