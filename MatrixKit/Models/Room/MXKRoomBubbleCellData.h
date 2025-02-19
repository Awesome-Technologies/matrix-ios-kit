/*
 Copyright 2015 OpenMarket Ltd
 Copyright 2019 The Matrix.org Foundation C.I.C

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MXKCellData.h"
#import "MXKRoomBubbleCellDataStoring.h"

#import "MXKRoomBubbleComponent.h"

#define MXKROOMBUBBLECELLDATA_TEXTVIEW_DEFAULT_VERTICAL_INSET 8

/**
 `MXKRoomBubbleCellData` instances compose data for `MXKRoomBubbleTableViewCell` cells.
 
 This is the basic implementation which considers only one component (event) by bubble.
 `MXKRoomBubbleCellDataWithAppendingMode` extends this class to merge consecutive messages from the same sender into one bubble.
 */
@interface MXKRoomBubbleCellData : MXKCellData <MXKRoomBubbleCellDataStoring>
{
@protected
    /**
     The data source owner of this instance.
     */
    MXKRoomDataSource *roomDataSource;
    
    /**
     Array of bubble components. Each bubble is supposed to have at least one component.
     */
    NSMutableArray *bubbleComponents;
    
    /**
     The body of the message with sets of attributes, or kind of content description in case of attachment (e.g. "image attachment")
     */
    NSAttributedString *attributedTextMessage;
    
    /**
     The optional text pattern to be highlighted in the body of the message.
     */
    NSString *highlightedPattern;
    UIColor  *highlightedPatternColor;
    UIFont   *highlightedPatternFont;
}

/**
 The matrix session.
 */
@property (nonatomic, readonly) MXSession *mxSession;

/**
 Returns bubble components list (`MXKRoomBubbleComponent` instances).
 */
@property (nonatomic, readonly) NSArray<MXKRoomBubbleComponent*> *bubbleComponents;

/**
 Read receipts per event.
 */
@property(nonatomic) NSMutableDictionary<NSString* /* eventId */,
                                         NSArray<MXReceiptData *> *> *readReceipts;

/**
 Aggregated reactions per event.
 */
@property(nonatomic) NSMutableDictionary<NSString* /* eventId */, MXAggregatedReactions*> *reactions;

/**
 Event formatter
 */
@property (nonatomic) MXKEventFormatter *eventFormatter;

/**
 The max width of the text view used to display the text message (relevant only for text message or attached file).
 */
@property (nonatomic) CGFloat maxTextViewWidth;

/**
 The bubble content size depends on its type:
 - Text: returns suitable content size of a text view to display the whole text message (respecting maxTextViewWidth).
 - Attached image or video: returns suitable content size for an image view in order to display
 attachment thumbnail or icon.
 - Attached file: returns suitable content size of a text view to display the file name (no icon is used presently).
 */
@property (nonatomic) CGSize contentSize;

/**
 Set of flags indicating fixes that need to be applied at display time.
 */
@property (nonatomic, readonly) MXKRoomBubbleComponentDisplayFix displayFix;

/**
 Attachment upload
 */
@property (nonatomic) NSString *uploadId;
@property (nonatomic) CGFloat uploadProgress;

/**
 Check and refresh the position of each component.
 */
- (void)prepareBubbleComponentsPosition;

/**
 Return the raw height of the provided text by removing any vertical margin/inset.
 
 @param attributedText the attributed text to measure
 @return the computed height
 */
- (CGFloat)rawTextHeight:(NSAttributedString*)attributedText;

/**
 Return the content size of a text view initialized with the provided attributed text.
 CAUTION: This method runs only on main thread.
 
 @param attributedText the attributed text to measure
 @param removeVerticalInset tell whether the computation should remove vertical inset in text container.
 @return the computed size content
 */
- (CGSize)textContentSize:(NSAttributedString*)attributedText removeVerticalInset:(BOOL)removeVerticalInset;

@end
