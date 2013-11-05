//
//  ImageTagger.cpp
//  DCEFit
//
//  Created by Tim Allman on 2013-10-21.
//
//

#include "ImageTagger.h"
#include "ItkTypedefs.h"

template <>
void ImageTagger<Image2DType>::operator()(Image2DType& image)
{
    Image2DType::SizeType dims = image.GetLargestPossibleRegion().GetSize();

    unsigned gridRows = dims[0] / gridSize_;
    unsigned gridCols = dims[1] / gridSize_;

    for (unsigned row = 0; row < dims[0]; ++row)
    {
        Image2DType::IndexType index;
        index[0] = row;

        for (unsigned col = 0; col < dims[1]; ++col)
        {
            index[1] = col;
            if (row % gridRows == 0)             // set all pixels in row
                image.SetPixel(index, 127.0);
            else if (col % gridCols == 0)        // set only pixels in the grid columns
                image.SetPixel(index, 127.0);
        }
    }
}

template <>
void ImageTagger<Image3DType>::operator()(Image3DType& image)
{
    Image3DType::SizeType dims = image.GetLargestPossibleRegion().GetSize();

    unsigned gridRows = dims[0] / gridSize_;
    unsigned gridCols = dims[1] / gridSize_;

    for (unsigned slice = 0; slice < dims[2]; ++slice)
    {
        Image3DType::IndexType index;
        index[2] = slice;
        for (unsigned row = 0; row < dims[0]; ++row)
        {
            index[0] = row;
            
            for (unsigned col = 0; col < dims[1]; ++col)
            {
                index[1] = col;
                if (row % gridRows == 0)             // set all pixels in row
                    image.SetPixel(index, 127.0);
                else if (col % gridCols == 0)        // set only pixels in the grid columns
                    image.SetPixel(index, 127.0);
            }
        }
    }
}

