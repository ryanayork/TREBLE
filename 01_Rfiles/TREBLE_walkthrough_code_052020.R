rm(list=ls());
options(stringsAsFactors=F);
library(umap)
library(scales)
library(MASS)
library(RColorBrewer)
library(colorRamps)
library(ape)

####################
#####Functions######
####################
#Function to extract windows of user defined features, size x and stepsize y
get_windows = function(features,
                       window_size = 10,
                       step_size = 1,
                       name = NULL){
  
  #Get windows
  peaks1 = splitWithOverlap(features, window_size, window_size-step_size)
  
  #Clean and combine into matrix
  peaks1 = peaks1[1:(length(peaks1)-window_size)]
  peaks1 = lapply(peaks1, function(x) unlist(as.data.frame(x)))
  peaks1 = do.call(cbind, peaks1)
  
  if(is.null(name) == FALSE){
    colnames(peaks1) = paste(name, '_', rownames(features)[1:ncol(peaks1)], sep = '')
  }else{
    colnames(peaks1) = rownames(features)[1:ncol(peaks1)]
  }
  
  return(peaks1)
}

#Function to extract velocity windows and (optionally) regularize, size x and stepsize y
#Velocities are expected to be in columns named: 'translational_velocity', 'angular_velocity', 'sideslip'
get_velocity_windows = function(features,
                                include_sideslip = FALSE,
                                return_xy_windows = FALSE,
                                window_size = 1,
                                step_size = 1,
                                symm = FALSE,
                                verbose = FALSE,
                                name = NULL){
  
  #Initialize window list
  frags = list()
  xys = list()
  
  #Get trajectories
  for(i in seq(1, (nrow(features)-window_size), step_size)){
    
    if(verbose == TRUE){
      if(i %% 10000 == TRUE){
        print(i)
      }
    }

    #Get velocity vectors
    vt = features$translational_velocity[seq(i, i+window_size, 1)]
    vr = features$angular_velocity[seq(i, i+window_size, 1)]
    if(include_sideslip == TRUE){
      vs = features$sideslip[seq(i, i+window_size, 1)]
    }
    x = features$x[seq(i, i+window_size, 1)]
    y = features$y[seq(i, i+window_size, 1)]
    
    time = features$time[seq(i, i+window_size, 1)]
    
    #Subtract first frame make t0 = 0
    vr = vr-vr[1]
    if(include_sideslip == TRUE){
      vs = vs-vs[1]
    }

    #Multiply by sign of second frame to normalize turn direction
    if(symm == TRUE){
      if(vr[2]<0){
        vr = vr*(-1)
      }
      
      if(include_sideslip == TRUE){
        if(vs[2]<0){
          vs = vs*(-1)
        }      }
      
      vr = abs(vr)
      
      if(include_sideslip == TRUE){
        vs = abs(vs)
      }
    }
    
    #Look at time difference
    t_diff = diff(time)
    
    if(include_sideslip == TRUE){
      frags[[paste(time[1], "_", time[length(time)], "_", name, sep = "")]] = c(vt, vr, vs)
      xys[[paste(time[1], "_", time[length(time)], "_", name, sep = "")]] = c(x, y) 
    }else{
      frags[[paste(time[1], "_", time[length(time)], "_", name, sep = "")]] = c(vt, vr) 
      xys[[paste(time[1], "_", time[length(time)], "_", name, sep = "")]] = c(x, y)
    }
  }
  
  #Remove elements with NAs
  frags = frags[lapply(frags, function(x) sum(is.na(x)))<1]
  xys = xys[lapply(xys, function(x) sum(is.na(x)))<1]
  
  #Combine into df
  if(return_xy_windows == TRUE){
    df = do.call(cbind, frags)
    xys_df = do.call(cbind, xys)
    
    l = list(df, xys_df)
    names(l) = c("velocity_windows", "xy_windows")
    return(l)
  }else{
    df = do.call(cbind, frags)
    return(df)
  }
}

#Function to bin a umap space into a n x n grid (umap coordinates are provided as the 'layout' object)
bin_umap = function(layout,
                    n_bins){
  
  n = n_bins
  
  #Split x into n bins
  x1 = seq(min(layout[,1]),
           max(layout[,1]),
           (max(layout[,1])-min(layout[,1]))/n)
  names(x1) = seq(1, n+1, 1)
  
  xnew = apply(layout, 1, function(x) names(x1)[which.min(abs(as.numeric(x[1]) - x1))])
  layout$xnew = xnew
  
  #Split y into n bins
  y1 = seq(min(layout[,2]),
           max(layout[,2]),
           (max(layout[,2])-min(layout[,2]))/n)
  names(y1) = seq(1, n+1, 1)
  
  ynew = apply(layout, 1, function(x) names(y1)[which.min(abs(as.numeric(x[2]) - y1))])
  layout$ynew = ynew
  
  #Paste xy to get unique bin combos (this will be input to sling shot as 'clusters')
  xy_new = paste(xnew, ynew, sep = "_")
  layout$xy_new = xy_new
  
  #Convert coordinates to numeric, sort first
  m = unique(xy_new)
  
  y = as.numeric(unlist(lapply(strsplit(m, "_"), function(v){v[2]})))
  m = m[order(y)]
  
  x = as.numeric(unlist(lapply(strsplit(m, "_"), function(v){v[1]})))
  m = m[order(x)]
  
  #Get names
  names(m) = seq(1, length(m), 1)
  names(xy_new) = names(m)[match(xy_new, m)]
  
  #Get vector of coords
  layout$coords = as.numeric(names(xy_new))
  
  #Return
  l = list(layout, xy_new)
  names(l) = c("layout", "new_coords")
  
  return(l)
}

#Function to iteratively run umap on windows of a desired size
iterative_umap = function(features,
                          velocity_windows = FALSE,
                          verbose = FALSE,
                          plot = FALSE,
                          step_size = 1,
                          window_size = 30,
                          n_bins = 32,
                          run_umap = TRUE,
                          ...){
  
  print("Getting windows")
  #Get windows
  windows = list()
  
  #Set up plots
  if(plot == TRUE){
    n = length(features)*2
    x = ceiling(sqrt(n))
    y = floor(sqrt(n))
    par(mfrow = c(x,y), mar = c(1,1,1,1))
    rm(n, x, y)
  }

  for(i in 1:length(features)){
    if(velocity_windows == TRUE){
      windows[[i]] = get_velocity_windows(features[[i]],
                                          window_size = window_size, 
                                          step_size = step_size,
                                          ...)
    }else{
      windows[[i]] = get_windows(features[[i]],
                                 window_size = window_size, 
                                 step_size = step_size,
                                 ...)
    }
  }
  
  if(run_umap == FALSE){
    #Return
    l = list(features, windows)
    names(l) = c("features", "windows")
    return(l)
  }else{
    print("Running UMAP")
    #Run UMAP
    umaps = list()
    for(i in 1:length(vel)){
      print(paste("umap", i, "out of", length(vel)))
      
      if(verbose == TRUE){
        umaps[[i]] = umap(t(windows[[i]]), verbose = TRUE)
      }else{
        umaps[[i]] = umap(t(windows[[i]]))
      }
      
      plot(umaps[[i]]$layout[,1:2],
           bty = 'n',
           xaxt = 'n',
           yaxt = 'n',
           ylab = "",
           pch = 20,
           xlab = "",
           col = alpha('grey50', 0.5))
      plot(umaps[[i]]$layout[,1:2],
           type = 'l',
           bty = 'n',
           xaxt = 'n',
           yaxt = 'n',
           ylab = "",
           xlab = "",
           col = alpha('grey50', 0.5))
    }
    
    #Extract layouts
    umaps = lapply(umaps, function(z) data.frame(x = z$layout[,1], y = z$layout[,2]))
    
    #Bin
    umaps = lapply(umaps, function(x) bin_umap(x, n_bins = n_bins)$layout)
    
    #Return
    l = list(vel, windows, umaps)
    names(l) = c("features", "windows", "umaps")
    return(l)
  }
}

#Function calculate Euclidean distance
euc.dist <- function(x1, x2) sqrt(sum((x1 - x2) ^ 2))

#Function to calculate distance between umap layouts using Procrustes and Euclidean distances
run_procrustes = function(umaps,
                          run_protest = FALSE){
  
  #Get all combinations of umaps to compare
  x = combn(seq(1, length(umaps), 1), 2)
  
  #Run
  pr_res = c()
  pr_sig = list()
  dists = c()
  for(i in 1:ncol(x)){
    #print("running procrustes")
    pr = procrustes(umaps[[x[1,i]]][,1:2], 
                    umaps[[x[2,i]]][,1:2])
    pr_res = c(pr_res, summary(pr)$rmse)
    
    dists = c(dists, euc.dist(umaps[[x[1,i]]][,1:2], 
                              umaps[[x[2,i]]][,1:2]))
    
    if(run_protest == TRUE){
      #print("running protest")
      pr_sig[[i]] = protest(umaps[[x[1,i]]][,1:2], 
                            umaps[[x[2,i]]][,1:2])
    }
  }
  
  if(run_protest == TRUE){
    res = list(pr_res, pr_sig)
    names(res) = c("procrustes", "protest")
  }else{
    res = list(pr_res, dists)
    names(res) = c("procrustes", "euclidean_distances")
  }
  return(res)
}

#Function to calculate the amount and timing of recurrence in a behavior space
calculate_recurrence = function(umaps,
                                filter_outliers = FALSE,
                                n_bins = 16,
                                threshold = 0.05){
  results = list()
  for(h in 1:length(umaps)){
    
    print(paste(h, "out of", length(umaps)))
    
    
    u = umaps[[h]]
    
    if(filter_outliers == TRUE){
      u$x[u$x>30] = 30
      u$x[u$x<(-30)] = -30
      u$y[u$y>30] = 30
      u$y[u$y<(-30)] = -30
    }

    #Get distances
    l = bin_umap(u,
                 n_bins = n_bins)$layout
    res = list()
    pos = unique(l$xy_new)
    
    dists = list()
    for(i in 1:length(pos)){
      #if(i%%100 == TRUE){
      # print(paste(i, "out of", length(pos)))
      #}
      x = as.numeric(as.numeric(unlist(lapply(strsplit(pos[i], "_"), function(v){v[1]}))),
                     as.numeric(unlist(lapply(strsplit(pos[i], "_"), function(v){v[2]}))))
      z = apply(l, 1, function(y) euc.dist(x, c(as.numeric(y[3]), as.numeric(y[4]))))
      dists[[pos[i]]] = z
    }
    
    #Calculate distance distribution
    thresh = quantile(unlist(dists), probs = threshold)
    #10% 
    #5.09902 
    
    #Extract recurrences usins 10% threshold
    recs = lapply(dists, function(x){
      rs = which(x<thresh)
      ds = diff(rs)
      ds[ds>thresh]
    })
    histogram = hist(unlist(recs), 
                     breaks = seq(1, max(unlist(recs), na.rm = TRUE), 1), 
                     xlim = c(0,200))
    
    #Label points recurrent in 1 second bins
    prop_recurrent = list()
    for(i in 1:200){
      z = lapply(recs, function(x) which(x==i))
      z = sum(lapply(z, function(x) length(x))>0)/length(recs)
      prop_recurrent[[i]] = z
    }
    
    #barplot(unlist(prop_recurrent))
    total_recurrent = sum(lapply(recs, function(x) length(x))>0)/length(recs)
    
    l = list(dists, unlist(recs), histogram, unlist(prop_recurrent), total_recurrent)
    names(l) = c("distances", 
                 "recurrences", 
                 "histogram",
                 "proportion_recurrent_in_bins",
                 "total_proportion_recurrent")
    results[[h]] = l
  }
  image(do.call(cbind, lapply(results, function(x) x$histogram$counts[1:200]/max(x$histogram$counts[1:200]))),
        col = colorRamps::matlab.like(32),
        xaxt = 'n',
        yaxt = 'n',
        xlab = 'Time',
        ylab = 'Replicate',
        cex.lab = 1.5)
  axis(1,
       at = seq(0, 1, 1/(200-1)),
       labels = seq(1, 200, 1),
       cex.axis = 1.5)
  
  return(results)
}

#Function to plot results of iterative tests
plot_results = function(res_list,
                        ylim = c(0,10),
                        ylab = NULL,
                        xlab = NULL,
                        ...){
  
  means = unlist(lapply(res_list, function(x) mean(x)))
  error = lapply(res_list, function(x) boxplot.stats(x)$stats)
  
  plot(means,
       xaxt = 'n',
       cex.axis = 1.5,
       cex.lab = 1.5,
       ylab = ylab,
       ylim = ylim,
       pch = 21,
       cex = 2,
       bty = 'n',
       las = 2,
       type = 'n',
       bg = 'grey80',
       col = 'grey60',
       xlab = xlab,
       ...)
  axis(1, 
       at = seq(1, length(means),1),
       labels = names(means),
       cex.lab = 1.5,
       cex.axis = 1.5,
       las = 2)
  
  for(i in 1:length(res_list)){
    points(jitter(rep(i, length(res_list[[i]])), 0.25),
           res_list[[i]],
           pch = 20,
           col = alpha('grey70', 0.5))}
  
  points(means,
         pch = 21,
         cex = 1.5,
         bg = 'grey40',
         col = 'grey40')}

#Function to plot results of iterative tests as normalized variance
plot_variance = function(res_list,
                         ylim = c(0,1),
                         ylab = NULL,
                         xlab = NULL,
                         ...){
  
  variance = unlist(lapply(res_list, function(x) sd(x)/mean(x)))
  
  plot(variance,
       xaxt = 'n',
       cex.axis = 1.5,
       cex.lab = 1.5,
       ylab = ylab,
       ylim = ylim,
       pch = 21,
       cex = 2,
       bty = 'n',
       las = 2,
       type = 'n',
       bg = 'grey80',
       col = 'grey60',
       xlab = xlab,
       ...)
  axis(1, 
       at = seq(1, length(variance),1),
       labels = names(variance),
       cex.lab = 1.5,
       cex.axis = 1.5,
       las = 2)
  
  points(variance,
         pch = 21,
         cex = 1.5,
         bg = 'grey40',
         col = 'grey40')
}

#Function to plot recurrence results
plot_recurrence = function(recurrences){
  
  #Analyze distribution of recurrences
  par(mfrow = c(length(recurrences), 1))
  par(mar = c(2,0.5,2,0.5))
  
  for(i in 1:length(recurrences)){
    image(do.call(cbind, lapply(recurrences[[i]], function(y) y$proportion_recurrent_in_bins)),
          col = colorRampPalette(hcl.colors(12, "YlOrRd", rev = TRUE))(100),
          xaxt = 'n',
          yaxt = 'n')
    title(main = paste(names(recurrences)[i], 'frames'),
          cex.main = 1.5,
          font.main = 1)}
  
  axis(1,
       at = seq(0, 1, 0.125),
       labels = seq(0, max(as.numeric(names(recurrences))), max(as.numeric(names(recurrences)))/8),
       cex.axis = 1.5)
}

#Function to plot as vector field
plot_vector_field = function(layout,
                             bin_umap = FALSE,
                             n_bins = 32,
                             color_by_theta = FALSE,
                             arrow_color = 'grey50',
                             return = FALSE){
  
  if(bin_umap == TRUE){
    layout = bin_umap(layout, n_bins = n_bins)$layout
  }

  layout$dx = c(0, diff(layout$x))
  layout$dy = c(0, diff(layout$y))
  
  bins = split(layout, layout$xy)
  dx_mean = lapply(bins, function(x) mean(x$dx))
  dy_mean = lapply(bins, function(x) mean(x$dy))
  
  df = data.frame(x = as.numeric(unlist(lapply(strsplit(names(dx_mean), "_"), function(v){v[1]}))),
                  y = as.numeric(unlist(lapply(strsplit(names(dx_mean), "_"), function(v){v[2]}))),
                  dx = unlist(dx_mean),
                  dy = unlist(dy_mean))
  df$theta = rep(NA, nrow(df))
  for(i in 1:nrow(df)){
    x1 = df[i,1] 
    y1 = df[i,2] 
    x2 = df[i,1] + df[i,3]
    y2 = df[i,2] + df[i,4]
    
    df$theta[i] = atan2(y2-y1, x2-x1)*(180/pi)
  }
  
  df$dist = rep(NA, nrow(df))
  for(i in 1:nrow(df)){
    x1 = df[i,1] 
    y1 = df[i,2] 
    x2 = df[i,1] + df[i,3]
    y2 = df[i,2] + df[i,4]
    
    df$dist[i] = euc.dist(c(x1, y1), c(x2, y2))
  }
  
  par(mar = c(1,1,1,1))
  
  if(color_by_theta == TRUE){
    x = round(df$dy, 2)
    cols = colorRampPalette(c('cyan4', 'grey90', 'orangered3'))(length(seq(min(x), max(x), 0.01)))
    names(cols) = round(seq(min(x), max(x), 0.01), 2)
    cols = cols[match(as.numeric(x), 
                      as.numeric(names(cols)))]
    
    theta = round(df$theta)
    s = seq(-180, 180, 1)
    cols = c(colorRampPalette(c('midnightblue', 'cyan4'))(90),
             colorRampPalette(c('cyan4', 'lightgoldenrod1'))(90),
             colorRampPalette(c('lightgoldenrod1', 'sienna2'))(90),
             colorRampPalette(c('sienna2', 'orangered3'))(91))
    names(cols) = s
    cols = cols[match(theta, names(cols))]
    
    plot(df$x, 
         df$y, 
         xlim = c(min(df$x)-2, max(df$x)+2),
         ylim = c(min(df$y)-2, max(df$y)+2),
         type = "n",
         #col = alpha('grey50', 0.5),
         pch = 20,
         xlab = "",
         ylab = "",
         bty = 'n',
         xaxt = 'n',
         yaxt = 'n')
    shape::Arrows(df[,1], 
                  df[,2], 
                  df[,1] + df[,3], 
                  df[,2] + df[,4],
                  arr.length = 0.05,
                  col = cols,
                  arr.type = "triangle")
  }else{
    
    plot(df$x, 
         df$y, 
         xlim = c(min(df$x)-2, max(df$x)+2),
         ylim = c(min(df$y)-2, max(df$y)+2),
         type = "n",
         #col = alpha('grey50', 0.5),
         pch = 20,
         xlab = "",
         ylab = "",
         bty = 'n',
         xaxt = 'n',
         yaxt = 'n')
    shape::Arrows(df[,1], 
                  df[,2], 
                  df[,1] + df[,3], 
                  df[,2] + df[,4],
                  arr.length = 0.05,
                  col = arrow_color,
                  arr.type = "triangle")
  }
  
  if(return == TRUE){
    return(layout)
  }
}

#Function to plot with features colored
plot_umap_features = function(layout,
                              windows,
                              bin_umap = FALSE,
                              n_bins = 32,
                              n_features = NULL,
                              feature_names = NULL,
                              colors = brewer.pal(11, 'Spectral'),
                              plot_points = FALSE,
                              return = FALSE,
                              ...){
  
  #Bin UMAP if desired
  if(bin_umap == TRUE){
    layout = bin_umap(layout,
                      n_bins = n_bins)$layout
  }
  
  #Get vector of rows to split windows on (as a function of feature number)
  tosplit = rep(1:n_features, 
                each=(nrow(windows)/n_features))
  
  #Split windows on features
  feat = split(as.data.frame(windows), tosplit)
  
  #Get colors
  cols = colorRampPalette(colors)(n_features)
  
  #Set up plotting aesthetics
  par(mfrow = c(1, n_features), bty = 'n', xaxt = 'n', yaxt = 'n', mar = c(2,2,2,2))
  
  #Loop through features and plot
  for(i in 1:length(feat)){
    
    #Calculate mean feature value per window
    m = colMeans(feat[[i]])
    
    #Add to layout
    if(is.null(feature_names) == FALSE){
      layout[,feature_names[i]] = m
    }else{
      layout = cbind(layout, m)
    }

    if(plot_points == TRUE){
      
      #Round mean feature value
      m = round(m, 2)
      
      #Take absolute value
      m = abs(m)
      
      #Get colors
      p = colorRampPalette(c('grey90', cols[i]))(length(seq(0, max(m), 0.01)))
      names(p) = seq(0, max(m), 0.01)
      p = p[match(m, names(p))]
      
      #Plot
      plot(layout[,1:2],
           pch = 20,
           col = p,
           ylab = '',
           xlab = '',
           ...)
      
      if(is.null(feature_names) == FALSE){
        title(main = feature_names[i],
              cex.main = 1.5,
              font.main = 1)}
      
    }else{
      
      #Split on bin
      m = split(m, layout$xy_new)
      
      #Get mean per bin
      m = lapply(m, function(x) mean(x, na.rm = TRUE))
      
      #Unlist
      m = unlist(m)
      
      #Round mean feature value
      m = round(m, 2)
      
      #Take absolute value
      m = abs(m)
      
      #Get colors
      p = colorRampPalette(c('grey90', cols[i]))(length(seq(0, max(m), 0.01)))
      names(p) = seq(0, max(m), 0.01)
      p = p[match(m, names(p))]
      
      #Plot
      plot(unlist(lapply(strsplit(names(m), "_"), function(v){v[1]})),
           unlist(lapply(strsplit(names(m), "_"), function(v){v[2]})),
           pch = 20,
           col = p,
           ylab = '',
           xlab = '',
           ...)
      
      if(is.null(feature_names) == FALSE){
        title(main = feature_names[i],
              cex.main = 1.5,
              font.main = 1)}
    }
  }
  if(return == TRUE){
    return(layout)
  }
}

#Function plot as a probability density function
plot_umap_pdf = function(layout,
                         h = 1,
                         n = 100, 
                         colors = matlab.like(100),
                         return = FALSE){
  
  #Get pdf
  pdf = kde2d(layout$x,
              layout$y,
              h = h,
              n = n)
  
  #Plot
  par(mar = c(1,1,1,1), bty = 'n', xaxt = 'n', yaxt = 'n')
  image(pdf$z,
        xlab = '',
        ylab = '',
        col = colors)
  
  #Return if desired
  if(return == TRUE){
    return(pdf)
  }
}

#Function to compare UMAP distributions across trials/individuals via bin-wise Fisher's test
run_umap_fishers = function(layout,
                            individuals_vector,
                            bin_umap = FALSE,
                            n_bins = 32,
                            odds_cutoff = 2,
                            cex = 0.5,
                            adjust_ps = FALSE,
                            verbose = FALSE,
                            return = FALSE){
  
  #Set up plots
  n = length(individuals)*2
  x = ceiling(sqrt(n))
  y = floor(sqrt(n))
  par(mfrow = c(x,y), mar = c(2,2,2,2))
  rm(n, x, y)
  
  #Bin layout if desired
  if(bin_umap == TRUE){
    layout = bin_umap(layout,
                      n_bins = n_bins)$layout
  }
  
  #Split layout
  individuals = split(layout,
                      individuals_vector)
  
  #Set up empty lists to save results
  all_odds = list()
  all_ps = list()
  
  #Loop through and run test on each individual
  for(h in 1:length(individuals)){
    
    if(verbose == TRUE){
      print(paste('individual', h, 'out of', length(individuals)))
    }
    r = individuals[[h]]$xy_new
    t = table(r)
    xy_table = table(layout$xy_new)
    
    t = t[match(names(xy_table), names(t))]
    names(t) = names(xy_table)
    t[is.na(t)] = 0

    odds = c()
    ps = c()
    
    for(i in 1:length(t)){
      w1 = t[i]
      x1 = xy_table[grep(paste("^", names(t[i]), "$", sep = ""), names(xy_table))]
      w2 = sum(t)-w1
      x2 = sum(xy_table)-x1
      
      out = fisher.test(as.matrix(
        rbind(
          c(w1, w2),
          c(x1, x2))))
      
      odds = c(odds, out$estimate)
      ps = c(ps, out$p.value)
    }
    
    #Adjust ps if desired
    if(adjust_ps == TRUE){
      ps = ps*length(ps)
    }
    
    #Add to list
    all_odds[[as.character(h)]] = odds
    all_ps[[as.character(h)]] = ps
    
    ##Plot odds ratios
    #Round and change names
    o = round(odds, 2)
    names(o) = names(t)
    
    #Get colors
    ints = seq(0, odds_cutoff, 0.01)
    o[o>odds_cutoff] = odds_cutoff
    cols = c(colorRampPalette(c("midnightblue", "grey90"))(length(seq(0, 1, 0.01))),
             colorRampPalette(c("grey90", "darkred"))(length(seq(1.01, odds_cutoff, 0.01))))
    names(cols) = ints
    cols = cols[match(o, names(cols))]
    
    #Plot
    plot(unlist(lapply(strsplit(names(o), "_"), function(v){v[1]})),
         unlist(lapply(strsplit(names(o), "_"), function(v){v[2]})),
         pch = 20,
         cex = cex,
         col = cols,
         cex.axis = 1.5,
         cex.lab = 1.5,
         xaxt = 'n',
         yaxt = 'n',
         ylab = "",
         xlab = "",
         bty = 'n')
    title(main = 'Odds ratios',
          cex.main = 1.5,
          font.main = 1)
    
    ##Plot p values
    #Set up colors
    cols = rep('grey90', length(ps))
    cols[ps<0.05] = 'red'
    
    #Plot
    plot(unlist(lapply(strsplit(names(o), "_"), function(v){v[1]})),
         unlist(lapply(strsplit(names(o), "_"), function(v){v[2]})),
         pch = 20,
         cex = cex,
         col = cols,
         cex.axis = 1.5,
         cex.lab = 1.5,
         xaxt = 'n',
         yaxt = 'n',
         ylab = "",
         xlab = "",
         bty = 'n')
    title(main = 'p-values',
          cex.main = 1.5,
          font.main = 1)
  }
  
  #Return if desired
  if(return == TRUE){
    l = list(all_odds, all_ps)
    names(l) = c('odds_ratios', 'p_values')
    return(l)
  }
}

###################################
#####Extract sample velocities#####
###################################
# win = readRDS("~/Desktop/behavior_space_methods_ms/01_supporting_files/R_files/umap_iterative_windows_random_walk_092319.RDS")
# 
# vel = win$`1`$velocities
# vel = lapply(vel, function(x) data.frame(time = x$time,
#                                          x = x$x,
#                                          y = x$y,
#                                          translational_velocity = x$vt_cm_smooth,
#                                          angular_velocity = x$vr_cm_smooth))
# vel = lapply(vel, function(x) x[1:5000,])
# 
# saveRDS(vel, '~/Desktop/TREBLE_walkthrough/00_data/sample_correlated_random_talk_velocities_5ksteps.RDS')

#################################################
#####Load velocity and run iterative windows#####
#################################################
#Load velocity
vel = readRDS("/Users/ryanayork/Desktop/TREBLE_walkthrough/00_data/sample_correlated_random_talk_velocities_5ksteps.RDS")
 
#Set windows to sweep (from 1 frame to 50, step size of 5)
toSweep = c(1, seq(5, 50, 5))

#Initialize list to save results from iterative_umap
iterative_windows = list()

#Run iterative windows and save results
for(i in 1:length(toSweep)){
  
  #Counter
  print(paste("Window size ", toSweep[i], '; ', i, ' out of ', length(toSweep), sep = ''))
  
  #Function
  iterative_windows[[as.character(toSweep[i])]] = iterative_umap(lapply(vel, function(x) x[1:1000,]),
                                                                        velocity_windows = TRUE,
                                                                        plot = TRUE,
                                                                        window_size = toSweep[i])}

#Save
saveRDS(iterative_windows,
        '/Users/ryanayork/Desktop/TREBLE_walkthrough/00_data/sample_correlated_random_walk_iterative_windows.RDS')

#Calculate Procrustes and Euclidean distance of results
iterative_windows_pr = lapply(iterative_windows, function(y) run_procrustes(y$umaps)$procrustes)
iterative_windows_dist = lapply(iterative_windows, function(y) run_procrustes(y$umaps)$euclidean_distances)

#Plot
par(mfrow = c(1,2))
plot_results(iterative_windows_pr,
             ylim = c(0, 8),
             ylab = "RMSE",
             xlab = "Window size (frames)")
plot_results(iterative_windows_dist,
             ylim = c(0, 500),
             ylab = "Mean Euclidean distance",
             xlab = "Window size (frames)")

#Plot as variance
par(mfrow = c(1,2))
plot_variance(iterative_windows_pr,
              ylim = c(0, 0.2),
              ylab = "RMSE",
              xlab = "Window size (frames)")
plot_variance(iterative_windows_dist,
              ylim = c(0, 0.2),
              ylab = "Mean Euclidean distance",
              xlab = "Window size (frames)")

#Calculate recurrence
recurrence = list()
for(i in 1:length(iterative_windows)){
  recurrence[[as.character(names(iterative_windows)[i])]] = calculate_recurrence(iterative_windows[[i]]$umaps,
                                                                                 n_bins = 16)}

#Save
saveRDS(recurrence, '/Users/ryanayork/Desktop/TREBLE_walkthrough/00_data/sample_correlated_random_walk_iterative_windows_recurrence.RDS')

#Plot recurrence distributions across replicates
plot_recurrence(recurrence)

#Plot mean recurrence times by window size
means = lapply(recurrence, function(x) unlist(lapply(x, function(y) (mean(y$recurrences)))))

par(mfrow = c(1,2))
plot_results(means,
             xlab = "Window size (frames)",
             ylab = "Mean recurrence time",
             ylim = c(0,200))

plot_variance(means,
              xlab = "Window size (frames)",
              ylab = "Coefficient of variation",
              ylim = c(0,1))

##################################################
#####Get windows of desired size and run UMAP#####
##################################################
#Extract windows of size 15 frames
windows = list()
for(i in 1:length(vel)){
  print(paste('replicate', i, 'out of', length(vel)))
  windows[[as.character(i)]] = get_velocity_windows(vel[[i]],
                                                    window_size = 15, 
                                                    name = paste('replicate_', i, sep = ''))}

#Combine windows
windows = do.call(cbind, windows)

#Save
saveRDS(windows, '/Users/ryanayork/Desktop/TREBLE_walkthrough/00_data/sample_correlated_random_walk_windows.RDS')

#Run UMAP
u = umap(t(windows),
         verbose = TRUE)

#Extract layout
layout = data.frame(x = u$layout[,1],
                    y = u$layout[,2],
                    individual = paste(unlist(lapply(strsplit(colnames(windows), "_"), function(v){v[3]})),
                                       unlist(lapply(strsplit(colnames(windows), "_"), function(v){v[4]})),
                                       sep= ''),
                    time = unlist(lapply(strsplit(colnames(windows), "_"), function(v){v[1]})))

#Bin
layout = bin_umap(layout,
                  n_bins = 32)$layout

#Save
saveRDS(layout, '/Users/ryanayork/Desktop/TREBLE_walkthrough/00_data/sample_correlated_random_walk_UMAP_layout.RDS')

########################
#####Analyzing UMAP#####
########################
##Plot layout as points and lines
par(mfrow = c(1,2), bty = 'n', xaxt = 'n', yaxt = 'n', mar = c(2,2,2,2))

#Points
plot(layout[,1:2],
     pch = 20,
     cex = 0.25,
     xlab = '',
     ylab = '',
     col = alpha('gray60', 0.25))

#Lines
plot(layout[,1:2],
     type = 'l',
     lwd = 0.25,
     xlab = '',
     ylab = '',
     col = alpha('gray60', 0.25))

##Plot layout as vector field
par(mfrow = c(1,2), bty = 'n', xaxt = 'n', yaxt = 'n', mar = c(2,2,2,2))

#Non-theta (angle) colored
plot_vector_field(layout)

#Theta colored
plot_vector_field(layout, 
                  color_by_theta = TRUE)

##Plot layout as vector field with more bins
par(mfrow = c(1,2), bty = 'n', xaxt = 'n', yaxt = 'n', mar = c(2,2,2,2))

#Non-theta (angle) colored
plot_vector_field(layout,
                  bin_umap = TRUE,
                  n_bins = 100)

#Theta colored
plot_vector_field(layout, 
                  color_by_theta = TRUE,
                  bin_umap = TRUE,
                  n_bins = 100)

##Plot with features colored
#Bins
plot_umap_features(layout, 
                   windows,
                   feature_names = c('Translational velocity', 'Angular velocity'),
                   colors = c('darkgreen', 'darkmagenta'),
                   n_features = 2)

#Points
plot_umap_features(layout, 
                   windows,
                   feature_names = c('Translational velocity', 'Angular velocity'),
                   plot_points = TRUE,
                   cex = 0.1,
                   colors = c('darkgreen', 'darkmagenta'),
                   n_features = 2)

###########################################
#####Compare across individuals/trials#####
###########################################
#Visualize occupancy within the space via a probability density function (pdf), producing a 'density map'
plot_umap_pdf(layout, h = 2)

#Plot individual pdfs
par(mfrow = c(2,5))
inds = split(layout, layout$individual)
pdfs = list()
for(i in 1:length(inds)){
  pdfs[[names(inds)[i]]] = plot_umap_pdf(inds[[i]], 
                                         h = 2,
                                         return = TRUE)
}

#Compare individual's distributions in space via Fisher's test
run_umap_fishers(layout,
                 layout$individual)

##Hierarchical clustering on density maps
#Unlist density maps and combine into a dataframe
p = do.call(cbind, lapply(pdfs, function(x) unlist(as.data.frame(x$z))))

#Normalize
p = apply(p, 2, function(x) x/max(x))

#Heatmap with hierarchical clustering
heatmap(t(p), 
        Colv = NA,
        labCol = '')







