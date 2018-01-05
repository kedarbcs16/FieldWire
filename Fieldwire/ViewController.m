//
//  ViewController.m
//  Fieldwire
//
//  Created by kedar on 12/26/17.
//  Copyright © 2017 kedar. All rights reserved.
//

#import "ViewController.h"
#import "CustomCollectionViewCell.h"
#import <Crashlytics/Crashlytics.h>

@interface ViewController ()
{
    NSMutableArray *imgArray;
    NSString *searchStr;
    UIRefreshControl *refreshControl;
    NSMutableArray *historyStack;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.imageView setHidden:YES];
    [self.closeBtn setHidden:YES];
   // [[Crashlytics sharedInstance] crash];
//    UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    button.frame = CGRectMake(20, 50, 100, 30);
//    [button setTitle:@"Crash" forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(crashButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:button];

    // Do any additional setup after loading the view, typically from a nib.
    //https://api.imgur.com/3/gallery/search?q=cats
    
    imgArray = [[NSMutableArray alloc]init];
    historyStack = [[NSMutableArray alloc]init];
    searchStr = @"cars";
    [historyStack addObject:@"cars"];
    [self fetchData:searchStr];
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refershControlAction) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    
}
//- (IBAction)crashButtonTapped:(id)sender {
//    [[Crashlytics sharedInstance] crash];
//}

-(void)refershControlAction{
    [self fetchData:searchStr];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.historyTableViewTopConstraint.constant = -240;
    
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"test %@",searchText);
    searchStr = searchText;
    self.historyTableViewTopConstraint.constant = 28;
    [self fetchData:searchStr];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"end");
    [searchBar resignFirstResponder];
    self.historyTableViewTopConstraint.constant = 28;
    if(!searchStr || searchStr.length==0)
        return;
    if (![historyStack containsObject:searchStr]) {
        [historyStack addObject:searchStr];
    }
    else
    {
        [historyStack removeObject:searchStr];
        [historyStack addObject:searchStr];
    }
    
    if(historyStack.count>6)
       [historyStack removeObjectAtIndex:0];
    [_historyTableView reloadData];
}

-(void)fetchData:(NSString *)query{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.imgur.com/3/gallery/search?q=%@",query]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setValue:[NSString stringWithFormat:@"Client-ID %@",@"aa586e60b09928a"] forHTTPHeaderField:@"Authorization"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      // ...
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [refreshControl endRefreshing];
                                      });
                                      
                                      NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                                      if(httpResponse.statusCode == 200)
                                      {
                                          NSError *parseError = nil;
                                          NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
                                          NSLog(@"The response is - %@",responseDictionary);
                                          NSMutableArray *imgs = [responseDictionary valueForKey:@"data"];
                                          
                                          if(imgs  && imgs.count){
                                              [imgArray removeAllObjects];
                                              for (NSDictionary *dic in imgs) {
                                                  NSArray *imgLinks = [dic valueForKey:@"images"];
                                                  for (NSDictionary *temp in imgLinks) {
                                                      int animated = [(NSString *)[temp valueForKey:@"animated"]intValue];
                                                      if(animated==0 && [temp valueForKey:@"link"])
                                                          [imgArray addObject:[temp valueForKey:@"link"]];
                                                  }
                                              }
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [self.collectionView reloadData];
                                              });
                                              
                                          }
                                      }
                                      else
                                      {
                                          NSLog(@"Error");
                                      }
                                      
                                      
                                  }];
    
    [task resume];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Previous Searches";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 24;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(historyStack.count>=6)
        return 6;
    else
        return historyStack.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"historyCell"];
    cell.textLabel.text = [historyStack objectAtIndex:[historyStack count]-indexPath.row-1 ];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_searchBar resignFirstResponder];
    self.historyTableViewTopConstraint.constant = 28;
    [self fetchData:[historyStack objectAtIndex:[historyStack count]-indexPath.row-1 ]];
    NSString *temp = [historyStack objectAtIndex:[historyStack count]-indexPath.row-1 ];
    [historyStack removeObject:temp];
    [historyStack addObject:temp];
    [_historyTableView reloadData];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)sectio
{
    return imgArray.count;
}
-(UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CustomCollectionViewCell *cell;
    NSString *identifier = @"collectionViewCell";
    CustomCollectionViewCell *cellNormal = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell=cellNormal;
    NSString *urlStr = [imgArray objectAtIndex:indexPath.row];
    if(urlStr){
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:urlStr]
                          placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                   options:SDWebImageProgressiveDownload];
    }
    
    
    
    return cell;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *urlStr = [imgArray objectAtIndex:indexPath.row];
    if(urlStr){
        
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:urlStr]
                          placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                   options:SDWebImageProgressiveDownload];
        [self.imageView setHidden:false];
        [self.closeBtn setHidden:false];
    }
}





- (IBAction)closeBtnPressed:(id)sender {
    [self.imageView setHidden:YES];
    [self.closeBtn setHidden:YES];
    [self.imageView setImage:[UIImage imageNamed:@"placeholder.png"]];
}
@end
