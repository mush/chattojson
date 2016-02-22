//
//  FetchHTMLPageTitleTask.h
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 1/21/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "TaskProvider.h"

#import "ParsedHTMLObject.h"

static NSString *kTitleParseError = @"com.parsehtmlpagetask.titleparseerror";
static const NSInteger kTitleParseErrorCode = 30000;
/**
 Given a valid html content in text this task parse the text and provides the title of the page as ParsedHTMLObject.
 Internally it uses NSScanner with default configuration to parse title. It also trims the whitespace characters
 from start and end of the parsed title. If there is any parsing error it sets the task's error.
 
 */
@interface ParseHTMLPageTask : NSObject<TaskProvider>
/**
 *  Constructor taking html content.
 *
 *  @param content html content in NSString.
 *
 */
-(instancetype)initWithHTMLPageContent:(NSString*)content;
@end
