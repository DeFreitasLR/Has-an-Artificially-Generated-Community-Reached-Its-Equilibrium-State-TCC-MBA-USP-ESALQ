
<!-- README.md is generated from README.Rmd. Please edit that file -->

# General overview

This repository contains all data, scripts and functions used for the
statistical analyses of the paper “The Landscape Ecology of Variable
Individuals” to be submitted.

In this study we generated artificial communities with varying degrees
of individual variation and subjected them to varying degrees of habitat
loss and fragmentation. Here we analyzed the relative importance of the
individual variation and landscape components in the persistence of
populations subjected to them.

Finally it creates all the Figures that are used for the paper.

# Repository structure

## Folders

-   data: contains all data needed to perform the analysis and create
    the figures.

    -   `raw` Stores the unmodified data pertaining to the simulations.
        The only instance is an example landscape configuration for an
        example figure creation.
    -   `refined` Stores the data pertaining to the simulations that
        were compiled from other sets of data. This is a dataset in
        which each line represents a simulated community and each column
        represents; i) Individual variation components, ii) landscape
        components, iii) extinction status of the population, and iv)
        time of the last performed action

-   output: contains all results, including the figures presented in the
    main text and supplementary materials of this study.

-   R: contains all R files with all analytical procedures to run the
    analysis using literature data present in this study.

    -   `data_processing` Stores the scrits that manipulate datasets

        01_GLM_Modeling.R: The Creation and selection of Generalised
        Linear Models that better describe the data of the project.

        02_HazardScoresExtractor: A script that computes the Cumulative
        hazard scores for all combinations of the parameters that are
        fed to the GLM

    -   `image_creator` Stores the scrits that generate figures (These
        scripts have to be run manually line by line)

        03_Heatmapimage: Creates the Heatmaps figures based on the
        computed cumulative hazard rates.

        04_ImageMethods: Generates and Image that exemplifies how
        Populational Individual variation works in the simulations

        05_survivalcurves: Generates survival curves divided by classes
        of interes

# Downloading the repository

The user can download this repo to a local folder in your computer or
clone it:

## downloading all files

``` r
download.file(url = "https://github.com/DeFreitasLR/The_Landscape_Ecology_of_Variable_Individuals.git")
```

to unzip the .zip file in your computer type

``` r
unzip(zipfile = "The_Landscape_Ecology_of_Variable_Individuals.zip")
```

# Authors

Lucas R. deFreitas & Paulo Inacio Prado Contact info: <lrfreitas@usp.br>
