//
//  ViewController.m
//  MSGToJSONTransformer
//
//  Created by Ashiqur Rahman on 2/9/16.
//  Copyright © 2016 Ashiqur Rahman. All rights reserved.
//

#import "ViewController.h"
#import "TextToJSONObjectTransformerTask.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textViewJSON;
@property (weak, nonatomic) IBOutlet UITextField *textFieldMsg;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnClickGenerate:(id)sender {
    
    TextToJSONObjectTransformerTask *task = [[TextToJSONObjectTransformerTask alloc]initWithText:self.textFieldMsg.text];
    
    [[[task task] chain:^id(ChainableTask *task) {
        ChatMsgObject *result = task.result;
        if (task.error == nil) {
            return [result toJSONString];
        }else{
            return [task.error description];
        }
    }] chainInMainThread:^id(ChainableTask *task) {
        self.textViewJSON.text = task.result;
        return nil;
    }];
    
    
    
}
@end
