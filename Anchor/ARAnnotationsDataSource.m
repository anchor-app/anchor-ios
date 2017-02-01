//
//  ARAnnotationsDataSource.m
//  Anchor
//
//  Created by Austen McDonald on 2/1/17.
//  Copyright © 2017 Roger Huffstetler. All rights reserved.
//

#import "ARAnnotationsDataSource.h"

#import "ARAnnotationTableViewCell.h"

@implementation ARAnnotationsDataSource

- (instancetype)initWithAnnotations:(NSArray<ARAnnotation *> *)annotations
{
  if (self = [super init]) {
    self.annnotations = annotations;
  }
  return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return _annnotations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *identifier = @"ARAnnotationTableViewCell";
  ARAnnotationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (cell == nil) {
    cell = [[ARAnnotationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  }

  ARAnnotation *a = _annnotations[indexPath.row];
  cell.annotation = a;

  return cell;
}

@end
