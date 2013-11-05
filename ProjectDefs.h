//
//  ProjectDefs.h
//  DCEFit
//
//  Created by Tim Allman on 2013-04-26.
//
//

#ifndef DCEFit_ProjectDefs_h
#define DCEFit_ProjectDefs_h

/*
 * This file contains only C compatible definitions, #defines etc that are
 * used throughout the program. This ensures that they are usable by any
 * module be it C, C++, Obj-C or Obj-C++.
 */

// These values must be synchronised with the values of the
// tags of the radio button cells.
enum MetricType
{
    MeanSquares = 0,
    MattesMutualInformation = 1
};

// Used as a selector for the optimizer to use
enum OptimizerType
{
    LBFGSB = 0,
    LBFGS = 1,
    RSGD = 2
};

// The size of the arrays containing registration pyramid parameters.
#define MAX_ARRAY_PARAMS 4
#define BSPLINE_ORDER 3

// The name of the logger used through this plugin.
#define LOGGER_NAME "ca.brasscats.osirix.DCEFit"

// The name of the rolling file log that we place in ~/Library/Logs
#define LOG_FILE_NAME LOGGER_NAME;

#endif