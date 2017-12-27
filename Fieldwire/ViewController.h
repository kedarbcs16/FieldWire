//
//  ViewController.h
//  Fieldwire
//
//  Created by kedar on 12/26/17.
//  Copyright © 2017 kedar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

- (IBAction)closeBtnPressed:(id)sender;

@end

