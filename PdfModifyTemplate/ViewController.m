#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)touchedDown:(id)sender {
    NSLog(@"Generate and show PDF");
    
    [self generateAndShowPDF];
}

- (void)generateAndShowPDF
{
    NSData *pdfData = [self generatePDF];
    [self.webView loadData:pdfData MIMEType:@"application/pdf" textEncodingName:@"utf-8" baseURL:nil];
}

#pragma mark - Generate PDF

- (NSData*)generatePDF
{
    NSURL *templateUrl = [[NSBundle mainBundle] URLForResource:@"template" withExtension:@"pdf"];

    NSMutableData *pdfData = [NSMutableData data];
    NSString *templatePath = [templateUrl path];

    //create empty pdf file;
    UIGraphicsBeginPDFContextToData(pdfData, CGRectMake(0, 0, 792, 612), nil);

    CFURLRef url = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)templatePath, kCFURLPOSIXPathStyle, 0);

    //open template file
    CGPDFDocumentRef templateDocument = CGPDFDocumentCreateWithURL(url);
    CFRelease(url);

    //get amount of pages in template
    size_t count = CGPDFDocumentGetNumberOfPages(templateDocument);

    //for each page in template
    for (size_t pageNumber = 1; pageNumber <= count; pageNumber++) {
        //get bounds of template page
        CGPDFPageRef templatePage = CGPDFDocumentGetPage(templateDocument, pageNumber);
        CGRect templatePageBounds = CGPDFPageGetBoxRect(templatePage, kCGPDFCropBox);

        //create empty page with corresponding bounds in new document
        UIGraphicsBeginPDFPageWithInfo(templatePageBounds, nil);
        CGContextRef context = UIGraphicsGetCurrentContext();

        //flip context due to different origins
        CGContextTranslateCTM(context, 0.0, templatePageBounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);

        //copy content of template page on the corresponding page in new file
        CGContextDrawPDFPage(context, templatePage);

        //flip context back
        CGContextTranslateCTM(context, 0.0, templatePageBounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);


        /* CUSTOM DRAWING */
        if (pageNumber == 1) {
            NSString *newText = @"New text.";
            UIFont *textFont = [UIFont systemFontOfSize:16];

            [newText drawAtPoint:CGPointMake(60, 150) withAttributes:@{NSFontAttributeName:textFont}];
        }

    }

    CGPDFDocumentRelease(templateDocument);
    UIGraphicsEndPDFContext();

    return pdfData;
}

@end