# **Fast Image Dehazing Using Dark Channel Prior** #

An implementation of the algorithm described in *Single Image Haze Removal Using Dark Channel Prior* [He et al. 09] ([page](http://kaiminghe.com/cvpr09/)), with the modifications proposed in *Guided Filtering* [He et al. 10] for faster transmission refinement. It was implemented with *Python 2.7* and uses the *SciPy* and *NumPy* libraries.

## Running ##

In order to run the program one needs: 

* [*Python 2.7*](https://www.python.org/) installed;

* [*SciPy*](https://www.scipy.org/index.html) installed;

* [*NumPy*](http://www.numpy.org/) installed.

Having those requirements, one should be able to run the program with the following command line (considering one is in the *src* folder):

```
$ python main.py -i ../images/cones.jpg -o ../results/cones_res.jpg
```

This programs calls the *main* module of the program to receive the arguments. The first argument *-i* is the path to the input image that will be dehazed. While the *-o* argument is the path to the output image, that is, the dehazed version of the input image. These are the only two required arguments.

For optional arguments, one can type:

```
$ python main.py -h
```

This will display the set of arguments available.

## Benchmarks and Results ##

A set of benchmark images can be found under the folder *images*. Most were taken from the main base paper page, but some were taken from the [page](http://www.cs.huji.ac.il/~raananf/projects/dehaze_cl/) of *Dehazing Using Color-Lines* [Fattal 14].

Results of applying the program to some of the benchmark images can be found under the folder *results*.

## References ##

There is a document under *references* listing all the papers used in the development of this project.
However, the two main references for this project were:

* *Single Image Haze Removal Using Dark Channel Prior* [He et al. 09], CVRP;
* *Guided Filtering* [He et al. 10], ECCV.

## About ##

This project was developed as a Final Project for the "INF01050 - Computational Photography" class, 2016, at UFRGS.