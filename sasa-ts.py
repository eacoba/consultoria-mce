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
import mdtraj as md
from matplotlib.pylab import *
import matplotlib.pyplot as plt

topdir=ff+'/'+str(nmol)+'/'+str(nmol)+'CBD.pdb'
trjdir=ff+'/'+str(nmol)+'/'+str(nmol)+'CBD-md0_1000.xtc'

trajectory = md.load(trjdir, top=topdir)
#trajectory = trajectory.image_molecules()

sasa = md.shrake_rupley(trajectory)

print(trajectory)
print('sasa data shape', sasa.shape)

np.savetxt(savedir+'/sasa-per-atom-'+ff+'-'+str(nmol)+'.csv', sasa, delimiter=",")

total_sasa = sasa.sum(axis=1)
print(total_sasa.shape)

np.savetxt(savedir+'/sasa-total-'+ff+'-'+str(nmol)+'.csv', total_sasa, delimiter=",")

plot(trajectory.time, total_sasa)
xlabel('Time [ps]', size=16)
ylabel('Total SASA (nm)^2', size=16)

plt.savefig(savedir+'/sasa-total-'+ff+'-'+str(nmol)+'.png', dpi=300, bbox_inches="tight") 

def autocorr(x):
    "Compute an autocorrelation with numpy"
    x = x - np.mean(x)
    result = np.correlate(x, x, mode='full')
    result = result[result.size//2:]
    return result / result[0]

semilogx(trajectory.time, autocorr(total_sasa))
xlabel('Time [ps]', size=16)
ylabel('SASA autocorrelation', size=16)

plt.savefig(savedir+'/sasa-acf-'+ff+'-'+str(nmol)+'.png', dpi=300, bbox_inches="tight")
