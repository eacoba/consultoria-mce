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
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import pandas as pd

from sklearn.decomposition import PCA
    
X = np.loadtxt(savedir+'dist_intermol_sort_gromos_10atoms_'+str(nmol)+'cbd.csv', delimiter=",")

# 2. Aplicar PCA con 2 componentes
pca = PCA(n_components=2)
Y_pca = pca.fit_transform(X)

# 3. Imprimir varianza explicada
explained_var = pca.explained_variance_ratio_
cumulative_var_pca = explained_var.cumsum() # acumulada
    
with open(savedir+'varianza_acumulada_10atoms-'+str(nmol)+'CBD-'+ff+'.txt', "w") as file:
    file.write(f"Varianza acumulada: {cumulative_var_pca}")

df_pca = pd.DataFrame(Y_pca, columns=['PC1', 'PC2'])
df_pca.to_csv(savedir+'Y_pca:10atoms-'+str(nmol)+'CBD-'+ff+'.csv', index=False)

# Graficar los primeros dos componentes
plt.figure(figsize=(8, 6))
plt.scatter(Y_pca[:, 0], Y_pca[:, 1], s=10, alpha=0.6)
plt.xlabel("PC 1")
plt.ylabel("PC 2")
plt.title("Proyección PCA - Primeros dos componentes")
plt.grid(True)
plt.tight_layout()

# Guardar la figura como imagen
plt.savefig(savedir+'Y_pca_10atoms-'+str(nmol)+'CBD-'+ff+'-proyeccion.png', dpi=300)
