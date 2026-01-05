* THE BEGINNING OF THE SEARCHING PROGRM.

*******/////////////////////////////////////////initial weight
*$ontext

miu.lo(t,n) = 0;
miu.up(t,n) = miuup(t,n);


SOLVE RICE MAXIMIZING UTILITY2 USING NLP;


FNKM(t,n)   = KK.M(t,n);
FNKM("1",N) = FNKM("2",N);

FWKM(T)     = SUM(N,1/FNKM(t,n))/ flag_nb_regions ;
LB(T,N)     = (1/FNKM(t,n))/FWKM(T);


LOOP(ISER,
**   solve the first round optimal (equal weight)

     MIU.LO(t,n) = 0;
     MIU.UP(t,n) = 1;

     SOLVE RICE MAXIMIZING UTILITY2 USING NLP;
*DISPLAY KK.M,FNKM,FWKM,LB;

     NGDP(ISER,T,N) = Y.L(t,n);
     NKP(ISER,T,N)  = KK.M(t,n);

*save marginal capital
     NKM(ISER,T,N)    = KK.M(t,n);
     NKM(ISER,"1",N)  = KK.M("2",N);

*world average marginal capital
     WKM(ISER,T)      = SUM(N,NKM(ISER,T,N))/ flag_nb_regions ;
*calculate the gap between nation and the world
     GAP(ISER,T,N)    = NKM(ISER,T,N)-WKM(ISER,T);
*adjust the weight
     NWEI("1",T,N)   = LB(T,N);
     NWEI(ISER+1,T,N) = NWEI(ISER,T,N)*(1-0.10*GAP(ISER,T,N)/WKM(ISER,T));
     SNWEI(ISER,T)  = SUM(N,NWEI(ISER,T,N));
     LB(T,N)            = flag_nb_regions * NWEI(ISER,T,N)/SNWEI(ISER,T);
     LB("1",N)         = LB("2",N);
     SM(ISER,T)        = SUM(N,LB(T,N));
);
*$offtext
*//////////////////////////////////////////////////////////////////////////////
**Optimal Case

miu.lo(t,n) = 0;
miu.up(t,n) = miuup(t,n);


SOLVE RICE MAXIMIZING UTILITY2 USING NLP;

*///////////////////////////////////////////////////////////////////////////////
