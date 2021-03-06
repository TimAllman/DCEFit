//
//  ImageImporter.mm
//  DCEFit
//
//  Created by Tim Allman on 2013-05-02.
//
//

#import <OsirixAPI/ViewerController.h>
#import <OsirixAPI/DCMPix.h>
#import <OsiriX/DCMObject.h>
#import <OsiriX/DCMAttributeTag.h>

#import "ImageImporter.h"

#include "ItkTypedefs.h"

@implementation ImageImporter

- (ImageImporter*)initWithViewerController:(ViewerController*)viewerController
{
    self = [super init];
    if (self)
    {
        viewer = viewerController;
        [self setupLogger];
        LOG4M_TRACE(logger_, @"ImageImporter.initWithViewerController");
    }
    return self;
}

- (void)dealloc
{
    [logger_ release];
    [super dealloc];
}

- (void) setupLogger
{
    NSString* loggerName = [[NSString stringWithUTF8String:LOGGER_NAME]
                            stringByAppendingString:@".ImageImporter"];
    logger_ = [[Logger newInstance:loggerName] retain];
}

- (Image3D::Pointer)getImageAtIndex:(unsigned)imageIdx
{
    LOG4M_TRACE(logger_, @"Enter");
    ImportImageFilter3D::Pointer importFilter = ImportImageFilter3D::New();
    ImportImageFilter3D::SizeType size;
    ImportImageFilter3D::IndexType start;
    ImportImageFilter3D::SpacingType spacing;
    ImportImageFilter3D::RegionType region;
    ImportImageFilter3D::OriginType origin;
    ImportImageFilter3D::DirectionType direction;

    //importFilter->DebugOn();

    //
    // Extract the needed information from OsiriX
    //
    // pointer to the first slice (i.e. start of buffer)
    NSMutableArray* pixList = [viewer pixList:imageIdx];
    DCMPix* firstPix = [pixList objectAtIndex:0];

    // start of the image in pixels
    start[0] = 0;
	start[1] = 0;
    start[2] = 0;
    LOG4M_DEBUG(logger_, @"  Start = %d, %d, %d", start[0], start[1], start[2]);

    // size of the image in pixels
    size[0] = [firstPix pwidth];
	size[1] = [firstPix pheight];
    size[2] = [[viewer pixList] count];
    LOG4M_DEBUG(logger_, @"  Size = %d, %d, %d", size[0], size[1], size[2]);

    // origin in mm
    origin[0] = [firstPix originX];
	origin[1] = [firstPix originY];
	origin[2] = [firstPix originZ];
    LOG4M_DEBUG(logger_, @"  Origin = %f, %f, %f", origin[0], origin[1], origin[2]);

    // pixel spacing in mm
	spacing[0] = [firstPix pixelSpacingX];
	spacing[1] = [firstPix pixelSpacingY];
	spacing[2] = [firstPix sliceInterval];

    // The slice interval may be 0 if there is only one slice per DCMPix object but
    // ITK does not allow 0 spacings so ...
    if (fabs(spacing[2]) < 1e-6)
        spacing[2] = 1.0;
    LOG4M_DEBUG(logger_, @"  Spacing = %f, %f, %f", spacing[0], spacing[1], spacing[2]);

    // For our purposes the DICOM orientation vectors get in the way.
    // We will just set this up so that the image appears to be axial.
    // This means that the upper left corner of the screen is the origin
    // with X increasing horizontally, Y increasing down the screen and
    // Z going into the screen.
    for (int i = 0; i < 3; ++i)
        for (int j = 0; j < 3; ++j)
        {
            if (i == j)
                direction(i, j) = 1.0;
            else
                direction(i, j) = 0.0;
        }

    LOG4M_DEBUG(logger_, @"itk::Image::direction = \n     [%3.4f, %3.4f, %3.4f]\n     "
                "[%3.4f, %3.4f, %3.4f]\n     [%3.4f, %3.4f, %3.4f]",
                direction(0, 0), direction(0, 1), direction(0, 2),
                direction(1, 0), direction(1, 1), direction(1, 2),
                direction(2, 0), direction(2, 1), direction(2, 2));

    // the size of the buffer
    long bufferSize = size[0] * size[1] * size[2];

    // Region to import -- the whole image
    region.SetIndex(start);
	region.SetSize(size);

    // pointer to the data
    float* data = [viewer volumePtr:imageIdx];
	importFilter->SetRegion(region);
	importFilter->SetOrigin(origin);
	importFilter->SetSpacing(spacing);
    importFilter->SetDirection(direction);

    // set this so that the filter does not own the data, OsiriX does
	importFilter->SetImportPointer(data, bufferSize, false);

    Image3D::Pointer image = importFilter->GetOutput();
	image->Update();

    return image;
}

@end
