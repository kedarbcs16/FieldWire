//
//  ViewController.m
//  Fieldwire
//
//  Created by kedar on 12/26/17.
//  Copyright © 2017 kedar. All rights reserved.
//

#import "ViewController.h"
#import "CustomCollectionViewCell.h"

@interface ViewController ()
{
    NSMutableArray *imgArray;
    NSString *searchStr;
    UIRefreshControl *refreshControl;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.imageView setHidden:YES];
    [self.closeBtn setHidden:YES];
    // Do any additional setup after loading the view, typically from a nib.
    //https://api.imgur.com/3/gallery/search?q=cats
    
    imgArray = [[NSMutableArray alloc]init];
    searchStr = @"cars";
    [self fetchData:searchStr];
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refershControlAction) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    
}
-(void)refershControlAction{
    [self fetchData:searchStr];
}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    NSLog(@"test %@",searchText);
    searchStr = searchText;
    [self fetchData:searchStr];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"end");
    [searchBar resignFirstResponder];
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
                                   options:SDWebImageRefreshCached];
    }
    
    
    
    return cell;
}



- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *urlStr = [imgArray objectAtIndex:indexPath.row];
    if(urlStr){
        
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:urlStr]
                          placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                                   options:SDWebImageRefreshCached];
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
