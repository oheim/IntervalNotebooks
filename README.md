# Interval Notebooks
Collection of optimization problems to be solved with interval arithmetic (verified results, various libraries)

## To view the notebooks
Click on the `.ipynb` files in Github's repository browser.

## To edit the notebooks
Clone the repository and start Jupyter.
* Standard requirements: Python3 with PIP, GNU Octave, GNU Make, GNU MPFR
* Special requirements
  * cling C++ interpreter: For Debian 9.2 I could just untar the binary for Ubuntu 16 from https://root.cern.ch/download/cling/ and set the environment variable `CLING_INSTALL_PREFIX` to point to its local folder
* Other requirements will be downloaded and installed as needed
* The following commands will run Jupyter locally in your browser
````
  git clone https://github.com/oheim/IntervalNotebooks.git
  cd IntervalNotebooks
  make
````
