//
//  SpeechPlugin.m
//  ATTiOSPhonegapPlugin
//
//  Created by Saurav Nagpal on 10/23/12.
//  Copyright (c) 2012 Saurav Nagpal. All rights reserved.
//

#import "SpeechPlugin.h"

@implementation SpeechPlugin

- (id) initWithDelegate:(id)delegate
{
    self = [super init];
    _delegate = delegate;
    return self;
}

- (void) dealloc
{
    _delegate = nil;
    [super dealloc];
}

-(void) speechToTextWithArgument:(NSMutableDictionary*)options
{
    //.................Intiliaze Local variables......................./
    const NSDictionary* audioRequestparameter = options;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    ///.....................................///

    NSString *file2 = [NSString stringWithFormat:@"%@",[audioRequestparameter valueForKey:@"filePath"]];
    NSString *fileName=[[[[file2 componentsSeparatedByString:@"/"] lastObject] componentsSeparatedByString:@"."] objectAtIndex:0];
    NSString *contentType = [NSString stringWithFormat:@"%@",[audioRequestparameter valueForKey:@"contentType"]];
    NSString *typeAudio=[[contentType componentsSeparatedByString:@"/"] lastObject];
    
    NSLog(@"typeAudio %@",typeAudio);
    NSString *file = nil;
    for (id bundle in [NSBundle allBundles]) {
        file = [bundle pathForResource:fileName ofType:typeAudio];
        if (file) {
            break;
        }
    }
    if (!file) {
        file = [[NSBundle bundleWithPath:file2] pathForResource:fileName ofType:typeAudio];
    }
    // NSString *file = [[NSBundle mainBundle] pathForResource:fileName ofType:typeAudio];
    NSData *fileData = nil;
    if (file) {
        fileData = [[[NSData alloc] initWithContentsOfFile:file] autorelease];
    }else {
        fileData = [[[NSData alloc] initWithContentsOfFile:file2] autorelease];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@",[audioRequestparameter valueForKey:@"url"]];
    [request setURL:[NSURL URLWithString:url]];
    
    [request setHTTPMethod:@"POST"];
    
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSString *token = [NSString stringWithFormat:@"%@",[audioRequestparameter valueForKey:@"token"]];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    
    NSString *accept = [NSString stringWithFormat:@"%@",[audioRequestparameter valueForKey:@"accept"]];
    if(accept != @"")
    {
        [request setValue:accept forHTTPHeaderField:@"Accept"];
        
    }
    NSString *transferEncoding = [audioRequestparameter valueForKey:@"transferEncoding]"];
    if(transferEncoding != @"")
    {
        [request setValue:transferEncoding forHTTPHeaderField:@"Transfer-Encoding"];
    }
    NSString *XSpeechContext = [NSString stringWithFormat:@"%@",[audioRequestparameter valueForKey:@"XSpeechContext"]];
    if(XSpeechContext != @"")
    {
        [request setValue:XSpeechContext forHTTPHeaderField:@"X-SpeechContext"];
    }
    NSString *contentLength = [NSString stringWithFormat:@"%@",[audioRequestparameter valueForKey:@"contentLength"]];
    if(contentLength !=@"")
    {
        [request setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    }
    
    
    if([XSpeechContext isEqualToString: @"Generic"]){
        
        NSString *contentLanguage = [NSString stringWithFormat:@"%@",[audioRequestparameter valueForKey:@"contentLanguage"]];
        if(contentLanguage != @""){
            [request setValue:contentLanguage forHTTPHeaderField:@"Content-Language"];
        }
    }else{
        NSString *xarg = [NSString stringWithFormat:@"%@",[audioRequestparameter valueForKey:@"xarg"]];
        if(xarg != @""){
            [request setValue:xarg forHTTPHeaderField:@"X-Arg"];
        }
    }
    
    [request setHTTPBody:fileData];
    ATTPluginHTTPRequest* httpRequest = [[ATTPluginHTTPRequest alloc] initRequest:request withDelegate:self];
    [httpRequest autorelease];
    _ReleaseObj(request);
    
}

#pragma mark -
#pragma mark HTTP Delegate
- (void) httpRequest:(ATTPluginHTTPRequest*)request didCompleteRequestWithData:(NSData*)data
{
    if([_delegate respondsToSelector:@selector(pluginFeature:didCompleteRequestWithData:forRequest:)])
        [_delegate pluginFeature:self didCompleteRequestWithData:data forRequest:ATT_SPEECH_TEXT_REQUEST];
}

- (void) httpRequest:(ATTPluginHTTPRequest*)request didFailWithError:(NSError*)error
{
    _sendErrorMessageToDelegate(_delegate,errorMessage,ATT_SPEECH_TEXT_REQUEST);
}

@end
