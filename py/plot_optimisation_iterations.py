"""
For plotting the trajectory of the root mean squared difference during the
optimisation process.
"""

import os
execfile(os.environ["PYTHONSTARTUP"])
import numpy as np
import pandas as pd
import logging as lg
import matplotlib.pyplot as plt
import seaborn
import glob

lg.basicConfig(level=lg.INFO)

proj_dir = os.environ["HOME"] + "/Calcium_Deconvolution"
opt_dir = proj_dir + "/csv/optimisation"
image_dir = proj_dir + "/images"
opt_files = glob.glob(opt_dir + "new*2e-2.csv")
for opt_file in opt_files:
    lg.info(' Processing ' + opt_file + '...')
    opt_table = pd.read_csv(opt_file)
    plt.plot(range(1,len(opt_table)+1), opt_table["rms"])
    plt.xlabel('Iterations')
    plt.ylabel('Sum of root mean squared differences')
    details = opt_file.split('_')[-4:]
    plt.title('Dataset ' + details[1] + ', Trace ' + details[2] + ', gopt=' + details[3][:-4])
    image_file_name = image_dir + '/optimisation_traces/' + opt_file.split('/')[-1].replace('csv', 'png')
    plt.savefig(image_file_name)
    plt.close()
lg.info(' Done.')
