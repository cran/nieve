## ----deriv, size= "footnotesize"----------------------------------------------
qEx <- function(p, xi) ((1 - p)^(-xi) - 1) / xi
dqEx <- D(expression(((1 - p)^(-xi) - 1) / xi), name = "xi")
d2qEx <- D(dqEx, name = "xi")
p <- 0.99; pBar <- 1 - p
xis <- c(1e-4, 1e-5, 1e-6, 1e-7, 1e-8, 1e-9)
for (xi in xis) {
    r <- rbind("ord 0" = c("lim" = -log(pBar), "der" = qEx(p = p, xi = xi)),
               "ord 1" = c("lim" = log(pBar)^2 / 2, "der" = eval(dqEx, list(p = p, xi = xi))),
               "ord 2" = c("lim" = -log(pBar)^3 / 3, "der" = eval(d2qEx, list(x = p, xi = xi))))
    cat("xi = ", xi, "\n")
    print(r)
}

## ----deriv2, size= "footnotesize"---------------------------------------------
library(nieve)
for (xi in xis) {
    x <- qGPD2(p, shape = xi, deriv = TRUE, hessian = TRUE)
    r <- rbind("ord 0" = c("lim" = -log(pBar), "der" = x),
               "ord 1" =  c("lim" = log(pBar)^2 / 2, "der" = attr(x, "gradient")[1, "shape"]),
               "ord 2" = c("lim" = -log(pBar)^3 / 3, "der" = attr(x, "hessian")[1, "shape", "shape"]))
    cat("xi = ", xi, "\n")
    print(r)
}

