
#Below is Hiroshi's edit to the plotHR function from Greg, to make the y-axis of cox regression referencing to HR=1 at X =0. 

# Sections with comment "Added by Hiroshi" indicate changes, else same as the original function. 

# Call this file through  source("survival_analysis/plotHR_hiroshiFunction.R")
# and use plotHR2, with argument rescaleHR = TRUE





plotHR2 <- function(models,
                    
                    #Added by Hiroshi - new argument to standardize HR to 1
                    rescaleHR = F,
                    term = 1,
                    se = TRUE,
                    cntrst = ifelse(inherits(models, "rms") ||
                                      inherits(models[[1]], "rms"), TRUE, FALSE),
                    polygon_ci = TRUE,
                    rug = "density",
                    xlab = "",
                    ylab = "Hazard Ratio",
                    main = NULL,
                    xlim = NULL,
                    ylim = NULL,
                    col.term = "#08519C",
                    col.se = "#DEEBF7",
                    col.dens = grey(.9),
                    lwd.term = 3,
                    lty.term = 1,
                    lwd.se = lwd.term,
                    lty.se = lty.term,
                    x.ticks = NULL,
                    y.ticks = NULL,
                    ylog = TRUE,
                    cex = 1,
                    y_axis_side = 2,
                    plot.bty = "n",
                    axes = TRUE,
                    alpha = .05,
                    ...) {
  
  # If the user wants to compare different models the same graph
  # the first dataset is then choosen as the default dataset
  # for getting the rug data.
  if (length(class(models)) != 1 || !inherits(models, "list")) {
    models <- list(models)
  }
  
  # Create vectors of the colors, line types etc to
  # allow for specific settings for each model
  confint_style <- lapply(1:length(models),
                          function(i) {
                            ret <- expand.grid(c("col", "lty", "lwd"), c("term", "se")) |>
                              apply(FUN = paste, MARGIN = 1, collapse = ".") |>
                              c("polygon_ci") |>
                              sapply(function(x) {
                                var <- get(x)
                                if (length(var) == 1) return(var)
                                if (length(var) == length(models)) return(var[[i]])
                                stop("Invalid length of ", x, ": ", length(var), " - should be 1 or 0")
                              }, simplify = FALSE)
                          })
  
  # set plotting parameters
  par(las = 1, cex = cex)
  
  # Get the term number and it's label
  all.labels <- prGetModelVariables(models[[1]], remove_splines = FALSE)
  
  # Allow the term searched for be a string
  if (is.character(term)) {
    term <- grep(term, all.labels)
    if (length(term) != 1) {
      stop(
        "Could not find one match for term: '", term, "'",
        " among the terms '", paste(all.labels, collapse = "', '"), "'"
      )
    }
  }
  
  # pick the name of the main term which is going to be plotted
  term.label <- all.labels[term]
  
  if (length(ylim) == 2 &&
      is.vector(ylim)) {
    if (ylog == TRUE) {
      ylim <- log(ylim)
    }
  } else if (!is.null(ylim)) {
    warning(
      "You have provided an invalid ylim argument",
      " that doesn't consist of two elements",
      " in a vector - hence it will be ignored"
    )
    ylim <- NULL
  }
  
  boundaries <- list()
  boundaries$y <- NULL
  if (length(ylim) == 2) {
    boundaries$y <- c(min(ylim), max(ylim))
  }
  
  # Just add the boundary values
  getYBoundaries <- function(ylim, current_limits, variable) {
    # Infinite values don't count
    variable <- variable[!is.infinite(variable)]
    if (length(ylim) == 2) {
      return(c(
        max(min(ylim), min(current_limits, variable)),
        min(max(ylim), max(current_limits, variable))
      ))
    } else if (!is.null(current_limits)) {
      return(c(
        min(current_limits, variable),
        max(current_limits, variable)
      ))
    }
    
    return(c(
      min(variable),
      max(variable)
    ))
  }
  

  
  
  
  xvalues <- NULL
  multi_data <- list()
  for (m in models) {
    est_list <- list(
      model = m,
      ylog = ylog,
      cntrst = cntrst,
      xlim = xlim,
      alpha = alpha,
      term.label = term.label
    )
    
    # Re-use the same data for each model as they are assumed to be nested
    if (length(multi_data) > 0) {
      est_list$new_data <- attr(multi_data[[1]], "new_data")
    }
    
    line_data <- do.call(prPhEstimate, est_list)
    
    
    #Added by Hiroshi edits ###################################################
    if(rescaleHR){
      #maxHR <- max(line_data$estimate)
      maxHR <- max(line_data[line_data$xvalues < 100, "estimate"])
      line_data$estimate <- line_data$estimate - maxHR
      line_data$lower <-    line_data$lower - maxHR
      line_data$upper <-    line_data$upper - maxHR
      #plot(x = line_data$xvalues, y = line_data$estimate)
      #plot(x = line_data$xvalues, y = line_data$estimate_scaled)
      #  plot(x = line_data$xvalues, y = line_data$estimate)
      # prPhConfIntPlot(line_data, polygon = T, col = "blue")
    }
    #End by Hiroshi ##########################################################
    
    
    
    if (length(multi_data) == 0) {
      xvalues <- line_data$xvalues
    }
    
    multi_data <- append(multi_data, list(line_data))
    
    # Update the plot boundaries to the new fit
    boundaries$y <- getYBoundaries(
      ylim = ylim,
      current_limits = boundaries$y,
      variable = line_data$estimate
    )
    
    # Add 10 % to make room for the ticks rug
    if (rug == "ticks") {
      boundaries$y[1] <-
        min(boundaries$y) -
        (boundaries$y[2] - boundaries$y[1]) * .1
    }
  }
  
  
  
  
  # plot empty plot with coordinate system and labels
  boundaries$x <- range(xvalues[])
  if (!tolower(rug) %in% c("density", "ticks") &&
      rug != FALSE &&
      !is.null(rug)) {
    warning("Currently the rug option only supports 'density' or 'ticks'")
  }
  
  # Use first model for density data
  base_data <- prGetModelData(models[[1]])
  xvalues_4_density <- base_data[, term.label]
  
  ## get the quartiles of the main term
  quantiles <- quantile(xvalues_4_density,
                        probs = c(0.025, 0.25, 0.50, 0.75, 0.975)
  )
  
  # Choose within limits
  if (length(xlim) == 2) {
    xvalues_4_density <-
      xvalues_4_density[xvalues_4_density >= min(xlim) &
                          xvalues_4_density <= max(xlim)]
  }
  
  
  
  
  
  structure(list(
    models = models,
    multi_data = multi_data,
    main = main,
    boundaries = boundaries,
    se = se,
    confint_style = confint_style,
    xlab = xlab,
    ylab = ylab,
    ylog = ylog,
    xlim = xlim,
    ylim = ylim,
    plot.bty = plot.bty,
    col.dens = col.dens,
    quantiles = quantiles,
    rug = rug,
    xvalues_4_density = xvalues_4_density,
    ticks = list(
      x = x.ticks,
      y = y.ticks,
      y_axis_side = y_axis_side
    ),
    axes = axes
  ),
  class = "plotHR"
  )
  
  
}


# End of custom function 
###################################################################################################################























### INTERNAL HIDDEN FUNCTIONS GREG ----------------------------------------

#' Gets the non-linear function's estimate
#'
#' The function uses predict if not specified contrast
#' in order to attain the estimate, upper, and lower
#' confidence interval
#'
#' @param model The fit of the model to be plotted
#' @param term.label The name of the label
#' @param ylog If the outcome should be presented in the anti-log form, i.e.
#'  \code{exp()}.
#' @param cntrst A boolean that indicates if the \code{\link[rms]{contrast}()}
#'  function is to be deployed for \pkg{rms} generated functions. The nice
#'  thing is that you get the median as a reference by default.
#' @param xlim The xlim if provided
#' @param new_data If not provided the function looks for the most common values
#'  i.e. median for continuous and mode for factors.
#'  
#' @importFrom rms contrast
#' @importFrom stats na.pass predict
#' 
#' @return \code{data.frame} with the columns xvalues, fit, ucl, lcl
#' 
#' @keywords internal
prPhEstimate <- function(model,
                         term.label,
                         ylog,
                         cntrst,
                         xlim,
                         alpha,
                         new_data) {
  if (missing(new_data)) {
    new_data <- prPhNewData(
      model = model,
      term.label = term.label,
      xlim = xlim
    )
  } else {
    # Unfortunately we cannot rely on all the
    # needed variables to be present among the
    # supplied data-frame and we need to see if
    # we're missing something
    tmp <-
      prPhNewData(
        model = model,
        term.label = term.label,
        xlim = xlim
      )
    
    # Add these variables
    add_vars <- colnames(tmp)[!colnames(tmp) %in% colnames(new_data) &
                                colnames(tmp) != term.label]
    for (dv in add_vars) {
      # Copy the element to the previous new_data
      # Note that the value is the same for the
      # entire column and hence we only need the first value
      new_data[[dv]] <- tmp[1, dv]
    }
    
    # Remove these variables
    rm_vars <- colnames(new_data)[!colnames(new_data) %in% colnames(tmp) &
                                    colnames(new_data) != term.label]
    for (r in rm_vars) {
      new_data[[r]] <- NULL
    }
  }
  
  if (inherits(model, "cph")) {
    if (cntrst) {
      a <- list(new_data[, term.label])
      b <- list(attr(new_data, "median"))
      names(b) <- names(a) <- term.label
      
      for (n in names(new_data)) {
        if (!n %in% names(a)) {
          a[[n]] <- new_data[1, n]
          b[[n]] <- new_data[1, n]
        }
      }
      cntr <- contrast(model,
                       a = a,
                       b = b
      )
      df <- as.data.frame(cntr[c(
        "Contrast",
        "Lower",
        "Upper"
      )])
    } else {
      pred <- predict(model,
                      newdata = new_data,
                      conf.int = 1 - alpha,
                      expand.na = FALSE,
                      na.action = na.pass
      )
      df <- as.data.frame(pred[c("linear.predictors", "lower", "upper")])
    }
  } else {
    if (cntrst) {
      stop(
        "Contrast plotting is not defined for the models of class '",
        paste(class(model), collapse = "', '"), "'"
      )
    } else {
      alt_label <- term.label
      if (!alt_label %in% names(model$assign)) {
        # Assume that the term is contained within a function call
        # such as pspline() or similar
        tmp <- names(model$assign)[grep(alt_label, names(model$assign), fixed = TRUE)]
        if (length(tmp) != 1) {
          stop(
            "Could not identify the term",
            " '", alt_label, "'",
            " among the following model terms:",
            " '", paste(names(model$assign), collapse = "', '"), "'"
          )
        }
        alt_label <- tmp
        rm(tmp)
      }
      pred <- predict(model,
                      newdata = new_data, type = "terms",
                      se.fit = TRUE, terms = alt_label
      )
      pred$upper <- as.double(pred$fit + qnorm(1 - alpha / 2) * pred$se.fit)
      pred$lower <- as.double(pred$fit - qnorm(1 - alpha / 2) * pred$se.fit)
      df <- as.data.frame(pred[c("fit", "lower", "upper")])
    }
  }
  
  colnames(df) <- c(
    "estimate",
    "lower",
    "upper"
  )
  
  df <- cbind(
    xvalues = new_data[, term.label],
    df
  )
  
  # Change to exponential form
  if (ylog == FALSE) {
    for (n in names(df)) {
      if (n != "xvalues") {
        df[, n] <- exp(df[, n])
      }
    }
  }
  
  attr(df, "new_data") <- new_data
  return(df)
}



















#' A function for retrieving new_data argument for predict
#'
#' @param model The model fit from \code{\link[survival]{coxph}()}
#'  or \code{\link[rms]{cph}()}
#' @param term.label The label that is the one that \code{\link{plotHR}()}
#'  intends to plot.
#' @param xlim The x-limits for the plot if any
#' @return \code{data.frame}
#' @keywords internal
prPhNewData <- function(model, term.label, xlim) {
  # Get new data to use as basis for the prediction
  new_data <- prGetModelData(model, terms_only = TRUE, term.label = term.label)
  
  # Remove any Surv class variable as this is not
  # part of the predictors
  new_data <-
    new_data[, sapply(new_data, function(x) !inherits(x, "Surv")),
             drop = FALSE]
  
  getMode <- function(x) {
    tbl <- table(x)
    ret <- names(tbl)[which.max(tbl)]
    factor(ret, levels = names(tbl))
  }
  
  # Set all other but the variable of interest to the
  # mode or the median
  for (variable in colnames(new_data)) {
    if (variable != term.label) {
      if (is.numeric(new_data[, variable])) {
        new_data[, variable] <- median(new_data[, variable])
      } else {
        new_data[, variable] <- getMode(new_data[, variable])
      }
    }
  }
  if (is.numeric(new_data[, term.label])) {
    nd_median <- median(new_data[, term.label], na.rm = TRUE)
  } else {
    nd_median <- getMode(new_data[, term.label])
  }
  
  new_data <- new_data[!duplicated(new_data[, term.label]), , drop = FALSE]
  
  if (!missing(xlim)) {
    if (NCOL(new_data) == 1) {
      new_data <- as.data.frame(
        matrix(
          new_data[new_data >= min(xlim) &
                     new_data <= max(xlim)],
          ncol = 1,
          dimnames = list(NULL, c(term.label))
        )
      )
    } else {
      new_data <- new_data[new_data[, term.label] >= min(xlim) &
                             new_data[, term.label] <= max(xlim), ,
                           drop = FALSE
      ]
    }
  }
  
  attr(new_data, "median") <- nd_median
  return(new_data)
}









#' Plots the confidence intervals
#'
#' Uses \code{\link[graphics]{polygon}()} or
#' \code{\link[graphics]{lines}()} to plot confidence
#' intervals.
#'
#' @param model_data A data frame with 'xvalues', 'upper', and 'lower'
#'  columns.
#' @param color The color of the line/polygon
#' @param polygon Boolean indicating polygon or line
#' @param lwd Line width - see \code{\link[grid]{gpar}()}
#' @param lty Line type - see \code{\link[grid]{gpar}()}
#' @keywords internal
#' @return \code{void} The function performs the print
prPhConfIntPlot <- function(model_data, color, polygon, lwd, lty) {
  current_i.backw <- order(model_data$xvalues, decreasing = TRUE)
  current_i.forw <- order(model_data$xvalues)
  
  if (polygon) {
    # The x-axel is always the same
    x.poly <- c(model_data$xvalues[current_i.forw], model_data$xvalues[current_i.backw])
    # The y axel is based upin the current model
    y.poly <- c(model_data$upper[current_i.forw], model_data$lower[current_i.backw])
    polygon(x.poly, y.poly, col = color, border = NA)
  } else {
    lines(model_data$xvalues[current_i.forw], model_data$upper[current_i.forw],
          col = color,
          lwd = lwd, lty = lty
    )
    lines(model_data$xvalues[current_i.forw],
          model_data$lower[current_i.forw],
          col = color,
          lwd = lwd, lty = lty
    )
  }
}






#' Plot a rug on the datapoints
#'
#' @param xvalues The xvalues that are used for the density
#' @return \code{void}
#' @keywords internal
#' @importFrom stats fivenum
prPhRugPlot <- function(xvalues) {
  # rugs at datapoints
  axis(
    side = 1,
    line = 0,
    at = jitter(xvalues),
    labels = FALSE,
    tick = TRUE,
    tcl = 0.8,
    lwd.ticks = 0.1,
    lwd = 0
  )
  
  # rugs and labels at 1Q, median and 3Q
  axis(
    side = 1,
    line = -1.5,
    at = fivenum(xvalues)[2:4],
    lwd = 0,
    tick = TRUE,
    tcl = 1.2,
    lwd.ticks = 1,
    col.ticks = "black",
    labels = c("Quartile 1", "Median", "Quartile 3"),
    cex.axis = 0.7,
    col.axis = "black",
    padj = -2.8
  )
  axis(
    side = 1,
    line = 0.0,
    at = fivenum(xvalues)[2:4],
    lwd = 0,
    tick = TRUE,
    tcl = 0.2,
    lwd.ticks = 1,
    col.ticks = "black",
    labels = FALSE
  )
}

#' Plot a density on the datapoints
#'
#' @param xvalues The xvalues that are used for the density
#' @param color The color of the density polygon
#' @return \code{void}
#' @keywords internal
prPhDensityPlot <- function(xvalues, color) {
  # calculate the coordinates of the density function
  density <- density(xvalues)
  # the height of the densityity curve
  max.density <- max(density$y)
  
  # Get the boundaries of the plot to
  # put the density polygon at the x-line
  plot_coordinates <- par("usr")
  
  # get the "length" and range of the y-axis
  y.scale <- plot_coordinates[4] - plot_coordinates[3]
  
  # transform the y-coordinates of the density
  # to the lower 10% of the plotting panel
  density$y <- (0.1 * y.scale / max.density) * density$y + plot_coordinates[3]
  
  ## plot the polygon
  polygon(density$x, density$y,
          border = FALSE, col = color
  )
}




















## Copyright (C) 2009 Reinhard Seifert,
## biostatistician at Haukeland University Hospital Bergen, Norway.
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by the
## Free Software Foundation; either version 2, or (at your option) any
## later version.
##
## These functions are distributed in the hope that they will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## The text of the GNU General Public License, version 2, is available
## as http://www.gnu.org/copyleft or by writing to the Free Software
## Foundation, 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

## Improvements made 2012 by Max Gordon,
## orthopaedic surgeon and PhD-student at the Karolinska Institute
##
## The changes consist of adaptation for use with the rms package,
## multiple models plotting and some code optimization


#' Plot a spline in a Cox regression model
#'
#' This function is a more specialized version of the \code{\link{termplot}()} function. It
#' creates a plot with the spline against hazard ratio. The plot can additianally have
#' indicator of variable density and have multiple lines.
#'
#' @section Multiple models in one plot:
#'
#' The function allows for plotting multiple splines in one graph. Sometimes you
#' might want to show more than one spline for the same variable. This allows
#' you to create that comparison.
#'
#' Examples of a situation where I've used multiple splines in one plot is when
#' I want to look at a variables behavior in different time periods. This is another
#' way of looking at the proportional hazards assumption. The Schoenfeld residuals
#' can be a little tricky to look at when you have the splines.
#'
#' Another example of when I've used this is when I've wanted to plot adjusted and
#' unadjusted splines. This can very nicely demonstrate which of the variable span is
#' mostly confounded. For instance - younger persons may exhibit a higher risk for a
#' procedure but when you put in your covariates you find that the increased hazard
#' changes back to the basic
#'
#' @param models A single model or a list() with several models
#' @param term The term of interest. Can be either the name or the number of the
#'  covariate in the model.
#' @param se Boolean if you want the confidence intervals or not
#' @param cntrst By contrasting values you can have the median as a reference
#'  point making it easier to compare hazard ratios.
#' @param polygon_ci If you want a polygon as indicator for your confidence interval.
#'  This can also be in the form of a vector if you have several models. Sometimes
#'  you only want one model to have a polygon and the rest to be dotted lines. This
#'  gives the reader an indication of which model is important.
#' @param rug The rug is the density of the population along the spline variable. Often
#'  this is displayed as a jitter with bars that are thicker & more common when there
#'  are more observations in that area or a smooth density plot that looks like a
#'  mountain. Use "density" for the mountain view and "ticks" for the jitter format.
#' @param xlab The label of the x-axis
#' @param ylab The label of the y-axis
#' @param main The main title of the plot
#' @param xlim A vector with 2 elements containing the upper & the lower bound of the x-axis
#' @param ylim A vector with 2 elements containing the upper & the lower bound of the y-axis
#' @param col.term The color of the estimate line. If multiple lines you can have
#'  different colors by giving a vector.
#' @param col.se The color of the confidence interval. If multiple lines you can have
#'  different colors by giving a vector.
#' @param col.dens The color of the density plot. Ignored if you're using jitter
#' @param lwd.term The width of the estimated line. If you have more than one model then
#'  provide the function with a vector if you want to have different lines for
#'  different width for each model.
#' @param lty.term The typeof the estimated line, see lty. If you have more than one model
#'  then provide the function with a vector if you want to have different line types for
#'  for each model.
#' @param lwd.se The line width of your confidence interval. This is ignored if you're using
#'  polygons for all the confidence intervals.
#' @param lty.se The line type of your confidence interval.  This is ignored if you're using
#'  polygons for all the confidence intervals.
#' @param x.ticks The ticks for the x-axis if you desire other than the default.
#' @param y.ticks The ticks for the y-axis if you desire other than the default.
#' @param ylog Show a logarithmic y-axis. Not having a logarithmic axis might seem easier
#'  to understand but it's actually not really a good idea. The distance between HR 0.5 and
#'  2.0 should be the same. This will only show on a logarithmic scale and therefore it is
#'  strongly recommended to use the logarithmic scale.
#' @param cex Increase if you want larger font size in the graph.
#' @param plot.bty Type of box that you want. See the bty description in
#'  graphical parameters (par). If bty is one of "o" (the default),
#'  "l", "7", "c", "u", or "]" the resulting box resembles the corresponding
#'  upper case letter. A value of "n" suppresses the box.
#' @param y_axis_side The side that the y axis is to be plotted, see axis() for details
#' @param axes A boolean that is used to identify if axes are to be plotted
#' @param alpha The alpha level for the confidence intervals
#' @param ... Any additional values that are to be sent to the plot() function
#' @return The function does not return anything
#'
#' @example inst/examples/plotHR_example.R
#'
#' @importFrom Gmisc fastDoCall
#' @importFrom grDevices grey
#' @importFrom graphics axTicks axis box lines par plot polygon
#' @importFrom stats quantile
#' @author Reinhard Seifert, Max Gordon
#'
#' @export
#' @rdname plotHR

























#' @exportS3Method
#' @rdname plotHR
#' @param x Sent the `plotHR` object to plot
print.plotHR <- function(x, ...) {
  plot(x, ...)
}














#' @exportS3Method
#' @rdname plotHR
#' @param y Ignored in plot
plot.plotHR <- function(x, y, ...) {
  if (!missing(y)) stop("Unexpected y parameter")
  plot(
    y = x$boundaries$y,
    x = x$boundaries$x,
    xlab = x$xlab,
    ylab = x$ylab,
    main = x$main,
    xaxs = "i",
    yaxs = "i",
    type = "n",
    axes = FALSE,
    ...
  )
  
  # plot CI as polygon shade - if 'se = TRUE' (default)
  if (x$se) {
    # Plot the last on top
    for (i in length(x$models):1) {
      prPhConfIntPlot(
        model_data = x$multi_data[[i]],
        color = x$confint_style[[i]]$col.se,
        polygon = x$confint_style[[i]]$polygon_ci,
        lwd = x$confint_style[[i]]$lwd.se,
        lty = x$confint_style[[i]]$lty.se
      )
    }
  }
  
  if (x$rug == "density") {
    prPhDensityPlot(x$xvalues_4_density,
                    color = x$col.dens
    )
  }
  
  # plot white lines (background color) for:
  # 2.5%tile, 1Q, median, 3Q and 97.5%tile
  # through confidence shade and density plot
  axis(
    side = 1,
    at = x$quantiles,
    labels = FALSE,
    lwd = 0,
    col.ticks = "white",
    lwd.ticks = 1,
    tck = 1
  )
  
  if (x$rug == "ticks") {
    prPhRugPlot(xvalues = x$xvalues_4_density)
  }
  
  # Plot the last fit on top, therefore use the reverse
  for (i in length(x$models):1) {
    current_i.forw <- order(x$multi_data[[i]]$xvalues)
    
    # Plots the actual regression line
    lines(
      x = x$multi_data[[i]]$xvalues[current_i.forw],
      y = x$multi_data[[i]]$estimate[current_i.forw],
      col = x$confint_style[[i]]$col.term,
      lwd = x$confint_style[[i]]$lwd.term,
      lty = x$confint_style[[i]]$lty.term
    )
  }
  
  # plot the axes
  if (x$axes) {
    axis(side = 1, at = x$ticks$x)
    if (is.null(x$ticks$y)) {
      x$ticks$y <- axTicks(2)
    } else if (x$ylog == TRUE) {
      # This is an assumption that the ticks
      # aren't provided in log
      x$ticks$y <- log(x$ticks$y)
    }
    
    
    if (x$ylog == TRUE) {
      y.ticks_labels <- ifelse(exp(x$ticks$y) >= 1,
                               sprintf("%0.1f", exp(x$ticks$y)),
                               sprintf("%0.2f", exp(x$ticks$y))
      )
      
      # Get familiar y-axis instead of the log
      axis(
        side = x$ticks$y_axis_side,
        at = x$ticks$y,
        labels = y.ticks_labels
      )
    } else {
      axis(side = x$ticks$y_axis_side, at = x$ticks$y)
    }
  }
  
  # plot a box around plotting panel if specified - not plotted by default
  box(bty = x$plot.bty)
}
















#' Get model data.frame
#'
#' Returns the raw variables from the original data
#' frame using the \code{\link[stats:model.frame]{get_all_vars}()}
#' but with the twist that it also performs any associated
#' subsetting based on the model's \code{\link[base]{subset}()} argument.
#'
#' @param x The fitted model.
#' @param terms_only Only use the right side of the equation by selecting the terms
#' @param term.label Sometimes need to retrieve specific spline labels that are not among
#'  the `labels(terms(x))`
#' @return data.frame
#' @importFrom stats get_all_vars
#'
#' @importFrom stats terms
#' @keywords internal
prGetModelData <- function(x, terms_only = FALSE, term.label) {
  # Extract the variable names
  true_vars <- all.vars(as.formula(x))
  
  # Get the environment of the formula
  env <- environment(as.formula(x))
  data <- eval(x$call$data,
               envir = env
  )
  
  # The data frame without the
  mf <- get_all_vars(as.formula(x),
                     data = data
  )
  
  if (terms_only) {
    cols2keep <- labels(terms(x))
    if (!missing(term.label)) {
      cols2keep <- c(cols2keep, term.label)
    }
    
    mf <- mf[, names(mf) %in% cols2keep, drop = FALSE]
  }
  
  if (!is.null(x$call$subset)) {
    if (!is.null(data)) {
      # As we don't know if the subsetting argument
      # contained data from the data frame or the environment
      # we need this additional check
      mf <- tryCatch(mf[eval(x$call$subset,
                             envir = data,
                             enclos = env
      ), ],
      error = function(e) {
        stop("Could not deduce the correct subset argument when extracting the data. ", e)
      }
      )
    } else {
      mf <- mf[eval(x$call$subset,
                    envir = env
      ), ]
    }
  }
  
  return(mf)
}


















# This file contains all the helper funcitons that the outer exported
# functions utilize. I try to have a pr at the start of the name for all
# the private functions.
#
# Author: max
###############################################################################

#' Looks for unique rowname match without grep
#'
#' Since a rowname may contain characters reserved by regular
#' expressions I've found it easier to deal with the rowname
#' finding by just checking for matching strings at the beginning
#' of the name while at the same time excluding names that have the
#' same stem, i.e. DM and DM_COMP will cause an issue since DM will
#' match both rows.
#'
#' @param rnames A vector with the rownames that are looked for
#' @param vn The variable name that is of interest
#' @param vars A vector with all the names and the potentially competing names
#' @return integer A vector containing the position of the matches
#'
#' TODO: remove this function in favor of the more powerful prMapVariable2Name
#' @keywords internal
prFindRownameMatches <- function(rnames, vn, vars) {
  # Find the beginning of the string that matches exactly to the var. name
  name_stub <- substr(rnames, 1, nchar(vn))
  matches <- which(name_stub == vn)
  
  # Since the beginning of the name may not be unique we need to
  # check for other "competing matches"
  # TODO: make this fix more elegant
  vars_name_stub <- substr(vars, 1, nchar(vn))
  if (sum(vars_name_stub == vn) > 1) {
    competing_vars <- vars[vars != vn &
                             vars_name_stub == vn]
    
    competing_matches <- NULL
    for (comp_vn in competing_vars) {
      competing_name_stub <- substr(rnames, 1, nchar(comp_vn))
      competing_matches <-
        c(
          competing_matches,
          which(competing_name_stub == comp_vn)
        )
    }
    
    # Clean out competing matches
    matches <- matches[!matches %in% competing_matches]
  }
  
  return(matches)
}

#' Get model outcome
#'
#' Uses the model to extract the outcome variable. Throws
#' error if unable to find the outcome.
#'
#' @param model The fitted model
#' @param mf The dataset that the model is fitted to - if missing it
#'  uses the \code{\link[stats]{model.frame}()} dataset. This can cause
#'  length issues as there may be variables that are excluded from the
#'  model for different reasons.
#' @return vector
#' @importFrom stats as.formula 
#'
#' @keywords internal
prExtractOutcomeFromModel <- function(model, mf) {
  if (missing(mf)) {
    mf <- model.frame(model)
    outcome <- mf[, names(mf) == deparse(as.formula(model)[[2]])]
  } else {
    outcome <- eval(as.formula(model)[[2]], envir = mf)
  }
  if (is.null(outcome)) {
    stop(
      "Could not identify the outcome: ", deparse(as.formula(model)[[2]]),
      " among the model.frame variables: '", paste(names(mf), collapse = "', '"), "'"
    )
  }
  
  # Only use the status when used for survival::Surv objects
  if (inherits(outcome, "Surv")) {
    return(outcome[, "status"])
  }
  
  return(outcome)
}

#' Get model data.frame
#'
#' Returns the raw variables from the original data
#' frame using the \code{\link[stats:model.frame]{get_all_vars}()}
#' but with the twist that it also performs any associated
#' subsetting based on the model's \code{\link[base]{subset}()} argument.
#'
#' @param x The fitted model.
#' @param terms_only Only use the right side of the equation by selecting the terms
#' @param term.label Sometimes need to retrieve specific spline labels that are not among
#'  the `labels(terms(x))`
#' @return data.frame
#' @importFrom stats get_all_vars
#'
#' @importFrom stats terms
#' @keywords internal
prGetModelData <- function(x, terms_only = FALSE, term.label) {
  # Extract the variable names
  true_vars <- all.vars(as.formula(x))
  
  # Get the environment of the formula
  env <- environment(as.formula(x))
  data <- eval(x$call$data,
               envir = env
  )
  
  # The data frame without the
  mf <- get_all_vars(as.formula(x),
                     data = data
  )
  
  if (terms_only) {
    cols2keep <- labels(terms(x))
    if (!missing(term.label)) {
      cols2keep <- c(cols2keep, term.label)
    }
    
    mf <- mf[, names(mf) %in% cols2keep, drop = FALSE]
  }
  
  if (!is.null(x$call$subset)) {
    if (!is.null(data)) {
      # As we don't know if the subsetting argument
      # contained data from the data frame or the environment
      # we need this additional check
      mf <- tryCatch(mf[eval(x$call$subset,
                             envir = data,
                             enclos = env
      ), ],
      error = function(e) {
        stop("Could not deduce the correct subset argument when extracting the data. ", e)
      }
      )
    } else {
      mf <- mf[eval(x$call$subset,
                    envir = env
      ), ]
    }
  }
  
  return(mf)
}
















#' Get the models variables
#'
#' This function extract the modelled variables. Any interaction
#' terms are removed as those should already be represented by
#' the individual terms.
#'
#' @param model A model fit
#' @param remove_splines If splines, etc. should be cleaned
#'  from the variables as these no longer are "pure" variables
#' @param remove_interaction_vars If interaction variables are
#'  not interesting then these should be removed. Often in
#'  the case of \code{\link{printCrudeAndAdjustedModel}()} it is impossible
#'  to properly show interaction variables and it's better to show
#'  these in a separate table
#' @param add_intercept Adds the intercept if it exists
#' @return vector with names
#'
#' @importFrom stringr str_split
#' @importFrom stringr str_trim
#' @keywords internal
prGetModelVariables <- function(model,
                                remove_splines = TRUE,
                                remove_interaction_vars = FALSE,
                                add_intercept = FALSE) {
  # We need the call names in order to identify
  # - interactions
  # - functions such as splines, I()
  if (inherits(model, "nlme")) {
    vars <- attr(model$fixDF$terms, "names")
  } else {
    vars <- attr(model$terms, "term.labels")
  }
  
  strata <- NULL
  if (any(grepl("^strat[a]{0,1}\\(", vars))) {
    strata <- vars[grep("^strat[a]{0,1}\\(", vars)]
    vars <- vars[-grep("^strat[a]{0,1}\\(", vars)]
  }
  
  cluster <- NULL
  if (any(grepl("^cluster{0,1}\\(", vars))) {
    cluster <- vars[grep("^cluster{0,1}\\(", vars)]
    vars <- vars[-grep("^cluster{0,1}\\(", vars)]
  }
  # Fix for bug in cph and coxph
  if (is.null(cluster) &&
      inherits(model, c("cph", "coxph"))) {
    alt_terms <- stringr::str_trim(strsplit(deparse(model$call$formula[[3]]),
                                            "+",
                                            fixed = TRUE
    )[[1]])
    if (any(grepl("^cluster{0,1}\\(", alt_terms))) {
      cluster <- alt_terms[grep("^cluster{0,1}\\(", alt_terms)]
    }
  }
  
  # Remove I() as these are not true variables
  unwanted_vars <- grep("^I\\(.*$", vars)
  if (length(unwanted_vars) > 0) {
    attr(vars, "I() removed") <- vars[unwanted_vars]
    vars <- vars[-unwanted_vars]
  }
  
  pat <- "^[[:alpha:]\\.]+[^(]+\\(.*$"
  fn_vars <- grep(pat, vars)
  if (length(fn_vars) > 0) {
    if (remove_splines) {
      # Remove splines and other functions
      attr(vars, "functions removed") <- vars[fn_vars]
      vars <- vars[-fn_vars]
    } else {
      # Cleane the variable names into proper names
      # the assumption here is that the real variable
      # name is the first one in the parameters
      pat <- "^[[:alpha:]\\.]+.*\\(([^,)]+).*$"
      vars[fn_vars] <- sub(pat, "\\1", vars[fn_vars])
    }
  }
  
  # Remove interaction terms as these are not variables
  int_term <- "^.+:.+$"
  in_vars <- grep(int_term, vars)
  if (length(in_vars) > 0) {
    if (remove_interaction_vars) {
      in_vn <- unlist(str_split(vars[in_vars], ":"),
                      use.names = FALSE
      )
      in_vars <- unique(c(in_vars, which(vars %in% in_vn)))
    }
    attr(vars, "interactions removed") <- vars[in_vars]
    vars <- vars[-in_vars]
  }
  
  if (add_intercept &&
      grepl("intercept", names(coef(model))[1], ignore.case = TRUE)) {
    vars <- c(
      names(coef(model))[1],
      vars
    )
  }
  
  clean_vars <- unique(vars)
  attributes(clean_vars) <- attributes(vars)
  if (!is.null(strata)) {
    attr(clean_vars, "strata") <- strata
  }
  if (!is.null(cluster)) {
    attr(clean_vars, "cluster") <- cluster
  }
  
  return(clean_vars)
}

#' Get statistics according to the type
#'
#' A simple function applied by the \code{\link[Gmisc]{getDescriptionStatsBy}()}
#' for the total column. This function is also used by \code{\link{printCrudeAndAdjustedModel}()}
#' in case of a basic linear regression is asked for a raw stat column
#'
#' @param x The variable that we want the statistics for
#' @param show_perc If this is a factor/proportion variable then we
#'  might want to show the percentages
#' @param html If the output should be in html or LaTeX formatting
#' @param digits Number of decimal digits
#' @param numbers_first If number is to be prior to the percentage
#' @param useNA If missing should be included
#' @param show_all_values This is by default false as for instance if there is
#'  no missing and there is only one variable then it is most sane to only show
#'  one option as the other one will just be a complement to the first. For instance
#'  sex - if you know gender then automatically you know the distribution of the
#'  other sex as it's 100 \% - other \%.
#' @param continuous_fn A function for describing continuous variables
#'  defaults to \code{\link{describeMean}()}
#' @param prop_fn A function for describing proportions, defaults to
#'  the factor function
#' @param factor_fn A function for describing factors, defaults to
#'  \code{\link{describeFactors}()}
#' @param percentage_sign If you want to suppress the percentage sign you
#'  can set this variable to FALSE. You can also choose something else that
#'  the default \% if you so wish by setting this variable.
#' @return A matrix or a vector depending on the settings
#'
#' TODO: Use the Gmisc function instead of this copy
#'
#' @importFrom Gmisc describeMean
#' @importFrom Gmisc describeFactors
#' @keywords internal
prGetStatistics <- function(x,
                            show_perc = FALSE,
                            html = TRUE,
                            digits = 1,
                            numbers_first = TRUE,
                            useNA = "no",
                            show_all_values = FALSE,
                            continuous_fn = describeMean,
                            factor_fn = describeFactors,
                            prop_fn = factor_fn,
                            percentage_sign = percentage_sign) {
  useNA <- prConvertShowMissing(useNA)
  if (is.factor(x) ||
      is.logical(x) ||
      is.character(x)) {
    if (length(unique(x)) == 2) {
      if (show_perc) {
        total_table <- prop_fn(x,
                               html = html,
                               digits = digits,
                               number_first = numbers_first,
                               useNA = useNA,
                               percentage_sign = percentage_sign
        )
      } else {
        total_table <- table(x, useNA = useNA)
        names(total_table)[is.na(names(total_table))] <- "Missing"
        # Choose only the reference level
        # Note: Currently references are required
        if (show_all_values == FALSE && FALSE) {
          total_table <- total_table[names(total_table) %in% c(levels(x)[1], "Missing")]
        }
      }
    } else {
      if (show_perc) {
        total_table <- factor_fn(x,
                                 html = html,
                                 digits = digits,
                                 number_first = numbers_first,
                                 useNA = useNA,
                                 percentage_sign = percentage_sign
        )
      } else {
        total_table <- table(x, useNA = useNA)
        names(total_table)[is.na(names(total_table))] <- "Missing"
      }
    }
  } else {
    total_table <- continuous_fn(x,
                                 html = html, digits = digits,
                                 number_first = numbers_first,
                                 useNA = useNA
    )
    
    # If a continuous variable has two rows then it's assumed that the second is the missing
    if (length(total_table) == 2 &&
        show_perc == FALSE) {
      total_table[2] <- sum(is.na(x))
    }
  }
  return(total_table)
}


#' A function for converting a useNA variable
#'
#' The variable is suppose to be directly compatible with
#' table(..., useNA = useNA). It throughs an error
#' if not compatible
#'
#' @param useNA Boolean or "no", "ifany", "always"
#' @return string
#'
#' @keywords internal
prConvertShowMissing <- function(useNA) {
  if (useNA == FALSE || useNA == "no") {
    useNA <- "no"
  } else if (useNA == TRUE) {
    useNA <- "ifany"
  }
  
  if (!useNA %in% c("no", "ifany", "always")) {
    stop(sprintf("You have set an invalid option for useNA variable, '%s' ,it should be boolean or one of the options: no, ifany or always.", useNA))
  }
  
  return(useNA)
}







#' A function that tries to resolve what variable corresponds to what row
#'
#' As both the \code{\link{getCrudeAndAdjustedModelData}()} and the
#' \code{\link{printCrudeAndAdjustedModel}()} need to now exactly
#' what name from the \code{\link[stats]{coef}()}/\code{\link[rms]{summary.rms}()}
#' correspond to we for generalizeability this rather elaborate function.
#'
#' @param var_names The variable names that are saught after
#' @param available_names The names that are available to search through
#' @param data The data set that is saught after
#' @param force_match Whether all variables need to be identified or not.
#'  E.g. you may only want to use some variables and already pruned the
#'  \code{available_names} and therefore wont have matches. This is the
#'  case when \code{\link{getCrudeAndAdjustedModelData}()} has been used together
#'  with the \code{var_select} argument.
#' @return \code{list} Returns a list with each element has the corresponding
#'  variable name and a subsequent list with the parameters \code{no_rows}
#'  and \code{location} indiciting the number of rows corresponding to that
#'  element and where those rows are located. For factors the list also contains
#'  \code{lvls} and \code{no_lvls}.
#' @keywords internal
#' @import utils
prMapVariable2Name <- function(var_names, available_names,
                               data, force_match = TRUE) {
  if (any(duplicated(available_names))) {
    stop(
      "You have non-unique names. You probably need to adjust",
      " (1) variable names or (2) factor labels."
    )
  }
  
  # Start with figuring out how many rows each variable
  var_data <- list()
  for (name in var_names) {
    if (grepl("intercept", name, ignore.case = TRUE)) {
      var_data[[name]] <-
        list(no_rows = 1)
    } else if (is.factor(data[, name])) {
      var_data[[name]] <-
        list(lvls = levels(data[, name]))
      # Sometimes due to subsetting some factors don't exist
      # we therefore need to remove those not actually in the dataset
      var_data[[name]]$lvls <-
        var_data[[name]]$lvls[var_data[[name]]$lvls %in%
                                as.character(unique(data[, name][!is.na(data[, name])]))]
      var_data[[name]][["no_lvls"]] <- length(var_data[[name]]$lvls)
      var_data[[name]][["no_rows"]] <- length(var_data[[name]]$lvls) - 1
    } else {
      var_data[[name]] <-
        list(no_rows = 1)
    }
  }
  
  # A function for stripping the name and the additional information
  # from the available name in order to get the cleanest form
  getResidualCharacters <- function(search, conflicting_name) {
    residual_chars <- substring(conflicting_name, nchar(search) + 1)
    if (!is.null(var_data[[search]]$lvls)) {
      best_resid <- residual_chars
      
      for (lvl in var_data[[search]]$lvls) {
        new_resid <- sub(lvl, "", residual_chars,
                         fixed = TRUE
        )
        if (nchar(new_resid) < nchar(best_resid)) {
          best_resid <- new_resid
          if (nchar(new_resid) == 0) {
            break
          }
        }
      }
      residual_chars <- best_resid
    }
    return(residual_chars)
  }
  
  matched_names <- c()
  matched_numbers <- c()
  org_available_names <- available_names
  # Start with simple non-factored variables as these should give a single-line match
  # then continue with the longest named variable
  for (name in var_names[order(sapply(var_data, function(x) is.null(x$lvls)),
                               nchar(var_names),
                               decreasing = TRUE
  )]) {
    matches <- which(name == substr(available_names, 1, nchar(name)))
    if (length(matches) == 0) {
      if (force_match) {
        stop(
          "Sorry but the function could not find a match for '", name, "'",
          " among any of the available names: '", paste(org_available_names,
                                                        collapse = "', '"
          ), "'"
        )
      }
    } else if (length(matches) == 1) {
      if (var_data[[name]]$no_rows != 1) {
        stop(
          "Expected more than one match for varible '", name, "'",
          " the only positive match was '", available_names[matches], "'"
        )
      }
    } else if (length(var_names) > length(matched_names) + 1) {
      if (is.null(var_data[[name]]$lvls) &&
          sum(name == available_names) == 1) {
        # Check if the searched for variable is a non-factor variable
        # if so then match if there is a perfect match
        
        matches <- which(name == available_names)
      } else if (length(var_names) > length(matched_names) + 1) {
        
        # Check that there is no conflicting match
        conflicting_vars <- var_names[var_names != name &
                                        !var_names %in% matched_names]
        possible_conflicts <- c()
        for (conf_var in conflicting_vars) {
          possible_conflicts <-
            union(
              possible_conflicts,
              which(substr(available_names, 1, nchar(conflicting_vars)) %in%
                      conflicting_vars)
            )
        }
        conflicts <- intersect(possible_conflicts, matches)
        if (length(conflicts) > 0) {
          conflicting_vars <- conflicting_vars[sapply(
            conflicting_vars,
            function(search) {
              any(search == substr(available_names, 1, nchar(search)))
            }
          )]
          
          for (conflict in conflicts) {
            # We will try to find a better match that leaves fewer "residual characters"
            # than what we started with
            start_res_chars <- getResidualCharacters(name, available_names[conflict])
            
            best_match <- NULL
            best_conf_name <- NULL
            for (conf_name in conflicting_vars) {
              resid_chars <- getResidualCharacters(conf_name, available_names[conflict])
              if (is.null(best_match) ||
                  nchar(best_match) > nchar(resid_chars)) {
                best_match <- resid_chars
                best_conf_name <- conf_name
              }
            }
            
            if (nchar(start_res_chars) == nchar(best_match)) {
              stop(
                "The software can't decide which name belongs to which variable.",
                " The variable that is searched for is '", name, "'",
                " and there is a conflict with the variable '", best_conf_name, "'.",
                " The best match for '", name, "' leaves: '", start_res_chars, "'",
                " while the conflict '", best_conf_name, "' leaves: '", best_match, "'",
                " when trying to match the name: '", available_names[conflict], "'"
              )
            } else if (nchar(start_res_chars) > nchar(best_match)) {
              # Now remove the matched row if we actually found a better match
              matches <- matches[matches != conflict]
            }
          }
        }
      }
      if (length(matches) == 0) {
        stop(
          "Could not identify the rows corresponding to the variable '", name, "'",
          " this could possibly be to similarity between different variable names",
          " and factor levels. Try to make sure that all variable names are unique",
          " the variables that are currently looked for are:",
          " '", paste(var_names,
                      collapse = "', '"
          ),
          "'."
        )
      }
    }
    
    # Check that multiple matches are continuous, everything else is suspicious
    if (length(matches) > 1) {
      matches <- matches[order(matches)]
      if (any(1 != tail(matches, length(matches) - 1) -
              head(matches, length(matches) - 1))) {
        stop(
          "The variable '", name, "' failed to provide an adequate",
          " consequent number of matches, the names matched are located at:",
          " '", paste(matches, collapse = "', '"), "'"
        )
      }
    }
    
    # Since we remove the matched names we need to look back at the original and
    # find the exact match in order to deduce the true number
    true_matches <- which(org_available_names %in%
                            available_names[matches])
    # Avoid accidentally rematching
    true_matches <- setdiff(true_matches, matched_numbers)
    var_data[[name]][["location"]] <- true_matches
    # Update the loop vars
    if (length(matches) > 0) {
      available_names <- available_names[-matches]
    }
    
    matched_names <- c(matched_names, name)
    matched_numbers <- c(matched_numbers, true_matches)
    
    if (length(var_data[[name]][["location"]]) == 0 &
        !force_match) {
      # Remove variable as it is not available
      var_data[[name]] <- NULL
    } else if (length(var_data[[name]][["location"]]) !=
               var_data[[name]][["no_rows"]]) {
      warning(
        "Expected the variable '", name, "'",
        " to contain '", var_data[[name]][["no_rows"]], "' no. rows",
        " but got '", length(var_data[[name]][["location"]]), "' no. rows."
      )
      var_data[[name]][["no_rows"]] <- length(var_data[[name]][["location"]])
    }
  }
  
  return(var_data)
}





#' Runs an \code{\link[Gmisc]{fastDoCall}()} within the environment of the model
#'
#' Sometimes the function can't find some of the variables that
#' were available when running the original variable. This function
#' uses the \code{\link[stats:formula]{as.formula}()} together with
#' \code{\link[base]{environment}()} in order to get the environment
#' that the original code used.
#'
#' @param model The model used
#' @param what The function or non-empty character string used for
#'  \code{\link[Gmisc]{fastDoCall}()}
#' @param ... Additional arguments passed to the function
#' @keywords internal
prEnvModelCall <- function(model, what, ...) {
  call_lst <- list(object = model)
  dots <- list(...)
  if (length(dots) > 0) {
    for (i in 1:length(dots)) {
      if (!is.null(names(dots)[i])) {
        call_lst[[names(dots)[i]]] <- dots[[i]]
      } else {
        call_lst <- c(
          call_lst,
          dots[[i]]
        )
      }
    }
  }
  model_env <- new.env(parent = environment(as.formula(model)))
  model_env$what <- what
  model_env$call_lst <- call_lst
  fastDoCall(what, call_lst,
             envir = model_env
  )
}

