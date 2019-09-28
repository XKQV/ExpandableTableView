//
//  ExpandableTableView.m
//  DoubleExpandTableViewDemo
//
//  Created by XKQ on 2019/9/28.
//  Copyright © 2019 董志玮. All rights reserved.
//

#import "ExpandableTableView.h"
#import "ExpandableTableViewCell.h"

static NSString *const cellIdentifier = @"cellIdentifier";
static NSString *const expandCellIdentifier = @"expandCellIdentifier";

@interface ExpandableTableView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSArray<ExperienceModel *>*>*> *modelArray;
@property (nonatomic, strong) NSArray<ExperienceModel *> *singleModelArray;
@property (nonatomic, assign) BOOL tableExpand;
@property (nonatomic, strong) NSMutableDictionary *expandStatusDictionary;

@end

@implementation ExpandableTableView

- (instancetype)initWithModel:(NSArray<NSDictionary<NSString *, NSArray<ExperienceModel *>*>*> *)modelArray {
    self = [super initWithFrame:CGRectZero style:UITableViewStylePlain];
    if (self) {
        self.modelArray = modelArray;
        self.expandStatusDictionary = @{}.mutableCopy;
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

- (NSArray<ExperienceModel *> *)singleModelArrayWithIndex:(NSUInteger)index {
    NSDictionary *modelDict = self.modelArray[index];
    NSArray *modelArray = modelDict.allValues[0];
    return modelArray;
}

- (BOOL)isExpandCellAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *modelArray = [self singleModelArrayWithIndex:indexPath.section];
    BOOL isExpandCell;
    if (self.tableExpand) {
        isExpandCell = indexPath.row == modelArray.count;
    } else {
        if (modelArray.count > 3) {
            isExpandCell = indexPath.row == 3;
        } else {
            isExpandCell = NO;
        }
    }
    return isExpandCell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [self dequeueReusableHeaderFooterViewWithIdentifier:@"header"];
    if (!header) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"header"];
    }
    NSDictionary *dataDict = self.modelArray[section];
    header.textLabel.text = dataDict.allKeys[0];
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.modelArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = [self singleModelArrayWithIndex:section].count;
    if (count > 3 && !self.tableExpand) {
        return 4;
    }
    return count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExpandableTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ExpandableTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    UITableViewCell *expandCell = [tableView dequeueReusableCellWithIdentifier:expandCellIdentifier];
    if (expandCell == nil) {
        expandCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:expandCellIdentifier];
    }
    NSArray *modelArray = [self singleModelArrayWithIndex:indexPath.section];
    NSUInteger count = self.tableExpand ? modelArray.count : 3;
    if (indexPath.row < count) {
        [cell configureCellWithModel:modelArray[indexPath.row] isExpand:[[self.expandStatusDictionary objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]] boolValue]];
        
        cell.expandBlock = ^(ExpandableTableViewCell *cell) {
            NSIndexPath *indexPath = [self indexPathForCell:cell];
            BOOL expand = ![[self.expandStatusDictionary objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]] boolValue];
            [self.expandStatusDictionary setObject:@(expand) forKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
            [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        };
        return cell;
    }
    if (indexPath.row == count && modelArray.count > 3) {
        expandCell.textLabel.center = CGPointMake([UIScreen mainScreen].bounds.size.width / 2, 0);
        expandCell.textLabel.text = self.tableExpand ? @"收起" : @"展开全部 ";
        expandCell.textLabel.textColor = [UIColor blueColor];
        return expandCell;
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self singleModelArrayWithIndex:indexPath.section].count > 3 && [self isExpandCellAtIndexPath:indexPath]) {
        self.tableExpand = !self.tableExpand;
        [self reloadData];
        if (!self.tableExpand) {
            [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        } else {
             [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
        
        
        return;
    }
    self.cellClickBlock();
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self isExpandCellAtIndexPath:indexPath]) {
        return 60;
    }
    if (indexPath.row < [self singleModelArrayWithIndex:indexPath.section].count) {
        return [ExpandableTableViewCell cellHeightWithModel:[self singleModelArrayWithIndex:indexPath.section][indexPath.row] isExpand:[[self.expandStatusDictionary objectForKey:[NSString stringWithFormat:@"%ld",(long)indexPath.row]] boolValue]];
    }
    return 0;
}

@end
