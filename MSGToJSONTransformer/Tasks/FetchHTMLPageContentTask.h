//
//  FetchHTMLPageContentTask.h
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 1/23/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "TaskProvider.h"

/**
 *  Given an NSURL the resultant task provides the html content in given endcoding format.
 *  It uses [NSURLSessionConfiguration defaultSessionConfiguration] as session configuration with its default value.
 *  Delegate queue is named as com.http.delegate.queue.
 *  TODO: currently it fetches the full content of the page. If it is just the title to get then there is no need
 *  to fetch it wholly. One thing can be done is to employ multipart content fetching and cancel on going connection
 *  if the related part of the page is loaded.
 *  <p>Issue: For iOS9+ the ATS needs to be set. In order to have any arbitrary url to work, NSAppTransportSecurity key needs to be set in info.plist.
 *  more details can be found here https://developer.apple.com/library/prerelease/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW33.
 *  </p>
 */
@interface FetchHTMLPageContentTask: NSObject<TaskProvider>

/**
 *  NSData to NSString encoding format. Default is NSASCIIStringEncoding
 */
@property(readwrite) NSStringEncoding encoding;

/**
 *
 *  @param url an NSURL
 *
 */
-(instancetype)initWithURL:(NSURL*)url;
@end
