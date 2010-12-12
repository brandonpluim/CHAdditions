//
//  UIItemTableView.h
//  UIItemTableView
//
//  Created by Dave DeLong on 12/10/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <UIKit/UITableView.h>

@class UIItemTableView;

@protocol UIItemTableViewDataSource <NSObject>

@required
- (NSUInteger) itemTableView:(UIItemTableView *)itemView numberOfChildrenOfItem:(id)item;
- (id) itemTableView:(UIItemTableView *)itemView child:(NSUInteger)child ofItem:(id)item;

- (UITableViewCell *) itemTableView:(UIItemTableView *)itemView cellForItem:(id)item;

@optional
- (NSString *) itemTableView:(UIItemTableView *)itemView titleForHeaderOfItem:(id)item;
- (NSString *) itemTableView:(UIItemTableView *)itemView titleForFooterOfItem:(id)item;

- (NSArray *) sectionIndexTitlesForItemTableView:(UIItemTableView *)itemView;
- (id) itemTableView:(UIItemTableView *)itemView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;

@end

@protocol UIItemTableViewDelegate <NSObject>

@optional

//accessory button
- (void) itemTableView:(UIItemTableView *)itemView didTapAccessoryButtonOfItem:(id)item;

//selection
- (BOOL) itemTableView:(UIItemTableView *)itemView shouldSelectItem:(id)item;
- (id) itemTableView:(UIItemTableView *)itemView itemToSelectInsteadOfItem:(id)item;
- (void) itemTableView:(UIItemTableView *)itemView willSelectItem:(id)item;
- (void) itemTableView:(UIItemTableView *)itemView didSelectItem:(id)item;

//deselection
- (BOOL) itemTableView:(UIItemTableView *)itemView shouldDeselectItem:(id)item;
- (id) itemTableView:(UIItemTableView *)itemView itemToDeselectInsteadOfItem:(id)item;
- (void) itemTableView:(UIItemTableView *)itemView willDeselectItem:(id)item;
- (void) itemTableView:(UIItemTableView *)itemView didDeselectItem:(id)item;

//editing
- (BOOL) itemTableView:(UIItemTableView *)itemView canEditItem:(id)item;
- (UITableViewCellEditingStyle) itemTableView:(UIItemTableView *)itemView editingStyleForItem:(id)item;
- (void) itemTableView:(UIItemTableView *)itemView willBeginEditingItem:(id)item;
- (void) itemTableView:(UIItemTableView *)itemView didEndEditingItem:(id)item;
- (void) itemTableView:(UIItemTableView *)itemView commitEditingStyle:(UITableViewCellEditingStyle)style forItem:(id)item;

//moving
- (BOOL) itemTableView:(UIItemTableView *)itemView canMoveItem:(id)item;
- (id) itemTableView:(UIItemTableView *)itemView itemToRetargetMoveOfItem:(id)fromItem toProposedItem:(id)item;
- (void) itemTableView:(UIItemTableView *)itemView moveItem:(id)fromItem toItem:(id)toItem;

//heights
- (CGFloat) itemTableView:(UIItemTableView *)itemView heightForRowOfItem:(id)item;
- (CGFloat) itemTableView:(UIItemTableView *)itemView heightForFooterOfItem:(id)item;
- (CGFloat) itemTableView:(UIItemTableView *)itemView heightForHeaderOfItem:(id)item;

//custom views
- (UIView *) itemTableView:(UIItemTableView *)itemView viewForFooterOfItem:(id)item;
- (UIView *) itemTableView:(UIItemTableView *)itemView viewForHeaderOfItem:(id)item;

//indentation
- (NSInteger) itemTableView:(UIItemTableView *)itemView indentationLevelForItem:(id)item;
- (BOOL) itemTableView:(UIItemTableView *)itemView shouldIndentWhileEditingItem:(id)item;

//delete button title
- (NSString *) itemTableView:(UIItemTableView *)itemView titleForDeleteConfirmationButtonOfItem:(id)item;

//cell displaying
- (void) itemTableView:(UIItemTableView *)itemView willDisplayCell:(UITableViewCell *)cell ofItem:(id)item;

@end



@interface UIItemTableView : UITableView <UITableViewDataSource, UITableViewDelegate> {
	@private
	BOOL _setupComplete;
	NSMutableArray * _items;
	
	id<UIItemTableViewDelegate> itemDelegate;
	id<UIItemTableViewDataSource> itemDatasource;
}

@property (nonatomic, assign) id<UIItemTableViewDelegate> itemDelegate;
@property (nonatomic, assign) id<UIItemTableViewDataSource> itemDatasource;

- (UITableViewCell *) cellForItem:(id)item;
- (id) itemForCell:(UITableViewCell *)cell;
- (id) itemForRowAtPoint:(CGPoint)point;
- (id) selectedItem;
- (id) itemsInRect:(CGRect)rect;
- (NSArray *) visibleItems;

- (void) deleteItems:(NSArray *)items withRowAnimation:(UITableViewRowAnimation)animation;
//- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
//- (void)insertSections:(NSIndexSet *)sections withRowAnimation:(UITableViewRowAnimation)animation;

- (NSInteger) numberOfChildrenOfItem:(id)item;
- (CGRect) rectForFooterOfItem:(id)item;
- (CGRect) rectForHeaderOfItem:(id)item;
- (CGRect) rectForItem:(id)item;

- (void) reloadItems:(NSArray *)items withRowAnimation:(UITableViewRowAnimation)animation;
- (void) scrollToItem:(id)item atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

- (void) selectItem:(id)item animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;
- (void) deselectItem:(id)item animated:(BOOL)animated;

@end
