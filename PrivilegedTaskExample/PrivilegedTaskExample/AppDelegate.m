/*
   Copyright (C) 2008-2021 Sveinbjorn Thordarson <sveinbjorn@sveinbjorn.org>
   
   BSD License
   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:
       * Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
       * Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
       * Neither the name of the copyright holder nor that of any other
       contributors may be used to endorse or promote products
       derived from this software without specific prior written permission.
   
   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
   WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
   DISCLAIMED. IN NO EVENT SHALL  BE LIABLE FOR ANY
   DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
   (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
   ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import "AppDelegate.h"
#import "STPrivilegedTask.h"

@implementation AppDelegate

- (BOOL)isValidShellCommand:(NSString *)cmd {
    NSArray *cmp = [cmd componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    if ([[NSFileManager defaultManager] isExecutableFileAtPath:cmp[0]] ) {
        return YES;
    }
    
    return NO;
}

- (IBAction)runNSTask:(id)sender {
    NSString *cmd = [self.commandTextField stringValue];
    
    if ([self isValidShellCommand:cmd] == NO) {
        NSBeep();
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Invalid shell command"];
        [alert setInformativeText:@"Command must start with path to executable file"];
        [alert runModal];
        return;
    }
    
    NSTask *task = [[NSTask alloc] init];
    
    NSMutableArray *components = [[cmd componentsSeparatedByCharactersInSet:
                       [NSCharacterSet whitespaceCharacterSet]] mutableCopy];
    
    task.launchPath = components[0];
    [components removeObjectAtIndex:0];
    task.arguments = components;
    task.currentDirectoryPath = [[NSBundle  mainBundle] resourcePath];
    
    NSPipe *outputPipe = [NSPipe pipe];
    [task setStandardOutput:outputPipe];
    [task setStandardError:outputPipe];
    NSFileHandle *readHandle = [outputPipe fileHandleForReading];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *outputData = [readHandle readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    [self.outputTextField setString:outputString];
    
    NSString *exitStr = [NSString stringWithFormat:@"Exit status: %d", task.terminationStatus];
    [self.exitStatusTextField setStringValue:exitStr];
}

- (IBAction)runSTPrivilegedTask:(id)sender {
    NSString *cmd = [self.commandTextField stringValue];
    if ([self isValidShellCommand:cmd] == NO) {
        NSBeep();
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Invalid shell command"];
        [alert setInformativeText:@"Command must start with path to executable file"];
        [alert runModal];
        return;
    }
    
    STPrivilegedTask *privilegedTask = [[STPrivilegedTask alloc] init];
    
    NSMutableArray *components = [[[self.commandTextField stringValue] componentsSeparatedByString:@" "] mutableCopy];
    NSString *launchPath = components[0];
    [components removeObjectAtIndex:0];
    
    [privilegedTask setLaunchPath:launchPath];
    [privilegedTask setArguments:components];
    [privilegedTask setCurrentDirectoryPath:[[NSBundle mainBundle] resourcePath]];
    
    // Set it off
    OSStatus err = [privilegedTask launch];
    if (err != errAuthorizationSuccess) {
        if (err == errAuthorizationCanceled) {
            NSLog(@"User cancelled");
            return;
        }  else {
            NSLog(@"Something went wrong: %d", (int)err);
            // For error codes, see http://www.opensource.apple.com/source/libsecurity_authorization/libsecurity_authorization-36329/lib/Authorization.h
        }
    }
    
    [privilegedTask waitUntilExit];
    
    // Success! Now, read the output file handle for data
    NSFileHandle *readHandle = [privilegedTask outputFileHandle];
    NSData *outputData = [readHandle readDataToEndOfFile]; // Blocking call
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    [self.outputTextField setString:outputString];
    
    NSString *exitStr = [NSString stringWithFormat:@"Exit status: %d", privilegedTask.terminationStatus];
    [self.exitStatusTextField setStringValue:exitStr];
}

@end
