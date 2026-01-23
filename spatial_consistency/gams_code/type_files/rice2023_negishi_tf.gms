$ontext
dice2023.gms
July 19, 2023
From simplication of DICE2022-beta.3-17-3.gms
$offtext

$title        July 19, 2023 (dice2023.gms)

set
    t  Time periods (5 years per period)                     /1*101/
    ISER    Weight searching interation index  /1*5 /
    ITER    Nash loop                          /1*5 /
    SIT     Nash loop for region1-15           /1*20/
flag_def_regions
;

PARAMETERS
    ININUT  initial nash utility to for the "log" equation           /-1E4/
    VEPS    provide a small value EPS                                /1E-13/
** Population and technology
        gama     Capital elasticity in production function        /.300    /
        dk       Depreciation rate on capital (per year)          /.100    /

*pop0     Initial world population 2020 (millions)
*popadj   Growth rate to calibrate to 2050 pop projection
*popasym  Asymptotic population (millions)
*q0       Initial world output 2020 (trill 2019 USD)
*A0       Initial level of total factor productivity
*gA0      Initial growth rate for TFP per 5 years
*delA     Decline rate of TFP per 5 years
*k0       Initial K 2020 for beta = 0.6 (trill 2019 USD)

** Emissions parameters and Non-CO2 GHG
        fosslim   Maximum cumulative extraction fossil fuels (GtC)     / 6000   /
        CumEmiss0 Cumulative emissions 2020 (GtC)                      / 633.5379/

*gsigma1   Initial growth of sigma (per year)
*delgsig   Decline rate of gsigma per period
*asymgsig   Asympototic gsigma
*e0        Industrial emissions 2020 (GtCO2 per year)
*miu0      Emissions control rate historical 2020

* Climate damage parameters

        a2        Coeff for quadratic damage                          / 0.00284 /
        a3        Coeff for higest power term damage                  / 0 /
        n3        Higest power for damage function                    / 3     /

** Abatement cost
        expcost2  Exponent of control cost function                   / 2.6  /
        pback2050 Cost of backstop 2019$ per tCO2 2050                / 515.  /
        gback     Initial cost decline backstop cost per year         / -.012 /
        delgback  Decline factor of gback per period                  /.95 /
        cprice0   Carbon price 2020 2019$ per tCO2                    / 6    /
        gcprice   Growth rate of base carbon price per year           /.01   /
** Limits on emissions controls
        limmiu2070
        limmiu2120
        delmiumax
** Preferences and timing

        Q       Utility derivative scaling factor                   /1E4 /
        Q1                                                          /1E5 /
        Q2                                                          /1E3 /
        betaclim                                                    / 0.6  /
        elasmu    Elasticity of marginal utility of consumption     / 0.9  /
        rhof      Riskfree real rate per year                       / .001 /
        rhok      Rate of risky social time preference per year     / .035 /
        prstp
** For redefinitions, not numerical
        sig0      Carbon intensity 2020 (kgCO2 per output 2020 USD 2019 no policy)
** Scaling so that MU(C(1)) = 1 and objective function = PV consumption
        tstep       Years per Period                               / 5  /
        scale1      Multiplicative scaling coefficient             /0.009889 /
        scale2      Additive scaling coefficient                   /-7776.944399/ ;
** Other calibration parameters
        prstp = rhof+rhoK*betaclim;
* Program control variables
sets     tfirst(t), tsecond(t), tlast(t);


flag_table_inputs


PARAMETERS
        L(t,n)           Level of population and labor
        LB(T,N)          Nation welfare weight
        aL(t,n)          Level of total factor productivity
        sigma(t,n)       CO2-emissions output ratio
        sigmatot(t,n)    GHG-output ratio
        RR(t)          Average utility social discount rate
        gA(t,n)          Growth rate of productivity from
        gL(t,n)          Growth rate of labor and population
        gcost1         Growth of cost factor
        gsig(t,n)        Change in sigma (rate of decarbonization)
        eland(t)       Emissions from deforestation (GtCO2 per year)
        cost1tot(T,n)    Abatement cost adjusted for backstop and sigma
        pbacktime(t,n)   Backstop price 2019$ per ton CO2
        optlrsav       Optimal long-run savings rate used for transversality
        scc(t,n)         Social cost of carbon
        cpricebase(t,n)  Carbon price in base case
        ppm(t,n)         Atmospheric concentrations parts per million
        atfrac2020(t)  Atmospheric share since 2020
        atfrac1765(t)  Atmospheric fraction of emissions since 1765
        abaterat(t,n)    Abatement cost per net output
        miuup(t,n)       Upper bound on miu
        gbacktime(t)   Decline rate of backstop price
;
** Dynamic parameter values
        L("1",n) = ECO("pop0",n);
        loop(t, L(t+1,n)=L(t,n)*(ECO("popasym",n)/L(t,n))**ECO("popadj",n) ;);
        gA(t,n)=ECO("gA0",n)*exp(-ECO("dela",n)*5*((t.val-1)));
        aL("1",n) = ECO("A0",n);
        loop(t, aL(t+1,n)=aL(t,n)/((1-gA(t,n))););
        RR(t) = 1/((1+prstp)**(tstep*(t.val-1)));
        LB(T,N) = 1;
        optlrsav = (dk + .004)/(dk + .004*elasmu + prstp)*gama;
        cpricebase(t,n)= cprice0*(1+gcprice)**(5*(t.val-1));

        gbacktime(t)=gback*delgback**((t.val-1));
        pbacktime(t,n)= pback2050*exp(-5*(.01)*(t.val-7)) ;
        pbacktime(t,n)$(t.val > 7) =  pback2050*exp(-5*(.001)*(t.val-7)) ;
        sigma("1",n)=ECO("sig0",n);
        gsig(t,n)=min(ECO("gsigma1",n)*ECO("delgsig",n) **((t.val-1)),ECO("asymgsig",n));
        loop(t, sigma(t+1,n)=sigma(t,n)*exp(5*gsig(t,n)););
** Emissions limits
        limmiu2070 = 1;
        limmiu2120 = 1.1;
        delmiumax = 0.12;
        miuup('1',n)= .05;
        miuup('2',n)= .10;
        miuup(t,n)$(t.val > 2) = ( delmiumax*(t.val-1));
        miuup(t,n)$(t.val > 8) = 0.85+.05*(t.val-8);
        miuup(t,n)$(t.val > 11) = limmiu2070;
        miuup(t,n)$(t.val > 20) = limmiu2120;
** Include file for non-CO2 GHGs
* Include: Include/Nonco2-b-3-17.gms
* nonco2 Parameters
Parameters
        CO2E_GHGabateB(t)         Abateable non-CO2 GHG emissions base
        CO2E_GHGabateact(t)       Abateable non-CO2 GHG emissions base (actual)
        F_Misc(t)                 Non-abateable forcings (GHG and other)
        emissrat(t,n)               Ratio of CO2e to industrial emissions
        FORC_CO2(t)               CO2 Forcings
        pbacktime_real(t,n)         Backstop tech cost
;
** Parameters for non-industrial emission
** Assumes abateable share of non-CO2 GHG is 65%
Parameters
        F_Misc2020     Non-abatable forcings 2020                       /  -0.054    /
        F_Misc2100     Non-abatable forcings 2100                        / .265/
        F_GHGabate2020 Forcings of abatable nonCO2 GHG                   / 0.518 /
        F_GHGabate2100 Forcings of abatable nonCO2 GHG                   / 0.957 /


        eland0         Carbon emissions from land 2015 (GtCO2 per year)  / 5.9    /
        deland         Decline rate of land emissions (per period)       / .1     /

        ECO2eGHGB2020  Emis of abatable nonCO2 GHG GtCO2e  2020             /  9.96/
        ECO2eGHGB2100  Emis of abatable nonCO2 GHG GtCO2e  2100             /  15.5 /
        emissrat2020   Ratio of CO2e to industrial CO2 2020                 / 1.40 /
        emissrat2100   Ratio of CO2e to industrial CO2 2020                 / 1.21 /
        Fcoef1         Coefficient of nonco2 abateable emissions            /0.00955/
        Fcoef2         Coefficient of nonco2 abateable emissions            /.861/
        ;
** Parameters emissions and non-CO2
        eland(t) = eland0*(1-deland)**(t.val-1); eland(t) = eland0*(1-deland)**(t.val-1);
        CO2E_GHGabateB(t)=ECO2eGHGB2020+((ECO2eGHGB2100-ECO2eGHGB2020)/16)*(t.val-1)$(t.val le 16)+((ECO2eGHGB2100-ECO2eGHGB2020))$(t.val ge 17);
        F_Misc(t)=F_Misc2020 +((F_Misc2100-F_Misc2020)/16)*(t.val-1)$(t.val le 16)+((F_Misc2100-F_Misc2020))$(t.val ge 17);
        emissrat(t,n) = emissrat2020 +((emissrat2100-emissrat2020)/16)*(t.val-1)$(t.val le 16)+((emissrat2100-emissrat2020))$(t.val ge 17);
        sigmatot(t,n) = sigma(t,n)*emissrat(t,n);
        cost1tot(t,n) = pbacktime(T,n)*sigmatot(T,n)/expcost2/1000;
VARIABLES
        ECO2(t)         Total CO2 emissions (GtCO2 per year)
        ECO2E(t)        Total CO2e emissions including abateable nonCO2 GHG (GtCO2 per year)
        EIND(t,n)         Industrial CO2 emissions (GtCO2 per yr)
        F_GHGabate      Forcings abateable nonCO2 GHG
;
Equations
        ECO2eq(t)         CO2 Emissions equation
        ECO2Eeq(t)        CO2E Emissions equation
        EINDeq(t,n)        Industrial CO2 equation
        MIU_GLOBALeq(t)     Global emission control rate equation
        F_GHGabateEQ(t)
;

* Program control definitions
        tfirst(t) = yes$(t.val eq 1);
        tsecond(t) = yes$(t.val eq 2);
        tlast(t)  = yes$(t.val eq card(t));

VARIABLES
        MIU(t,n)          Emission control rate GHGs
        MIU_GLOBAL(t)      Global emission control rate GHGs
        C(t,n)            Consumption (trillions 2019 US dollars per year)
        K(t,n)            Capital stock (trillions 2019 US dollars)
        CPC(t,n)          Per capita consumption (thousands 2019 USD per year)
        I(t,n)            Investment (trillions 2019 USD per year)
        S(t,n)            Gross savings rate as fraction of gross world product
        RI(t,n)           Real interest rate (per annum)
        Y(t,n)            Gross world product net of abatement and damages (trillions 2019 USD per year)
        YGROSS(t,n)       Gross world product GROSS of abatement and damages (trillions 2019 USD per year)
        YNET(t,n)         Output net of damages equation (trillions 2019 USD per year)
        DAMAGES(t,n)      Damages (trillions 2019 USD per year)
        DAMFRAC(t,n)      Damages as fraction of gross output
        ABATECOSTFRAC(T,n) Cost of emissions reductions fraction
        ABATECOST(t,n)    Cost of emissions reductions  (trillions 2019 USD per year)
        MCABATE(t,n)      Marginal cost of abatement (2019$ per ton CO2)
        CCATOT(t)       Total carbon emissions (GtC)
        PERIODU(t,n)      One period utility function
        CPRICE(t,n)       Carbon price (2019$ per ton of CO2)
        CEMUTOTPER(t,n)   Period utility
        UTILITY          Social welfare function
        UTILITY1         Social welfare function
        UTILITY2         Social welfare function
;
NONNEGATIVE VARIABLES  MIU, TATM, MAT, MU, ML, Y, YNET, YGROSS, C, K, I;
EQUATIONS
*Emissions and Damages
        CCATOTEQ(t)      Cumulative total carbon emissions
        DAMFRACEQ(t,n)     Equation for damage fraction
        DAMEQ(t,n)         Damage equation
        abatefraceq(T,n)   Equation for abatement cost fraction
        ABATEEQ(t,n)       Cost of emissions reductions (abatement cost) equation
        MCABATEEQ(t,n)     Equation for MC abatement
        CARBPRICEEQ(t,n)   Carbon price equation from abatement
*Economic variables
        YGROSSEQ(t,n)      Output gross equation
        YNETEQ(t,n)        Output net of damages equation
        YY(t,n)            Output net equation
        SS(t,n)            Saving equation
        CC(t,n)            Consumption equation
        CPCE(t,n)          Per capita consumption definition
        KK(t,n)            Capital balance equation
* Utility
        PERIODUEQ(t,n)     Instantaneous utility function equation
        CEMUTOTPEREQ(t,n)  Period utility
**  Objective functions (to be scaled properly)
        OBJ              Objective function
        OBJJ             Objective function
        OBJJJ            Objective function;

** Include file for DFAIR model and climate equations
* Include: Include/FAIR-beta-3-17c.gms
** Equals old FAIR with recalibrated parameters for revised F2xco2 and Millar model.
** Deletes nonnegative reservoirs. See explanation below


PARAMETERS
         yr0     Calendar year that corresponds to model year zero         /2020/
        emshare0 Carbon emissions share into Reservoir 0   /0.2173/
        emshare1 Carbon emissions share into Reservoir 1    /0.224/
        emshare2 Carbon emissions share into Reservoir 2    /0.2824/
        emshare3 Carbon emissions share into Reservoir 3    /0.2763/
        tau0    Decay time constant for R0  (year)                            /1000000/
        tau1    Decay time constant for R1  (year)                            /394.4/
        tau2    Decay time constant for R2  (year)       /36.53/
        tau3    Decay time constant for R3  (year) /4.304/

        teq1    Thermal equilibration parameter for box 1 (m^2 per KW)         /0.324/
        teq2    Thermal equilibration parameter for box 2 (m^2 per KW)        /0.44/
        d1      Thermal response timescale for deep ocean (year)               /236/
        d2      Thermal response timescale for upper ocean (year)              /4.07/

        irf0    Pre-industrial IRF100 (year)                                        /32.4/
        irC      Increase in IRF100 with cumulative carbon uptake (years per GtC)    /0.019/
        irT      Increase in IRF100 with warming (years per degree K)                /4.165/
        fco22x   Forcings of equilibrium CO2 doubling (Wm-2)                        /3.93/

** INITIAL CONDITIONS TO BE CALIBRATED TO HISTORY
** CALIBRATION
       mat0   Initial concentration in atmosphere in 2020 (GtC)       /886.5128014/

       res00  Initial concentration in Reservoir 0 in 2020 (GtC)      /150.093 /
       res10  Initial concentration in Reservior 1 in 2020 (GtC)      /102.698 /
       res20  Initial concentration in Reservoir 2 in 2020 (GtC)      /39.534  /
       res30  Initial concentration in Reservoir 3 in 2020 (GtC)      / 6.1865 /



       mateq      Equilibrium concentration atmosphere  (GtC)            /588   /
       tbox10    Initial temperature box 1 change in 2020 (C from 1765)  /0.1477  /
       tbox20    Initial temperature box 2 change in 2020 (C from 1765)  /1.099454/
       tatm0     Initial atmospheric temperature change in 2020          /1.24715 /
       b1        tAtm is equal to b1 x ccaTot used if Tshorcut is 1     /0.001968548/
       Tshortcut is 1 a shrotcut is defined to defined the temperature is 0 otherwise, thz DFAIR model is used  / 0  /

;
Tshortcut=0;

VARIABLES
*Note: Stock variables correspond to levels at the END of the period
        FORC(t)        Increase in radiative forcing (watts per m2 from 1765)
        TATM(t)        Increase temperature of atmosphere (degrees C from 1765)
        TBOX1(t)       Increase temperature of box 1 (degrees C from 1765)
        TBOX2(t)       Increase temperature of box 2 (degrees C from 1765)
        RES0(t)        Carbon concentration in Reservoir 0 (GtC from 1765)
        RES1(t)        Carbon concentration in Reservoir 1 (GtC from 1765)
        RES2(t)        Carbon concentration in Reservoir 2 (GtC from 1765)
        RES3(t)        Carbon concentration in Reservoir 3 (GtC from 1765)
        MAT(t)         Carbon concentration increase in atmosphere (GtC from 1765)
        CACC(t)        Accumulated carbon in ocean and other sinks (GtC)
        IRFt(t)        IRF100 at time t
        alpha(t)       Carbon decay time scaling factor
        SumAlpha      Placeholder variable for objective function;

**** IMPORTANT PROGRAMMING NOTE. Earlier implementations has reservoirs as non-negative.
**** However, these are not physical but mathematical solutions.
**** So, they need to be unconstrained so that can have negative emissions.
NONNEGATIVE VARIABLES   TATM, MAT,  IRFt, alpha

EQUATIONS
        FORCE(t)        Radiative forcing equation
        RES0LOM(t)      Reservoir 0 law of motion
        RES1LOM(t)      Reservoir 1 law of motion
        RES2LOM(t)      Reservoir 2 law of motion
        RES3LOM(t)      Reservoir 3 law of motion
        MMAT(t)         Atmospheric concentration equation
        Cacceq(t)       Accumulated carbon in sinks equation
        TATMEQ(t)       Temperature-climate equation for atmosphere
        TBOX1EQ(t)      Temperature box 1 law of motion
        TBOX2EQ(t)      Temperature box 2 law of motion
        IRFeqLHS(t)     Left-hand side of IRF100 equation
        IRFeqRHS(t)     Right-hand side of IRF100 equation
;
** Equations of the model
    res0lom(t+1)..   RES0(t+1) =E=  (emshare0*tau0*alpha(t+1)*(Eco2(t+1)/3.667))*(1-exp(-tstep/(tau0*alpha(t+1))))+Res0(t)*exp(-tstep/(tau0*alpha(t+1)));
    res1lom(t+1)..   RES1(t+1) =E=  (emshare1*tau1*alpha(t+1)*(Eco2(t+1)/3.667))*(1-exp(-tstep/(tau1*alpha(t+1))))+Res1(t)*exp(-tstep/(tau1*alpha(t+1)));
    res2lom(t+1)..   RES2(t+1) =E=  (emshare2*tau2*alpha(t+1)*(Eco2(t+1)/3.667))*(1-exp(-tstep/(tau2*alpha(t+1))))+Res2(t)*exp(-tstep/(tau2*alpha(t+1)));
    res3lom(t+1)..   RES3(t+1) =E=  (emshare3*tau3*alpha(t+1)*(Eco2(t+1)/3.667))*(1-exp(-tstep/(tau3*alpha(t+1))))+Res3(t)*exp(-tstep/(tau3*alpha(t+1)));
    mmat(t+1)..      MAT(t+1)  =E=   mateq+Res0(t+1)+Res1(t+1)+Res2(t+1)+Res3(t+1);
    cacceq(t)..      Cacc(t)   =E=  (CCATOT(t)-(MAT(t)-mateq));
    force(t)..       FORC(t)    =E=  fco22x*((log((MAT(t)/mateq))/log(2))) + F_Misc(t)+F_GHGabate(t);
    tbox1eq(t+1)..   Tbox1(t+1) =E=  Tbox1(t)*exp(-tstep/d1)+teq1*Forc(t+1)*(1-exp(-tstep/d1));
    tbox2eq(t+1)..   Tbox2(t+1) =E=  Tbox2(t)*exp(-tstep/d2)+teq2*Forc(t+1)*(1-exp(-tstep/d2));
    tatmeq(t+1)..    TATM(t+1)  =E=   (1-Tshortcut)*(Tbox1(t+1)+Tbox2(t+1)) + Tshortcut * b1 * CCATOT(t+1);
    irfeqlhs(t)..    IRFt(t)   =E=  ((alpha(t)*emshare0*tau0*(1-exp(-100/(alpha(t)*tau0))))+(alpha(t)*emshare1*tau1*(1-exp(-100/(alpha(t)*tau1))))+(alpha(t)*emshare2*tau2*(1-exp(-100/(alpha(t)*tau2))))+(alpha(t)*emshare3*tau3*(1-exp(-100/(alpha(t)*tau3)))));
    irfeqrhs(t)..    IRFt(t)   =E=  96.6 / (1+ exp(- 0.03 *(irf0+irC*Cacc(t)+irT*TATM(t)- 24.98)));

**  Upper and lower bounds for stability
MAT.LO(t)       = 10;
TATM.UP(t)      = 20;
TATM.lo(t)      = .5;
alpha.up(t) = 100;
alpha.lo(t) = 0.1;

* Initial conditions
MAT.FX(tfirst)    = mat0;
TATM.FX(tfirst)   = tatm0;
Res0.fx(tfirst) = Res00;
Res1.fx(tfirst) = Res10;
Res2.fx(tfirst) = Res20;
Res3.fx(tfirst) = Res30;
Tbox1.fx(tfirst) = Tbox10;
Tbox2.fx(tfirst) = Tbox20;

** Solution options
option iterlim = 99900;
option reslim = 99999;
option solprint = on;
option limrow = 0;
option limcol = 0;


** Equations of the model
**Emissions and Damages
 eindeq(t,n)..          EIND(t,n)         =E= sigma(t,n) * YGROSS(t,n) * (1 - MIU(t,n));
 MIU_GLOBALeq(t)..    MIU_GLOBAL(t)         =E= 1 - sum(n,EIND(t,n)) / (sum(n,sigma(t,n) * YGROSS(t,n)) + 1);
 eco2eq(t)..          ECO2(t)         =E= sum(n,EIND(t,n)) + eland(t) * (1 - MIU_GLOBAL(t));
 eco2Eeq(t)..         ECO2E(t)        =E= ECO2(t) + CO2E_GHGabateB(t) * (1-MIU_GLOBAL(t)) ;
 F_GHGabateEQ(t+1)..  F_GHGabate(t+1) =E= Fcoef2*F_GHGabate(t)+ Fcoef1*CO2E_GHGabateB(t)*(1-MIU_GLOBAL(t) );
 ccatoteq(t+1)..      CCATOT(t+1)     =E= CCATOT(t) +  ECO2(T)*(5/3.666) ;
 damfraceq(t,n) ..      DAMFRAC(t,n)      =E= (1 - 1 / (1 + ECO("a2",n)*TATM(t)**2 +  ECO("a3",n)*TATM(t)**ECO("n3",n)));
 dameq(t,n)..           DAMAGES(t,n)      =E= YGROSS(t,n) * DAMFRAC(t,n);
 abatefraceq(T,n)..     ABATECOSTFRAC(T,n) =E= COST1TOT(T,n)  * (MIU(T,n)**EXPCOST2);
 abateeq(T,n)..         ABATECOST(T,n)   =E= YGROSS(T,n) * ABATECOSTFRAC(T,n);
 mcabateeq(t,n)..       MCABATE(t,n)     =E=  pbacktime(t,n)* MIU(t,n)**(expcost2-1) ;
 carbpriceeq(t,n)..     CPRICE(t,n)      =E=  pbacktime(t,n) * (MIU(t,n))**(expcost2-1);
**Economic variables
 ygrosseq(t,n)..        YGROSS(t,n)      =E= aL(t,n) * (L(t,n)/1000)**(1-gama) * K(t,n)**gama;
 yneteq(t,n)..          YNET(t,n)        =E= YGROSS(t,n) * (1-damfrac(t,n));
 yy(t,n)..              Y(t,n)           =E= YNET(t,n) * (1-ABATECOSTFRAC(t,n));
 ss(t,n)..              I(t,n)           =E= S(t,n) * Y(t,n);
 cc(t,n)..              C(t,n)           =E= Y(t,n) - I(t,n);
 cpce(t,n)..            CPC(t,n)         =E= 1000 * C(t,n) / L(t,n);
 kk(t+1,n)..            K(t+1,n)         =E= (1-dk)**tstep * K(t,n) + tstep * I(t,n);
**Utility and objective function
 cemutotpereq(t,n)..    CEMUTOTPER(t,n)  =E= PERIODU(t,n) * L(t,n) * RR(t);
 periodueq(t,n)..       PERIODU(t,n)     =E= ((C(T,n)*1000/L(T,n))**(1-elasmu)-1)/(1-elasmu)-1;
 OBJ..                   UTILITY  =E= Q* SUM((t,n), LB(T,N)*CEMUTOTPER(t,n));
 OBJJ..                  UTILITY1 =E= Q1*SUM((t,n), LB(T,N)*CEMUTOTPER(t,n));
 OBJJJ..                 UTILITY2 =E= Q2*SUM((t,n), LB(T,N)*CEMUTOTPER(t,n));



*///////////////////////////////////////////////////////////////////////////////
*******************************Upper and lower bounds***************************
*///////////////////////////////////////////////////////////////////////////////

* Ccntrol rate limits
miu.up(t,n) = miuup(t,n);
*S.fx(t,n)         = optlrsav;
*S.UP(t,n)         = 1;
K.LO(t,n)         = 1;
C.LO(t,n)         = 0.05;
CPC.LO(t,n)       = .001;

*Control for terminal savings rate
*set lag10(t) ;
*lag10(t) =  yes$(t.val gt card(t)-10);
*S.FX(lag10(t)) = optlrsav;
*ri.fx(tlast) = .014;

* Initial conditions
ccatot.fx(tfirst) = CumEmiss0;
k.FX(tfirst,n)      = ECO("k0",n);
F_GHGabate.fx(tfirst) = F_GHGabate2020;

** Solution options
option iterlim = 99900;
option reslim = 99999;
option solprint = on;
option limrow = 0;
option limcol = 0;

model  RICE /all/;


********************************************************************************
*****///////////     Equal Weight Solve  --  Negishi weight     ///////////*****
********************************************************************************
PARAMETERS

    CINTEN(t,n)
    KP(t,n)
    EIE(ITER,SIT,N,T)
    MIE(ITER,SIT,N,T)

** Negishi parameters
    FNKM(t,n)             first round national KK.M
    FWKM(T)               first round world KK.M
    NKM(ISER,T,N)         National marginal Capital
    WKM(ISER,T)           World average marginal K
    NWEI(ISER,T,N)        National adjusted weight
    SNWEI(ISER,T)         Total National adjusted weight
    WWEI(ISER,T)          World adjusted weight
    GAP(ISER,T,N)         Gap between nation weight and world average
    AVG(N)                Average 20 weight
    SM(ISER,T)

    NGDP(ISER,T,N)        Negishi adjusting GDP
    NSIG(ISER,T,N)        Negishi adjusting SIGMA
    NKP(ISER,T,N)         Negishi adjusting KK.M
    NE(ISER,T,N)          Negishi adjusting Emission
    NES(ISER,T)           Negishi adjusting World Emission
    NTE(ISER,T)           Negishi adjusting World Temperature
;


file resLARGE2022 /rice2023_negishi.csv/; resLARGE2022.nd = 10 ; resLARGE2022.nw = 0 ; resLARGE2022.pw=20000; resLARGE2022.pc=5;
put resLARGE2022;
put /"Results of rice2023_negishi.csv with final results: July 19, 2023";




flag_solve