// Copyright 2019-present the Material Components for iOS authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "MDCTextControlVerticalPositioningReferenceOutlined.h"
#import "MDCTextControlVerticalPositioningReference.h"

/**
 These values do not come from anywhere in particular. They are values I chose in an attempt to
 achieve the look and feel of the textfields at
 https://material.io/design/components/text-fields.html.
*/
static const CGFloat kMinPaddingAroundTextWhenNoLabel = 6.0f;
static const CGFloat kMaxPaddingAroundTextWhenNoLabel = 10.0f;
static const CGFloat kMinPaddingBetweenFloatingLabelAndEditingText = (CGFloat)8.0;
static const CGFloat kMaxPaddingBetweenFloatingLabelAndEditingText = (CGFloat)12.0;
static const CGFloat kMinPaddingAroundAssistiveLabels = (CGFloat)3.0;
static const CGFloat kMaxPaddingAroundAssistiveLabels = (CGFloat)6.0;

@interface MDCTextControlVerticalPositioningReferenceOutlined ()
@property(nonatomic, assign) CGFloat paddingAroundAssistiveLabels;
@end

/**
  For slightly more context on what this class is doing look at
  MDCTextControlVerticalPositioningReferenceBase. It's very similar and has some comments. Maybe at
  some point all the positioning references should be refactored to share a superclass, because
  there's currently a lot of duplicated code among the three of them.
 */
@implementation MDCTextControlVerticalPositioningReferenceOutlined
@synthesize paddingBetweenContainerTopAndFloatingLabel =
    _paddingBetweenContainerTopAndFloatingLabel;
@synthesize paddingBetweenContainerTopAndNormalLabel = _paddingBetweenContainerTopAndNormalLabel;
@synthesize paddingBetweenFloatingLabelAndEditingText = _paddingBetweenFloatingLabelAndEditingText;
@synthesize paddingBetweenEditingTextAndContainerBottom =
    _paddingBetweenEditingTextAndContainerBottom;
@synthesize containerHeightWithFloatingLabel = _containerHeightWithFloatingLabel;
@synthesize containerHeightWithoutFloatingLabel = _containerHeightWithoutFloatingLabel;
@synthesize paddingAroundTextWhenNoFloatingLabel = _paddingAroundTextWhenNoFloatingLabel;

- (instancetype)initWithFloatingFontLineHeight:(CGFloat)floatingLabelHeight
                          normalFontLineHeight:(CGFloat)normalFontLineHeight
                                 textRowHeight:(CGFloat)textRowHeight
                              numberOfTextRows:(CGFloat)numberOfTextRows
                                       density:(CGFloat)density
                      preferredContainerHeight:(CGFloat)preferredContainerHeight {
  self = [super init];
  if (self) {
    [self calculatePaddingValuesWithFoatingFontLineHeight:floatingLabelHeight
                                     normalFontLineHeight:normalFontLineHeight
                                            textRowHeight:textRowHeight
                                         numberOfTextRows:numberOfTextRows
                                                  density:density
                                 preferredContainerHeight:preferredContainerHeight];
  }
  return self;
}

- (void)calculatePaddingValuesWithFoatingFontLineHeight:(CGFloat)floatingLabelHeight
                                   normalFontLineHeight:(CGFloat)normalFontLineHeight
                                          textRowHeight:(CGFloat)textRowHeight
                                       numberOfTextRows:(CGFloat)numberOfTextRows
                                                density:(CGFloat)density
                               preferredContainerHeight:(CGFloat)preferredContainerHeight {
  BOOL isMultiline = numberOfTextRows > 1 || numberOfTextRows == 0;
  CGFloat clampedDensity = MDCTextControlClampDensity(density);
  CGFloat halfOfFloatingLabelHeight = ((CGFloat)0.5 * floatingLabelHeight);

  _paddingBetweenContainerTopAndFloatingLabel = (CGFloat)0 - halfOfFloatingLabelHeight;

  _paddingBetweenFloatingLabelAndEditingText = MDCTextControlPaddingValueWithMinimumPadding(
      kMinPaddingBetweenFloatingLabelAndEditingText, kMaxPaddingBetweenFloatingLabelAndEditingText,
      clampedDensity);

  _paddingBetweenContainerTopAndNormalLabel =
      halfOfFloatingLabelHeight + _paddingBetweenFloatingLabelAndEditingText;
  _paddingBetweenEditingTextAndContainerBottom = _paddingBetweenContainerTopAndNormalLabel;

  _paddingAroundAssistiveLabels = MDCTextControlPaddingValueWithMinimumPadding(
      kMinPaddingAroundAssistiveLabels, kMaxPaddingAroundAssistiveLabels, clampedDensity);

  CGFloat containerHeightWithPaddingsDeterminedByDensity =
      MDCTextControlCalculateContainerHeightWithFloatingLabelHeight(
          floatingLabelHeight, textRowHeight, numberOfTextRows,
          _paddingBetweenContainerTopAndFloatingLabel, _paddingBetweenFloatingLabelAndEditingText,
          _paddingBetweenEditingTextAndContainerBottom);
  BOOL clientHasSpecifiedValidPreferredContainerHeight =
      preferredContainerHeight > containerHeightWithPaddingsDeterminedByDensity;
  if (clientHasSpecifiedValidPreferredContainerHeight && !isMultiline) {
    CGFloat difference = preferredContainerHeight - containerHeightWithPaddingsDeterminedByDensity;
    CGFloat sumOfPaddingValues = _paddingBetweenContainerTopAndFloatingLabel +
                                 _paddingBetweenFloatingLabelAndEditingText +
                                 _paddingBetweenEditingTextAndContainerBottom;
    _paddingBetweenContainerTopAndFloatingLabel =
        _paddingBetweenContainerTopAndFloatingLabel +
        ((_paddingBetweenContainerTopAndFloatingLabel / sumOfPaddingValues) * difference);
    _paddingBetweenFloatingLabelAndEditingText =
        _paddingBetweenFloatingLabelAndEditingText +
        ((_paddingBetweenFloatingLabelAndEditingText / sumOfPaddingValues) * difference);
    _paddingBetweenEditingTextAndContainerBottom =
        _paddingBetweenEditingTextAndContainerBottom +
        ((_paddingBetweenEditingTextAndContainerBottom / sumOfPaddingValues) * difference);
  }

  if (clientHasSpecifiedValidPreferredContainerHeight) {
    _containerHeightWithFloatingLabel = preferredContainerHeight;
  } else {
    _containerHeightWithFloatingLabel = containerHeightWithPaddingsDeterminedByDensity;
  }

  CGFloat halfOfNormalFontLineHeight = (CGFloat)0.5 * normalFontLineHeight;
  if (isMultiline) {
    CGFloat heightWithOneRow = MDCTextControlCalculateContainerHeightWithFloatingLabelHeight(
        floatingLabelHeight, textRowHeight, 1, _paddingBetweenContainerTopAndFloatingLabel,
        _paddingBetweenFloatingLabelAndEditingText, _paddingBetweenEditingTextAndContainerBottom);
    CGFloat halfOfHeightWithOneRow = (CGFloat)0.5 * heightWithOneRow;
    _paddingBetweenContainerTopAndNormalLabel = halfOfHeightWithOneRow - halfOfNormalFontLineHeight;
  } else {
    CGFloat halfOfContainerHeight = (CGFloat)0.5 * _containerHeightWithFloatingLabel;
    _paddingBetweenContainerTopAndNormalLabel = halfOfContainerHeight - halfOfNormalFontLineHeight;
  }

  _paddingAroundTextWhenNoFloatingLabel = MDCTextControlPaddingValueWithMinimumPadding(
      kMinPaddingAroundTextWhenNoLabel, kMaxPaddingAroundTextWhenNoLabel, clampedDensity);

  CGFloat containerHeightWhenNoFloatingLabelWithPaddingsDeterminedByDensity =
      MDCTextControlCalculateContainerHeightWhenNoFloatingLabelWithTextRowHeight(
          textRowHeight, numberOfTextRows, _paddingAroundTextWhenNoFloatingLabel);
  BOOL clientHasSpecifiedValidPreferredContainerHeightWhenNoFloatingLabel =
      preferredContainerHeight > containerHeightWhenNoFloatingLabelWithPaddingsDeterminedByDensity;
  if (clientHasSpecifiedValidPreferredContainerHeightWhenNoFloatingLabel && !isMultiline) {
    CGFloat difference = preferredContainerHeight - containerHeightWithPaddingsDeterminedByDensity;
    CGFloat sumOfPaddingValues = _paddingAroundTextWhenNoFloatingLabel * 2.0f;
    _paddingAroundTextWhenNoFloatingLabel =
        _paddingAroundTextWhenNoFloatingLabel +
        ((_paddingAroundTextWhenNoFloatingLabel / sumOfPaddingValues) * difference);
  }

  if (clientHasSpecifiedValidPreferredContainerHeightWhenNoFloatingLabel) {
    _containerHeightWithoutFloatingLabel = preferredContainerHeight;
  } else {
    _containerHeightWithoutFloatingLabel =
        containerHeightWhenNoFloatingLabelWithPaddingsDeterminedByDensity;
  }
}

- (CGFloat)paddingBetweenContainerTopAndFloatingLabel {
  return _paddingBetweenContainerTopAndFloatingLabel;
}

- (CGFloat)paddingBetweenContainerTopAndNormalLabel {
  return _paddingBetweenContainerTopAndNormalLabel;
}

- (CGFloat)paddingBetweenFloatingLabelAndEditingText {
  return _paddingBetweenFloatingLabelAndEditingText;
}

- (CGFloat)paddingBetweenEditingTextAndContainerBottom {
  return _paddingBetweenEditingTextAndContainerBottom;
}

- (CGFloat)paddingAboveAssistiveLabels {
  return self.paddingAroundAssistiveLabels;
}

- (CGFloat)paddingBelowAssistiveLabels {
  return self.paddingAroundAssistiveLabels;
}

- (CGFloat)containerHeightWithFloatingLabel {
  return _containerHeightWithFloatingLabel;
}

- (CGFloat)containerHeightWithoutFloatingLabel {
  return _containerHeightWithoutFloatingLabel;
}

- (CGFloat)paddingAroundTextWhenNoFloatingLabel {
  return _paddingAroundTextWhenNoFloatingLabel;
}

@end
