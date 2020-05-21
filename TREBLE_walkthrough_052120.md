```R
################################
#####1. Load functions/data#####
###############################
#Load the TREBLE functions
source("/Users/ryanayork/Desktop/TREBLE_walkthrough/01_Rfiles/TREBLE_walkthrough_functions_051920.R")
```

    Loading required package: permute
    
    Loading required package: lattice
    
    This is vegan 2.5-6
    



```R
#Load velocity/feature data
vel = readRDS("/Users/ryanayork/Desktop/TREBLE_walkthrough/00_data/sample_correlated_random_talk_velocities_5ksteps.RDS")
```


```R
##############################################
#####2. Empirically determine window size#####
##############################################
##Behavior space creation depends on choosing a window size for extracting parameters
##Below is code for emprically exploring the relationship between window sizes and the variance and temporal
##properties of behavior space

#Choose a range of window sizes to test (here from 1 frame to 50 with a step size of 5)
toSweep = c(1, seq(5, 50, 5))

#Initialize list to save results from iterative_umap
iterative_windows = list()
```


```R
##'iterative_umap' is a function that takes the feature data, extracts windows of a given size for all
##trial/individual/replicate, and creates a behavior space for each
#Below is a sample run for a single window size
sample = iterative_umap(lapply(vel, function(x) x[1:2000,]),
               velocity_windows = TRUE,
               plot = TRUE,
               window_size = toSweep[1])
```

    [1] "Getting windows"
    [1] "Running UMAP"
    [1] "umap 1 out of 10"
    [1] "umap 2 out of 10"
    [1] "umap 3 out of 10"
    [1] "umap 4 out of 10"
    [1] "umap 5 out of 10"
    [1] "umap 6 out of 10"
    [1] "umap 7 out of 10"
    [1] "umap 8 out of 10"
    [1] "umap 9 out of 10"
    [1] "umap 10 out of 10"



![png](output_3_1.png)



```R
#Running iterative windows across windows to be swept and saving results
for(i in 1:length(toSweep)){
  
  #Counter
  print(paste("Window size ", toSweep[i], '; ', i, ' out of ', length(toSweep), sep = ''))
  
  #Function
  iterative_windows[[as.character(toSweep[i])]] = iterative_umap(lapply(vel, function(x) x[1:2000,]),
                                                                 velocity_windows = TRUE,
                                                                 window_size = toSweep[i])}
```

    [1] "Window size 1; 1 out of 11"
    [1] "Getting windows"
    [1] "Running UMAP"
    [1] "umap 1 out of 10"



![png](output_4_1.png)


    [1] "umap 2 out of 10"



![png](output_4_3.png)



![png](output_4_4.png)


    [1] "umap 3 out of 10"



![png](output_4_6.png)



![png](output_4_7.png)


    [1] "umap 4 out of 10"



![png](output_4_9.png)



![png](output_4_10.png)


    [1] "umap 5 out of 10"



![png](output_4_12.png)



![png](output_4_13.png)


    [1] "umap 6 out of 10"



![png](output_4_15.png)



![png](output_4_16.png)


    [1] "umap 7 out of 10"



![png](output_4_18.png)



![png](output_4_19.png)


    [1] "umap 8 out of 10"



![png](output_4_21.png)



![png](output_4_22.png)


    [1] "umap 9 out of 10"



![png](output_4_24.png)



![png](output_4_25.png)


    [1] "umap 10 out of 10"



![png](output_4_27.png)



![png](output_4_28.png)


    [1] "Window size 5; 2 out of 11"
    [1] "Getting windows"
    [1] "Running UMAP"
    [1] "umap 1 out of 10"



![png](output_4_30.png)



![png](output_4_31.png)


    [1] "umap 2 out of 10"



![png](output_4_33.png)



![png](output_4_34.png)


    [1] "umap 3 out of 10"



![png](output_4_36.png)



![png](output_4_37.png)


    [1] "umap 4 out of 10"



![png](output_4_39.png)



![png](output_4_40.png)


    [1] "umap 5 out of 10"



![png](output_4_42.png)



![png](output_4_43.png)


    [1] "umap 6 out of 10"



![png](output_4_45.png)



![png](output_4_46.png)


    [1] "umap 7 out of 10"



![png](output_4_48.png)



![png](output_4_49.png)


    [1] "umap 8 out of 10"



![png](output_4_51.png)



![png](output_4_52.png)


    [1] "umap 9 out of 10"



![png](output_4_54.png)



![png](output_4_55.png)


    [1] "umap 10 out of 10"



![png](output_4_57.png)



![png](output_4_58.png)


    [1] "Window size 10; 3 out of 11"
    [1] "Getting windows"
    [1] "Running UMAP"
    [1] "umap 1 out of 10"



![png](output_4_60.png)



![png](output_4_61.png)


    [1] "umap 2 out of 10"



![png](output_4_63.png)



![png](output_4_64.png)


    [1] "umap 3 out of 10"



![png](output_4_66.png)



![png](output_4_67.png)


    [1] "umap 4 out of 10"



![png](output_4_69.png)



![png](output_4_70.png)


    [1] "umap 5 out of 10"



![png](output_4_72.png)



![png](output_4_73.png)


    [1] "umap 6 out of 10"



![png](output_4_75.png)



![png](output_4_76.png)


    [1] "umap 7 out of 10"



![png](output_4_78.png)



![png](output_4_79.png)


    [1] "umap 8 out of 10"



![png](output_4_81.png)



![png](output_4_82.png)


    [1] "umap 9 out of 10"



![png](output_4_84.png)



![png](output_4_85.png)


    [1] "umap 10 out of 10"



![png](output_4_87.png)



![png](output_4_88.png)


    [1] "Window size 15; 4 out of 11"
    [1] "Getting windows"
    [1] "Running UMAP"
    [1] "umap 1 out of 10"



![png](output_4_90.png)



![png](output_4_91.png)


    [1] "umap 2 out of 10"



![png](output_4_93.png)



![png](output_4_94.png)


    [1] "umap 3 out of 10"



![png](output_4_96.png)



![png](output_4_97.png)


    [1] "umap 4 out of 10"



![png](output_4_99.png)



![png](output_4_100.png)


    [1] "umap 5 out of 10"



![png](output_4_102.png)



![png](output_4_103.png)


    [1] "umap 6 out of 10"



![png](output_4_105.png)



![png](output_4_106.png)


    [1] "umap 7 out of 10"



![png](output_4_108.png)



![png](output_4_109.png)


    [1] "umap 8 out of 10"



![png](output_4_111.png)



![png](output_4_112.png)


    [1] "umap 9 out of 10"



![png](output_4_114.png)



![png](output_4_115.png)


    [1] "umap 10 out of 10"



![png](output_4_117.png)



![png](output_4_118.png)


    [1] "Window size 20; 5 out of 11"
    [1] "Getting windows"
    [1] "Running UMAP"
    [1] "umap 1 out of 10"



![png](output_4_120.png)



![png](output_4_121.png)


    [1] "umap 2 out of 10"



![png](output_4_123.png)



![png](output_4_124.png)


    [1] "umap 3 out of 10"



![png](output_4_126.png)



![png](output_4_127.png)


    [1] "umap 4 out of 10"



![png](output_4_129.png)



![png](output_4_130.png)


    [1] "umap 5 out of 10"



![png](output_4_132.png)



![png](output_4_133.png)


    [1] "umap 6 out of 10"



![png](output_4_135.png)



![png](output_4_136.png)


    [1] "umap 7 out of 10"



![png](output_4_138.png)



![png](output_4_139.png)


    [1] "umap 8 out of 10"



![png](output_4_141.png)



![png](output_4_142.png)


    [1] "umap 9 out of 10"



![png](output_4_144.png)



![png](output_4_145.png)


    [1] "umap 10 out of 10"



![png](output_4_147.png)



![png](output_4_148.png)


    [1] "Window size 25; 6 out of 11"
    [1] "Getting windows"
    [1] "Running UMAP"
    [1] "umap 1 out of 10"



![png](output_4_150.png)



![png](output_4_151.png)


    [1] "umap 2 out of 10"



![png](output_4_153.png)



![png](output_4_154.png)


    [1] "umap 3 out of 10"



![png](output_4_156.png)



![png](output_4_157.png)


    [1] "umap 4 out of 10"



![png](output_4_159.png)



![png](output_4_160.png)


    [1] "umap 5 out of 10"



![png](output_4_162.png)



![png](output_4_163.png)


    [1] "umap 6 out of 10"



![png](output_4_165.png)



![png](output_4_166.png)


    [1] "umap 7 out of 10"



![png](output_4_168.png)



![png](output_4_169.png)


    [1] "umap 8 out of 10"



![png](output_4_171.png)



![png](output_4_172.png)


    [1] "umap 9 out of 10"



![png](output_4_174.png)



![png](output_4_175.png)


    [1] "umap 10 out of 10"



![png](output_4_177.png)



![png](output_4_178.png)


    [1] "Window size 30; 7 out of 11"
    [1] "Getting windows"
    [1] "Running UMAP"
    [1] "umap 1 out of 10"



![png](output_4_180.png)



![png](output_4_181.png)


    [1] "umap 2 out of 10"



![png](output_4_183.png)



![png](output_4_184.png)


    [1] "umap 3 out of 10"



![png](output_4_186.png)



![png](output_4_187.png)


    [1] "umap 4 out of 10"



![png](output_4_189.png)



![png](output_4_190.png)


    [1] "umap 5 out of 10"



![png](output_4_192.png)



![png](output_4_193.png)


    [1] "umap 6 out of 10"



![png](output_4_195.png)



![png](output_4_196.png)


    [1] "umap 7 out of 10"



![png](output_4_198.png)



![png](output_4_199.png)


    [1] "umap 8 out of 10"



![png](output_4_201.png)



![png](output_4_202.png)


    [1] "umap 9 out of 10"



![png](output_4_204.png)



![png](output_4_205.png)


    [1] "umap 10 out of 10"



![png](output_4_207.png)



![png](output_4_208.png)


    [1] "Window size 35; 8 out of 11"
    [1] "Getting windows"
    [1] "Running UMAP"
    [1] "umap 1 out of 10"



![png](output_4_210.png)



![png](output_4_211.png)


    [1] "umap 2 out of 10"



![png](output_4_213.png)



![png](output_4_214.png)


    [1] "umap 3 out of 10"



![png](output_4_216.png)



![png](output_4_217.png)


    [1] "umap 4 out of 10"



![png](output_4_219.png)



![png](output_4_220.png)


    [1] "umap 5 out of 10"



![png](output_4_222.png)



![png](output_4_223.png)


    [1] "umap 6 out of 10"



![png](output_4_225.png)



![png](output_4_226.png)


    [1] "umap 7 out of 10"



![png](output_4_228.png)



![png](output_4_229.png)


    [1] "umap 8 out of 10"



![png](output_4_231.png)



![png](output_4_232.png)


    [1] "umap 9 out of 10"



![png](output_4_234.png)



![png](output_4_235.png)


    [1] "umap 10 out of 10"



![png](output_4_237.png)



![png](output_4_238.png)


    [1] "Window size 40; 9 out of 11"
    [1] "Getting windows"
    [1] "Running UMAP"
    [1] "umap 1 out of 10"



![png](output_4_240.png)



![png](output_4_241.png)


    [1] "umap 2 out of 10"



![png](output_4_243.png)



![png](output_4_244.png)


    [1] "umap 3 out of 10"



![png](output_4_246.png)



![png](output_4_247.png)


    [1] "umap 4 out of 10"



![png](output_4_249.png)



![png](output_4_250.png)


    [1] "umap 5 out of 10"



![png](output_4_252.png)



![png](output_4_253.png)


    [1] "umap 6 out of 10"



![png](output_4_255.png)



![png](output_4_256.png)


    [1] "umap 7 out of 10"



![png](output_4_258.png)



![png](output_4_259.png)


    [1] "umap 8 out of 10"



![png](output_4_261.png)



![png](output_4_262.png)


    [1] "umap 9 out of 10"



![png](output_4_264.png)



![png](output_4_265.png)


    [1] "umap 10 out of 10"



![png](output_4_267.png)



![png](output_4_268.png)


    [1] "Window size 45; 10 out of 11"
    [1] "Getting windows"
    [1] "Running UMAP"
    [1] "umap 1 out of 10"



![png](output_4_270.png)



![png](output_4_271.png)


    [1] "umap 2 out of 10"



![png](output_4_273.png)



![png](output_4_274.png)


    [1] "umap 3 out of 10"



![png](output_4_276.png)



![png](output_4_277.png)


    [1] "umap 4 out of 10"



![png](output_4_279.png)



![png](output_4_280.png)


    [1] "umap 5 out of 10"



![png](output_4_282.png)



![png](output_4_283.png)


    [1] "umap 6 out of 10"



![png](output_4_285.png)



![png](output_4_286.png)


    [1] "umap 7 out of 10"



![png](output_4_288.png)



![png](output_4_289.png)


    [1] "umap 8 out of 10"



![png](output_4_291.png)



![png](output_4_292.png)


    [1] "umap 9 out of 10"



![png](output_4_294.png)



![png](output_4_295.png)


    [1] "umap 10 out of 10"



![png](output_4_297.png)



![png](output_4_298.png)


    [1] "Window size 50; 11 out of 11"
    [1] "Getting windows"
    [1] "Running UMAP"
    [1] "umap 1 out of 10"



![png](output_4_300.png)



![png](output_4_301.png)


    [1] "umap 2 out of 10"



![png](output_4_303.png)



![png](output_4_304.png)


    [1] "umap 3 out of 10"



![png](output_4_306.png)



![png](output_4_307.png)


    [1] "umap 4 out of 10"



![png](output_4_309.png)



![png](output_4_310.png)


    [1] "umap 5 out of 10"



![png](output_4_312.png)



![png](output_4_313.png)


    [1] "umap 6 out of 10"



![png](output_4_315.png)



![png](output_4_316.png)


    [1] "umap 7 out of 10"



![png](output_4_318.png)



![png](output_4_319.png)


    [1] "umap 8 out of 10"



![png](output_4_321.png)



![png](output_4_322.png)


    [1] "umap 9 out of 10"



![png](output_4_324.png)



![png](output_4_325.png)


    [1] "umap 10 out of 10"



![png](output_4_327.png)



![png](output_4_328.png)



![png](output_4_329.png)



```R
#Save
#saveRDS(iterative_windows, '/Users/ryanayork/Desktop/TREBLE_walkthrough/00_data/sample_correlated_random_walk_iterative_windows.RDS')
```


```R
#Load
#iterative_windows = readRDS('/Users/ryanayork/Desktop/TREBLE_walkthrough/00_data/sample_correlated_random_walk_iterative_windows.RDS')
```


```R
##Structural variation of the behavior spaces produced by 'iterative_windows' 
##can be explored using distance masures.
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
```


![png](output_7_0.png)



```R
##Since the mean values of the distance measures vary a bit it might be useful to also visualize
##the distance measures as variance controlling for the mean (i.e. dividing variance by the mean)
#Plot variance 
par(mfrow = c(1,2))
plot_variance(iterative_windows_pr,
              ylim = c(0, 0.2),
              ylab = "RMSE",
              xlab = "Window size (frames)")
plot_variance(iterative_windows_dist,
              ylim = c(0, 0.2),
              ylab = "Mean Euclidean distance",
              xlab = "Window size (frames)")
```


![png](output_8_0.png)



```R
##The spaces produced by 'iterative_windows' may also possess different temporal properties
##based on window size
##A temporal property that might be of concern is the amount of recurrence in a given space, reflecting
##how stereotyped/periodic paths are through the space
#Calculate recurrence across all window sizes
recurrence = list()
for(i in 1:length(iterative_windows)){
  recurrence[[as.character(names(iterative_windows)[i])]] = calculate_recurrence(iterative_windows[[i]]$umaps,
                                                                                 n_bins = 16)}
```

    [1] "1 out of 10"
    [1] "2 out of 10"



![png](output_9_1.png)


    [1] "3 out of 10"



![png](output_9_3.png)


    [1] "4 out of 10"



![png](output_9_5.png)


    [1] "5 out of 10"



![png](output_9_7.png)


    [1] "6 out of 10"



![png](output_9_9.png)


    [1] "7 out of 10"



![png](output_9_11.png)


    [1] "8 out of 10"



![png](output_9_13.png)


    [1] "9 out of 10"



![png](output_9_15.png)


    [1] "10 out of 10"



![png](output_9_17.png)



![png](output_9_18.png)


    [1] "1 out of 10"



![png](output_9_20.png)


    [1] "2 out of 10"



![png](output_9_22.png)


    [1] "3 out of 10"



![png](output_9_24.png)


    [1] "4 out of 10"



![png](output_9_26.png)


    [1] "5 out of 10"



![png](output_9_28.png)


    [1] "6 out of 10"



![png](output_9_30.png)


    [1] "7 out of 10"



![png](output_9_32.png)


    [1] "8 out of 10"



![png](output_9_34.png)


    [1] "9 out of 10"



![png](output_9_36.png)


    [1] "10 out of 10"



![png](output_9_38.png)



![png](output_9_39.png)


    [1] "1 out of 10"



![png](output_9_41.png)


    [1] "2 out of 10"



![png](output_9_43.png)


    [1] "3 out of 10"



![png](output_9_45.png)


    [1] "4 out of 10"



![png](output_9_47.png)


    [1] "5 out of 10"



![png](output_9_49.png)


    [1] "6 out of 10"



![png](output_9_51.png)


    [1] "7 out of 10"



![png](output_9_53.png)


    [1] "8 out of 10"



![png](output_9_55.png)


    [1] "9 out of 10"



![png](output_9_57.png)


    [1] "10 out of 10"



![png](output_9_59.png)



![png](output_9_60.png)


    [1] "1 out of 10"



![png](output_9_62.png)


    [1] "2 out of 10"



![png](output_9_64.png)


    [1] "3 out of 10"



![png](output_9_66.png)


    [1] "4 out of 10"



![png](output_9_68.png)


    [1] "5 out of 10"



![png](output_9_70.png)


    [1] "6 out of 10"



![png](output_9_72.png)


    [1] "7 out of 10"



![png](output_9_74.png)


    [1] "8 out of 10"



![png](output_9_76.png)


    [1] "9 out of 10"



![png](output_9_78.png)


    [1] "10 out of 10"



![png](output_9_80.png)



![png](output_9_81.png)


    [1] "1 out of 10"



![png](output_9_83.png)


    [1] "2 out of 10"



![png](output_9_85.png)


    [1] "3 out of 10"



![png](output_9_87.png)


    [1] "4 out of 10"



![png](output_9_89.png)


    [1] "5 out of 10"



![png](output_9_91.png)


    [1] "6 out of 10"



![png](output_9_93.png)


    [1] "7 out of 10"



![png](output_9_95.png)


    [1] "8 out of 10"



![png](output_9_97.png)


    [1] "9 out of 10"



![png](output_9_99.png)


    [1] "10 out of 10"



![png](output_9_101.png)



![png](output_9_102.png)


    [1] "1 out of 10"



![png](output_9_104.png)


    [1] "2 out of 10"



![png](output_9_106.png)


    [1] "3 out of 10"



![png](output_9_108.png)


    [1] "4 out of 10"



![png](output_9_110.png)


    [1] "5 out of 10"



![png](output_9_112.png)


    [1] "6 out of 10"



![png](output_9_114.png)


    [1] "7 out of 10"



![png](output_9_116.png)


    [1] "8 out of 10"



![png](output_9_118.png)


    [1] "9 out of 10"



![png](output_9_120.png)


    [1] "10 out of 10"



![png](output_9_122.png)



![png](output_9_123.png)


    [1] "1 out of 10"



![png](output_9_125.png)


    [1] "2 out of 10"



![png](output_9_127.png)


    [1] "3 out of 10"



![png](output_9_129.png)


    [1] "4 out of 10"



![png](output_9_131.png)


    [1] "5 out of 10"



![png](output_9_133.png)


    [1] "6 out of 10"



![png](output_9_135.png)


    [1] "7 out of 10"



![png](output_9_137.png)


    [1] "8 out of 10"



![png](output_9_139.png)


    [1] "9 out of 10"



![png](output_9_141.png)


    [1] "10 out of 10"



![png](output_9_143.png)



![png](output_9_144.png)


    [1] "1 out of 10"



![png](output_9_146.png)


    [1] "2 out of 10"



![png](output_9_148.png)


    [1] "3 out of 10"



![png](output_9_150.png)


    [1] "4 out of 10"



![png](output_9_152.png)


    [1] "5 out of 10"



![png](output_9_154.png)


    [1] "6 out of 10"



![png](output_9_156.png)


    [1] "7 out of 10"



![png](output_9_158.png)


    [1] "8 out of 10"



![png](output_9_160.png)


    [1] "9 out of 10"



![png](output_9_162.png)


    [1] "10 out of 10"



![png](output_9_164.png)



![png](output_9_165.png)


    [1] "1 out of 10"



![png](output_9_167.png)


    [1] "2 out of 10"



![png](output_9_169.png)


    [1] "3 out of 10"



![png](output_9_171.png)


    [1] "4 out of 10"



![png](output_9_173.png)


    [1] "5 out of 10"



![png](output_9_175.png)


    [1] "6 out of 10"



![png](output_9_177.png)


    [1] "7 out of 10"



![png](output_9_179.png)


    [1] "8 out of 10"



![png](output_9_181.png)


    [1] "9 out of 10"



![png](output_9_183.png)


    [1] "10 out of 10"



![png](output_9_185.png)



![png](output_9_186.png)


    [1] "1 out of 10"



![png](output_9_188.png)


    [1] "2 out of 10"



![png](output_9_190.png)


    [1] "3 out of 10"



![png](output_9_192.png)


    [1] "4 out of 10"



![png](output_9_194.png)


    [1] "5 out of 10"



![png](output_9_196.png)


    [1] "6 out of 10"



![png](output_9_198.png)


    [1] "7 out of 10"



![png](output_9_200.png)


    [1] "8 out of 10"



![png](output_9_202.png)


    [1] "9 out of 10"



![png](output_9_204.png)


    [1] "10 out of 10"



![png](output_9_206.png)



![png](output_9_207.png)


    [1] "1 out of 10"



![png](output_9_209.png)


    [1] "2 out of 10"



![png](output_9_211.png)


    [1] "3 out of 10"



![png](output_9_213.png)


    [1] "4 out of 10"



![png](output_9_215.png)


    [1] "5 out of 10"



![png](output_9_217.png)


    [1] "6 out of 10"



![png](output_9_219.png)


    [1] "7 out of 10"



![png](output_9_221.png)


    [1] "8 out of 10"



![png](output_9_223.png)


    [1] "9 out of 10"



![png](output_9_225.png)


    [1] "10 out of 10"



![png](output_9_227.png)



![png](output_9_228.png)



![png](output_9_229.png)



```R
#Save
#saveRDS(recurrence, '/Users/ryanayork/Desktop/TREBLE_walkthrough/00_data/sample_correlated_random_walk_iterative_windows_recurrence.RDS')
```


```R
#Load
#recurrence = readRDS('/Users/ryanayork/Desktop/TREBLE_walkthrough/00_data/sample_correlated_random_walk_iterative_windows_recurrence.RDS')
```


```R
##Below is a function for plotting the results of 'calculate_recurrence'
##Recurrence is visualized using a heatmap for each window size, the rows of which correspond
##to replicate behavior spaces
##The heatmap is colored by the proportion of bins in the space that return to each bin after a previous visit
##The x-axis corresponds to time after the previous visit
#Plot recurrence
plot_recurrence(recurrence)
```


![png](output_12_0.png)



```R
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
```


![png](output_13_0.png)



```R
##################################################
#####Get windows of desired size and run UMAP#####
##################################################
##Given the above analyses it looks like a window size of 15 frames may be a reasonable
##tradeoff between recurrence and structural variability
#Extract windows of size 15 frames
windows = list()
for(i in 1:length(vel)){
  print(paste('replicate', i, 'out of', length(vel)))
  windows[[as.character(i)]] = get_velocity_windows(vel[[i]],
                                                    window_size = 15, 
                                                    name = paste('replicate_', i, sep = ''))}
```

    [1] "replicate 1 out of 10"
    [1] "replicate 2 out of 10"
    [1] "replicate 3 out of 10"
    [1] "replicate 4 out of 10"
    [1] "replicate 5 out of 10"
    [1] "replicate 6 out of 10"
    [1] "replicate 7 out of 10"
    [1] "replicate 8 out of 10"
    [1] "replicate 9 out of 10"
    [1] "replicate 10 out of 10"



```R
#Combine windows
windows = do.call(cbind, windows)
```


```R
#Save
#saveRDS(windows, '/Users/ryanayork/Desktop/TREBLE_walkthrough/00_data/sample_correlated_random_walk_windows.RDS')
```


```R
#Run UMAP
u = umap(t(windows),
         verbose = TRUE)
```

    [2020-05-21 10:30:16]  starting umap
    
    [2020-05-21 10:30:16]  creating graph of nearest neighbors
    
    [2020-05-21 10:32:34]  creating initial embedding
    
    [2020-05-21 10:32:45]  optimizing embedding
    
    [2020-05-21 10:32:45]  epoch: 1
    
    [2020-05-21 10:32:45]  epoch: 2
    
    [2020-05-21 10:32:45]  epoch: 3
    
    [2020-05-21 10:32:46]  epoch: 4
    
    [2020-05-21 10:32:46]  epoch: 5
    
    [2020-05-21 10:32:47]  epoch: 6
    
    [2020-05-21 10:32:47]  epoch: 7
    
    [2020-05-21 10:32:48]  epoch: 8
    
    [2020-05-21 10:32:48]  epoch: 9
    
    [2020-05-21 10:32:48]  epoch: 10
    
    [2020-05-21 10:32:49]  epoch: 11
    
    [2020-05-21 10:32:49]  epoch: 12
    
    [2020-05-21 10:32:49]  epoch: 13
    
    [2020-05-21 10:32:50]  epoch: 14
    
    [2020-05-21 10:32:50]  epoch: 15
    
    [2020-05-21 10:32:50]  epoch: 16
    
    [2020-05-21 10:32:51]  epoch: 17
    
    [2020-05-21 10:32:51]  epoch: 18
    
    [2020-05-21 10:32:51]  epoch: 19
    
    [2020-05-21 10:32:52]  epoch: 20
    
    [2020-05-21 10:32:52]  epoch: 21
    
    [2020-05-21 10:32:52]  epoch: 22
    
    [2020-05-21 10:32:53]  epoch: 23
    
    [2020-05-21 10:32:53]  epoch: 24
    
    [2020-05-21 10:32:53]  epoch: 25
    
    [2020-05-21 10:32:54]  epoch: 26
    
    [2020-05-21 10:32:54]  epoch: 27
    
    [2020-05-21 10:32:54]  epoch: 28
    
    [2020-05-21 10:32:55]  epoch: 29
    
    [2020-05-21 10:32:55]  epoch: 30
    
    [2020-05-21 10:32:55]  epoch: 31
    
    [2020-05-21 10:32:56]  epoch: 32
    
    [2020-05-21 10:32:56]  epoch: 33
    
    [2020-05-21 10:32:56]  epoch: 34
    
    [2020-05-21 10:32:57]  epoch: 35
    
    [2020-05-21 10:32:57]  epoch: 36
    
    [2020-05-21 10:32:57]  epoch: 37
    
    [2020-05-21 10:32:58]  epoch: 38
    
    [2020-05-21 10:32:58]  epoch: 39
    
    [2020-05-21 10:32:58]  epoch: 40
    
    [2020-05-21 10:32:59]  epoch: 41
    
    [2020-05-21 10:32:59]  epoch: 42
    
    [2020-05-21 10:33:00]  epoch: 43
    
    [2020-05-21 10:33:00]  epoch: 44
    
    [2020-05-21 10:33:00]  epoch: 45
    
    [2020-05-21 10:33:00]  epoch: 46
    
    [2020-05-21 10:33:01]  epoch: 47
    
    [2020-05-21 10:33:01]  epoch: 48
    
    [2020-05-21 10:33:01]  epoch: 49
    
    [2020-05-21 10:33:02]  epoch: 50
    
    [2020-05-21 10:33:02]  epoch: 51
    
    [2020-05-21 10:33:02]  epoch: 52
    
    [2020-05-21 10:33:03]  epoch: 53
    
    [2020-05-21 10:33:03]  epoch: 54
    
    [2020-05-21 10:33:04]  epoch: 55
    
    [2020-05-21 10:33:04]  epoch: 56
    
    [2020-05-21 10:33:04]  epoch: 57
    
    [2020-05-21 10:33:04]  epoch: 58
    
    [2020-05-21 10:33:05]  epoch: 59
    
    [2020-05-21 10:33:05]  epoch: 60
    
    [2020-05-21 10:33:06]  epoch: 61
    
    [2020-05-21 10:33:06]  epoch: 62
    
    [2020-05-21 10:33:06]  epoch: 63
    
    [2020-05-21 10:33:07]  epoch: 64
    
    [2020-05-21 10:33:07]  epoch: 65
    
    [2020-05-21 10:33:07]  epoch: 66
    
    [2020-05-21 10:33:08]  epoch: 67
    
    [2020-05-21 10:33:08]  epoch: 68
    
    [2020-05-21 10:33:08]  epoch: 69
    
    [2020-05-21 10:33:09]  epoch: 70
    
    [2020-05-21 10:33:09]  epoch: 71
    
    [2020-05-21 10:33:09]  epoch: 72
    
    [2020-05-21 10:33:10]  epoch: 73
    
    [2020-05-21 10:33:10]  epoch: 74
    
    [2020-05-21 10:33:10]  epoch: 75
    
    [2020-05-21 10:33:11]  epoch: 76
    
    [2020-05-21 10:33:11]  epoch: 77
    
    [2020-05-21 10:33:11]  epoch: 78
    
    [2020-05-21 10:33:12]  epoch: 79
    
    [2020-05-21 10:33:12]  epoch: 80
    
    [2020-05-21 10:33:12]  epoch: 81
    
    [2020-05-21 10:33:13]  epoch: 82
    
    [2020-05-21 10:33:13]  epoch: 83
    
    [2020-05-21 10:33:13]  epoch: 84
    
    [2020-05-21 10:33:14]  epoch: 85
    
    [2020-05-21 10:33:14]  epoch: 86
    
    [2020-05-21 10:33:14]  epoch: 87
    
    [2020-05-21 10:33:15]  epoch: 88
    
    [2020-05-21 10:33:15]  epoch: 89
    
    [2020-05-21 10:33:15]  epoch: 90
    
    [2020-05-21 10:33:16]  epoch: 91
    
    [2020-05-21 10:33:16]  epoch: 92
    
    [2020-05-21 10:33:16]  epoch: 93
    
    [2020-05-21 10:33:17]  epoch: 94
    
    [2020-05-21 10:33:17]  epoch: 95
    
    [2020-05-21 10:33:17]  epoch: 96
    
    [2020-05-21 10:33:18]  epoch: 97
    
    [2020-05-21 10:33:18]  epoch: 98
    
    [2020-05-21 10:33:18]  epoch: 99
    
    [2020-05-21 10:33:19]  epoch: 100
    
    [2020-05-21 10:33:19]  epoch: 101
    
    [2020-05-21 10:33:19]  epoch: 102
    
    [2020-05-21 10:33:20]  epoch: 103
    
    [2020-05-21 10:33:20]  epoch: 104
    
    [2020-05-21 10:33:20]  epoch: 105
    
    [2020-05-21 10:33:21]  epoch: 106
    
    [2020-05-21 10:33:21]  epoch: 107
    
    [2020-05-21 10:33:21]  epoch: 108
    
    [2020-05-21 10:33:22]  epoch: 109
    
    [2020-05-21 10:33:22]  epoch: 110
    
    [2020-05-21 10:33:22]  epoch: 111
    
    [2020-05-21 10:33:23]  epoch: 112
    
    [2020-05-21 10:33:23]  epoch: 113
    
    [2020-05-21 10:33:23]  epoch: 114
    
    [2020-05-21 10:33:24]  epoch: 115
    
    [2020-05-21 10:33:24]  epoch: 116
    
    [2020-05-21 10:33:25]  epoch: 117
    
    [2020-05-21 10:33:25]  epoch: 118
    
    [2020-05-21 10:33:25]  epoch: 119
    
    [2020-05-21 10:33:26]  epoch: 120
    
    [2020-05-21 10:33:26]  epoch: 121
    
    [2020-05-21 10:33:26]  epoch: 122
    
    [2020-05-21 10:33:27]  epoch: 123
    
    [2020-05-21 10:33:27]  epoch: 124
    
    [2020-05-21 10:33:27]  epoch: 125
    
    [2020-05-21 10:33:28]  epoch: 126
    
    [2020-05-21 10:33:28]  epoch: 127
    
    [2020-05-21 10:33:28]  epoch: 128
    
    [2020-05-21 10:33:29]  epoch: 129
    
    [2020-05-21 10:33:29]  epoch: 130
    
    [2020-05-21 10:33:29]  epoch: 131
    
    [2020-05-21 10:33:30]  epoch: 132
    
    [2020-05-21 10:33:30]  epoch: 133
    
    [2020-05-21 10:33:31]  epoch: 134
    
    [2020-05-21 10:33:31]  epoch: 135
    
    [2020-05-21 10:33:31]  epoch: 136
    
    [2020-05-21 10:33:32]  epoch: 137
    
    [2020-05-21 10:33:32]  epoch: 138
    
    [2020-05-21 10:33:32]  epoch: 139
    
    [2020-05-21 10:33:33]  epoch: 140
    
    [2020-05-21 10:33:33]  epoch: 141
    
    [2020-05-21 10:33:33]  epoch: 142
    
    [2020-05-21 10:33:33]  epoch: 143
    
    [2020-05-21 10:33:34]  epoch: 144
    
    [2020-05-21 10:33:34]  epoch: 145
    
    [2020-05-21 10:33:35]  epoch: 146
    
    [2020-05-21 10:33:35]  epoch: 147
    
    [2020-05-21 10:33:35]  epoch: 148
    
    [2020-05-21 10:33:35]  epoch: 149
    
    [2020-05-21 10:33:36]  epoch: 150
    
    [2020-05-21 10:33:36]  epoch: 151
    
    [2020-05-21 10:33:37]  epoch: 152
    
    [2020-05-21 10:33:37]  epoch: 153
    
    [2020-05-21 10:33:37]  epoch: 154
    
    [2020-05-21 10:33:38]  epoch: 155
    
    [2020-05-21 10:33:38]  epoch: 156
    
    [2020-05-21 10:33:38]  epoch: 157
    
    [2020-05-21 10:33:39]  epoch: 158
    
    [2020-05-21 10:33:39]  epoch: 159
    
    [2020-05-21 10:33:39]  epoch: 160
    
    [2020-05-21 10:33:40]  epoch: 161
    
    [2020-05-21 10:33:40]  epoch: 162
    
    [2020-05-21 10:33:40]  epoch: 163
    
    [2020-05-21 10:33:41]  epoch: 164
    
    [2020-05-21 10:33:41]  epoch: 165
    
    [2020-05-21 10:33:41]  epoch: 166
    
    [2020-05-21 10:33:42]  epoch: 167
    
    [2020-05-21 10:33:42]  epoch: 168
    
    [2020-05-21 10:33:42]  epoch: 169
    
    [2020-05-21 10:33:43]  epoch: 170
    
    [2020-05-21 10:33:43]  epoch: 171
    
    [2020-05-21 10:33:43]  epoch: 172
    
    [2020-05-21 10:33:44]  epoch: 173
    
    [2020-05-21 10:33:44]  epoch: 174
    
    [2020-05-21 10:33:44]  epoch: 175
    
    [2020-05-21 10:33:45]  epoch: 176
    
    [2020-05-21 10:33:45]  epoch: 177
    
    [2020-05-21 10:33:45]  epoch: 178
    
    [2020-05-21 10:33:46]  epoch: 179
    
    [2020-05-21 10:33:46]  epoch: 180
    
    [2020-05-21 10:33:46]  epoch: 181
    
    [2020-05-21 10:33:47]  epoch: 182
    
    [2020-05-21 10:33:47]  epoch: 183
    
    [2020-05-21 10:33:47]  epoch: 184
    
    [2020-05-21 10:33:48]  epoch: 185
    
    [2020-05-21 10:33:48]  epoch: 186
    
    [2020-05-21 10:33:48]  epoch: 187
    
    [2020-05-21 10:33:49]  epoch: 188
    
    [2020-05-21 10:33:49]  epoch: 189
    
    [2020-05-21 10:33:49]  epoch: 190
    
    [2020-05-21 10:33:50]  epoch: 191
    
    [2020-05-21 10:33:50]  epoch: 192
    
    [2020-05-21 10:33:50]  epoch: 193
    
    [2020-05-21 10:33:51]  epoch: 194
    
    [2020-05-21 10:33:51]  epoch: 195
    
    [2020-05-21 10:33:51]  epoch: 196
    
    [2020-05-21 10:33:52]  epoch: 197
    
    [2020-05-21 10:33:52]  epoch: 198
    
    [2020-05-21 10:33:52]  epoch: 199
    
    [2020-05-21 10:33:53]  epoch: 200
    
    [2020-05-21 10:33:53]  done
    



```R
#Extract layout
layout = data.frame(x = u$layout[,1],
                    y = u$layout[,2],
                    individual = paste(unlist(lapply(strsplit(colnames(windows), "_"), function(v){v[3]})),
                                       unlist(lapply(strsplit(colnames(windows), "_"), function(v){v[4]})),
                                       sep= ''),
                    time = unlist(lapply(strsplit(colnames(windows), "_"), function(v){v[1]})))
```


```R
#Bin
layout = bin_umap(layout,
                  n_bins = 32)$layout
```


```R
#Save
#saveRDS(layout, '/Users/ryanayork/Desktop/TREBLE_walkthrough/00_data/sample_correlated_random_walk_UMAP_layout.RDS')
```


```R
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
```


![png](output_21_0.png)



```R
##Plot layout as vector field
par(mfrow = c(1,2), bty = 'n', xaxt = 'n', yaxt = 'n', mar = c(2,2,2,2))

#Non-theta (angle) colored
plot_vector_field(layout)

#Theta colored
plot_vector_field(layout, 
                  color_by_theta = TRUE)
```


![png](output_22_0.png)



```R
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
```


![png](output_23_0.png)



```R
##Plot with features colored
#Bins
plot_umap_features(layout, 
                   windows,
                   feature_names = c('Translational velocity', 'Angular velocity'),
                   colors = c('darkgreen', 'darkmagenta'),
                   n_features = 2)
```


![png](output_24_0.png)



```R
##Plot with features colored
#Points
plot_umap_features(layout, 
                   windows,
                   feature_names = c('Translational velocity', 'Angular velocity'),
                   plot_points = TRUE,
                   cex = 0.1,
                   colors = c('darkgreen', 'darkmagenta'),
                   n_features = 2)
```


![png](output_25_0.png)



```R
###########################################
#####Compare across individuals/trials#####
###########################################
#Visualize occupancy within the space via a probability density function (pdf), producing a 'density map'
plot_umap_pdf(layout, h = 2)
```


![png](output_26_0.png)



```R
#Plot individual pdfs
par(mfrow = c(2,5))
inds = split(layout, layout$individual)
pdfs = list()
for(i in 1:length(inds)){
  pdfs[[names(inds)[i]]] = plot_umap_pdf(inds[[i]], 
                                         h = 2,
                                         return = TRUE)
}
```


![png](output_27_0.png)



```R
#Compare individual's distributions in space via Fisher's test
run_umap_fishers(layout,
                 layout$individual)
```


![png](output_28_0.png)



```R
##Hierarchical clustering on density maps
#Unlist density maps and combine into a dataframe
p = do.call(cbind, lapply(pdfs, function(x) unlist(as.data.frame(x$z))))

#Normalize
p = apply(p, 2, function(x) x/max(x))

#Heatmap with hierarchical clustering
heatmap(t(p), 
        Colv = NA,
        labCol = '')
```


![png](output_29_0.png)



```R

```
