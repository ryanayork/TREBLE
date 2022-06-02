```
---
title: "Running TREBLE's iterative window search"
author: Ryan York
date: "May 25, 2022"
output: 
  html_document
---
```

# Running TREBLE's iterative window search

**Initiate session and load data**
```{r load-packages, include=FALSE}
library(treble)
library(umap)
library(scales)
library(MASS)
library(RColorBrewer)
library(colorRamps)
library(vegan)
```

Load data. In this walkthrough we are using velocity components calculated from correlated random walk trajectories (n = 10; length = 5000 steps).
```{r}
vel = readRDS('~/Desktop/05_TREBLE_walkthrough/00_data/sample_correlated_random_walk_velocities_5ksteps.RDS')
```

**Run iterative windows**

This step aids the user in determining the optimal window size for use in generating the downstream behavior space. In the TREBLE framework, an optimal window size should represent the timescale over which the most basic elements of movement (i.e. 'movement primitives') occur and change. Generally, this is reflected by behavior spaces that are less variable across samples and display more recurrence (i.e. movements tend to be repeated stereo typically over time). Optimal sizes are identified by generating behavior spaces over a range of window sizes and assessing how their structure, temporal properties, and overall variance.


For this data set, a unique behavior space will be generated for each sample using the function `iterative_umap`. We will test windows ranging in size from 1 frame to 50 frames, with a step size of 5. First, we will generate a vector containing the desired window sizes (`toSweep`)
```{r}
toSweep = c(1, seq(5, 50, 5))
```

Next we will create an empty list for saving the results from `iterative_umap`.
```{r}
iterative_windows = list()
```

Now `iterative_umap` will be run over the desired range of window sizes, saving the results into `iterative_umap`. To aid in computational time, just the first 1000 frames of each sample are being used to generate behavior spaces. The number of frames used can be easily changed and should ideally represent a substantial amount of the full sample length. If desired, `iterative_umap` can produce plots of the behavior spaces generated during each call by using `plot=TRUE`.
```{r}
for(i in 1:length(toSweep)){

  #Print counter if desired
  print(paste("Window size ", toSweep[i], '; ', i, ' out of ', length(toSweep), sep = ''))

  #Generate behavior spaces for all window sizes
  iterative_windows[[as.character(toSweep[i])]] = iterative_umap(lapply(vel, function(x) x[1:1000,]),
                                                                 velocity_windows = TRUE,
                                                                 window_size = toSweep[i])}
```

Let's take a look at the results by plotting each of the behavior spaces generated for the first sample (contained in the first element of the `umaps` element of the `iterative_windows` list). You can already see that the shape of the space varies broadly across window sizes, beginning as disparate spaces with big jumps between points, becoming more recurrent 'c' or 'u' shaped spaces, and then ultimately getting more disorganized. These qualitative observations will get quantitatively measured in the next section.
```{r echo =FALSE}
par(mfrow = c(3,4))
#Extract umaps for the desired sample
x = lapply(iterative_windows, function(x) x$umaps[[1]])

#Plot each
for(i in 1:length(x)){
  plot(x[[i]][,1:2],
       type = 'l',
       bty = 'n', 
       xaxt = 'n',
       yaxt = 'n',
       xlab = '', 
       ylab = '',
       col = alpha('gray50', 0.5))}
```

**Analyzing diagnostics of the iterative window search**

Now we will compare the results of the iterative window search using a variety of metrics. First, we will calculate variation in the structure of the behavior spaces using two metrics: Procrustes and Euclidean distances. Procrustes distance measures the relationship between two sets of points (which here correspond to the points in each 2d behavior space). To measure Procrustes distance points are scaled to each other, shifted to be in the same position, rotated to be in the same orientation, and then compared pairwise via their root mean square distance (RMSD). For more on this see: wikipedia.org/wiki/Procrustes_analysis. 

Since it is concerned with the overall shape of multiple point sets, Procrustes is a measure of global variation. On the other hand, Euclidean distance is a measure of local variation. Here, Euclidean distance is measured as the distance between points within an individual behavior space, the distribution of which gives a sense of how the spacing of points in a given behavior space. Analyzing these two measures can thus provide a sense of the overall patterns of structural variation between behavior spaces, in addition to the variance observed across behavior spaces of a given window size (more on this below). Both Procrustes and Euclidean distances are calculated using the function `run_procrustes`.
```{r}
#Procrustes distance
iterative_windows_pr = lapply(iterative_windows, function(y) run_procrustes(y$umaps)$procrustes)

#Eucliean distance
iterative_windows_dist = lapply(iterative_windows, function(y) run_procrustes(y$umaps)$euclidean_distances)
```

The output can be visualized using the functions `plot_results` and `plot_variance`. The full distributions of Procrustes and Euclidean distances will be plotted with `plot_results` while their coefficients of variance (mean normalized variance) will be displayed with `plot_variance`. In this case, we see that both Procrustes and Euclidean distances decrease as window size increases (from the output of plot_results). However, the coefficient of variance distributions display relatively strong minima around window sizes of 20 frames. Taken together, these suggest that, while distance decreases with size, window sizes greater than 20 frames are associated with increasing differences between samples (as reflected by the increasing variance). This highlights the utility of analyzing both the full distributions and their variance.
```{r}
par(mfrow = c(2,2))
#Plot full distributions
plot_results(iterative_windows_pr,
             ylim = c(0, 8),
             ylab = "Procrustes RMSD",
             xlab = "Window size (frames)")
plot_results(iterative_windows_dist,
             ylim = c(0, 500),
             ylab = "Mean Euclidean distance",
             xlab = "Window size (frames)")

#Plot as mean normalized variance
plot_variance(iterative_windows_pr,
              ylim = c(0, 0.2),
              ylab = "Procrustes distance (coef. var.)",
              xlab = "Window size (frames)")
plot_variance(iterative_windows_dist,
              ylim = c(0, 0.2),
              ylab = "Euclidean distance (coef. var.)",
              xlab = "Window size (frames)")
```

The goal of the TREBLE framework is to identify the window size that most captures the temporal structure of movement primitives. Here, we reason that true primitives are repetitive and re-employed during an animal's movement (for example leg swinging during walking). One way of conceptualizing this is that, in a 2d behavior space, re-employed primitives should display recurrence (i.e. the animal returns repeatedly the same position in space that corresponds to a given primitive). Recurrence is therefore a useful metric for identifying an optimal window size to use. Window sizes that yield more recurrent spaces with a higher percentage of points being returned to are likely capturing at least some of the key primitives for the movement being analyzed. Here, we use the function `calculate_recurrence` to measure the amount of time it takes to return to each point in behavior space. The distribution of these return times can thus give us a sense of how recurrent a given behavior space is and the timescale over returns are most likely to happen. As above, it is also useful to examine the variance of these distributions (analyzed in the next section).
```{r}
#Generate empty list to store results in
recurrence = list()

#Calculate recurrence for all behavior spaces
for(i in 1:length(iterative_windows)){
  recurrence[[as.character(names(iterative_windows)[i])]] = calculate_recurrence(iterative_windows[[i]]$umaps,
                                                                                 n_bins = 16)}
```

The function `plot_recurrence` examines the distribution of return time for each window size tested. Samples are displayed row-wise will return times are represented in the columns.

```{r echo =FALSE, fig.height = 12, fig.width = 4}
par(mar = c(0.01,0.01,0.01,0.01))
plot_recurrence(recurrence)
```

As with the Procrustes and Euclidean distance measurements, we can plot the results using `plot_results` and `plot_variance`. Here, it appears that the mean recurrence time is reduced using window sizes of around 5-15 frames.
```{r echo =FALSE}
#Calculate mean recurrence times for each window size/sample
means = lapply(recurrence, function(x) unlist(lapply(x, function(y) (mean(y$recurrences)))))

#Plot
par(mfrow = c(1,2))
plot_results(means,
             xlab = "Window size (frames)",
             ylab = "Mean recurrence time",
             ylim = c(0,200))

plot_variance(means,
              xlab = "Window size (frames)",
              ylab = "Coefficient of variation",
              ylim = c(0,1))
```
