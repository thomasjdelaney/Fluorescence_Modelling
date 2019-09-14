## For doing some analysis on the optimised parameters of the Fluorescence model

import os
execfile(os.environ["PYTHONSTARTUP"])
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn
import getopt
import glob
import itertools
import logging as lg

lg.basicConfig(level=lg.INFO, format="%(asctime)s %(levelname)s: %(message)s", datefmt="%Y-%m-%d %H:%M:%S")

def init_params():
  params = {  "opt_csv_dir"   :   os.environ["HOME"] + "/Calcium_Deconvolution/csv/optimisation/",
              "opt_image_dir" :   os.environ["HOME"] + "/Calcium_Deconvolution/images/optimisation/",
              "save_images"   :   False,
              "debug"         :   False }
  command_line_options = ["help", "opt_csv_dir=", "opt_image_dir=", "save_images", "debug"]
  opts, args = getopt.getopt(sys.argv[1:], "h:o:i:s:d", command_line_options)
  for opt, arg in opts:
    if opt in ("-h", "--help"):
      print"python py/make_free_parameter_plots.py --opt_csv_dir <directory> --debug"
      print"example command"
      sys.exit()
    elif opt in ("-o", "--opt_csv_dir"):
      params["opt_csv_dir"] = arg
    elif opt in ("-i", "--opt_image_dir"):
      params["opt_image_dir"] = arg
    elif opt in ("-s", "--save_images"):
      params["save_images"] = True
    elif opt in ("-d", "--debug"):
      params["debug"] = True
  return params

def saveOrShow(save_images, filename, opt_image_dir):
  save_name = ""
  if save_images:
    save_name = opt_image_dir + filename
    plt.savefig(save_name)
  else:
    plt.show(block=False)
  return save_name

def getOptimisedParamsFrame(opt_files):
  num_files = len(opt_files)
  columns = pd.read_csv(opt_files[0]).columns
  opt_frame = pd.DataFrame(index=range(num_files), columns=columns)
  for i in xrange(num_files):
    file_frame = pd.read_csv(opt_files[i])
    opt_row = file_frame.iloc[file_frame.rms.idxmin(), :]
    opt_frame.iloc[i, :] = opt_row
  return opt_frame

def makeParamBoxPlot(param, opt_frame, save_images, opt_image_dir):
  opt_series = opt_frame[param]
  opt_series.plot.box(showmeans=True)
  plt.scatter(np.ones(opt_series.shape), opt_series)
  plt.ylim(ymin=0);
  save_name = saveOrShow(save_images, "optimised_" + param + "_values.png", opt_image_dir)
  plt.close('all')
  return save_name

def makeParamComparison(params_columns, opt_frame, save_images, opt_image_dir):
  num_params = len(params_columns)
  grid_size = num_params - 1
  param_index_pairs = list(itertools.combinations(range(num_params), 2))
  plt.figure(figsize=(16,9))
  for index_pair in param_index_pairs:
    plot_number = ((index_pair[1]-1)*grid_size) + index_pair[0] + 1
    plt.subplot(grid_size, grid_size, plot_number)
    param_pair = params_columns[[index_pair]]
    plt.scatter(opt_frame[param_pair[0]], opt_frame[param_pair[1]])
    plt.xlim(xmin=0); plt.ylim(ymin=0);
    plt.xlabel(param_pair[0]) if index_pair[1] == num_params-1 else None
    plt.ylabel(param_pair[1]) if index_pair[0] == 0 else None
  save_name = saveOrShow(save_images, "optimised_pairwise_comparison.png", opt_image_dir)
  plt.close('all')
  return save_name

def main():
  lg.info("Starting main function...")
  params = init_params()
  if params['debug']:
    lg.info(" Entering debug mode...")
    return None
  opt_files = glob.glob(params["opt_csv_dir"] + "/*")
  opt_frame = getOptimisedParamsFrame(opt_files)
  params_columns = opt_frame.columns[0:5]
  for param in params_columns:
    save_name = makeParamBoxPlot(param, opt_frame, params["save_images"], params["opt_image_dir"])
    lg.info("Figure saved: " + save_name)
  save_name = makeParamComparison(params_columns, opt_frame, params["save_images"], params["opt_image_dir"])
  lg.info("Figure saved: " + save_name)
  lg.info("Done.")

if __name__ == '__main__':
  main()
