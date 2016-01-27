//
//  ScanViewController.m
//  BLE Commander
//

#import "ScanViewController.h"
#import "DeviceCommunicateViewController.h"
#import "BLECommanderiOS/BLECommanderiOS.h"


@interface ScanViewController () <DeviceCommunicateViewControllerDelegate, BLECommanderDelegate>
@property (nonatomic, strong)BLECommanderiOS *mBleCommanderiOS;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *scanButton;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation ScanViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Configure TruConnect
    self.mBleCommanderiOS = [[BLECommanderiOS alloc] init];
    self.mBleCommanderiOS.delegate = self;
    
    [self setupViewAppearance];
}

- (void)setupViewAppearance
{
    //Setup the view and button appearance
    self.title = @"Scan for Devices";
    self.scanButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.scanButton.layer.borderWidth = 1;
    self.scanButton.layer.cornerRadius = 4;
    self.scanButton.clipsToBounds = true;
    [self.scanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.110 green:0.114 blue:0.118 alpha:1];
    
    //Right navigation button
    UIImage *iconImage = [UIImage imageNamed:@"icon"];
    UIButton *iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    iconButton.bounds = CGRectMake(0, 0, 34, 34);
    [iconButton setContentMode:UIViewContentModeScaleAspectFit];
    [iconButton setImage:iconImage forState:UIControlStateNormal];
    UIBarButtonItem *faceBtn = [[UIBarButtonItem alloc] initWithCustomView:iconButton];
    self.navigationItem.rightBarButtonItem = faceBtn;
    
    self.tableView.separatorColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    self.tableView.rowHeight = 60;
    
    //Configure the TableView cell separator insets
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
}


- (void)showAlert:(NSString *)title withBody:(NSString *)body
{
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//    TimedOutViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"TimeOut"];
//    vc.errorMessage = body;
//    vc.errorTitle = title;
//    vc.view.frame = CGRectMake(0, 0, 270.0f, 290.0f);
//    [self presentPopUpViewController:vc completion:^{
//        [self startScanning];
//    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //Configure Delegate
    self.mBleCommanderiOS.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //Start Scanning
    [self startScanning];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
}

- (void)startScanning
{
    [self stopScanning];
    
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(stopScanning) userInfo:nil repeats:false];
    
    //Start Scanning
    BOOL didStartScanning = [self.mBleCommanderiOS startScan];
    self.title = @"Scanning";
    self.scanButton.enabled = false;
    [self.scanButton setTitle:@"Scanning" forState:UIControlStateNormal];
    [self.scanButton setBackgroundColor:[UIColor whiteColor]];
    [self.scanButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = true;
    [self.tableView reloadData];
}

- (void)stopScanning
{
    //Stop Scanning
    [self.mBleCommanderiOS stopScan];
    [self.tableView reloadData];
    self.title = @"Scan for Devices";
    self.scanButton.enabled = true;
    [self.scanButton setTitle:@"Scan" forState:UIControlStateNormal];
    [self.scanButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = false;
}

- (void)disconnectFromDevice
{
    //Disconnect from device
    [self.mBleCommanderiOS disconnect];
    [self.tableView reloadData];
    self.title = @"Scan for Devices";
    [self.scanButton setTitle:@"Scan" forState:UIControlStateNormal];
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = false;
}

- (void)connectionTimeout
{
    [self showAlert:@"Timed out" withBody:@"The connection timed out. Please try again"];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showDeviceDetail"])
    {
        DeviceCommunicateViewController *tmpView = segue.destinationViewController;
        tmpView.delegate = self;
        tmpView.mBleCommanderiOS = self.mBleCommanderiOS;
        tmpView.deviceName = [[[self.mBleCommanderiOS.devicesDiscovered objectAtIndex:[self.tableView indexPathForSelectedRow].row] valueForKey:@"adv"] valueForKey:CBAdvertisementDataLocalNameKey];
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:false];
    }
}

//Scan button pressed
- (IBAction)scanForDevices:(id)sender
{
    switch (self.mBleCommanderiOS.connectionState)
    {
        case DISCONNECTED:
        {
            //Start Scanning
            [self startScanning];
            break;
        }
        case SCANNING:
        {
            //Stop Scanning
            [self stopScanning];
            break;
        }
        case CONNECTING:
        case INTERROGATING:
        case CONNECTED:
        {
            //Disconnect from device
            [self disconnectFromDevice];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.mBleCommanderiOS.devicesDiscovered count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicCell" forIndexPath:indexPath];
    NSString *deviceName = [NSString stringWithFormat:@"%@",[[[self.mBleCommanderiOS.devicesDiscovered objectAtIndex:indexPath.row] valueForKey:@"adv"] valueForKey:CBAdvertisementDataLocalNameKey]];
    if ([deviceName isEqualToString:@"(null)"])
    {
        cell.textLabel.text = @"Unnamed Device";
    }
    else
    {
        cell.textLabel.text = deviceName;
    }
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.timer invalidate];
    
    self.scanButton.enabled = false;
    [self.mBleCommanderiOS connectToDevice:[self.tableView cellForRowAtIndexPath:indexPath].textLabel.text];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Configure the TableView cell separator insets
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [tableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [tableView setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
}

#pragma mark - DeviceDetailViewControllerDelegate

- (void)deviceConnectionDidTimeOut
{
    [self.navigationController popToRootViewControllerAnimated:true];
    [self showAlert:@"Connection Lost" withBody:@"The connection to the device was lost. Please try reconnecting."];
}

#pragma mark - BLECommanderDelegate

//Called when a new device has been detected.
- (void)scanDelegate
{
    [self.tableView reloadData];
}

//Called when the connection state has changed.
- (void)connectionStateDelegate:(ConnectionState)newConState
{
    switch (newConState)
    {
        case DISCONNECTED:
            [self stopScanning];
            break;
            
        case SCANNING:
            [self.scanButton setTitle:@"Scanning" forState:UIControlStateNormal];
            [self.tableView reloadData];
            break;
            
        case CONNECTING:
            [self.scanButton setTitle:@"Connecting" forState:UIControlStateNormal];
            [self.scanButton setBackgroundColor:[UIColor whiteColor]];
            [self.scanButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            break;
            
        case INTERROGATING:
            [self.scanButton setTitle:@"Interrogating" forState:UIControlStateNormal];
            [self.scanButton setBackgroundColor:[UIColor whiteColor]];
            [self.scanButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            break;
            
        case CONNECTED:
        {
            [self.scanButton setTitle:@"Connected" forState:UIControlStateNormal];
            [self.scanButton setBackgroundColor:[UIColor whiteColor]];
            [self.scanButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [self performSegueWithIdentifier:@"showDeviceDetail" sender:self];
            
            //Stop scanning
            [self stopScanning];
            break;
        }
            
        case DISCONNECTING:
            [self.scanButton setTitle:@"Disconnecting" forState:UIControlStateNormal];
            [self.scanButton setBackgroundColor:[UIColor whiteColor]];
            [self.scanButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            break;
            
        case CONNECTIONTIMEDOUT:
            [self connectionTimeout];
            break;
            
        default:
            break;
    }
}

//Called when the bus mode has changed.
- (void)busModeDelegate:(BusMode)newBusMode
{
    
}

//Called when data has been read from the pheripheral.
- (void) dataReadDelegate:(NSData *) newData
{
    
}

//Called when data has been written to the device.
- (void) dataWriteDelegate
{
    
}

- (void) dataParserDelegate:(Header)header payload:(NSString *)payload
{
    NSLog(@"Header:");
    NSLog(@"Type: %d", header.type);
    NSLog(@"Code: %d", header.code);
    NSLog(@"Length: %d", (unsigned int)header.length);
    
    NSLog(@"Payload: %@", payload);
}

@end
