//
//  UIItemTableView.m
//  UIItemTableView
//
//  Created by Dave DeLong on 12/10/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "UIItemTableView.h"

@interface UIItemTableViewLoadable : NSObject
+ (id) loadable;
@end
@implementation UIItemTableViewLoadable
+ (id) loadable {
	static UIItemTableViewLoadable * _loadable = nil;
	if (_loadable == nil) {
		_loadable = [[UIItemTableViewLoadable alloc] init];
	}
	return _loadable;
}
@end

@interface UIItemTableViewCompactible : NSObject
+ (id) compactible;
@end
@implementation UIItemTableViewCompactible
+ (id) compactible {
	static UIItemTableViewCompactible * _compactible = nil;
	if (_compactible == nil) {
		_compactible = [[UIItemTableViewCompactible alloc] init];
	}
	return _compactible;
}
@end



@interface UIItemTableViewItemSection : NSObject
{
	id item;
	NSMutableArray * rows;
}

@property (nonatomic, retain) id item;
@property (nonatomic, retain) NSMutableArray * rows;

@end

@implementation UIItemTableViewItemSection
@synthesize item, rows;

+ (id) itemSection {
	UIItemTableViewItemSection * s = [[UIItemTableViewItemSection alloc] init];
	[s setRows:[NSMutableArray array]];
	return [s autorelease];
}

- (void) dealloc {
	[item release];
	[rows release];
	[super dealloc];
}

- (void) reserveSpotsForRows:(NSUInteger)numberOfRows {
	if ([rows count] != 0) { [NSException raise:NSGenericException format:@"attempting to reserve spots with existing rows"]; }
	for (NSUInteger i = 0; i < numberOfRows; ++i) {
		[rows addObject:[UIItemTableViewLoadable loadable]];
	}
}

- (void) compact {
	NSMutableIndexSet * indexes = [NSMutableIndexSet indexSet];
	[rows enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL * stop) {
		if (obj == [UIItemTableViewCompactible compactible]) {
			[indexes addIndex:index];
		}
	}];
	[rows removeObjectsAtIndexes:indexes];
}

@end




@implementation UIItemTableView
@synthesize itemDelegate, itemDatasource;

- (void) _setup {
	if (_setupComplete) { return; }
	[super setDelegate:self];
	[super setDataSource:self];
	_items = [[NSMutableArray alloc] init];
	_setupComplete = YES;
}

- (void) awakeFromNib {
	[self _setup];
}

- (id) initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
	self = [super initWithFrame:frame style:style];
	if (self) {
		[self _setup];
	}
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self _setup];
	}
	return self;
}

- (id) initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self _setup];
	}
	return self;
}

- (void) dealloc {
	[_items release];
	[super dealloc];
}

- (void) setDelegate:(id <UITableViewDelegate>)delegate {
	[NSException raise:NSGenericException format:@"-%@ should not be invoked", NSStringFromSelector(_cmd)];	
}

- (void) setDataSource:(id <UITableViewDataSource>)dataSource {
	[NSException raise:NSGenericException format:@"-%@ should not be invoked", NSStringFromSelector(_cmd)];	
}

- (id<UITableViewDataSource>) dataSource { return self; }
- (id<UITableViewDelegate>) delegate { return self; }

- (void) setItemDelegate:(id <UIItemTableViewDelegate>)newDelegate {
	itemDelegate = newDelegate;
	//this should case us to flush our cache of what methods the delegate responds to
	[super setDelegate:nil];
	[super setDelegate:self];
}

- (void) setItemDatasource:(id <UIItemTableViewDataSource>)newDatasource {
	itemDatasource = newDatasource;
	[super setDataSource:nil];
	[super setDataSource:self];
}

- (BOOL) respondsToSelector:(SEL)aSelector {
	//<ItemDataSource> methods
	if (sel_isEqual(aSelector, @selector(numberOfSectionsInTableView:))) {
		return [[self itemDatasource] respondsToSelector:@selector(itemTableView:numberOfChildrenOfItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:numberOfRowsInSection:))) {
		return [[self itemDatasource] respondsToSelector:@selector(itemTableView:numberOfChildrenOfItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:cellForRowAtIndexPath:))) {
		return [[self itemDatasource] respondsToSelector:@selector(itemTableView:cellForItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:titleForHeaderInSection:))) {
		return [[self itemDatasource] respondsToSelector:@selector(itemTableView:titleForHeaderOfItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:titleForFooterInSection:))) {
		return [[self itemDatasource] respondsToSelector:@selector(itemTableView:titleForFooterOfItem:)];
	}
	if (sel_isEqual(aSelector, @selector(sectionIndexTitlesForTableView:))) {
		return [[self itemDatasource] respondsToSelector:@selector(sectionIndexTitlesForItemTableView:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:sectionForSectionIndexTitle:atIndex:))) {
		return [[self itemDatasource] respondsToSelector:@selector(itemTableView:sectionForSectionIndexTitle:atIndex:)];
	}
	
	//<ItemDelegate> methods
	if (sel_isEqual(aSelector, @selector(tableView:willDisplayCell:forRowAtIndexPath:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:willDisplayCell:ofItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:heightForRowAtIndexPath:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:heightForRowOfItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:heightForHeaderInSection:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:heightForHeaderOfItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:heightForFooterInSection:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:heightForFooterOfItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:viewForHeaderInSection:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:viewForHeaderOfItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:viewForFooterInSection:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:viewForFooterOfItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:accessoryButtonTappedForRowWithIndexPath:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:didTapAccessoryButtonOfItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:willSelectRowAtIndexPath:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:shouldSelectItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:willDeselectRowAtIndexPath:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:shouldDeselectItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:didSelectRowAtIndexPath:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:didSelectItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:didDeselectRowAtIndexPath:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:didDeselectItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:canEditRowAtIndexPath:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:canEditItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:editingStyleForRowAtIndexPath:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:editingStyleForItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:titleForDeleteConfirmationButtonOfItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:shouldIndentWhileEditingRowAtIndexPath:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:shouldIndentWhileEditingItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:willBeginEditingRowAtIndexPath:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:willBeginEditingItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:didEndEditingRowAtIndexPath:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:didEndEditingItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:commitEditingStyle:forRowAtIndexPath:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:commitEditingStyle:forItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:canMoveRowAtIndexPath:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:canMoveItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:moveRowAtIndexPath:toIndexPath:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:moveItem:toItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:itemToRetargetMoveOfItem:toProposedItem:)];
	}
	if (sel_isEqual(aSelector, @selector(tableView:indentationLevelForRowAtIndexPath:))) {
		return [[self itemDelegate] respondsToSelector:@selector(itemTableView:indentationLevelForItem:)];
	}
	
	
	return [super respondsToSelector:aSelector];
}

- (UIItemTableViewItemSection *) _sectionAtIndex:(NSUInteger)index {
	if (index >= [_items count]) { return nil; }
	id s = [_items objectAtIndex:index];
	if (s == [UIItemTableViewLoadable loadable]) {
		s = [UIItemTableViewItemSection itemSection];
		id item = [[self itemDatasource] itemTableView:self child:index ofItem:nil];
		if (item == nil) {
			[NSException raise:NSInvalidArgumentException format:@"invalid child item"];
		}
		[s setItem:item];
		
		NSUInteger children = [[self itemDatasource] itemTableView:self numberOfChildrenOfItem:item];
		[s reserveSpotsForRows:children];
		
		[_items replaceObjectAtIndex:index withObject:s];
	}
	return s;
}

- (id) _itemForIndexPath:(NSIndexPath *)path {
	UIItemTableViewItemSection * s = [self _sectionAtIndex:[path section]];
	id item = [[s rows] objectAtIndex:[path row]];
	if (item == [UIItemTableViewLoadable loadable]) {
		item = [[self itemDatasource] itemTableView:self child:[path row] ofItem:[s item]];
		if (item == nil) {
			[NSException raise:NSInvalidArgumentException format:@"invalid child item"];
		}
		[[s rows] replaceObjectAtIndex:[path row] withObject:item];
	}
	return [[s rows] objectAtIndex:[path row]];
}

- (NSArray *) _itemsForIndexPaths:(NSArray *)paths {
	NSMutableArray * items = [NSMutableArray array];
	for (NSIndexPath * path in paths) {
		[items addObject:[self _itemForIndexPath:path]];
	}
	return items;
}

- (UIItemTableViewItemSection *) _sectionForItem:(id)item {
	for (UIItemTableViewItemSection * section in _items) {
		if ([section item] == item) {
			return section;
		}
	}
	return nil;
}

- (NSInteger) _sectionIndexForItem:(id)item {
	__block NSInteger _section = NSNotFound;
	[_items enumerateObjectsUsingBlock:^(id obj, NSUInteger section, BOOL * stop) {
		if (obj == item) {
			_section = section;
			*stop = YES;
		}
	}];
	return _section;
}

- (NSIndexPath *) _indexPathForItem:(id)item {
	NSUInteger numberOfSections = [_items count];
	for (NSUInteger sectionIndex = 0; sectionIndex < numberOfSections; ++sectionIndex) {
		//retrieve (maybe load) the section
		UIItemTableViewItemSection * section = [self _sectionAtIndex:sectionIndex];
		NSUInteger numberOfRows = [[section rows] count];
		for (NSUInteger rowIndex = 0; rowIndex < numberOfRows; ++rowIndex) {
			NSIndexPath * indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
			//retrieve (maybe load) the item
			id rowItem = [self _itemForIndexPath:indexPath];
			if (rowItem == item) {
				return indexPath;
			}
		}
	}
	return nil;
}

- (void) reloadData {
	[_items removeAllObjects];
	[super reloadData];
}

- (void) deleteItems:(NSArray *)items withRowAnimation:(UITableViewRowAnimation)animation {
	NSMutableArray * indexPaths = [NSMutableArray array];
	NSMutableIndexSet * sectionIndexes = [NSMutableIndexSet indexSet];
	[items enumerateObjectsUsingBlock:^(id item, NSUInteger index, BOOL * stop) {
		NSInteger section = [self _sectionIndexForItem:item];
		if (section == NSNotFound) {
			[indexPaths addObject:[self _indexPathForItem:item]];
		} else {
			[sectionIndexes addIndex:index];
		}
	}];
	
	[indexPaths enumerateObjectsUsingBlock:^(id indexPath, NSUInteger index, BOOL * stop) {
		UIItemTableViewItemSection * section = [self _sectionAtIndex:[indexPath section]];
		[[section rows] replaceObjectAtIndex:[indexPath row] withObject:[UIItemTableViewCompactible compactible]];
	}];
	
	[_items removeObjectsAtIndexes:sectionIndexes];
	[_items makeObjectsPerformSelector:@selector(compact)];
	
	if ([indexPaths count] > 0) {
		[self deleteRowsAtIndexPaths:indexPaths withRowAnimation:animation];
	}
	if ([sectionIndexes count] > 0) {
		[self deleteSections:sectionIndexes withRowAnimation:animation];
	}
}

- (void) deselectItem:(id)item animated:(BOOL)animated {
	[self deselectRowAtIndexPath:[self _indexPathForItem:item] animated:animated];
}

- (UITableViewCell *) cellForItem:(id)item {
	return [self cellForRowAtIndexPath:[self _indexPathForItem:item]];
}

- (id) itemForCell:(UITableViewCell *)cell {
	return [self _itemForIndexPath:[self indexPathForCell:cell]];
}

- (id) itemForRowAtPoint:(CGPoint)point {
	return [self _itemForIndexPath:[self indexPathForRowAtPoint:point]];
}

- (id) selectedItem {
	return [self _itemForIndexPath:[self indexPathForSelectedRow]];
}

- (id) itemsInRect:(CGRect)rect {
	return [self _itemsForIndexPaths:[self indexPathsForRowsInRect:rect]];
}

- (NSArray *) visibleItems {
	return [self _itemsForIndexPaths:[self indexPathsForVisibleRows]];
}

- (NSInteger) numberOfChildrenOfItem:(id)item {
	UIItemTableViewItemSection * section = [self _sectionForItem:item];
	return [[section rows] count];
}

- (CGRect) rectForFooterOfItem:(id)item {
	return [self rectForFooterInSection:[self _sectionIndexForItem:item]];
}

- (CGRect) rectForHeaderOfItem:(id)item {
	return [self rectForHeaderInSection:[self _sectionIndexForItem:item]];
}

- (CGRect) rectForItem:(id)item {
	NSInteger section = [self _sectionIndexForItem:item];
	if (section != NSNotFound) {
		return [self rectForSection:section];
	}
	return [self rectForRowAtIndexPath:[self _indexPathForItem:item]];
}

- (void) reloadItems:(NSArray *)items withRowAnimation:(UITableViewRowAnimation)animation {
	NSMutableArray * indexPaths = [NSMutableArray array];
	NSMutableIndexSet * sectionIndexes = [NSMutableIndexSet indexSet];
	[items enumerateObjectsUsingBlock:^(id item, NSUInteger index, BOOL * stop) {
		NSInteger section = [self _sectionIndexForItem:item];
		if (section == NSNotFound) {
			[indexPaths addObject:[self _indexPathForItem:item]];
		} else {
			[sectionIndexes addIndex:index];
		}
	}];
	if ([indexPaths count] > 0) {
		[self reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
	}
	if ([sectionIndexes count] > 0) {
		[self reloadSections:sectionIndexes withRowAnimation:animation];
	}
}

- (void) scrollToItem:(id)item atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated {
	[self scrollToRowAtIndexPath:[self _indexPathForItem:item] atScrollPosition:scrollPosition animated:animated];
}

- (void) selectItem:(id)item animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
	[self selectRowAtIndexPath:[self _indexPathForItem:item] animated:animated scrollPosition:scrollPosition];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	if ([_items count] == 0) {
		NSUInteger sections = [[self itemDatasource] itemTableView:self numberOfChildrenOfItem:nil];
		for (NSUInteger i = 0; i < sections; ++i) {
			[_items addObject:[UIItemTableViewLoadable loadable]];
		}
	}
	return [_items count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section >= [_items count]) { return 0; }
	UIItemTableViewItemSection * s = [self _sectionAtIndex:section];
	return [[s rows] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UIItemTableViewItemSection * s = [self _sectionAtIndex:[indexPath section]];
	id item = [[s rows] objectAtIndex:[indexPath row]];
	if (item == [UIItemTableViewLoadable loadable]) {
		item = [[self itemDatasource] itemTableView:self child:[indexPath row] ofItem:[s item]];
		if (item == nil) {
			[NSException raise:NSInvalidArgumentException format:@"invalid child item"];
		}
		[[s rows] replaceObjectAtIndex:[indexPath row] withObject:item];
	}
	
	return [[self itemDatasource] itemTableView:self cellForItem:item];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// fixed font style. use custom view (UILabel) if you want something different
	UIItemTableViewItemSection * s = [self _sectionAtIndex:section];
	return [[self itemDatasource] itemTableView:self titleForHeaderOfItem:[s item]];
	
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	UIItemTableViewItemSection * s = [self _sectionAtIndex:section];
	return [[self itemDatasource] itemTableView:self titleForFooterOfItem:[s item]];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[self itemDelegate] itemTableView:self canEditItem:[self _itemForIndexPath:indexPath]];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[self itemDelegate] itemTableView:self canMoveItem:[self _itemForIndexPath:indexPath]];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return [[self itemDatasource] sectionIndexTitlesForItemTableView:self];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	id section = [[self itemDatasource] itemTableView:self sectionForSectionIndexTitle:title atIndex:index];
	return [self _sectionIndexForItem:section];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[self itemDelegate] itemTableView:self commitEditingStyle:editingStyle forItem:[self _itemForIndexPath:indexPath]];
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
	[[self itemDelegate] itemTableView:self moveItem:[self _itemForIndexPath:sourceIndexPath] toItem:[self _itemForIndexPath:destinationIndexPath]];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	[[self itemDelegate] itemTableView:self willDisplayCell:cell ofItem:[self _itemForIndexPath:indexPath]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[self itemDelegate] itemTableView:self heightForRowOfItem:[self _itemForIndexPath:indexPath]];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	UIItemTableViewItemSection * s = [self _sectionAtIndex:section];
	return [[self itemDelegate] itemTableView:self heightForHeaderOfItem:[s item]];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	UIItemTableViewItemSection * s = [self _sectionAtIndex:section];
	return [[self itemDelegate] itemTableView:self heightForFooterOfItem:[s item]];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIItemTableViewItemSection * s = [self _sectionAtIndex:section];
	return [[self itemDelegate] itemTableView:self viewForHeaderOfItem:[s item]];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIItemTableViewItemSection * s = [self _sectionAtIndex:section];
	return [[self itemDelegate] itemTableView:self viewForFooterOfItem:[s item]];
}

// Accessories (disclosures). 
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	[[self itemDelegate] itemTableView:self didTapAccessoryButtonOfItem:[self _itemForIndexPath:indexPath]];
}
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[self itemDelegate] itemTableView:self shouldSelectItem:[self _itemForIndexPath:indexPath]]) {
		if ([[self itemDelegate] respondsToSelector:@selector(itemTableView:itemToSelectInsteadOfItem:)]) {
			id item = [[self itemDelegate] itemTableView:self itemToSelectInsteadOfItem:[self _itemForIndexPath:indexPath]];
			
			if ([[self itemDelegate] respondsToSelector:@selector(itemTableView:willSelectItem:)]) {
				[[self itemDelegate] itemTableView:self willSelectItem:item];
			}
			
			return [self _indexPathForItem:item];
		}
	}
	return indexPath;		   
}
- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([[self itemDelegate] itemTableView:self shouldDeselectItem:[self _itemForIndexPath:indexPath]]) {
		if ([[self itemDelegate] respondsToSelector:@selector(itemTableView:itemToDeselectInsteadOfItem:)]) {
			id item = [[self itemDelegate] itemTableView:self itemToDeselectInsteadOfItem:[self _itemForIndexPath:indexPath]];
			
			if ([[self itemDelegate] respondsToSelector:@selector(itemTableView:willDeselectItem:)]) {
				[[self itemDelegate] itemTableView:self willDeselectItem:item];
			}
			
			return [self _indexPathForItem:item];
		}
	}
	return indexPath;		   
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[self itemDelegate] itemTableView:self didSelectItem:[self _itemForIndexPath:indexPath]];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[self itemDelegate] itemTableView:self didDeselectItem:[self _itemForIndexPath:indexPath]];
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[self itemDelegate] itemTableView:self editingStyleForItem:[self _itemForIndexPath:indexPath]];
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[self itemDelegate] itemTableView:self titleForDeleteConfirmationButtonOfItem:[self _itemForIndexPath:indexPath]];
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[self itemDelegate] itemTableView:self shouldIndentWhileEditingItem:[self _itemForIndexPath:indexPath]];
}
- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	[[self itemDelegate] itemTableView:self willBeginEditingItem:[self _itemForIndexPath:indexPath]];
}
- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	[[self itemDelegate] itemTableView:self didEndEditingItem:[self _itemForIndexPath:indexPath]];
}
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
	id retarget = [[self itemDelegate] itemTableView:self itemToRetargetMoveOfItem:[self _itemForIndexPath:sourceIndexPath] toProposedItem:[self _itemForIndexPath:proposedDestinationIndexPath]];
	return [self _indexPathForItem:retarget];
}
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [[self itemDelegate] itemTableView:self indentationLevelForItem:[self _itemForIndexPath:indexPath]];
}


@end
