//
//  LatestVideosTVC.m
//  iTipstrTv
//
//  Created by Leads Mobile App Team on 6/7/13.
//  Copyright (c) 2013 iOS Team. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "LatestVideosTVC.h"
#import "VimeoHttpClient.h"
#import "StreamingVC.h"
#import "AFImageRequestOperation.h"

@interface LatestVideosTVC ()

@end

@implementation LatestVideosTVC
@synthesize videoItems;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    VimeoHttpClient *vimeoHttpClient =[VimeoHttpClient sharedVimeoHttpClient];
    vimeoHttpClient.delegate = self;
    
    [vimeoHttpClient collectDataFromVimeoServer];
    
    
    
//    
//    // Remove table cell separator
//    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//    
//    // Assign our own backgroud for the view
//    self.parentViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"common_bg"]];
//    self.tableView.backgroundColor = [UIColor clearColor];
//    
//    // Add padding to the top of the table view
//    UIEdgeInsets inset = UIEdgeInsetsMake(5, 0, 0, 0);
//    self.tableView.contentInset = inset;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - custom methods

-(UIImage *)getImage:(NSString *) imageUrl
{
//   NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:gameObj.gameThumbnails]]; UIImage *myImage=[UIImage imageWithData:data]; imageView.image=[UIImage imageWithData:UIImageJPEGRepresentation(myImage, 0.9)];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
    UIImage *myImage = [UIImage imageWithData:data];
    UIImage *jpegImage = [UIImage imageWithData:UIImageJPEGRepresentation(myImage, 0.9)];
    return jpegImage;
}

-(NSString *) getTime:(NSString *)seconds
{
    int sec = [seconds intValue];
    NSString *strTime;
    if(sec<60)
    {
       strTime = [NSString stringWithFormat:@"00:%i",sec];
    }
    else
    {
        int vagfol = (int)sec/60;
        int vagshes = sec%60;
        
        strTime = [NSString stringWithFormat:@"%i:%i",vagfol,vagshes];
    }
    
    return strTime;
}


- (UIImage *)cellBackgroundForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowCount = [self tableView:[self tableView] numberOfRowsInSection:0];
    NSInteger rowIndex = indexPath.row;
    UIImage *background = nil;
    
    if (rowIndex == 0) {
        background = [UIImage imageNamed:@"cell_top.png"];
    } else if (rowIndex == rowCount - 1) {
        background = [UIImage imageNamed:@"cell_bottom.png"];
    } else {
        background = [UIImage imageNamed:@"cell_middle.png"];
    }
    
    return background;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of section.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.videoItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSDictionary *videoDict = [self.videoItems objectAtIndex:indexPath.row];
    //image view
    NSString *imageUrl = [videoDict objectForKey:@"thumbnail_large"];
    UIImageView *imageView = (UIImageView*)[cell.contentView viewWithTag:100];
   // imageView.image = [self getImage:imageUrl];
    //Store this image on the same server as the weather canned files
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request
                                                                              imageProcessingBlock:nil
                                                                                           success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                                                               imageView.image = image;
//                                                                                               [self saveImage:image withFilename:@"background.png"];
                                                                                           }
                                                                                           failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                                                                               NSLog(@"Error %@",error);
                                                                                           }];
    [operation start];
    //Title Label
    UILabel *labelTitle = (UILabel*)[cell.contentView viewWithTag:101];
    labelTitle.text = [videoDict objectForKey:@"title"];
    
    //Time label
    UILabel *labelDuration = (UILabel*)[cell.contentView viewWithTag:102];
    labelDuration.text=[self getTime:[videoDict objectForKey:@"duration"]];
    
    
//    cell.textLabel.text = [videoDict objectForKey:@"title"];
    
    // Assign our own background image for the cell
//    UIImage *background = [self cellBackgroundForRowAtIndexPath:indexPath];
//    
//    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
//    cellBackgroundView.image = background;
//    cell.backgroundView = cellBackgroundView;
    
    return cell;
}

 

#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSDictionary *videoDict=[self.videoItems objectAtIndex:indexPath.row];
//    NSURL *videoUrl = [NSURL URLWithString:[videoDict objectForKey:@"url"]];
//    
//    NSURL *appleUrl = [NSURL URLWithString:@"https://vimeo.com/65050844"];
//    
//    NSLog(@"video url : %@",videoUrl);
//    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:appleUrl];
//    
//    [self presentMoviePlayerViewControllerAnimated:player]; 
//    
//}


#pragma mark - VimeoHttpClientDelegate methods
-(void)vimeoHttpClient:(VimeoHttpClient *)client didUpdateWithData:(id)data
{
    self.videoItems = data;
    self.title = @"Latest Videos";
    [self.tableView reloadData];
    
   // NSLog(@"data inside tvc: %@",self.videoItems);
}
-(void)vimeoHttpClient:(VimeoHttpClient *)client didFailWithError:(NSError *)error
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Videos"
                                                 message:[NSString stringWithFormat:@"%@",error]
                                                delegate:nil
                                       cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
    
}


#pragma mark - segue method
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    StreamingVC *svc = segue.destinationViewController;
    svc.selectedDict = [self.videoItems objectAtIndex:indexPath.row];
    
}




@end
