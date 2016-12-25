# Non_Parametric_Kernel_Density_Estimation
We propose to use a kernel density estimation (KDE) based approach for classification. This non-parametric approach intrinsically provides the likelihood of membership for each class in a principled manner.

The implementation was used in:

[1] M. U. Ghani, F. Mesadi, S. D. Kanik, A. O. Argunsah, A. Hobbiss, I. Israely, D. Unay, T. Tasdizen, and M. Cetin, "Shape and appearance features based dendritic spine classification," Journal of Neuroscience Methods.

Any papers using this code should cite [1] accordingly.

The software has been tested under Matlab R2013b.

After unpacking the compressed file, start Matlab and can then run "KDE_JNeuMeth.m" in the root directory.

If errors are reported, you probably do not have some of the following MATLAB toolboxes. Please make sure that you have properly installed following MATLAB toolboxes:
1. Statistics and Machine Learning Toolbox
2. Bioinformatics Toolbox

If you still have problems, you can email me at ghani@sabanciuniv.edu or mughani@bu.edu
I will do my best to help.

As is, the code performs dendritic spine classification using Disjunctive Normal Shape Models (DNSM) and Histogram of Oriented Gradients (HOG) based features (as discussed in [1]). However, the implementation is generic, you can prepare your new feature representation files as "DNSM_N8M16_Segmented.xlsx" and use our implementation to perform KDE based classification and statistical significance analysis.
 
Note that, if number of classes are different in your dataset, you will have to modify some portion of code in "KDE_JNeuMeth.m", where I have tried to comment heavily.

Please also report any bug to ghani@sabanciuniv.edu or mughani@bu.edu
