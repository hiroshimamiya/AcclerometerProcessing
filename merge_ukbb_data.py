
import os
import pandas as pd

os.chdir('/home/yalap95/current_df')
print(os.getcwd())


current_df = pd.read_csv('current_subset_df.csv')
twi = pd.read_csv('townsend.csv')
c_ox = pd.read_csv('current_df_ox.csv')
strokes_mi = pd.read_csv('strokes_mi.csv')

current_subset_2 = pd.merge(current_df, twi, on='eid')

current_subset_2.to_csv('/home/yalap95/current_df/current_subset_2.csv', index=False)

final_df = pd.merge(current_subset_2, strokes_mi, on='eid')
final_df.to_csv('/home/yalap95/current_df/final_df.csv', index=False)


#current_subset_ox_2 = pd.merge(c_ox, twi, on='eid')
