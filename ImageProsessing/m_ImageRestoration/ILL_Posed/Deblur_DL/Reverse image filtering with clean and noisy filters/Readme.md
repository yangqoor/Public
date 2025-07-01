# Reverse image filtering with clean and noisy filters 
This repository contains a simple implementation in MATLAB of the following [paper](https://link.springer.com/article/10.1007/s11760-022-02236-w) on reverse image filtering noisy filters. 

## Example 
An example of use is shown in the file ```test.m```. It performs defiltering on a noisy motion blurred image. 

## Dependencies 
No particular dependency (e.g., to additional toolboxes). 

## Notes 
The file ```Landweber.m``` contains an implementation of the main approach described in the paper. The files ```PC_Landweber.m``` and ```NA_Landweber.m``` contain accelerated variants (described in the paper as well). 

## Reference 
This is a link to the [paper](https://link.springer.com/article/10.1007/s11760-022-02236-w) where the methods were introduced. The corresponding bibtex entry is  
```
@article{Wang2023,
title = "Reverse image filtering with clean and noisy filters",
author = "Wang, Lizhong and Fayolle, Pierre-Alain and Belyaev, Alexander",
year = "2023",
journal = "Signal, Image and Video Processing",
volume = "17", 
pages = "333-341", 
issn = "1863-1703",
publisher = "Springer",
doi = "https://doi.org/10.1007/s11760-022-02236-w", 
}
```
