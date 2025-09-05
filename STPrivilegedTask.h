/*
    STPrivilegedTask - NSTask-like wrapper around AuthorizationExecuteWithPrivileges
    Copyright (C) 2008-2025 Sveinbjorn Thordarson <sveinbjorn@sveinbjorn.org>
    
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

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const STPrivilegedTaskDidTerminateNotification;

// Defines error value for when AuthorizationExecuteWithPrivileges no longer exists
// Rather than defining a new enum, we just create a global constant
extern const OSStatus errAuthorizationFnNoLongerExists;

@interface STPrivilegedTask : NSObject

/**
 The arguments to be passed to the launched task.
 */
@property (copy, nullable) NSArray<NSString *> *arguments;

/**
 The current working directory for the launched task.
 
 @warning This changes the current working directory for the entire process, not just the task.
 It is not thread-safe and can lead to unexpected behavior.
 */
@property (copy, nullable) NSString *currentDirectoryPath;

/**
 The path to the executable to be launched.
 */
@property (copy, nullable) NSString *launchPath;

/**
 A file handle for reading the output of the launched task.
 */
@property (readonly, strong, nullable) NSFileHandle *outputFileHandle;

/**
 A Boolean value indicating whether the task is currently running.
 */
@property (readonly) BOOL isRunning;

/**
 The process identifier of the launched task.
 
 @warning This is not a reliable way to get the process identifier.
 It is retrieved using a trick that may not work in all cases.
 */
@property (readonly) pid_t processIdentifier;

/**
 The termination status of the launched task.
 */
@property (readonly) int terminationStatus;

/**
 A block to be executed when the task terminates.
 */
@property (copy, nullable) void (^terminationHandler)(STPrivilegedTask *);

/**
 Checks if the underlying `AuthorizationExecuteWithPrivileges` function is available.
 
 @return `YES` if the function is available, `NO` otherwise.
 */
+ (BOOL)authorizationFunctionAvailable;

/**
 Initializes a new `STPrivilegedTask` with the specified launch path.
 
 @param path The path to the executable to be launched.
 @return An initialized `STPrivilegedTask` object.
 */
- (instancetype)initWithLaunchPath:(NSString *)path;

/**
 Initializes a new `STPrivilegedTask` with the specified launch path and arguments.
 
 @param path The path to the executable to be launched.
 @param args An array of strings representing the arguments to be passed to the task.
 @return An initialized `STPrivilegedTask` object.
 */
- (instancetype)initWithLaunchPath:(NSString *)path arguments:(nullable NSArray<NSString *> *)args;

/**
 Initializes a new `STPrivilegedTask` with the specified launch path, arguments, and current directory.
 
 @param path The path to the executable to be launched.
 @param args An array of strings representing the arguments to be passed to the task.
 @param cwd The current working directory for the task.
 @return An initialized `STPrivilegedTask` object.
 */
- (instancetype)initWithLaunchPath:(NSString *)path arguments:(nullable NSArray<NSString *> *)args currentDirectory:(nullable NSString *)cwd;

/**
 Creates and launches a new privileged task with the specified launch path.
 
 @param path The path to the executable to be launched.
 @return An `STPrivilegedTask` object for the launched task.
 */
+ (STPrivilegedTask *)launchedPrivilegedTaskWithLaunchPath:(NSString *)path;

/**
 Creates and launches a new privileged task with the specified launch path and arguments.
 
 @param path The path to the executable to be launched.
 @param args An array of strings representing the arguments to be passed to the task.
 @return An `STPrivilegedTask` object for the launched task.
 */
+ (STPrivilegedTask *)launchedPrivilegedTaskWithLaunchPath:(NSString *)path arguments:(nullable NSArray<NSString *> *)args;

/**
 Creates and launches a new privileged task with the specified launch path, arguments, and current directory.
 
 @param path The path to the executable to be launched.
 @param args An array of strings representing the arguments to be passed to the task.
 @param cwd The current working directory for the task.
 @return An `STPrivilegedTask` object for the launched task.
 */
+ (STPrivilegedTask *)launchedPrivilegedTaskWithLaunchPath:(NSString *)path arguments:(nullable NSArray<NSString *> *)args currentDirectory:(nullable NSString *)cwd;

/**
 Creates and launches a new privileged task with the specified launch path, arguments, current directory, and authorization.
 
 @param path The path to the executable to be launched.
 @param args An array of strings representing the arguments to be passed to the task.
 @param cwd The current working directory for the task.
 @param authorization An `AuthorizationRef` to use for the task.
 @return An `STPrivilegedTask` object for the launched task.
 */
+ (STPrivilegedTask *)launchedPrivilegedTaskWithLaunchPath:(NSString *)path arguments:(nullable NSArray<NSString *> *)args currentDirectory:(nullable NSString *)cwd authorization:(AuthorizationRef)authorization;

/**
 Launches the task.
 
 @return An `OSStatus` code indicating the result of the launch operation.
 */
- (OSStatus)launch;

/**
 Launches the task with the specified authorization.
 
 @param authorization An `AuthorizationRef` to use for the task.
 @return An `OSStatus` code indicating the result of the launch operation.
 */
- (OSStatus)launchWithAuthorization:(AuthorizationRef)authorization;

/**
 Waits until the task has completed.
 */
- (void)waitUntilExit;

@end

NS_ASSUME_NONNULL_END

