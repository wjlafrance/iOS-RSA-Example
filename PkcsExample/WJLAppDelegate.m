// Copyright (c) 2014, William LaFrance.
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//   * Redistributions of source code must retain the above copyright
//     notice, this list of conditions and the following disclaimer.
//   * Redistributions in binary form must reproduce the above copyright
//     notice, this list of conditions and the following disclaimer in the
//     documentation and/or other materials provided with the distribution.
//   * Neither the name of the copyright holder nor the
//     names of its contributors may be used to endorse or promote products
//     derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL COPYRIGHT HOLDER BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "WJLAppDelegate.h"
#import "WJLPkcsContext.h"
#import "NSData+DebugOutput.h"

@implementation WJLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    //

    WJLPkcsContext *client = [[WJLPkcsContext alloc] init];
    WJLPkcsContext *server = [[WJLPkcsContext alloc] init];

    // Client crafts a message
    NSString *clientPlainText = @"Hello";

    // Encrypt client's plaintext using server's public key
    NSData *clientCipherText = [client encrypt:[clientPlainText dataUsingEncoding:NSUTF8StringEncoding] forRecipient:server];
    NSLog(@"%@", [clientCipherText debugOutput]);

    // Server receives and decrypts client's message using server's private key
    NSString *serverDecrypted = [[NSString alloc] initWithData:[server decrypt:clientCipherText] encoding:NSUTF8StringEncoding];
    NSLog(@"%@", serverDecrypted);

    NSAssert([serverDecrypted isEqualToString:clientPlainText], @"Server's decrypted text must exactly match client's plaintext");

    // Server crafts a response
    NSString *serverPlaintext = [NSString stringWithFormat:@"Hello client! To prove I could decrypt your message, I'll repeat it for you:\n\n%@", serverDecrypted];

    // Encrypt server's plaintext with client's public key
    NSData *serverCipherText = [server encrypt:[serverPlaintext dataUsingEncoding:NSUTF8StringEncoding] forRecipient:client];
    NSLog(@"%@", [serverCipherText debugOutput]);

    NSString *clientDecrypted = [[NSString alloc] initWithData:[client decrypt:serverCipherText] encoding:NSUTF8StringEncoding];
    NSLog(@"%@", clientDecrypted);

    NSAssert([clientDecrypted isEqualToString:serverPlaintext], @"Client's decrypted text must exactly match server's plaintext");

    return YES;
}

@end
