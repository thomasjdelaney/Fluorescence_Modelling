import pandas as pd, numpy as np, matplotlib.pyplot as plt

m = pd.read_csv("/home/pgrads/td16954/linux/Calcium_Deconvolution/csv/8.classification_measures.model.csv")
t = pd.read_csv("/home/pgrads/td16954/linux/Calcium_Deconvolution/csv/8.classification_measures.train.csv")
ri = pd.read_csv("/home/pgrads/td16954/linux/Calcium_Deconvolution/csv/8.classification_measures.release_increase.csv")
rd = pd.read_csv("/home/pgrads/td16954/linux/Calcium_Deconvolution/csv/8.classification_measures.release_decrease.csv")

model = m["tp_rate"][m["precision"].notnull()]
train = t["tp_rate"][m["precision"].notnull()]
release_increase = ri["tp_rate"][m["precision"].notnull()]
release_decrease = rd["tp_rate"][m["precision"].notnull()]
