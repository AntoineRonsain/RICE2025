miu.lo(t,n) = 1E-6;
MIU.UP(t,n)   = miuup(t,n);
MIU.FX("1",n) = ECO("MIU0",N);



******////////////////////////////////////////////////////////////////////******
*************************** Calculate Nash Equilibrium *************************
******/////////////////////////////formula/////////////////////////////////******

PARAMETERS
    marg_S(ITER, t, n)      "Utilité marginale de la contrainte d'épargne (Shadow Price)"
    marg_DAM(ITER, t, n)    "Coût marginal des dommages (Shadow Price de l'équation DAMEQ)"
    marg_K(ITER, t, n)      "Valeur marginale du stock de capital"
;




flag_loop_nash_solver





