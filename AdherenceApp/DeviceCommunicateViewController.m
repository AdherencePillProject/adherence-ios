

#import "DeviceCommunicateViewController.h"
#import "BLECommanderiOS/BLECommanderiOS.h"
#import <Parse/Parse.h>
#define kStreamMode 0
#define kCommandMode 1

@interface DeviceCommunicateViewController () <UITextFieldDelegate, BLECommanderDelegate>
@property (nonatomic, weak) IBOutlet UITextField *messageTextfield;
@property (nonatomic, weak) IBOutlet UITextView *logTextView;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segementControl;
@property (nonatomic, assign) BOOL lastWrittenConsoleTextWasResponseReceived;
@property (nonatomic, strong) NSString *returnLineString;
@property (nonatomic, assign) NSInteger selectedEndLineIndex;
@property (nonatomic, strong) NSMutableData *buffer;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation DeviceCommunicateViewController
int num; int currImageLength;
bool readingImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViewAppearance];
    num = 0;
    readingImage = false;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"lineEndKey"])
    {
        self.selectedEndLineIndex = [[defaults objectForKey:@"lineEndKey"]integerValue];
    }
    else
    {
        self.selectedEndLineIndex = 0;
    }
}

- (void)setupViewAppearance
{
    self.messageTextfield.placeholder = @"Enter a message...";
    [self consoleAppend:@"Mode changed to STREAM MODE\n" isIncomingFromDevice:false];
    
    [self setupButtons];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.segementControl.tintColor = [UIColor colorWithRed:240.0f/255.0f green:95.0f/255.0f blue:34.0f/255.0f alpha:1];
    
    //
    NSString *stringText = @"Disconnect";
    NSMutableAttributedString *titleAttributed = [[NSMutableAttributedString alloc] initWithString:stringText];
    [titleAttributed addAttribute:NSFontAttributeName
                            value:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]
                            range:NSMakeRange(0, [stringText length])];
    [titleAttributed addAttribute:NSForegroundColorAttributeName
                            value:[UIColor colorWithRed:255 green:0 blue:0 alpha:1]
                            range:NSMakeRange(0, [stringText length])];
    
    CGRect frame = CGRectMake(0, 0, 80, 24);
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setAttributedTitle:titleAttributed forState:UIControlStateNormal];
    button.alpha = 0.5;
    button.tintColor = [UIColor colorWithRed:255 green:0 blue:0 alpha:1];
    [button addTarget:self action:@selector(disconnectFromDevice) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 5;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor colorWithRed:255 green:0 blue:0 alpha:0.4].CGColor;
    UIBarButtonItem* disconnectButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    disconnectButton.tintColor = [UIColor lightGrayColor];
    
    self.navigationItem.leftBarButtonItem = disconnectButton;
    
    UIColor *color = [UIColor colorWithWhite:0.516 alpha:1.000];
    self.messageTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.messageTextfield.placeholder attributes:@{NSForegroundColorAttributeName: color}];
}

- (void)setupButtons
{
    if (self.segementControl.selectedSegmentIndex == kStreamMode)
    {
        UIImage *iconImage = [UIImage imageNamed:@"icon"];
        UIButton *aboutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        aboutButton.bounds = CGRectMake(0, 0, 34, 34);
        [aboutButton setContentMode:UIViewContentModeScaleAspectFit];
        [aboutButton setImage:iconImage forState:UIControlStateNormal];
        UIBarButtonItem *faceBtn = [[UIBarButtonItem alloc] initWithCustomView:aboutButton];
        
        UIImage *iconSettingsImage = [[UIImage imageNamed:@"icon_settings"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIButton *settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        settingsButton.tintColor = [UIColor blackColor];
        settingsButton.bounds = CGRectMake(0, 0, 30, 30);
        [settingsButton setContentMode:UIViewContentModeScaleAspectFit];
        [settingsButton setImage:iconSettingsImage forState:UIControlStateNormal];
        UIBarButtonItem *settingsBarButton = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
        
        self.navigationItem.rightBarButtonItems = @[faceBtn, settingsBarButton];
    }
    else
    {
        UIImage *iconImage = [UIImage imageNamed:@"icon"];
        UIButton *aboutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        aboutButton.bounds = CGRectMake(0, 0, 34, 34);
        [aboutButton setContentMode:UIViewContentModeScaleAspectFit];
        [aboutButton setImage:iconImage forState:UIControlStateNormal];
        UIBarButtonItem *faceBtn = [[UIBarButtonItem alloc] initWithCustomView:aboutButton];
        
        self.navigationItem.rightBarButtonItems = @[faceBtn];
    }
}

- (void)disconnectFromDevice
{
    //Disconnect from current device
    [self.mBleCommanderiOS disconnect];
    
    [self.navigationController popViewControllerAnimated:true];
}

//Adjust view size
- (void)keyboardFrameDidChange:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    
    CGRect beginFrameRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey]CGRectValue];
    CGRect endFrameRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (beginFrameRect.origin.y > endFrameRect.origin.y)
    {
        float keyboardSize = beginFrameRect.origin.y - endFrameRect.origin.y;
        [UIView animateWithDuration:0.35 delay:0.1 options:0 animations:^{
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - keyboardSize)];
        } completion:^(BOOL finished) {
            if(self.logTextView.text.length > 0 )
            {
                if (self.logTextView.contentSize.height  > self.logTextView.bounds.size.height)
                {
                    CGPoint bottomOffset = CGPointMake(0, self.logTextView.contentSize.height - self.logTextView.bounds.size.height);
                    [self.logTextView setContentOffset:bottomOffset animated:YES];
                }
            }
        }];
    }
    else
    {
        float keyboardSize = endFrameRect.origin.y - beginFrameRect.origin.y;
        [UIView animateWithDuration:0.1 delay:0 options:0 animations:^{
            [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height + keyboardSize)];
        } completion:^(BOOL finished) {
            if(self.logTextView.text.length > 0 )
            {
                if (self.logTextView.contentSize.height  > self.logTextView.bounds.size.height)
                {
                    CGPoint bottomOffset = CGPointMake(0, self.logTextView.contentSize.height - self.logTextView.bounds.size.height);
                    [self.logTextView setContentOffset:bottomOffset animated:YES];
                }
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.deviceName)
    {
        self.title = self.deviceName;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)getEndLineString:(NSInteger)index
{
    if (index == 0)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"lineEndKey"])
        {
            index = [[defaults objectForKey:@"lineEndKey"]integerValue];
        }
        else
        {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults synchronize];
        }
    }
    
    NSString *endLineString = @"";
    switch (index)
    {
        case 1: //CR
            endLineString = @"\r";
            break;
        case 2: //LF
            endLineString = @"\n";
            break;
        case 3: //CRLF
            endLineString = @"\r\n";
            break;
        case 4: //LFCR
            endLineString = @"\n\r";
            break;
        default:
            break;
    }
    
    return endLineString;
}

- (void)setMBleCommanderiOS:(BLECommanderiOS *)mBleCommanderiOS
{
    _mBleCommanderiOS = mBleCommanderiOS;
    self.mBleCommanderiOS.delegate = self;
    [self.mBleCommanderiOS writeBusMode:STREAM_MODE];
    if (![self.mBleCommanderiOS writeBusMode:STREAM_MODE])
    {
        NSLog(@"Failed to change mode to stream");
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.messageTextfield resignFirstResponder] ;
}

- (void)writeString:(NSString *)string
{
    NSString *stringToWrite;
    
    if (self.segementControl.selectedSegmentIndex == kCommandMode)
    {
        stringToWrite = [NSString stringWithFormat:@"%@\n\r", string];
    }
    else
    {
        NSString *endLineString = [self getEndLineString:self.selectedEndLineIndex];
        
        stringToWrite = [NSString stringWithFormat:@"%@%@", string, endLineString];
        [self appendOutgoingMessage:stringToWrite];
        self.messageTextfield.text = @"";
    }
    
    //    self.messageTextfield.enabled = FALSE;
    [self.mBleCommanderiOS writeString:stringToWrite];
}

- (IBAction)busModeButtonTouched:(UISegmentedControl *)sender
{
    UIColor *color = [UIColor colorWithWhite:0.516 alpha:1.000];
    self.messageTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.messageTextfield.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    
    self.messageTextfield.text = @"";
    self.logTextView.text = @"";
    switch (sender.selectedSegmentIndex)
    {
        case kStreamMode:
        {
            self.messageTextfield.placeholder = @"Enter a message...";
            if (![self.mBleCommanderiOS writeBusMode:STREAM_MODE])
            {
                NSLog(@"Failed to change mode to stream");
                [self.segementControl setSelectedSegmentIndex:kStreamMode];
            }
            UIColor *color = [UIColor colorWithWhite:0.516 alpha:1.000];
            self.messageTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.messageTextfield.placeholder attributes:@{NSForegroundColorAttributeName: color}];
            [self consoleAppend:@"Mode changed to STREAM MODE\n" isIncomingFromDevice:false];
            break;
        }
        case kCommandMode:
        {
            self.messageTextfield.placeholder = @"Enter a command...";
            if (![self.mBleCommanderiOS writeBusMode:REMOTE_COMMAND_MODE])
            {
                NSLog(@"Failed to change mode to remote");
                [self.segementControl setSelectedSegmentIndex:kCommandMode];
            }
            UIColor *color = [UIColor whiteColor];
            self.messageTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.messageTextfield.placeholder attributes:@{NSForegroundColorAttributeName: color}];
            [self consoleAppend:@"Mode changed to COMMAND MODE\n" isIncomingFromDevice:false];
            break ;
        }
        default:
            break;
    }
    
    if (self.messageTextfield.isFirstResponder)
    {
        self.messageTextfield.placeholder = @"";
    }
    
    [self setupButtons];
}

- (void)consoleAppend:(NSString *)string isIncomingFromDevice:(BOOL)isIncomingFromDevice
{
    [self.logTextView insertText:string] ;
    [self.logTextView scrollRangeToVisible:NSMakeRange([self.logTextView.text length], 0)] ;
}

- (BOOL)consoleWindowTextEndsInNewLine
{
    return [self.logTextView.text hasSuffix:@"\n"] || [self.logTextView.text hasSuffix:@"\r"];
}

- (BOOL)stringIsNewline:(NSString *)responseString
{
    return [responseString isEqualToString:@"\n"] || [responseString isEqualToString:@"\r"];
}

- (NSMutableAttributedString *)getResponseAttributedString:(NSString *)responseString
{
    
    NSString *prefix = @"> ";
    
    if (self.lastWrittenConsoleTextWasResponseReceived)
    {
        if([self consoleWindowTextEndsInNewLine])
        {
            responseString = [NSString stringWithFormat:@"%@  %@", prefix, responseString];
        }
        else if([self stringIsNewline:responseString])
        {
            responseString = [NSString stringWithFormat:@"\n%@  ", prefix];
        }
    }
    else
    {
        responseString = [NSString stringWithFormat:@"\n%@  %@", prefix, responseString];
    }
    
    NSMutableAttributedString *responseStringAttributed = [[NSMutableAttributedString alloc] initWithString:responseString];
    [responseStringAttributed addAttribute:NSFontAttributeName
                                     value:[UIFont systemFontOfSize:14]
                                     range:NSMakeRange(0, [responseString length])];
    [responseStringAttributed addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor greenColor]
                                     range:NSMakeRange(0, [responseString length])];
    return responseStringAttributed;
}

- (void)appendIncomingResponse:(NSString *)responseString
{
    NSMutableAttributedString *responseStringAttributed = [self getResponseAttributedString:responseString];
    NSAttributedString *currentAttributedString = self.logTextView.attributedText;
    NSMutableAttributedString *newAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:currentAttributedString];
    [newAttributedString appendAttributedString:responseStringAttributed];
    
    [self.logTextView setAttributedText:newAttributedString];
    self.lastWrittenConsoleTextWasResponseReceived = YES;
}

- (void)appendOutgoingMessage:(NSString *)outgoingMessage
{
    if(outgoingMessage)
    {
        NSMutableAttributedString *responseStringAttributed = [self getOutgoingAttributedString:outgoingMessage];
        NSAttributedString *currentAttributedString = self.logTextView.attributedText;
        NSMutableAttributedString *newAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:currentAttributedString];
        [newAttributedString appendAttributedString:responseStringAttributed];
        
        [self.logTextView setAttributedText:newAttributedString];
        self.lastWrittenConsoleTextWasResponseReceived = NO;
    }
}

- (NSMutableAttributedString *)getOutgoingAttributedString:(NSString *)outgoingMessage
{
    
    NSString *prefix = @"< ";
    outgoingMessage = [NSString stringWithFormat:@"\n%@  %@", prefix, outgoingMessage];
    
    NSMutableAttributedString *responseStringAttributed = [[NSMutableAttributedString alloc] initWithString:outgoingMessage];
    [responseStringAttributed addAttribute:NSFontAttributeName
                                     value:[UIFont systemFontOfSize:14]
                                     range:NSMakeRange(0, [outgoingMessage length])];
    [responseStringAttributed addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor whiteColor]
                                     range:NSMakeRange(0, [outgoingMessage length])];
    return responseStringAttributed;
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.messageTextfield)
    {
        [self writeString:textField.text];
    }
    
    if (self.mBleCommanderiOS.busMode == REMOTE_COMMAND_MODE)
    {
        //Command mode
        NSString *prefix = @"\n> ";
        [self consoleAppend:prefix isIncomingFromDevice:false];
    }
    
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.placeholder = @"";
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    switch (self.segementControl.selectedSegmentIndex)
    {
        case kStreamMode:
        {
            self.messageTextfield.placeholder = @"Enter a message...";
            UIColor *color = [UIColor colorWithWhite:0.516 alpha:1.000];
            self.messageTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.messageTextfield.placeholder attributes:@{NSForegroundColorAttributeName: color}];
            break;
        }
        case kCommandMode:
        {
            self.messageTextfield.placeholder = @"Enter a command...";
            UIColor *color = [UIColor colorWithWhite:0.516 alpha:1.000];
            self.messageTextfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.messageTextfield.placeholder attributes:@{NSForegroundColorAttributeName: color}];
            break ;
        }
        default:
            break;
    }
}


#pragma mark - BLECommanderDelegate

//Called when a new device has been detected.
- (void)scanDelegate
{
    
}

- (void)connectionStateDelegate:(ConnectionState)newConnectionState
{
    switch (newConnectionState)
    {
        case DISCONNECTED:
            break;
            
        case SCANNING:
            break;
            
        case CONNECTING:
            break;
            
        case INTERROGATING:
            break;
            
        case CONNECTED:
            break;
            
        case DISCONNECTING:
            break;
            
        default:
            break;
    }
}

- (void)busModeDelegate:(BusMode)newBusMode
{
    
}

- (void)dataReadDelegate:(NSData *) newData
{
    //Check mode, if stream then any data received will be from the computer/serial.

        NSString *str = [[NSString alloc] initWithBytes:[newData bytes] length:newData.length encoding:NSUTF8StringEncoding];
        if(str != nil){
            [self consoleAppend:str isIncomingFromDevice:false];
        }

        if(readingImage){
            if(num > currImageLength){
                NSLog(@"%@", str);
                self.imageView.image = [UIImage imageWithData:self.buffer];
                [self consoleAppend:@"Saving image..." isIncomingFromDevice:false];
                PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"Image-%lu", (unsigned long)[self.buffer hash]] data:self.buffer];
                
                // Save the image to Parse
                
                [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (!error) {
                        PFObject* newPhotoObject = [PFObject objectWithClassName:@"ImageStorageDev"];
                        [newPhotoObject setObject:imageFile forKey:@"Image"];
                        
                        [newPhotoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (!error) {
                                [self consoleAppend:@"Image saved!" isIncomingFromDevice:false];
                                NSLog(@"Saved");
                            }
                            else{
                                // Error
                                NSLog(@"Error: %@ %@", error, [error userInfo]);
                            }
                        }];
                    }
                }];

                self.buffer = nil;
                readingImage = false;
                num = 0;
            }
            [self.buffer appendData:newData];
            num+= newData.length;
            NSLog(@"%d", num);
        }
        else {
            if([str  isEqual: @"I"]){
                NSLog(@"%@", str);
            }
            
            if(newData.length == 2){
                int* b = (int *)newData.bytes;
                currImageLength = *b;
                NSLog(@"%d",currImageLength);
                self.buffer = [[NSMutableData alloc] init];
                readingImage = true;
            }
            
            if(newData.length == 20){
                if(self.buffer){
                    [self.buffer appendData:newData];
                    self.imageView.image = [UIImage imageWithData:self.buffer];
                }
            }
        }
        


        //Stream mode

}

- (void) dataWriteDelegate
{
    //Check mode, if stream then append data
    if (self.mBleCommanderiOS.busMode == STREAM_MODE)
    {
        //Stream mode
    }
    else
    {
        //Command mode
    }
    self.messageTextfield.text = nil;
}

- (void)dataParserDelegate:(Header)header payload:(NSString *)payload
{
    NSLog(@"Header:");
    NSLog(@"Type: %d", header.type);
    NSLog(@"Code: %d", header.code);
    NSLog(@"Length: %d", (unsigned int)header.length);
    
    NSLog(@"Payload: %@", payload);
}

@end
