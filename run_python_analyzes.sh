#GAFF_AM1-BCC GAFF_Chrobak
for i in GROMOS54a7 #OPLS_1DC77F SWISS_PARAM
do
	for j in 2 4 6 8 20
	do
		python pca-per-system-algorithm.py --ff ${i} --nmol $j
                #python tica-per-system-algorithm.py --ff ${i} --nmol $j
		#python henze-zirkler-test-system.py --ff ${i} --nmol $j
	done
done 
