//
//  TransmitDataHandler.m
//  ShareWithFriends
//
//  Created by Niels van Rooij on 14-08-09.
//

#import "TransmitDataHandler.h"
#import "TransmitDataHandlerUtility.h"
#import "SendReceiveLogger.h"

#define TM_REQUESTING_PERMISSION_TO_SEND @"SEND"
#define TM_ACCEPT_CONTACT @"ACPT"
#define TM_REJECT_CONTACT @"RJCT"
#define TM_INFO_SIZE @"SIZE"
#define TM_ACKNOWLEDGE @"ACKN"
#define TM_DATA @"DATA"
#define TM_NEXT @"NEXT"
#define TM_DONE @"DONE"
#define TM_SUCCESS @"SUCS"
#define TM_BUSY @"BUSY"
#define TM_ERROR @"ERRO"
#define TM_CANCEL @"CNCL"

// Needs to be cleaned up by typedef
#define PROCESSING_TAG 0
#define CONFIRMATION_RETRY_TAG 1
#define CONFIRMATION_RECEIVE_TAG 2

// Sounds
#define ERROR_SOUND_FILE_NAME "flute-squeak"
#define RECEIVED_SOUND_FILE_NAME "cheesy-chimes"
#define REQUEST_SOUND_FILE_NAME "cork"
#define SEND_SOUND_FILE_NAME "belltree"


#define kMaxPackageSize 4092
#define CONNECTION_TIMEOUT 30

typedef enum  {
	CTBusy = 0,
	CTError = 1,
	CTAcknowledge = 2,
	CTNext = 3,
	CTSuccess = 4,
	CTAccept = 5,
	CTReject = 6,
	CTRequest = 7,
	CTCancel = 8,
	CTSize = 9,
	CTRealData = 10,
	CTDone = 11
} sendCommandType;

@interface TransmitDataHandler ()
- (void)handleReceivingData:(NSData *)data;
- (void)handleSendingData:(NSData *)data;

// Helpers
- (void)updateLastCommandReceived:(NSString *)command;

// send methods
- (void)sendCommand:(sendCommandType)type toDevice:(Device *)device;

// Error & message dialogs
- (void)showMessageWithTitle:(NSString *)title message:(NSString *)msg;
- (void)throwError:(NSString *)message;
- (void)throwUnexpectedCommandError;
- (void)promptConfirmationWithTag:(int)tag title:(NSString *)title message:(NSString *)msg;
- (void)showProcess:(NSString *)message;
- (void)showProcess:(NSString *)message withBar:(BOOL)showBar withProgress:(float)p;
- (void)closeCurrentPopup;

// Cleaning
- (void) cleanCurrentState;

// Connecting
- (void)deviceConnected;
- (void)deviceConnectionFailed;
- (void)deviceConnectionDisconnected;

// Getter
- (TransmitObjects*) getTransmitObjects;

// Sounds
- (void)loadSounds;
- (void)disposeSounds;
@end

@implementation TransmitDataHandler
@synthesize delegate;

- (TransmitObjects*) getTransmitObjects{
	return _tmObjects;
}

#pragma mark -
#pragma mark Public methods
- (void)sendTransmitObjects:(TransmitObjects *)objects toDevice:(Device *)device{
	if (_currentState == TMDHSNone){
		// Sets the DataHandler to occupied
		_currentState = TMDHSSending;
		_currentStateRelatedDevice = [device retain];
		_cancelled = NO;
		_cancelledByHost = NO;
		_bytesSend = 0;
		
		_tmObjects = [objects retain];
		_dataToSend = [[NSKeyedArchiver archivedDataWithRootObject:_tmObjects] retain];
		[self showProcess:[NSString stringWithFormat:NSLocalizedString(@"TransmitDataHandler_WAITING_FOR_ACCEPTANCE_PROCESS", @"TransmitDataHandler_WAITING_FOR_ACCEPTANCE_PROCESS"), _currentStateRelatedDevice.deviceName]];
		
		if (![_currentStateRelatedDevice isConnected])
			//[_currentStateRelatedDevice connectAndReplyTo:self selector:@selector(deviceConnected) errorSelector:@selector(deviceConnectionFailed)];
			[_currentStateRelatedDevice connectAndReplyTo:self selector:@selector(deviceConnected) errorSelector:@selector(deviceConnectionFailed) disconnectSelector:@selector(deviceConnectionDisconnected)];
		else
			[self deviceConnected];		
	} else{
		[self throwError:NSLocalizedString(@"TransmitDataHandler_SEND_BUSY_ERROR", @"TransmitDataHandler_SEND_BUSY_ERROR")];
	}
}

- (void)deviceConnected {
	[self sendCommand:CTRequest toDevice:nil];
}

- (void)deviceConnectionFailed {
	[self throwError:[NSString stringWithFormat:NSLocalizedString(@"TransmitDataHandler_CONNECTION_ERROR", "TransmitDataHandler_CONNECTION_ERROR"), _currentStateRelatedDevice.deviceName]];
}

- (void)deviceConnectionDisconnected {
	if (!(_currentState==TMDHSNone))
		[self throwError:[NSString stringWithFormat:NSLocalizedString(@"TransmitDataHandler_CONNECTION_ERROR", "TransmitDataHandler_CONNECTION_ERROR"), _currentStateRelatedDevice.deviceName]];
}


#pragma mark -
#pragma mark Initializer
- (id)initWithDevicesManager:(DevicesManager *)devicesManager andMainViewController:(UIViewController *)viewController;{
	if (self = [super init]){
		_currentState = TMDHSNone;
		_devicesManager = devicesManager;
		_cancelled = NO;
		_mainViewController = viewController;
		connectionTimedOut = nil;
		[self loadSounds];
	}
	return self;
}

#pragma mark -
#pragma mark Helpers

- (void)updateLastCommandReceived:(NSString *)command {
	if (_lastCommandReceived)
		[_lastCommandReceived release];
	_lastCommandReceived = [command copy];
}

#pragma mark -
#pragma mark DataHandlerProtocol
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
	// Caller whenever data is received from the session	
	Device *device = [_devicesManager deviceWithID:peer];
	if (device) {
		// Checks if it's busy, otherwise call other handler methods
		switch (_currentState) {
			case TMDHSNone:
				if ([[TDHUHelper getCommandFromMessage:data] isEqual:TM_REQUESTING_PERMISSION_TO_SEND]) {
					_currentState = TMDHSReceiving;
					_currentStateRelatedDevice = [device retain];				
					[self handleReceivingData:data];
				}
				break;
			case TMDHSReceiving:
				if (![_currentStateRelatedDevice isEqual:device] || [[TDHUHelper getCommandFromMessage:data] isEqual:TM_REQUESTING_PERMISSION_TO_SEND]) {
					[self sendCommand:CTBusy toDevice:device];
				} else if(!_cancelled){
					if(connectionTimedOut){
						[connectionTimedOut invalidate];
						connectionTimedOut = nil;
					}
						
					[self handleReceivingData:data];
				}					
				break;
			case TMDHSSending:
				if (![_currentStateRelatedDevice isEqual:device] || [[TDHUHelper getCommandFromMessage:data] isEqual:TM_REQUESTING_PERMISSION_TO_SEND]) {
					[self sendCommand:CTBusy toDevice:device];
				} else if(!_cancelled){
					if(connectionTimedOut){
						[connectionTimedOut invalidate];
						connectionTimedOut = nil;
					}
					[self handleSendingData:data];
				}
				break;
			default:
				break;
		}	
	}		
		
}

#pragma mark -
#pragma mark Sending and Receiving handlers
- (void)handleReceivingData:(NSData *)data {
	NSString *command = [TDHUHelper getCommandFromMessage:data];
	
	// First, check for specific error situations
	if (!command) {[self throwError:NSLocalizedString(@"TransmitDataHandler_RECEIVED_UNRECOGNIGZED_COMMAND", @"TransmitDataHandler_RECEIVED_UNRECOGNIGZED_COMMAND")];
	} else if ([command isEqual:TM_ERROR]) {
		[self throwError:NSLocalizedString(@"TransmitDataHandler_RECEIVED_ERROR_ERROR", @"TransmitDataHandler_RECEIVED_ERROR_ERROR")];
	} else if ([command isEqual:TM_CANCEL]) {
		_cancelled = YES;
		_cancelledByHost = YES;
		if(_lastCommandReceived)
			[self throwError:NSLocalizedString(@"TransmitDataHandler_PEER_CANCELLED_ERROR", @"TransmitDataHandler_PEER_CANCELLED_ERROR")];
	} else if ([command isEqual:TM_BUSY]) {[self throwError:[NSString stringWithFormat:NSLocalizedString(@"TransmitDataHandler_RECEIVED_BUSY_ERROR", @"TransmitDataHandler_RECEIVED_BUSY_ERROR"), _currentStateRelatedDevice.deviceName]];
	} else {
		// If it's not an error, then let's check the command and compare it to the last command received to check if the command is expected
		if (!_lastCommandReceived) {
			if (![command isEqual:TM_REQUESTING_PERMISSION_TO_SEND]) {
				if(!_cancelled){					
					[self sendCommand:CTError toDevice:nil];
					[self throwUnexpectedCommandError];
				}
			} else {
				// Prompt the user whether to receive the contact or not
				_currentStateRelatedReceiveTitle = [[TDHUHelper getValueFromMessage:data] retain];
				AudioServicesPlayAlertSound(requestSound);
				[self promptConfirmationWithTag:CONFIRMATION_RECEIVE_TAG 
										  title:NSLocalizedString(@"TransmitDataHandler_RECEIVE_VIEW_TITLE", @"TransmitDataHandler_RECEIVE_VIEW_TITLE")
										message:[NSString stringWithFormat:NSLocalizedString(@"TransmitDataHandler_RECEIVE_VIEW_MESSAGE", @"TransmitDataHandler_RECEIVE_VIEW_MESSAGE"),
												 _currentStateRelatedDevice.deviceName, _currentStateRelatedReceiveTitle]];				
				[self updateLastCommandReceived:command];
			}
		} else if ([_lastCommandReceived isEqual:TM_REQUESTING_PERMISSION_TO_SEND]) {
			if (![command isEqual:TM_INFO_SIZE]) {
				[self sendCommand:CTError toDevice:nil];
				[self throwUnexpectedCommandError];
			} else {
				_bytesToReceive = [[TDHUHelper getValueFromMessage:data] intValue];
				[self sendCommand:CTAcknowledge toDevice:nil];				
				[self updateLastCommandReceived:command];
			}
		} else if ([_lastCommandReceived isEqual:TM_INFO_SIZE]) {
			if(![command isEqual:TM_DATA]){
				[self sendCommand:CTError toDevice:nil];
				[self throwError:[NSString stringWithFormat:NSLocalizedString(@"TransmitDataHandler_RECEPTION_ERROR", @"TransmitDataHandler_RECEPTION_ERROR"), _currentStateRelatedDevice.deviceName]];				
			}else{
				if(!_dataReceived)
					_dataReceived = [[NSMutableData dataWithCapacity:0] retain];
				[_dataReceived appendData:[TDHUHelper getDataFromMessage:data]];
				[self sendCommand:CTNext toDevice:nil];
				[self updateLastCommandReceived:command];
			}
		} else if([_lastCommandReceived isEqual:TM_DATA]){
			if([command isEqual:TM_DONE]){
				if (_dataReceived && (_bytesToReceive == [_dataReceived length])) {
					// Receive the real data (eg. contact) and tell the provider to store it
					_tmObjects = [[NSKeyedUnarchiver unarchiveObjectWithData:_dataReceived] retain];
					
					if (_tmObjects) {
//						AudioServicesPlaySystemSound(receivedSound);
						[self sendCommand:CTSuccess toDevice:nil];
						[[SendReceiveLogger sharedSendReceiveLogger] writeReceptionToLog:_tmObjects.title fromDevice:_currentStateRelatedDevice wasSuccesful:YES];
						if (delegate && [delegate respondsToSelector:@selector(handleReceivedData)])
							[delegate performSelector:@selector(handleReceivedData)];
						[self cleanCurrentState];
					} else {
						[self sendCommand:CTError toDevice:nil];
						[self throwError:[NSString stringWithFormat:NSLocalizedString(@"TransmitDataHandler_RECEPTION_ERROR", @"TransmitDataHandler_RECEPTION_ERROR"), _currentStateRelatedDevice.deviceName]];
					}
				}				
			} else if ([command isEqual:TM_DATA]){
				[_dataReceived appendData:[TDHUHelper getDataFromMessage:data]];
				[self sendCommand:CTNext toDevice:nil];
				[self updateLastCommandReceived:command];				
			} else {
				[self sendCommand:CTError toDevice:nil];
				[self throwUnexpectedCommandError];				
			}			
		}
	}
}
- (void)handleSendingData:(NSData *)data {
	NSString *command = [TDHUHelper getCommandFromMessage:data];
	
	// First, check for specific error situations
	if (!command) {[self throwError:NSLocalizedString(@"TransmitDataHandler_RECEIVED_UNRECOGNIGZED_COMMAND", @"TransmitDataHandler_RECEIVED_UNRECOGNIGZED_COMMAND")];
	} else if ([command isEqual:TM_ERROR]) {[self throwError:NSLocalizedString(@"TransmitDataHandler_RECEIVED_ERROR_ERROR", @"TransmitDataHandler_RECEIVED_ERROR_ERROR")];
	} else if ([command isEqual:TM_CANCEL]) {
		_cancelled = YES;
		_cancelledByHost = YES;
		[self throwError:[NSString stringWithFormat:NSLocalizedString(@"TransmitDataHandler_PEER_CANCELLED_ERROR", @"TransmitDataHandler_PEER_CANCELLED_ERROR"), _currentStateRelatedDevice.deviceName]];
	} else if ([command isEqual:TM_BUSY]) {	[self throwError:[NSString stringWithFormat:NSLocalizedString(@"TransmitDataHandler_RECEIVED_BUSY_ERROR", @"TransmitDataHandler_RECEIVED_BUSY_ERROR"), _currentStateRelatedDevice.deviceName]];
	} else {
		// If it's not an error, then let's check the command and compare it to the last command received to check if the command is expected
		if (!_lastCommandReceived) {
			if ([command isEqual:TM_ACCEPT_CONTACT]) {
				[self sendCommand:CTSize toDevice:nil];
				[self updateLastCommandReceived:command];
			} else if ([command isEqual:TM_REJECT_CONTACT]) {
				// Prompt the user whether to retry to send or not
				AudioServicesPlayAlertSound(requestSound);
				[self promptConfirmationWithTag:CONFIRMATION_RETRY_TAG 
										  title:NSLocalizedString(@"TransmitDataHandler_RETRY_VIEW_TITLE", @"TransmitDataHandler_RETRY_VIEW_TITLE")
										message:[NSString stringWithFormat:NSLocalizedString(@"TransmitDataHandler_RETRY_VIEW_MESSAGE", @"TransmitDataHandler_RETRY_VIEW_MESSAGE"),
												 _tmObjects.title, _currentStateRelatedDevice.deviceName]];
			} else {
				[self sendCommand:CTError toDevice:nil];
				[self throwUnexpectedCommandError];
			}
		} else if ([_lastCommandReceived isEqual:TM_ACCEPT_CONTACT]) {
			if(![command isEqual:TM_ACKNOWLEDGE]){
				[self sendCommand:CTError toDevice:nil];
				[self throwUnexpectedCommandError];				
			} else {
				[self sendCommand:CTRealData toDevice:nil];
				[self updateLastCommandReceived:command];
			}
		} else if ([_lastCommandReceived isEqual:TM_ACKNOWLEDGE]) {
			if(![command isEqual:TM_NEXT]){ 
				[self sendCommand:CTError toDevice:nil];
				[self throwUnexpectedCommandError];				
			} else {
				if (_bytesSend == [_dataToSend length]){
					[self sendCommand:CTDone toDevice:nil];
					[self updateLastCommandReceived:command];				   
				}else
					[self sendCommand:CTRealData toDevice:nil];
			}				   	
		} else if ([_lastCommandReceived isEqual:TM_NEXT]) {
			if (![command isEqual:TM_SUCCESS]) {
				[self sendCommand:CTError toDevice:nil];
				[self throwUnexpectedCommandError];
			} else {
//				AudioServicesPlaySystemSound(sendSound);
				[[SendReceiveLogger sharedSendReceiveLogger] writeTransmissionToLog:_tmObjects.title fromDevice:_currentStateRelatedDevice wasSuccesful:YES];
				[self cleanCurrentState];
			}
		} else {
			[self sendCommand:CTError toDevice:nil];
			[self throwUnexpectedCommandError];
		}
	}	
}

#pragma mark -
#pragma mark Send methods

- (void)sendCommand:(sendCommandType)type toDevice:(Device*)device{
	NSString *strToSend;
	NSError *error;
	BOOL succes = YES;
	switch (type) {
			// Busy
		case CTBusy:
			if(device){
				if(!(succes = [device sendData:[TDHUHelper getDataFromString:TM_BUSY] error:&error]))
					NSLog(@"%@",[error localizedDescription]);
			}			
			break;
			// Error
		case CTError:
			if (_currentStateRelatedDevice && [_currentStateRelatedDevice isConnected])
				succes = [_currentStateRelatedDevice sendData:[TDHUHelper dataFromString:TM_ERROR] error:&error];	
			break;
		case CTAcknowledge:
			if (_currentStateRelatedDevice && [_currentStateRelatedDevice isConnected])
				[self showProcess:[NSString stringWithFormat:NSLocalizedString(@"TransmitDataHandler_RECEIVING_PROCESS", @"TransmitDataHandler_RECEIVING_PROCESS"), _currentStateRelatedReceiveTitle]];
			succes = [_currentStateRelatedDevice sendData:[TDHUHelper dataFromString:TM_ACKNOWLEDGE] error:&error];
			break;
		case CTNext:
			if (_currentStateRelatedDevice && [_currentStateRelatedDevice isConnected])
				succes = [_currentStateRelatedDevice sendData:[TDHUHelper dataFromString:TM_NEXT] error:&error];
			break;
		case CTSuccess:
			if (_currentStateRelatedDevice && [_currentStateRelatedDevice isConnected])
				succes = [_currentStateRelatedDevice sendData:[TDHUHelper dataFromString:TM_SUCCESS] error:&error];
			break;
		case CTAccept:
			if (_currentStateRelatedDevice && [_currentStateRelatedDevice isConnected])
				succes = [_currentStateRelatedDevice sendData:[TDHUHelper dataFromString:TM_ACCEPT_CONTACT] error:&error];
			break;
		case CTReject:
			if (_currentStateRelatedDevice && [_currentStateRelatedDevice isConnected])
				succes = [_currentStateRelatedDevice sendData:[TDHUHelper dataFromString:TM_REJECT_CONTACT] error:&error];
			break;
		case CTRequest:
			strToSend = [NSString stringWithFormat:@"%@%@", TM_REQUESTING_PERMISSION_TO_SEND, _tmObjects.title];
			if (_currentStateRelatedDevice && [_currentStateRelatedDevice isConnected])
				succes = [_currentStateRelatedDevice sendData:[TDHUHelper dataFromString:strToSend] error:&error];			
			break;
		case CTCancel:
			if (_currentStateRelatedDevice && [_currentStateRelatedDevice isConnected])
				succes = [_currentStateRelatedDevice sendData:[TDHUHelper dataFromString:TM_CANCEL] error:&error];
			break;
		case CTSize:
			if (_currentStateRelatedDevice && [_currentStateRelatedDevice isConnected])
				succes = [_currentStateRelatedDevice sendData:[TDHUHelper dataFromString:[NSString stringWithFormat:@"%@%d", TM_INFO_SIZE, [_dataToSend length]]] error:nil];
			break;
		case CTRealData:{
			if(_bytesSend ==0)
				[self showProcess:[NSString stringWithFormat:NSLocalizedString(@"TransmitDataHandler_SENDING_PROCESS", @"TransmitDataHandler_SENDING_PROCESS"),_tmObjects.title] withBar:YES withProgress:0];
			int l = kMaxPackageSize;
			NSRange range;
			range.location = _bytesSend;
			if(_bytesSend+kMaxPackageSize > [_dataToSend length])
				l = [_dataToSend length] - _bytesSend;
			range.length = l;
			
			// Prepare Command
			NSString *cmd = [NSString stringWithString:TM_DATA];
			NSMutableData *pckg = [[NSMutableData alloc] initWithData:[TDHUHelper dataFromString:cmd]];
			[pckg appendData:[_dataToSend subdataWithRange:range]];
			if(!_cancelled && _currentStateRelatedDevice && [_currentStateRelatedDevice isConnected])
				succes = [_currentStateRelatedDevice sendData:pckg error:&error];
			[pckg release];
			_bytesSend += l;	
			
		}
		break;
		case CTDone:
			if (_currentStateRelatedDevice && [_currentStateRelatedDevice isConnected])
				succes = [_currentStateRelatedDevice sendData:[TDHUHelper dataFromString:TM_DONE] error:&error];			
			break;
		default:
			break;
	}
	
	if(!CTRequest)
		connectionTimedOut = [NSTimer scheduledTimerWithTimeInterval:CONNECTION_TIMEOUT target:self selector:@selector(connectionHasTimedOut:) userInfo:nil repeats:NO];
	

	if (!succes)
		[self throwError:[NSString stringWithFormat:NSLocalizedString(@"TransmitDataHandler_RECEPTION_ERROR", @"TransmitDataHandler_RECEPTION_ERROR"), _currentStateRelatedDevice.deviceName]];
}

#pragma mark -
#pragma mark Errors

- (void)throwError:(NSString *)message {
	[self closeCurrentPopup];
//	AudioServicesPlaySystemSound(errorSound);
	[self showMessageWithTitle:NSLocalizedString(@"TransmitDataHandler_ERROR_VIEW_TITLE", @"TransmitDataHandler_ERROR_VIEW_TITLE") message:message];
	[self cleanCurrentState];
}
- (void)throwUnexpectedCommandError {
	[self throwError:NSLocalizedString(@"TransmitDataHandler_UNEXPECTED_COMMAND_ERROR", @"TransmitDataHandler_UNEXPECTED_COMMAND_ERROR")];
}
- (void)promptConfirmationWithTag:(int)tag title:(NSString *)title message:(NSString *)msg {
	[self closeCurrentPopup];
	
	NSString *text = [NSString stringWithFormat:@"%@\n\n%@",title,msg];
	_currentPopUpSheetView = [[UIActionSheet alloc] initWithTitle:text
														delegate:self 
											   cancelButtonTitle:NSLocalizedString(@"General_NO", @"No")
										  destructiveButtonTitle:nil
											   otherButtonTitles:NSLocalizedString(@"General_YES", @"Yes"),nil];
	_currentPopUpSheetView.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	_currentPopUpSheetView.tag = tag;
	[_currentPopUpSheetView showInView:_mainViewController.view];
	
}
- (void)showMessageWithTitle:(NSString *)title message:(NSString *)msg {
	[self closeCurrentPopup];
	
	UIAlertView *confirmationView = [[UIAlertView alloc] initWithTitle:title
															   message:msg
															  delegate:nil
													 cancelButtonTitle:NSLocalizedString(@"General_OK", @"General_OK")
													 otherButtonTitles:nil];
	
	[confirmationView show];
	[confirmationView release];
}
- (void)showProcess:(NSString *)message{	
	[self closeCurrentPopup];
	_currentPopUpSheetView = [[UIActionSheet alloc] initWithTitle:[message stringByAppendingString:@"\n"]
														  delegate:self 
												cancelButtonTitle:NSLocalizedString(@"General_CANCEL",@"Cancel")
										   destructiveButtonTitle:nil
												otherButtonTitles:nil];
	_currentPopUpSheetView.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	_currentPopUpSheetView.tag = PROCESSING_TAG;

	[_currentPopUpSheetView showInView:_mainViewController.view];
}

- (void)showProcess:(NSString *)message withBar:(BOOL)showBar withProgress:(float)p{
	if(_bytesSend==0){
		[self closeCurrentPopup];
		if(showBar){		
			_progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(25, 40, 265, 20)];
			_progressView.progressViewStyle = UIProgressViewStyleBar;
			_progressView.progress = 0;
			timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateProgress:) userInfo:nil repeats:YES];
//			[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];

		}
		_currentPopUpSheetView = [[UIActionSheet alloc] initWithTitle:[message stringByAppendingString:(showBar)?@"\n\n":@"\n"]
															 delegate:self 
													cancelButtonTitle:NSLocalizedString(@"General_CANCEL",@"Cancel")
											   destructiveButtonTitle:nil
													otherButtonTitles:nil];
		_currentPopUpSheetView.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
		_currentPopUpSheetView.tag = PROCESSING_TAG;
		
		[_currentPopUpSheetView showInView:_mainViewController.view];
		if (showBar)
			[_currentPopUpSheetView addSubview:_progressView];
		
	} 
}
- (void)updateProgress:(NSTimer*)theTimer{
	NSUInteger _dataLength = [_dataToSend length];
	float _currentProgress = ((float)_bytesSend / (float)_dataLength) / (float)1;
	_progressView.progress = _currentProgress;
	[_progressView setNeedsDisplay];
}

- (void)closeCurrentPopup {		
	if (_currentPopUpSheetView) {
		[_currentPopUpSheetView dismissWithClickedButtonIndex:1 animated:YES];
		_currentPopUpSheetView.delegate = nil;
		[_currentPopUpSheetView release];
		_currentPopUpSheetView = nil;
	}
}

#pragma mark -
#pragma mark CleaningState
- (void)cleanCurrentState {
	if(connectionTimedOut){
		[connectionTimedOut invalidate];
		connectionTimedOut = nil;
	}
	switch (_currentState) {
		case TMDHSReceiving:
			if(_dataReceived){
				[_dataReceived release];
				_dataReceived = nil;
			}
			if (_currentStateRelatedReceiveTitle){
				[_currentStateRelatedReceiveTitle release];
				_currentStateRelatedReceiveTitle = nil;
			}
			if(_tmObjects){
				[_tmObjects release];
				_tmObjects = nil;
			}			
			
			if (_lastCommandReceived) {
				[_lastCommandReceived release];
				_lastCommandReceived = nil;
			}			
			break;
		case TMDHSSending:
			if(_dataToSend){
				[_dataToSend release];
				_dataToSend = nil;
			}
			if (_currentStateRelatedDevice) {
				[_currentStateRelatedDevice release];
			}
			if(timer && timer.isValid){
				[timer invalidate];
				timer = nil;
			}
			if(_progressView){
				[_progressView release];
				_progressView = nil;
			}
			if(_tmObjects){
				[_tmObjects release];
				_tmObjects = nil;
			}		
			if (_lastCommandReceived) {
				[_lastCommandReceived release];
				_lastCommandReceived = nil;
			}		
			
			break;
		default:
			// TDHMSNone
			// Do nothing
			break;
	}
		

	_currentState = TMDHSNone;

	_bytesToReceive = 0;
	_bytesSend = 0;
	[self closeCurrentPopup];	
}


#pragma mark -
#pragma mark UIActionSheetDelegate and UIAlertViewDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (actionSheet.tag == CONFIRMATION_RECEIVE_TAG) {
		if (buttonIndex == 0) { // YES
			_cancelled = NO;
			_cancelledByHost = NO;
			[self closeCurrentPopup];
			[self sendCommand:CTAccept toDevice:nil];
		} else { // NO
			[self closeCurrentPopup];
			[self sendCommand:CTReject toDevice:nil];
			[self cleanCurrentState];
		}
	} else if (actionSheet.tag == CONFIRMATION_RETRY_TAG) {
		if (buttonIndex == 0) { // YES
			[self closeCurrentPopup];
			[self sendCommand:CTRequest toDevice:nil];
		} else { // NO
			[self cleanCurrentState];
		}
	}else if (actionSheet.tag == PROCESSING_TAG) {
		// Clicked on CANCEL
		if (_currentStateRelatedDevice && [_currentStateRelatedDevice isConnected] && !_cancelledByHost){
			[self sendCommand:CTCancel toDevice:nil];
			_cancelled = YES;		
		}			
		[self closeCurrentPopup];	
		[self cleanCurrentState];
	}
}

#pragma mark -
#pragma mark ConnectionTimedOut
- (void)connectionHasTimedOut:(NSTimer*)theTimer{
	[self throwError:NSLocalizedString(@"TransmitDataHandler_UNEXPECTED_CONNECTION_TIMEDOUT", @"TransmitDataHandler_UNEXPECTED_CONNECTION_TIMEDOUT")];
}

#pragma mark -
#pragma mark Dealloc
- (void)dealloc{
	[self disposeSounds];
	[super dealloc];
}

#pragma mark -
#pragma mark Sounds
- (void)loadSounds {
	CFBundleRef mainBundle = CFBundleGetMainBundle();
	
//	CFURLRef errorURL = CFBundleCopyResourceURL(mainBundle, CFSTR(ERROR_SOUND_FILE_NAME), CFSTR("aiff"), NULL);
//	CFURLRef receivedURL = CFBundleCopyResourceURL(mainBundle, CFSTR(RECEIVED_SOUND_FILE_NAME), CFSTR("aiff"), NULL);
	CFURLRef requestURL = CFBundleCopyResourceURL(mainBundle, CFSTR(REQUEST_SOUND_FILE_NAME), CFSTR("aiff"), NULL);
//	CFURLRef sendURL = CFBundleCopyResourceURL(mainBundle, CFSTR(SEND_SOUND_FILE_NAME), CFSTR("aiff"), NULL);
	
//	AudioServicesCreateSystemSoundID(errorURL, &errorSound);
//	AudioServicesCreateSystemSoundID(receivedURL, &receivedSound);
	AudioServicesCreateSystemSoundID(requestURL, &requestSound);
//	AudioServicesCreateSystemSoundID(sendURL, &sendSound);
	
//	CFRelease(errorURL);
//	CFRelease(receivedURL);
	CFRelease(requestURL);
//	CFRelease(sendURL);
}
- (void)disposeSounds{
//	AudioServicesDisposeSystemSoundID(errorSound);
//	AudioServicesDisposeSystemSoundID(receivedSound);
	AudioServicesDisposeSystemSoundID(requestSound);
//	AudioServicesDisposeSystemSoundID(sendSound);
}

@end
