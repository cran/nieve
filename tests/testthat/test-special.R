## ***************************************************************************
## AUTHOR: Yves Deville <deville.yves@alpestat.com>
## GOAL: Test the implementation of the GEV distribution (C code used via
## .Call)
##
## ***************************************************************************

library(testthat)
context("GEV_special")

set.seed(1234)

