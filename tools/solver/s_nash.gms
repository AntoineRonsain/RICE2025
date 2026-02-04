miu.lo(t,n) = 1E-6;
MIU.UP(t,n)   = miuup(t,n);
MIU.FX("1",n) = ECO("MIU0",N);



******////////////////////////////////////////////////////////////////////******
*************************** Calculate Nash Equilibrium *************************
******/////////////////////////////formula/////////////////////////////////******

PARAMETERS
    marg_S(ITER, t, n)      "Shadow Price of saving"
    marg_DAM(ITER, t, n)    "Shadow Price of damage fraction"
    marg_K(ITER, t, n)      "Shadow Price of capital"
    marg_ABA(ITER, t, n)    "Shadow Price of abatement fraction"
;




flag_loop_nash_solver





