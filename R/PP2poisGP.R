## ****************************************************************************
##'
##' @description Transform Point Process (PP) parameters into
##'     Poisson-GP parameters. The provided parameters are GEV
##'     parameters: location \eqn{\mu^\star}{muStar_w}, scale
##'     \eqn{\sigma^\star_w}{sigmaStar} and shape
##'     \eqn{\xi^\star}{xiStar}. They are assumed to describe (the
##'     tail of) the distribution for a maximum on a time-interval
##'     with given duration \eqn{w}. For a given threshold \eqn{u}
##'     chosen to be in the interior of the support of the GEV
##'     distribution, there exists a unique vector of three Poisson-GP
##'     parameters such that the maximum \eqn{M} of the marks on an
##'     interval with duration \code{w} has the prescribed GEV
##'     tail. Remind that the three Poisson-GP parameters are the rate
##'     of the Poisson process in time: \eqn{\lambda_u}, and the two
##'     GP parameters: \code{scale} \eqn{\sigma_u} and \code{shape}
##'     \eqn{\xi}. The shape parameters \eqn{\xi^\star}{xiStar} and
##'     \eqn{\xi} are identical.
##'
##' @details The Poisson-GP parameters are obtained by 
##'     \deqn{\left\{
##'          \begin{array}{c c l}
##'              \sigma_u &=& \sigma_w^\star + \xi^\star \left[ u - \mu_w^\star \right],\\
##'              \lambda_u &=& w^{-1} \, \left[\sigma_u / \sigma_w^\star \right]^{-1/ \xi^\star},\\
##'              \xi &=& \xi^\star, 
##'           \end{array}\right.}{
##'              sigma_u = sigmaStar_w + xiStar * [ u - muStar_x ]
##'              lambda_u = w^{-1} * [sigma_u / sigmaStar_w ]^(-1 / xiStar)
##'              xi = \xiStar}
##'     the second equation becomes \eqn{\lambda_u = w^{-1}} for
##'     \eqn{\xi^\star = 0}{xiStar = 0}.
##' 
##' @export
##' 
##' @usage
##' PP2poisGP(locStar = 0.0, scaleStar = 1.0, shapeStar = 0.0,
##'           threshold,
##'           w = 1.0, deriv = FALSE) 
##' 
##' @title Transform Point-Process Parameters into Poisson-GP
##' Parameters
##'
##' @param locStar,scaleStar,shapeStar Numeric vectors containing the
##' GEV location, scale and shape parameters.
##'
##' @param threshold Numeric vector containing the thresholds of the
##' Poisson-GP model, i.e. the location of the Generalised Pareto
##' Distribution. \emph{The threshold must be an interior point of the
##' support of the corresponding GEV distribution}.
##' 
##' @param w The block duration. Its physical dimension is time and
##' the product \eqn{\lambda \times w}{\lambda * w} is dimensionless.
##'
##' @param deriv Logical. If \code{TRUE} the derivative (Jacobian) of
##' the transformation is computed and returned as an attribute named
##' \code{"gradient"} of the attribute.
##'
##' @return A matrix with three columns representing the Poisson-GP
##' parameters \code{lambda}, \code{scale} and \code{shape}.
##'
##' @note This function is essentially a re-implementation in C of the
##' function \code{\link[Renext]{gev2Ren}} of \bold{Renext}.  As a
##' major improvement, this function is "vectorized" w.r.t. the
##' parameters so it can transform efficiently a large number of PP
##' parameter vectors as it can be required e.g. in a MCMC Bayesian
##' inference. Note also that this function copes with values near
##' zero for the shape parameter: it suitably computes then both the
##' function value and its derivatives.
##' 
##' @seealso \code{\link{poisGP2PP}} for the reciprocal
##' transformation.
##' 
PP2poisGP <- function(locStar = 0.0, scaleStar = 1.0, shapeStar = 0.0,
                      threshold, w = 1.0,
                      deriv = FALSE) {
    
    if (length(w) != 1) {
        stop("'w' must for now have length one")
    }

    if (any(is.na(locStar)) || any(is.na(scaleStar)) ||
        any(is.na(shapeStar)) || any(is.na(threshold)) || is.na(w)) {
        stop("NA are not allowed in 'locStar', 'scaleStar', 'shapeStar',",
             " 'threshold' or 'w'")
    }
    
    if (any(scaleStar <= 0.0)) {
        stop("'scaleStar' must contain positive values")
    }
    
    res <- .Call(Call_PP2poisGP,
                 as.double(locStar),
                 as.double(scaleStar),
                 as.double(shapeStar),
                 as.double(threshold),
                 as.double(w),
                 as.integer(deriv))

    g <- attr(res, "gradient")
    
    n <- length(res) / 3
    nm2 <- c("lambda", "scale", "shape")
    res <- array(res, dim = c(n, 3),
                 dimnames = list(NULL, nm2))
    
    if (deriv) {
        nm3 <- c("loc", "scale", "shape")
        attr(res, "gradient") <-
            array(g,
                  dim = c(n, 3L, 3L),
                  dimnames = list(NULL, nm2, nm3))
        
        
    }
 
    
    return(res)
    
}
