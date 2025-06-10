import argparse

parser = argparse.ArgumentParser(description="Ejemplo con banderas")
parser.add_argument("--ff", type=str, default="GROMOS54a7", help="Campo de fuerza")
parser.add_argument("--nmol", type=int, default=2, help="Número de moléculas")

args = parser.parse_args()

ff = args.ff
nmol = args.nmol
savedir = ff+'/'+str(nmol)+'/'

print(ff+'-'+str(nmol))

import numpy as np
import pandas as pd
import pingouin as pg
    
X = np.loadtxt(savedir+'dist_intermol_sort_gromos_'+str(nmol)+'cbd.csv', delimiter=",", dtype=np.float32)

hztest = pg.multivariate_normality(X, alpha=0.05)

result_df = hztest.to_frame().T  # Transponer para que sea una fila

result_df.to_csv(savedir + 'normalidad_multivariada_' + str(nmol) + 'CBD-' + ff + '.csv', index=False)
