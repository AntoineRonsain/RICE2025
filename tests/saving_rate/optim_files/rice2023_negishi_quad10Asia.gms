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
N /USA, RUS, JAP, CAN, OAB, EU, CHN, IND, BRZ, SAF, OEU, REF, MAF, LAM, ASIA0, ASIA1, ASIA2, ASIA3, ASIA4, ASIA5, ASIA6, ASIA7, ASIA8, ASIA9/

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
        Q1                                                          /1E3 /
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


SETS ECOT
/pop0, popasym, popadj, a0, gA0, dela, sig0, gsigma1, delgsig, asymgsig, q0, K0, miu0, a2, a3, n3/

TABLE ECO(ECOT,N)
          USA         RUS         JAP          CAN         OAB         EU          CHN         IND         BRZ           SAF         OEU          REF         MAF           LAM          ASIA0        ASIA1        ASIA2        ASIA3        ASIA4        ASIA5        ASIA6        ASIA7        ASIA8        ASIA9
pop0      331.432     143.787     126.496      37.6032     88.2753     510.945     1424.55     1383.2      213.863       58.7212     101.697      98.16       1793.67       420.939      117.743      117.743      117.743      117.743      117.743      117.743      117.743      117.743      117.743      117.743
popasym   489.012     143.787     126.496      56.7038     98.3873     512.515     1441.18     1678.57     232.724       77.5934     111.315      118.112     3657.55       526.507      147.559      147.559      147.559      147.559      147.559      147.559      147.559      147.559      147.559      147.559
popadj    0.0948651   0.145       0.145        0.095758    0.0836356   0.845329    0.864755    0.311317    0.423562      0.203888    0.328072     0.266731    0.152873      0.272184     0.262046     0.262046     0.262046     0.262046     0.262046     0.262046     0.262046     0.262046     0.262046     0.262046
a0        13.3999     8.1927      9.2269       11.4356     8.54114     9.93393     5.68029     3.40244     5.36764       4.83754     6.90522      6.68749     3.694         5.58724      4.41482      4.41482      4.41482      4.41482      4.41482      4.41482      4.41482      4.41482      4.41482      4.41482
gA0       0.0297618   0.0573968   0.0471163    0.0400154   0.0500945   0.0475897   0.109478    0.170205    0.0832742     0.0821519   0.0731599    0.0662272   0.0953594     0.0774209    0.104503     0.104503     0.104503     0.104503     0.104503     0.104503     0.104503     0.104503     0.104503     0.104503
dela      0.00276194  0.00544409  0.00435665   0.00412869  0.00449444  0.0047987   0.0103848   0.0137549   0.00697187    0.00640958  0.00686484   0.00578246  0.00681257    0.00644025   0.00849175   0.00849175   0.00849175   0.00849175   0.00849175   0.00849175   0.00849175   0.00849175   0.00849175   0.00849175
sig0      0.280922    0.479159    0.254381     0.260517    0.259556    0.165847    0.527972    0.281054    0.170522      0.657903    0.249117     0.358589    0.290092      0.215192     0.238792     0.238792     0.238792     0.238792     0.238792     0.238792     0.238792     0.238792     0.238792     0.238792
gsigma1   -0.0240468  -0.0191403  -0.00655657  -0.0302755  -0.032377   -0.0278566  -0.0174615  -0.0133732  -0.000656878  -0.0112051  -0.00958924  -0.041946   -0.000927845  -0.00881594  -0.00911635  -0.00911635  -0.00911635  -0.00911635  -0.00911635  -0.00911635  -0.00911635  -0.00911635  -0.00911635  -0.00911635
delgsig   0.941915    0.990365    0.993352     0.959565    0.935345    0.971375    0.957398    0.997355    0.998825      0.996289    0.990639     0.935723    0.999648      0.994804     0.994484     0.994484     0.994484     0.994484     0.994484     0.994484     0.994484     0.994484     0.994484     0.994484
asymgsig  -0.005      -0.005      -0.005       -0.005      -0.005      -0.005      -0.005      -0.005      -0.005        -0.005      -0.005       -0.005      -0.005        -0.005       -0.005       -0.005       -0.005       -0.005       -0.005       -0.005       -0.005       -0.005       -0.005       -0.005
q0        21.6153     4.29061     5.82879      1.96194     3.10118     23.0363     23.3937     9.81744     3.81842       0.847688    2.15806      1.51893     13.0466       7.38158      1.38835      1.38835      1.38835      1.38835      1.38835      1.38835      1.38835      1.38835      1.38835      1.38835
K0        43.6249     7.43774     16.9125      4.35539     6.51907     53.9706     65.485      18.7344     9.48238       1.79211     3.76203      1.48676     23.9355       14.5124      2.99892      2.99892      2.99892      2.99892      2.99892      2.99892      2.99892      2.99892      2.99892      2.99892
miu0      0.0486596   0.0157365   0.0139357    0.0115777   0.0120244   0.0330613   0.0309619   0.0222417   0.0150853     0.00639427  0.00800447   0.0101568   0.0539258     0.0172459    0.0285936    0.0285936    0.0285936    0.0285936    0.0285936    0.0285936    0.0285936    0.0285936    0.0285936    0.0285936
a2        0.003467    0.003467    0.003467     0.003467    0.003467    0.003467    0.003467    0.003467    0.003467      0.003467    0.003467     0.003467    0.003467      0.003467     0.003467     0.003467     0.003467     0.003467     0.003467     0.003467     0.003467     0.003467     0.003467     0.003467
a3        0           0           0            0           0           0           0           0           0             0           0            0           0             0            0            0            0            0            0            0            0            0            0            0
n3        1           1           1            1           1           1           1           1           1             1           1            1           1             1            1            1            1            1            1            1            1            1            1            1;



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
 damfraceq(t,n) ..      DAMFRAC(t,n)      =E= ECO("a2",n)*TATM(t)**2;
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

RES0LOM.SCALE(t) = 1.0E+6;
RES0.SCALE(t) = 100;
MAT.SCALE(t)  = 100;


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

RICE.scaleopt = 1;

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


file resLARGE2022 /rice2023_negishi_quad.csv/; resLARGE2022.nd = 10 ; resLARGE2022.nw = 0 ; resLARGE2022.pw=20000; resLARGE2022.pc=5;
put resLARGE2022;
put /"Results of rice2023_negishi_quad.csv with final results: July 19, 2023";





* THE BEGINNING OF THE SEARCHING PROGRM.

*******/////////////////////////////////////////initial weight
*$ontext

miu.lo(t,n) = 1E-6;
miu.up(t,n) = miuup(t,n);


SOLVE RICE MAXIMIZING UTILITY2 USING NLP;


FNKM(t,n)   = KK.M(t,n);
FNKM("1",N) = FNKM("2",N);

FWKM(T)     = SUM(N,1/FNKM(t,n))/  24  ;
LB(T,N)     = (1/FNKM(t,n))/FWKM(T);


LOOP(ISER,
**   solve the first round optimal (equal weight)

     miu.lo(t,n) = 1E-6;
     MIU.UP(t,n) = 1;

     SOLVE RICE MAXIMIZING UTILITY2 USING NLP;
*DISPLAY KK.M,FNKM,FWKM,LB;

     NGDP(ISER,T,N) = Y.L(t,n);
     NKP(ISER,T,N)  = KK.M(t,n);

*save marginal capital
     NKM(ISER,T,N)    = KK.M(t,n);
     NKM(ISER,"1",N)  = KK.M("2",N);

*world average marginal capital
     WKM(ISER,T)      = SUM(N,NKM(ISER,T,N))/  24  ;
*calculate the gap between nation and the world
     GAP(ISER,T,N)    = NKM(ISER,T,N)-WKM(ISER,T);
*adjust the weight
     NWEI("1",T,N)   = LB(T,N);
     NWEI(ISER+1,T,N) = NWEI(ISER,T,N)*(1-0.10*GAP(ISER,T,N)/WKM(ISER,T));
     SNWEI(ISER,T)  = SUM(N,NWEI(ISER,T,N));
     LB(T,N)            =  24  * NWEI(ISER,T,N)/SNWEI(ISER,T);
     LB("1",N)         = LB("2",N);
     SM(ISER,T)        = SUM(N,LB(T,N));
);
*$offtext
*//////////////////////////////////////////////////////////////////////////////
**Optimal Case

miu.lo(t,n) = 1E-6;
miu.up(t,n) = miuup(t,n);


SOLVE RICE MAXIMIZING UTILITY2 USING NLP;

*///////////////////////////////////////////////////////////////////////////////
put /"SCENARIO: Low Damage"
put / "REGION: USA"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"USA"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"USA"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"USA"));
put / "Weight";
Loop(T, put LB(T,"USA"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"USA"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"USA"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"USA"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"USA"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"USA"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"USA"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"USA"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"USA"));
scc("1","USA") = scc("2","USA") * .85;
Loop(T, put scc(t,"USA"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"USA"));
put / "Carbon price";
Loop(T, put cprice.l(T,"USA"));
put / "Saving rate";
Loop(T, put S.l(T,"USA"));
put / "REGION: RUS"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"RUS"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"RUS"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"RUS"));
put / "Weight";
Loop(T, put LB(T,"RUS"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"RUS"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"RUS"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"RUS"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"RUS"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"RUS"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"RUS"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"RUS"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"RUS"));
scc("1","RUS") = scc("2","RUS") * .85;
Loop(T, put scc(t,"RUS"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"RUS"));
put / "Carbon price";
Loop(T, put cprice.l(T,"RUS"));
put / "Saving rate";
Loop(T, put S.l(T,"RUS"));
put / "REGION: JAP"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"JAP"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"JAP"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"JAP"));
put / "Weight";
Loop(T, put LB(T,"JAP"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"JAP"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"JAP"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"JAP"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"JAP"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"JAP"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"JAP"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"JAP"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"JAP"));
scc("1","JAP") = scc("2","JAP") * .85;
Loop(T, put scc(t,"JAP"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"JAP"));
put / "Carbon price";
Loop(T, put cprice.l(T,"JAP"));
put / "Saving rate";
Loop(T, put S.l(T,"JAP"));
put / "REGION: CAN"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"CAN"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"CAN"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"CAN"));
put / "Weight";
Loop(T, put LB(T,"CAN"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"CAN"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"CAN"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"CAN"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"CAN"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"CAN"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"CAN"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"CAN"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"CAN"));
scc("1","CAN") = scc("2","CAN") * .85;
Loop(T, put scc(t,"CAN"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"CAN"));
put / "Carbon price";
Loop(T, put cprice.l(T,"CAN"));
put / "Saving rate";
Loop(T, put S.l(T,"CAN"));
put / "REGION: OAB"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"OAB"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"OAB"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"OAB"));
put / "Weight";
Loop(T, put LB(T,"OAB"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"OAB"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"OAB"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"OAB"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"OAB"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"OAB"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"OAB"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"OAB"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"OAB"));
scc("1","OAB") = scc("2","OAB") * .85;
Loop(T, put scc(t,"OAB"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"OAB"));
put / "Carbon price";
Loop(T, put cprice.l(T,"OAB"));
put / "Saving rate";
Loop(T, put S.l(T,"OAB"));
put / "REGION: EU"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"EU"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"EU"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"EU"));
put / "Weight";
Loop(T, put LB(T,"EU"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"EU"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"EU"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"EU"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"EU"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"EU"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"EU"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"EU"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"EU"));
scc("1","EU") = scc("2","EU") * .85;
Loop(T, put scc(t,"EU"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"EU"));
put / "Carbon price";
Loop(T, put cprice.l(T,"EU"));
put / "Saving rate";
Loop(T, put S.l(T,"EU"));
put / "REGION: CHN"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"CHN"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"CHN"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"CHN"));
put / "Weight";
Loop(T, put LB(T,"CHN"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"CHN"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"CHN"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"CHN"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"CHN"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"CHN"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"CHN"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"CHN"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"CHN"));
scc("1","CHN") = scc("2","CHN") * .85;
Loop(T, put scc(t,"CHN"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"CHN"));
put / "Carbon price";
Loop(T, put cprice.l(T,"CHN"));
put / "Saving rate";
Loop(T, put S.l(T,"CHN"));
put / "REGION: IND"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"IND"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"IND"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"IND"));
put / "Weight";
Loop(T, put LB(T,"IND"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"IND"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"IND"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"IND"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"IND"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"IND"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"IND"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"IND"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"IND"));
scc("1","IND") = scc("2","IND") * .85;
Loop(T, put scc(t,"IND"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"IND"));
put / "Carbon price";
Loop(T, put cprice.l(T,"IND"));
put / "Saving rate";
Loop(T, put S.l(T,"IND"));
put / "REGION: BRZ"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"BRZ"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"BRZ"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"BRZ"));
put / "Weight";
Loop(T, put LB(T,"BRZ"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"BRZ"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"BRZ"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"BRZ"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"BRZ"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"BRZ"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"BRZ"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"BRZ"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"BRZ"));
scc("1","BRZ") = scc("2","BRZ") * .85;
Loop(T, put scc(t,"BRZ"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"BRZ"));
put / "Carbon price";
Loop(T, put cprice.l(T,"BRZ"));
put / "Saving rate";
Loop(T, put S.l(T,"BRZ"));
put / "REGION: SAF"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"SAF"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"SAF"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"SAF"));
put / "Weight";
Loop(T, put LB(T,"SAF"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"SAF"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"SAF"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"SAF"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"SAF"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"SAF"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"SAF"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"SAF"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"SAF"));
scc("1","SAF") = scc("2","SAF") * .85;
Loop(T, put scc(t,"SAF"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"SAF"));
put / "Carbon price";
Loop(T, put cprice.l(T,"SAF"));
put / "Saving rate";
Loop(T, put S.l(T,"SAF"));
put / "REGION: OEU"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"OEU"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"OEU"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"OEU"));
put / "Weight";
Loop(T, put LB(T,"OEU"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"OEU"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"OEU"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"OEU"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"OEU"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"OEU"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"OEU"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"OEU"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"OEU"));
scc("1","OEU") = scc("2","OEU") * .85;
Loop(T, put scc(t,"OEU"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"OEU"));
put / "Carbon price";
Loop(T, put cprice.l(T,"OEU"));
put / "Saving rate";
Loop(T, put S.l(T,"OEU"));
put / "REGION: REF"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"REF"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"REF"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"REF"));
put / "Weight";
Loop(T, put LB(T,"REF"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"REF"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"REF"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"REF"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"REF"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"REF"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"REF"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"REF"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"REF"));
scc("1","REF") = scc("2","REF") * .85;
Loop(T, put scc(t,"REF"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"REF"));
put / "Carbon price";
Loop(T, put cprice.l(T,"REF"));
put / "Saving rate";
Loop(T, put S.l(T,"REF"));
put / "REGION: MAF"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"MAF"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"MAF"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"MAF"));
put / "Weight";
Loop(T, put LB(T,"MAF"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"MAF"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"MAF"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"MAF"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"MAF"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"MAF"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"MAF"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"MAF"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"MAF"));
scc("1","MAF") = scc("2","MAF") * .85;
Loop(T, put scc(t,"MAF"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"MAF"));
put / "Carbon price";
Loop(T, put cprice.l(T,"MAF"));
put / "Saving rate";
Loop(T, put S.l(T,"MAF"));
put / "REGION: LAM"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"LAM"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"LAM"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"LAM"));
put / "Weight";
Loop(T, put LB(T,"LAM"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"LAM"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"LAM"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"LAM"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"LAM"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"LAM"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"LAM"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"LAM"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"LAM"));
scc("1","LAM") = scc("2","LAM") * .85;
Loop(T, put scc(t,"LAM"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"LAM"));
put / "Carbon price";
Loop(T, put cprice.l(T,"LAM"));
put / "Saving rate";
Loop(T, put S.l(T,"LAM"));
put / "REGION: ASIA0"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA0"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA0"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA0"));
put / "Weight";
Loop(T, put LB(T,"ASIA0"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"ASIA0"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"ASIA0"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"ASIA0"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"ASIA0"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"ASIA0"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"ASIA0"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"ASIA0"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"ASIA0"));
scc("1","ASIA0") = scc("2","ASIA0") * .85;
Loop(T, put scc(t,"ASIA0"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA0"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA0"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA0"));
put / "REGION: ASIA1"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA1"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA1"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA1"));
put / "Weight";
Loop(T, put LB(T,"ASIA1"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"ASIA1"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"ASIA1"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"ASIA1"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"ASIA1"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"ASIA1"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"ASIA1"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"ASIA1"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"ASIA1"));
scc("1","ASIA1") = scc("2","ASIA1") * .85;
Loop(T, put scc(t,"ASIA1"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA1"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA1"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA1"));
put / "REGION: ASIA2"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA2"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA2"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA2"));
put / "Weight";
Loop(T, put LB(T,"ASIA2"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"ASIA2"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"ASIA2"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"ASIA2"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"ASIA2"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"ASIA2"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"ASIA2"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"ASIA2"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"ASIA2"));
scc("1","ASIA2") = scc("2","ASIA2") * .85;
Loop(T, put scc(t,"ASIA2"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA2"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA2"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA2"));
put / "REGION: ASIA3"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA3"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA3"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA3"));
put / "Weight";
Loop(T, put LB(T,"ASIA3"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"ASIA3"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"ASIA3"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"ASIA3"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"ASIA3"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"ASIA3"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"ASIA3"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"ASIA3"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"ASIA3"));
scc("1","ASIA3") = scc("2","ASIA3") * .85;
Loop(T, put scc(t,"ASIA3"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA3"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA3"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA3"));
put / "REGION: ASIA4"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA4"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA4"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA4"));
put / "Weight";
Loop(T, put LB(T,"ASIA4"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"ASIA4"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"ASIA4"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"ASIA4"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"ASIA4"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"ASIA4"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"ASIA4"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"ASIA4"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"ASIA4"));
scc("1","ASIA4") = scc("2","ASIA4") * .85;
Loop(T, put scc(t,"ASIA4"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA4"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA4"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA4"));
put / "REGION: ASIA5"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA5"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA5"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA5"));
put / "Weight";
Loop(T, put LB(T,"ASIA5"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"ASIA5"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"ASIA5"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"ASIA5"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"ASIA5"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"ASIA5"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"ASIA5"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"ASIA5"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"ASIA5"));
scc("1","ASIA5") = scc("2","ASIA5") * .85;
Loop(T, put scc(t,"ASIA5"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA5"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA5"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA5"));
put / "REGION: ASIA6"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA6"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA6"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA6"));
put / "Weight";
Loop(T, put LB(T,"ASIA6"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"ASIA6"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"ASIA6"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"ASIA6"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"ASIA6"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"ASIA6"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"ASIA6"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"ASIA6"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"ASIA6"));
scc("1","ASIA6") = scc("2","ASIA6") * .85;
Loop(T, put scc(t,"ASIA6"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA6"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA6"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA6"));
put / "REGION: ASIA7"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA7"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA7"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA7"));
put / "Weight";
Loop(T, put LB(T,"ASIA7"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"ASIA7"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"ASIA7"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"ASIA7"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"ASIA7"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"ASIA7"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"ASIA7"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"ASIA7"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"ASIA7"));
scc("1","ASIA7") = scc("2","ASIA7") * .85;
Loop(T, put scc(t,"ASIA7"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA7"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA7"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA7"));
put / "REGION: ASIA8"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA8"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA8"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA8"));
put / "Weight";
Loop(T, put LB(T,"ASIA8"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"ASIA8"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"ASIA8"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"ASIA8"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"ASIA8"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"ASIA8"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"ASIA8"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"ASIA8"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"ASIA8"));
scc("1","ASIA8") = scc("2","ASIA8") * .85;
Loop(T, put scc(t,"ASIA8"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA8"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA8"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA8"));
put / "REGION: ASIA9"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA9"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA9"));
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA9"));
put / "Weight";
Loop(T, put LB(T,"ASIA9"));
put / "Output, gross-net, 2019$";
Loop(T, put ynet.l(t,"ASIA9"));
put / "Output, gross-gross, 2019$";
Loop(T, put YGROSS.L(t,"ASIA9"));
put / "Capital stock, 2019$" ;
Loop (T, put k.l(t,"ASIA9"));
put / "Climate damages, fraction of output" ;
Loop (T, put DAMFRAC.l(T,"ASIA9"));
put / "Abatement, 2019$" ;
Loop (T, put abatecost.l(t,"ASIA9"));
put / "Abatement/0utput" ;
Loop (T, put ABATECOSTFRAC.l(t,"ASIA9"));
put / "Sigma,(CO2/output, no controls, all CO2)";
Loop(T, put sigma(t,"ASIA9"));
put / "Social cost of carbon $/tCO2";
scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"ASIA9"));
scc("1","ASIA9") = scc("2","ASIA9") * .85;
Loop(T, put scc(t,"ASIA9"));
put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA9"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA9"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA9"));
put /"REGION: World"
put / "Total CO2 Emissions, GTCO2/year" ;
Loop (T, put Eco2.l(T));
put / "Actual other abatable GHG forcings w/m2" ;
Loop (T, put F_GHGabate.L(t) );
put / "Atmospheric temperature (deg c above preind)";
Loop(T, put TATM.l(T));
put / "MIU global";
Loop(T, put MIU_GLOBAL.l(T));
