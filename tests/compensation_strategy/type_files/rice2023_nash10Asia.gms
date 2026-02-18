$ontext
dice2023.gms
July 19, 2023
From simplication of DICE2022-beta.3-17-3.gms
$offtext

$title        July 19, 2023 (dice2023.gms)

set
    t  Time periods (5 years per period)                     /1*101/
    ISER    Weight searching interation index  /1*5 /
    ITER    Nash loop                          /1*1 /
    SIT     Nash loop for region1-15           /1*25/

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

        quad      Quadratic damage                        / 1 /

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
        Q2                                                          /1E8 /
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
a3        4.7935e-06  4.7935e-06  4.7935e-06   4.7935e-06  4.7935e-06  4.7935e-06  4.7935e-06  4.7935e-06  4.7935e-06    4.7935e-06  4.7935e-06   4.7935e-06  4.7935e-06    4.7935e-06   4.7935e-06   4.7935e-06   4.7935e-06   4.7935e-06   4.7935e-06   4.7935e-06   4.7935e-06   4.7935e-06   4.7935e-06   4.7935e-06
n3        6.21735     6.21735     6.21735      6.21735     6.21735     6.21735     6.21735     6.21735     6.21735       6.21735     6.21735      6.21735     6.21735       6.21735      6.21735      6.21735      6.21735      6.21735      6.21735      6.21735      6.21735      6.21735      6.21735      6.21735;



PARAMETERS

        EIE(ITER,SIT,t,n)
        MIE(ITER,SIT,t,n)
        SE(ITER,SIT,t,n)
        marginal_miu(T,n)

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
NUT_USA         Nash Utility of USA
NUT_RUS         Nash Utility of RUS
NUT_JAP         Nash Utility of JAP
NUT_CAN         Nash Utility of CAN
NUT_OAB         Nash Utility of OAB
NUT_EU         Nash Utility of EU
NUT_CHN         Nash Utility of CHN
NUT_IND         Nash Utility of IND
NUT_BRZ         Nash Utility of BRZ
NUT_SAF         Nash Utility of SAF
NUT_OEU         Nash Utility of OEU
NUT_REF         Nash Utility of REF
NUT_MAF         Nash Utility of MAF
NUT_LAM         Nash Utility of LAM
NUT_ASIA0         Nash Utility of ASIA0
NUT_ASIA1         Nash Utility of ASIA1
NUT_ASIA2         Nash Utility of ASIA2
NUT_ASIA3         Nash Utility of ASIA3
NUT_ASIA4         Nash Utility of ASIA4
NUT_ASIA5         Nash Utility of ASIA5
NUT_ASIA6         Nash Utility of ASIA6
NUT_ASIA7         Nash Utility of ASIA7
NUT_ASIA8         Nash Utility of ASIA8
NUT_ASIA9         Nash Utility of ASIA9

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
**provide an initial value for proxy nash utility in Linda Scenario
NUT_USA = ININUT;
NUT_RUS = ININUT;
NUT_JAP = ININUT;
NUT_CAN = ININUT;
NUT_OAB = ININUT;
NUT_EU = ININUT;
NUT_CHN = ININUT;
NUT_IND = ININUT;
NUT_BRZ = ININUT;
NUT_SAF = ININUT;
NUT_OEU = ININUT;
NUT_REF = ININUT;
NUT_MAF = ININUT;
NUT_LAM = ININUT;
NUT_ASIA0 = ININUT;
NUT_ASIA1 = ININUT;
NUT_ASIA2 = ININUT;
NUT_ASIA3 = ININUT;
NUT_ASIA4 = ININUT;
NUT_ASIA5 = ININUT;
NUT_ASIA6 = ININUT;
NUT_ASIA7 = ININUT;
NUT_ASIA8 = ININUT;
NUT_ASIA9 = ININUT;


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
UT_USA Social welfare function of USA
UT1_USA Social welfare function of USA
UT2_USA Social welfare function of USA
UT_RUS Social welfare function of RUS
UT1_RUS Social welfare function of RUS
UT2_RUS Social welfare function of RUS
UT_JAP Social welfare function of JAP
UT1_JAP Social welfare function of JAP
UT2_JAP Social welfare function of JAP
UT_CAN Social welfare function of CAN
UT1_CAN Social welfare function of CAN
UT2_CAN Social welfare function of CAN
UT_OAB Social welfare function of OAB
UT1_OAB Social welfare function of OAB
UT2_OAB Social welfare function of OAB
UT_EU Social welfare function of EU
UT1_EU Social welfare function of EU
UT2_EU Social welfare function of EU
UT_CHN Social welfare function of CHN
UT1_CHN Social welfare function of CHN
UT2_CHN Social welfare function of CHN
UT_IND Social welfare function of IND
UT1_IND Social welfare function of IND
UT2_IND Social welfare function of IND
UT_BRZ Social welfare function of BRZ
UT1_BRZ Social welfare function of BRZ
UT2_BRZ Social welfare function of BRZ
UT_SAF Social welfare function of SAF
UT1_SAF Social welfare function of SAF
UT2_SAF Social welfare function of SAF
UT_OEU Social welfare function of OEU
UT1_OEU Social welfare function of OEU
UT2_OEU Social welfare function of OEU
UT_REF Social welfare function of REF
UT1_REF Social welfare function of REF
UT2_REF Social welfare function of REF
UT_MAF Social welfare function of MAF
UT1_MAF Social welfare function of MAF
UT2_MAF Social welfare function of MAF
UT_LAM Social welfare function of LAM
UT1_LAM Social welfare function of LAM
UT2_LAM Social welfare function of LAM
UT_ASIA0 Social welfare function of ASIA0
UT1_ASIA0 Social welfare function of ASIA0
UT2_ASIA0 Social welfare function of ASIA0
UT_ASIA1 Social welfare function of ASIA1
UT1_ASIA1 Social welfare function of ASIA1
UT2_ASIA1 Social welfare function of ASIA1
UT_ASIA2 Social welfare function of ASIA2
UT1_ASIA2 Social welfare function of ASIA2
UT2_ASIA2 Social welfare function of ASIA2
UT_ASIA3 Social welfare function of ASIA3
UT1_ASIA3 Social welfare function of ASIA3
UT2_ASIA3 Social welfare function of ASIA3
UT_ASIA4 Social welfare function of ASIA4
UT1_ASIA4 Social welfare function of ASIA4
UT2_ASIA4 Social welfare function of ASIA4
UT_ASIA5 Social welfare function of ASIA5
UT1_ASIA5 Social welfare function of ASIA5
UT2_ASIA5 Social welfare function of ASIA5
UT_ASIA6 Social welfare function of ASIA6
UT1_ASIA6 Social welfare function of ASIA6
UT2_ASIA6 Social welfare function of ASIA6
UT_ASIA7 Social welfare function of ASIA7
UT1_ASIA7 Social welfare function of ASIA7
UT2_ASIA7 Social welfare function of ASIA7
UT_ASIA8 Social welfare function of ASIA8
UT1_ASIA8 Social welfare function of ASIA8
UT2_ASIA8 Social welfare function of ASIA8
UT_ASIA9 Social welfare function of ASIA9
UT1_ASIA9 Social welfare function of ASIA9
UT2_ASIA9 Social welfare function of ASIA9

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
        OBJ              Objective function;

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
 eindeq(t,n)..        EIND(t,n)         =E= sigma(t,n) * YGROSS(t,n) * (1 - MIU(t,n));
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
 OBJ..                  UTILITY =E= Q2*SUM((t,n), CEMUTOTPER(t,n));

EQUATIONS
OBJ_USA
OBJ1_USA
OBJ2_USA
OBJ_RUS
OBJ1_RUS
OBJ2_RUS
OBJ_JAP
OBJ1_JAP
OBJ2_JAP
OBJ_CAN
OBJ1_CAN
OBJ2_CAN
OBJ_OAB
OBJ1_OAB
OBJ2_OAB
OBJ_EU
OBJ1_EU
OBJ2_EU
OBJ_CHN
OBJ1_CHN
OBJ2_CHN
OBJ_IND
OBJ1_IND
OBJ2_IND
OBJ_BRZ
OBJ1_BRZ
OBJ2_BRZ
OBJ_SAF
OBJ1_SAF
OBJ2_SAF
OBJ_OEU
OBJ1_OEU
OBJ2_OEU
OBJ_REF
OBJ1_REF
OBJ2_REF
OBJ_MAF
OBJ1_MAF
OBJ2_MAF
OBJ_LAM
OBJ1_LAM
OBJ2_LAM
OBJ_ASIA0
OBJ1_ASIA0
OBJ2_ASIA0
OBJ_ASIA1
OBJ1_ASIA1
OBJ2_ASIA1
OBJ_ASIA2
OBJ1_ASIA2
OBJ2_ASIA2
OBJ_ASIA3
OBJ1_ASIA3
OBJ2_ASIA3
OBJ_ASIA4
OBJ1_ASIA4
OBJ2_ASIA4
OBJ_ASIA5
OBJ1_ASIA5
OBJ2_ASIA5
OBJ_ASIA6
OBJ1_ASIA6
OBJ2_ASIA6
OBJ_ASIA7
OBJ1_ASIA7
OBJ2_ASIA7
OBJ_ASIA8
OBJ1_ASIA8
OBJ2_ASIA8
OBJ_ASIA9
OBJ1_ASIA9
OBJ2_ASIA9
;
OBJ_USA..    UT_USA =E= Q* SUM(t, CEMUTOTPER(t,"USA"));
OBJ1_USA..    UT1_USA =E= Q1* SUM(t, CEMUTOTPER(t,"USA"));
OBJ2_USA..    UT2_USA =E= Q2* SUM(t, CEMUTOTPER(t,"USA"));
OBJ_RUS..    UT_RUS =E= Q* SUM(t, CEMUTOTPER(t,"RUS"));
OBJ1_RUS..    UT1_RUS =E= Q1* SUM(t, CEMUTOTPER(t,"RUS"));
OBJ2_RUS..    UT2_RUS =E= Q2* SUM(t, CEMUTOTPER(t,"RUS"));
OBJ_JAP..    UT_JAP =E= Q* SUM(t, CEMUTOTPER(t,"JAP"));
OBJ1_JAP..    UT1_JAP =E= Q1* SUM(t, CEMUTOTPER(t,"JAP"));
OBJ2_JAP..    UT2_JAP =E= Q2* SUM(t, CEMUTOTPER(t,"JAP"));
OBJ_CAN..    UT_CAN =E= Q* SUM(t, CEMUTOTPER(t,"CAN"));
OBJ1_CAN..    UT1_CAN =E= Q1* SUM(t, CEMUTOTPER(t,"CAN"));
OBJ2_CAN..    UT2_CAN =E= Q2* SUM(t, CEMUTOTPER(t,"CAN"));
OBJ_OAB..    UT_OAB =E= Q* SUM(t, CEMUTOTPER(t,"OAB"));
OBJ1_OAB..    UT1_OAB =E= Q1* SUM(t, CEMUTOTPER(t,"OAB"));
OBJ2_OAB..    UT2_OAB =E= Q2* SUM(t, CEMUTOTPER(t,"OAB"));
OBJ_EU..    UT_EU =E= Q* SUM(t, CEMUTOTPER(t,"EU"));
OBJ1_EU..    UT1_EU =E= Q1* SUM(t, CEMUTOTPER(t,"EU"));
OBJ2_EU..    UT2_EU =E= Q2* SUM(t, CEMUTOTPER(t,"EU"));
OBJ_CHN..    UT_CHN =E= Q* SUM(t, CEMUTOTPER(t,"CHN"));
OBJ1_CHN..    UT1_CHN =E= Q1* SUM(t, CEMUTOTPER(t,"CHN"));
OBJ2_CHN..    UT2_CHN =E= Q2* SUM(t, CEMUTOTPER(t,"CHN"));
OBJ_IND..    UT_IND =E= Q* SUM(t, CEMUTOTPER(t,"IND"));
OBJ1_IND..    UT1_IND =E= Q1* SUM(t, CEMUTOTPER(t,"IND"));
OBJ2_IND..    UT2_IND =E= Q2* SUM(t, CEMUTOTPER(t,"IND"));
OBJ_BRZ..    UT_BRZ =E= Q* SUM(t, CEMUTOTPER(t,"BRZ"));
OBJ1_BRZ..    UT1_BRZ =E= Q1* SUM(t, CEMUTOTPER(t,"BRZ"));
OBJ2_BRZ..    UT2_BRZ =E= Q2* SUM(t, CEMUTOTPER(t,"BRZ"));
OBJ_SAF..    UT_SAF =E= Q* SUM(t, CEMUTOTPER(t,"SAF"));
OBJ1_SAF..    UT1_SAF =E= Q1* SUM(t, CEMUTOTPER(t,"SAF"));
OBJ2_SAF..    UT2_SAF =E= Q2* SUM(t, CEMUTOTPER(t,"SAF"));
OBJ_OEU..    UT_OEU =E= Q* SUM(t, CEMUTOTPER(t,"OEU"));
OBJ1_OEU..    UT1_OEU =E= Q1* SUM(t, CEMUTOTPER(t,"OEU"));
OBJ2_OEU..    UT2_OEU =E= Q2* SUM(t, CEMUTOTPER(t,"OEU"));
OBJ_REF..    UT_REF =E= Q* SUM(t, CEMUTOTPER(t,"REF"));
OBJ1_REF..    UT1_REF =E= Q1* SUM(t, CEMUTOTPER(t,"REF"));
OBJ2_REF..    UT2_REF =E= Q2* SUM(t, CEMUTOTPER(t,"REF"));
OBJ_MAF..    UT_MAF =E= Q* SUM(t, CEMUTOTPER(t,"MAF"));
OBJ1_MAF..    UT1_MAF =E= Q1* SUM(t, CEMUTOTPER(t,"MAF"));
OBJ2_MAF..    UT2_MAF =E= Q2* SUM(t, CEMUTOTPER(t,"MAF"));
OBJ_LAM..    UT_LAM =E= Q* SUM(t, CEMUTOTPER(t,"LAM"));
OBJ1_LAM..    UT1_LAM =E= Q1* SUM(t, CEMUTOTPER(t,"LAM"));
OBJ2_LAM..    UT2_LAM =E= Q2* SUM(t, CEMUTOTPER(t,"LAM"));
OBJ_ASIA0..    UT_ASIA0 =E= Q* SUM(t, CEMUTOTPER(t,"ASIA0"));
OBJ1_ASIA0..    UT1_ASIA0 =E= Q1* SUM(t, CEMUTOTPER(t,"ASIA0"));
OBJ2_ASIA0..    UT2_ASIA0 =E= Q2* SUM(t, CEMUTOTPER(t,"ASIA0"));
OBJ_ASIA1..    UT_ASIA1 =E= Q* SUM(t, CEMUTOTPER(t,"ASIA1"));
OBJ1_ASIA1..    UT1_ASIA1 =E= Q1* SUM(t, CEMUTOTPER(t,"ASIA1"));
OBJ2_ASIA1..    UT2_ASIA1 =E= Q2* SUM(t, CEMUTOTPER(t,"ASIA1"));
OBJ_ASIA2..    UT_ASIA2 =E= Q* SUM(t, CEMUTOTPER(t,"ASIA2"));
OBJ1_ASIA2..    UT1_ASIA2 =E= Q1* SUM(t, CEMUTOTPER(t,"ASIA2"));
OBJ2_ASIA2..    UT2_ASIA2 =E= Q2* SUM(t, CEMUTOTPER(t,"ASIA2"));
OBJ_ASIA3..    UT_ASIA3 =E= Q* SUM(t, CEMUTOTPER(t,"ASIA3"));
OBJ1_ASIA3..    UT1_ASIA3 =E= Q1* SUM(t, CEMUTOTPER(t,"ASIA3"));
OBJ2_ASIA3..    UT2_ASIA3 =E= Q2* SUM(t, CEMUTOTPER(t,"ASIA3"));
OBJ_ASIA4..    UT_ASIA4 =E= Q* SUM(t, CEMUTOTPER(t,"ASIA4"));
OBJ1_ASIA4..    UT1_ASIA4 =E= Q1* SUM(t, CEMUTOTPER(t,"ASIA4"));
OBJ2_ASIA4..    UT2_ASIA4 =E= Q2* SUM(t, CEMUTOTPER(t,"ASIA4"));
OBJ_ASIA5..    UT_ASIA5 =E= Q* SUM(t, CEMUTOTPER(t,"ASIA5"));
OBJ1_ASIA5..    UT1_ASIA5 =E= Q1* SUM(t, CEMUTOTPER(t,"ASIA5"));
OBJ2_ASIA5..    UT2_ASIA5 =E= Q2* SUM(t, CEMUTOTPER(t,"ASIA5"));
OBJ_ASIA6..    UT_ASIA6 =E= Q* SUM(t, CEMUTOTPER(t,"ASIA6"));
OBJ1_ASIA6..    UT1_ASIA6 =E= Q1* SUM(t, CEMUTOTPER(t,"ASIA6"));
OBJ2_ASIA6..    UT2_ASIA6 =E= Q2* SUM(t, CEMUTOTPER(t,"ASIA6"));
OBJ_ASIA7..    UT_ASIA7 =E= Q* SUM(t, CEMUTOTPER(t,"ASIA7"));
OBJ1_ASIA7..    UT1_ASIA7 =E= Q1* SUM(t, CEMUTOTPER(t,"ASIA7"));
OBJ2_ASIA7..    UT2_ASIA7 =E= Q2* SUM(t, CEMUTOTPER(t,"ASIA7"));
OBJ_ASIA8..    UT_ASIA8 =E= Q* SUM(t, CEMUTOTPER(t,"ASIA8"));
OBJ1_ASIA8..    UT1_ASIA8 =E= Q1* SUM(t, CEMUTOTPER(t,"ASIA8"));
OBJ2_ASIA8..    UT2_ASIA8 =E= Q2* SUM(t, CEMUTOTPER(t,"ASIA8"));
OBJ_ASIA9..    UT_ASIA9 =E= Q* SUM(t, CEMUTOTPER(t,"ASIA9"));
OBJ1_ASIA9..    UT1_ASIA9 =E= Q1* SUM(t, CEMUTOTPER(t,"ASIA9"));
OBJ2_ASIA9..    UT2_ASIA9 =E= Q2* SUM(t, CEMUTOTPER(t,"ASIA9"));



*///////////////////////////////////////////////////////////////////////////////
*******************************Upper and lower bounds***************************
*///////////////////////////////////////////////////////////////////////////////

* Ccntrol rate limits
miu.up(t,n) = miuup(t,n);
S.fx(t,n)         = optlrsav;
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
*****///////////                 Nash Equilibrium               ///////////*****
********************************************************************************

**release the bounds
*M.LO(T)    = 0.5*M0;
*M.UP(T)    = 15000;



file resLARGE2022 /rice2023_nash.csv/; resLARGE2022.nd = 10 ; resLARGE2022.nw = 0 ; resLARGE2022.pw=20000; resLARGE2022.pc=5;
put resLARGE2022;
put /"Results of rice2023_nash.csv with final results: July 19, 2023";


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




SOLVE  RICE MAXIMIZING UT2_USA USING NLP;
marginal_miu(T,"USA") = MIU.m(T,"USA");
marg_S(ITER, t,"USA") = S.m(T,"USA");
marg_DAM(ITER, t,"USA") = DAMFRACEQ.m(T,"USA");
marg_ABA(ITER, t,"USA") = abatefraceq.m(T,"USA");
marg_K(ITER, t,"USA") = KK.m(T,"USA");

SOLVE  RICE MAXIMIZING UT2_RUS USING NLP;
marginal_miu(T,"RUS") = MIU.m(T,"RUS");
marg_S(ITER, t,"RUS") = S.m(T,"RUS");
marg_DAM(ITER, t,"RUS") = DAMFRACEQ.m(T,"RUS");
marg_ABA(ITER, t,"RUS") = abatefraceq.m(T,"RUS");
marg_K(ITER, t,"RUS") = KK.m(T,"RUS");

SOLVE  RICE MAXIMIZING UT2_JAP USING NLP;
marginal_miu(T,"JAP") = MIU.m(T,"JAP");
marg_S(ITER, t,"JAP") = S.m(T,"JAP");
marg_DAM(ITER, t,"JAP") = DAMFRACEQ.m(T,"JAP");
marg_ABA(ITER, t,"JAP") = abatefraceq.m(T,"JAP");
marg_K(ITER, t,"JAP") = KK.m(T,"JAP");

SOLVE  RICE MAXIMIZING UT2_CAN USING NLP;
marginal_miu(T,"CAN") = MIU.m(T,"CAN");
marg_S(ITER, t,"CAN") = S.m(T,"CAN");
marg_DAM(ITER, t,"CAN") = DAMFRACEQ.m(T,"CAN");
marg_ABA(ITER, t,"CAN") = abatefraceq.m(T,"CAN");
marg_K(ITER, t,"CAN") = KK.m(T,"CAN");

SOLVE  RICE MAXIMIZING UT2_OAB USING NLP;
marginal_miu(T,"OAB") = MIU.m(T,"OAB");
marg_S(ITER, t,"OAB") = S.m(T,"OAB");
marg_DAM(ITER, t,"OAB") = DAMFRACEQ.m(T,"OAB");
marg_ABA(ITER, t,"OAB") = abatefraceq.m(T,"OAB");
marg_K(ITER, t,"OAB") = KK.m(T,"OAB");


SOLVE  RICE MAXIMIZING UT2_EU USING NLP;
marginal_miu(T,"EU") = MIU.m(T,"EU");
marg_S(ITER, t,"EU") = S.m(T,"EU");
marg_DAM(ITER, t,"EU") = DAMFRACEQ.m(T,"EU");
marg_ABA(ITER, t,"EU") = abatefraceq.m(T,"EU");
marg_K(ITER, t,"EU") = KK.m(T,"EU");


SOLVE  RICE MAXIMIZING UT2_CHN USING NLP;
marginal_miu(T,"CHN") = MIU.m(T,"CHN");
marg_S(ITER, t,"CHN") = S.m(T,"CHN");
marg_DAM(ITER, t,"CHN") = DAMFRACEQ.m(T,"CHN");
marg_ABA(ITER, t,"CHN") = abatefraceq.m(T,"CHN");
marg_K(ITER, t,"CHN") = KK.m(T,"CHN");


SOLVE  RICE MAXIMIZING UT2_IND USING NLP;
marginal_miu(T,"IND") = MIU.m(T,"IND");
marg_S(ITER, t,"IND") = S.m(T,"IND");
marg_DAM(ITER, t,"IND") = DAMFRACEQ.m(T,"IND");
marg_ABA(ITER, t,"IND") = abatefraceq.m(T,"IND");
marg_K(ITER, t,"IND") = KK.m(T,"IND");


SOLVE  RICE MAXIMIZING UT2_BRZ USING NLP;
marginal_miu(T,"BRZ") = MIU.m(T,"BRZ");
marg_S(ITER, t,"BRZ") = S.m(T,"BRZ");
marg_DAM(ITER, t,"BRZ") = DAMFRACEQ.m(T,"BRZ");
marg_ABA(ITER, t,"BRZ") = abatefraceq.m(T,"BRZ");
marg_K(ITER, t,"BRZ") = KK.m(T,"BRZ");


SOLVE  RICE MAXIMIZING UT2_SAF USING NLP;
marginal_miu(T,"SAF") = MIU.m(T,"SAF");
marg_S(ITER, t,"SAF") = S.m(T,"SAF");
marg_DAM(ITER, t,"SAF") = DAMFRACEQ.m(T,"SAF");
marg_ABA(ITER, t,"SAF") = abatefraceq.m(T,"SAF");
marg_K(ITER, t,"SAF") = KK.m(T,"SAF");


SOLVE  RICE MAXIMIZING UT2_OEU USING NLP;
marginal_miu(T,"OEU") = MIU.m(T,"OEU");
marg_S(ITER, t,"OEU") = S.m(T,"OEU");
marg_DAM(ITER, t,"OEU") = DAMFRACEQ.m(T,"OEU");
marg_ABA(ITER, t,"OEU") = abatefraceq.m(T,"OEU");
marg_K(ITER, t,"OEU") = KK.m(T,"OEU");


SOLVE  RICE MAXIMIZING UT2_REF USING NLP;
marginal_miu(T,"REF") = MIU.m(T,"REF");
marg_S(ITER, t,"REF") = S.m(T,"REF");
marg_DAM(ITER, t,"REF") = DAMFRACEQ.m(T,"REF");
marg_ABA(ITER, t,"REF") = abatefraceq.m(T,"REF");
marg_K(ITER, t,"REF") = KK.m(T,"REF");


SOLVE  RICE MAXIMIZING UT2_MAF USING NLP;
marginal_miu(T,"MAF") = MIU.m(T,"MAF");
marg_S(ITER, t,"MAF") = S.m(T,"MAF");
marg_DAM(ITER, t,"MAF") = DAMFRACEQ.m(T,"MAF");
marg_ABA(ITER, t,"MAF") = abatefraceq.m(T,"MAF");
marg_K(ITER, t,"MAF") = KK.m(T,"MAF");


SOLVE  RICE MAXIMIZING UT2_LAM USING NLP;
marginal_miu(T,"LAM") = MIU.m(T,"LAM");
marg_S(ITER, t,"LAM") = S.m(T,"LAM");
marg_DAM(ITER, t,"LAM") = DAMFRACEQ.m(T,"LAM");
marg_ABA(ITER, t,"LAM") = abatefraceq.m(T,"LAM");
marg_K(ITER, t,"LAM") = KK.m(T,"LAM");


SOLVE  RICE MAXIMIZING UT2_ASIA0 USING NLP;
marginal_miu(T,"ASIA0") = MIU.m(T,"ASIA0");
marg_S(ITER, t,"ASIA0") = S.m(T,"ASIA0");
marg_DAM(ITER, t,"ASIA0") = DAMFRACEQ.m(T,"ASIA0");
marg_ABA(ITER, t,"ASIA0") = abatefraceq.m(T,"ASIA0");
marg_K(ITER, t,"ASIA0") = KK.m(T,"ASIA0");


SOLVE  RICE MAXIMIZING UT2_ASIA1 USING NLP;
marginal_miu(T,"ASIA1") = MIU.m(T,"ASIA1");
marg_S(ITER, t,"ASIA1") = S.m(T,"ASIA1");
marg_DAM(ITER, t,"ASIA1") = DAMFRACEQ.m(T,"ASIA1");
marg_ABA(ITER, t,"ASIA1") = abatefraceq.m(T,"ASIA1");
marg_K(ITER, t,"ASIA1") = KK.m(T,"ASIA1");


SOLVE  RICE MAXIMIZING UT2_ASIA2 USING NLP;
marginal_miu(T,"ASIA2") = MIU.m(T,"ASIA2");
marg_S(ITER, t,"ASIA2") = S.m(T,"ASIA2");
marg_DAM(ITER, t,"ASIA2") = DAMFRACEQ.m(T,"ASIA2");
marg_ABA(ITER, t,"ASIA2") = abatefraceq.m(T,"ASIA2");
marg_K(ITER, t,"ASIA2") = KK.m(T,"ASIA2");


SOLVE  RICE MAXIMIZING UT2_ASIA3 USING NLP;
marginal_miu(T,"ASIA3") = MIU.m(T,"ASIA3");
marg_S(ITER, t,"ASIA3") = S.m(T,"ASIA3");
marg_DAM(ITER, t,"ASIA3") = DAMFRACEQ.m(T,"ASIA3");
marg_ABA(ITER, t,"ASIA3") = abatefraceq.m(T,"ASIA3");
marg_K(ITER, t,"ASIA3") = KK.m(T,"ASIA3");


SOLVE  RICE MAXIMIZING UT2_ASIA4 USING NLP;
marginal_miu(T,"ASIA4") = MIU.m(T,"ASIA4");
marg_S(ITER, t,"ASIA4") = S.m(T,"ASIA4");
marg_DAM(ITER, t,"ASIA4") = DAMFRACEQ.m(T,"ASIA4");
marg_ABA(ITER, t,"ASIA4") = abatefraceq.m(T,"ASIA4");
marg_K(ITER, t,"ASIA4") = KK.m(T,"ASIA4");


SOLVE  RICE MAXIMIZING UT2_ASIA5 USING NLP;
marginal_miu(T,"ASIA5") = MIU.m(T,"ASIA5");
marg_S(ITER, t,"ASIA5") = S.m(T,"ASIA5");
marg_DAM(ITER, t,"ASIA5") = DAMFRACEQ.m(T,"ASIA5");
marg_ABA(ITER, t,"ASIA5") = abatefraceq.m(T,"ASIA5");
marg_K(ITER, t,"ASIA5") = KK.m(T,"ASIA5");


SOLVE  RICE MAXIMIZING UT2_ASIA6 USING NLP;
marginal_miu(T,"ASIA6") = MIU.m(T,"ASIA6");
marg_S(ITER, t,"ASIA6") = S.m(T,"ASIA6");
marg_DAM(ITER, t,"ASIA6") = DAMFRACEQ.m(T,"ASIA6");
marg_ABA(ITER, t,"ASIA6") = abatefraceq.m(T,"ASIA6");
marg_K(ITER, t,"ASIA6") = KK.m(T,"ASIA6");


SOLVE  RICE MAXIMIZING UT2_ASIA7 USING NLP;
marginal_miu(T,"ASIA7") = MIU.m(T,"ASIA7");
marg_S(ITER, t,"ASIA7") = S.m(T,"ASIA7");
marg_DAM(ITER, t,"ASIA7") = DAMFRACEQ.m(T,"ASIA7");
marg_ABA(ITER, t,"ASIA7") = abatefraceq.m(T,"ASIA7");
marg_K(ITER, t,"ASIA7") = KK.m(T,"ASIA7");


SOLVE  RICE MAXIMIZING UT2_ASIA8 USING NLP;
marginal_miu(T,"ASIA8") = MIU.m(T,"ASIA8");
marg_S(ITER, t,"ASIA8") = S.m(T,"ASIA8");
marg_DAM(ITER, t,"ASIA8") = DAMFRACEQ.m(T,"ASIA8");
marg_ABA(ITER, t,"ASIA8") = abatefraceq.m(T,"ASIA8");
marg_K(ITER, t,"ASIA8") = KK.m(T,"ASIA8");


SOLVE  RICE MAXIMIZING UT2_ASIA9 USING NLP;
marginal_miu(T,"ASIA9") = MIU.m(T,"ASIA9");
marg_S(ITER, t,"ASIA9") = S.m(T,"ASIA9");
marg_DAM(ITER, t,"ASIA9") = DAMFRACEQ.m(T,"ASIA9");
marg_ABA(ITER, t,"ASIA9") = abatefraceq.m(T,"ASIA9");
marg_K(ITER, t,"ASIA9") = KK.m(T,"ASIA9");
);









put /"SCENARIO: Medium Damage"
put /"REGION: USA"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"USA"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"USA"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"USA")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"USA"));
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
put / "Regional welfare";
Loop(T, put UT2_USA.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"USA"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "USA"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "USA"));put / "Population (exogenous)" ;
Loop (T, put L(T,"USA"));
put / "Carbon price";
Loop(T, put cprice.l(T,"USA"));
put / "Saving rate";
Loop(T, put S.l(T,"USA"));
put /"REGION: RUS"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"RUS"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"RUS"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"RUS")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"RUS"));
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
put / "Regional welfare";
Loop(T, put UT2_RUS.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"RUS"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "RUS"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "RUS"));put / "Population (exogenous)" ;
Loop (T, put L(T,"RUS"));
put / "Carbon price";
Loop(T, put cprice.l(T,"RUS"));
put / "Saving rate";
Loop(T, put S.l(T,"RUS"));
put /"REGION: JAP"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"JAP"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"JAP"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"JAP")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"JAP"));
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
put / "Regional welfare";
Loop(T, put UT2_JAP.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"JAP"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "JAP"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "JAP"));put / "Population (exogenous)" ;
Loop (T, put L(T,"JAP"));
put / "Carbon price";
Loop(T, put cprice.l(T,"JAP"));
put / "Saving rate";
Loop(T, put S.l(T,"JAP"));
put /"REGION: CAN"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"CAN"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"CAN"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"CAN")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"CAN"));
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
put / "Regional welfare";
Loop(T, put UT2_CAN.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"CAN"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "CAN"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "CAN"));put / "Population (exogenous)" ;
Loop (T, put L(T,"CAN"));
put / "Carbon price";
Loop(T, put cprice.l(T,"CAN"));
put / "Saving rate";
Loop(T, put S.l(T,"CAN"));
put /"REGION: OAB"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"OAB"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"OAB"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"OAB")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"OAB"));
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
put / "Regional welfare";
Loop(T, put UT2_OAB.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"OAB"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "OAB"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "OAB"));put / "Population (exogenous)" ;
Loop (T, put L(T,"OAB"));
put / "Carbon price";
Loop(T, put cprice.l(T,"OAB"));
put / "Saving rate";
Loop(T, put S.l(T,"OAB"));
put /"REGION: EU"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"EU"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"EU"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"EU")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"EU"));
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
put / "Regional welfare";
Loop(T, put UT2_EU.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"EU"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "EU"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "EU"));put / "Population (exogenous)" ;
Loop (T, put L(T,"EU"));
put / "Carbon price";
Loop(T, put cprice.l(T,"EU"));
put / "Saving rate";
Loop(T, put S.l(T,"EU"));
put /"REGION: CHN"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"CHN"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"CHN"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"CHN")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"CHN"));
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
put / "Regional welfare";
Loop(T, put UT2_CHN.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"CHN"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "CHN"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "CHN"));put / "Population (exogenous)" ;
Loop (T, put L(T,"CHN"));
put / "Carbon price";
Loop(T, put cprice.l(T,"CHN"));
put / "Saving rate";
Loop(T, put S.l(T,"CHN"));
put /"REGION: IND"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"IND"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"IND"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"IND")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"IND"));
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
put / "Regional welfare";
Loop(T, put UT2_IND.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"IND"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "IND"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "IND"));put / "Population (exogenous)" ;
Loop (T, put L(T,"IND"));
put / "Carbon price";
Loop(T, put cprice.l(T,"IND"));
put / "Saving rate";
Loop(T, put S.l(T,"IND"));
put /"REGION: BRZ"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"BRZ"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"BRZ"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"BRZ")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"BRZ"));
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
put / "Regional welfare";
Loop(T, put UT2_BRZ.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"BRZ"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "BRZ"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "BRZ"));put / "Population (exogenous)" ;
Loop (T, put L(T,"BRZ"));
put / "Carbon price";
Loop(T, put cprice.l(T,"BRZ"));
put / "Saving rate";
Loop(T, put S.l(T,"BRZ"));
put /"REGION: SAF"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"SAF"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"SAF"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"SAF")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"SAF"));
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
put / "Regional welfare";
Loop(T, put UT2_SAF.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"SAF"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "SAF"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "SAF"));put / "Population (exogenous)" ;
Loop (T, put L(T,"SAF"));
put / "Carbon price";
Loop(T, put cprice.l(T,"SAF"));
put / "Saving rate";
Loop(T, put S.l(T,"SAF"));
put /"REGION: OEU"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"OEU"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"OEU"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"OEU")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"OEU"));
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
put / "Regional welfare";
Loop(T, put UT2_OEU.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"OEU"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "OEU"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "OEU"));put / "Population (exogenous)" ;
Loop (T, put L(T,"OEU"));
put / "Carbon price";
Loop(T, put cprice.l(T,"OEU"));
put / "Saving rate";
Loop(T, put S.l(T,"OEU"));
put /"REGION: REF"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"REF"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"REF"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"REF")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"REF"));
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
put / "Regional welfare";
Loop(T, put UT2_REF.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"REF"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "REF"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "REF"));put / "Population (exogenous)" ;
Loop (T, put L(T,"REF"));
put / "Carbon price";
Loop(T, put cprice.l(T,"REF"));
put / "Saving rate";
Loop(T, put S.l(T,"REF"));
put /"REGION: MAF"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"MAF"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"MAF"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"MAF")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"MAF"));
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
put / "Regional welfare";
Loop(T, put UT2_MAF.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"MAF"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "MAF"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "MAF"));put / "Population (exogenous)" ;
Loop (T, put L(T,"MAF"));
put / "Carbon price";
Loop(T, put cprice.l(T,"MAF"));
put / "Saving rate";
Loop(T, put S.l(T,"MAF"));
put /"REGION: LAM"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"LAM"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"LAM"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"LAM")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"LAM"));
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
put / "Regional welfare";
Loop(T, put UT2_LAM.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"LAM"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "LAM"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "LAM"));put / "Population (exogenous)" ;
Loop (T, put L(T,"LAM"));
put / "Carbon price";
Loop(T, put cprice.l(T,"LAM"));
put / "Saving rate";
Loop(T, put S.l(T,"LAM"));
put /"REGION: ASIA0"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA0"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA0"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA0")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA0"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA0.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA0"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA0"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA0"));put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA0"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA0"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA0"));
put /"REGION: ASIA1"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA1"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA1"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA1")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA1"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA1.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA1"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA1"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA1"));put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA1"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA1"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA1"));
put /"REGION: ASIA2"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA2"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA2"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA2")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA2"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA2.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA2"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA2"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA2"));put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA2"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA2"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA2"));
put /"REGION: ASIA3"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA3"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA3"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA3")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA3"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA3.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA3"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA3"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA3"));put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA3"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA3"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA3"));
put /"REGION: ASIA4"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA4"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA4"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA4")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA4"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA4.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA4"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA4"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA4"));put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA4"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA4"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA4"));
put /"REGION: ASIA5"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA5"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA5"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA5")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA5"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA5.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA5"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA5"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA5"));put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA5"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA5"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA5"));
put /"REGION: ASIA6"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA6"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA6"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA6")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA6"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA6.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA6"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA6"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA6"));put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA6"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA6"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA6"));
put /"REGION: ASIA7"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA7"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA7"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA7")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA7"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA7.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA7"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA7"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA7"));put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA7"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA7"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA7"));
put /"REGION: ASIA8"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA8"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA8"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA8")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA8"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA8.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA8"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA8"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA8"));put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA8"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA8"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA8"));
put /"REGION: ASIA9"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA9"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA9"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA9")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA9"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA9.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA9"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA9"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA9"));put / "Population (exogenous)" ;
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
ECO("a2","USA") = 0.00284;
ECO("a3","USA") = 1.57e-05;
ECO("n3","USA") = 7.315027067;
ECO("a2","RUS") = 0.00284;
ECO("a3","RUS") = 1.57e-05;
ECO("n3","RUS") = 7.315027067;
ECO("a2","JAP") = 0.00284;
ECO("a3","JAP") = 1.57e-05;
ECO("n3","JAP") = 7.315027067;
ECO("a2","CAN") = 0.00284;
ECO("a3","CAN") = 1.57e-05;
ECO("n3","CAN") = 7.315027067;
ECO("a2","OAB") = 0.00284;
ECO("a3","OAB") = 1.57e-05;
ECO("n3","OAB") = 7.315027067;
ECO("a2","EU") = 0.00284;
ECO("a3","EU") = 1.57e-05;
ECO("n3","EU") = 7.315027067;
ECO("a2","CHN") = 0.00284;
ECO("a3","CHN") = 1.57e-05;
ECO("n3","CHN") = 7.315027067;
ECO("a2","IND") = 0.00284;
ECO("a3","IND") = 1.57e-05;
ECO("n3","IND") = 7.315027067;
ECO("a2","BRZ") = 0.00284;
ECO("a3","BRZ") = 1.57e-05;
ECO("n3","BRZ") = 7.315027067;
ECO("a2","SAF") = 0.00284;
ECO("a3","SAF") = 1.57e-05;
ECO("n3","SAF") = 7.315027067;
ECO("a2","OEU") = 0.00284;
ECO("a3","OEU") = 1.57e-05;
ECO("n3","OEU") = 7.315027067;
ECO("a2","REF") = 0.00284;
ECO("a3","REF") = 1.57e-05;
ECO("n3","REF") = 7.315027067;
ECO("a2","MAF") = 0.00284;
ECO("a3","MAF") = 1.57e-05;
ECO("n3","MAF") = 7.315027067;
ECO("a2","LAM") = 0.00284;
ECO("a3","LAM") = 1.57e-05;
ECO("n3","LAM") = 7.315027067;
ECO("a2","ASIA0") = 0.00284;
ECO("a3","ASIA0") = 1.57e-05;
ECO("n3","ASIA0") = 7.315027067;
ECO("a2","ASIA1") = 0.00284;
ECO("a3","ASIA1") = 1.57e-05;
ECO("n3","ASIA1") = 7.315027067;
ECO("a2","ASIA2") = 0.00284;
ECO("a3","ASIA2") = 1.57e-05;
ECO("n3","ASIA2") = 7.315027067;
ECO("a2","ASIA3") = 0.00284;
ECO("a3","ASIA3") = 1.57e-05;
ECO("n3","ASIA3") = 7.315027067;
ECO("a2","ASIA4") = 0.00284;
ECO("a3","ASIA4") = 1.57e-05;
ECO("n3","ASIA4") = 7.315027067;
ECO("a2","ASIA5") = 0.00284;
ECO("a3","ASIA5") = 1.57e-05;
ECO("n3","ASIA5") = 7.315027067;
ECO("a2","ASIA6") = 0.00284;
ECO("a3","ASIA6") = 1.57e-05;
ECO("n3","ASIA6") = 7.315027067;
ECO("a2","ASIA7") = 0.00284;
ECO("a3","ASIA7") = 1.57e-05;
ECO("n3","ASIA7") = 7.315027067;
ECO("a2","ASIA8") = 0.00284;
ECO("a3","ASIA8") = 1.57e-05;
ECO("n3","ASIA8") = 7.315027067;
ECO("a2","ASIA9") = 0.00284;
ECO("a3","ASIA9") = 1.57e-05;
ECO("n3","ASIA9") = 7.315027067;



******////////////////////////////////////////////////////////////////////******
*************************** Calculate Nash Equilibrium *************************
******/////////////////////////////formula/////////////////////////////////******

PARAMETERS
    marg_S(ITER, t, n)      "Shadow Price of saving"
    marg_DAM(ITER, t, n)    "Shadow Price of damage fraction"
    marg_K(ITER, t, n)      "Shadow Price of capital"
    marg_ABA(ITER, t, n)    "Shadow Price of abatement fraction"
;




SOLVE  RICE MAXIMIZING UT2_USA USING NLP;
marginal_miu(T,"USA") = MIU.m(T,"USA");
marg_S(ITER, t,"USA") = S.m(T,"USA");
marg_DAM(ITER, t,"USA") = DAMFRACEQ.m(T,"USA");
marg_ABA(ITER, t,"USA") = abatefraceq.m(T,"USA");
marg_K(ITER, t,"USA") = KK.m(T,"USA");

SOLVE  RICE MAXIMIZING UT2_RUS USING NLP;
marginal_miu(T,"RUS") = MIU.m(T,"RUS");
marg_S(ITER, t,"RUS") = S.m(T,"RUS");
marg_DAM(ITER, t,"RUS") = DAMFRACEQ.m(T,"RUS");
marg_ABA(ITER, t,"RUS") = abatefraceq.m(T,"RUS");
marg_K(ITER, t,"RUS") = KK.m(T,"RUS");

SOLVE  RICE MAXIMIZING UT2_JAP USING NLP;
marginal_miu(T,"JAP") = MIU.m(T,"JAP");
marg_S(ITER, t,"JAP") = S.m(T,"JAP");
marg_DAM(ITER, t,"JAP") = DAMFRACEQ.m(T,"JAP");
marg_ABA(ITER, t,"JAP") = abatefraceq.m(T,"JAP");
marg_K(ITER, t,"JAP") = KK.m(T,"JAP");

SOLVE  RICE MAXIMIZING UT2_CAN USING NLP;
marginal_miu(T,"CAN") = MIU.m(T,"CAN");
marg_S(ITER, t,"CAN") = S.m(T,"CAN");
marg_DAM(ITER, t,"CAN") = DAMFRACEQ.m(T,"CAN");
marg_ABA(ITER, t,"CAN") = abatefraceq.m(T,"CAN");
marg_K(ITER, t,"CAN") = KK.m(T,"CAN");

SOLVE  RICE MAXIMIZING UT2_OAB USING NLP;
marginal_miu(T,"OAB") = MIU.m(T,"OAB");
marg_S(ITER, t,"OAB") = S.m(T,"OAB");
marg_DAM(ITER, t,"OAB") = DAMFRACEQ.m(T,"OAB");
marg_ABA(ITER, t,"OAB") = abatefraceq.m(T,"OAB");
marg_K(ITER, t,"OAB") = KK.m(T,"OAB");


SOLVE  RICE MAXIMIZING UT2_EU USING NLP;
marginal_miu(T,"EU") = MIU.m(T,"EU");
marg_S(ITER, t,"EU") = S.m(T,"EU");
marg_DAM(ITER, t,"EU") = DAMFRACEQ.m(T,"EU");
marg_ABA(ITER, t,"EU") = abatefraceq.m(T,"EU");
marg_K(ITER, t,"EU") = KK.m(T,"EU");


SOLVE  RICE MAXIMIZING UT2_CHN USING NLP;
marginal_miu(T,"CHN") = MIU.m(T,"CHN");
marg_S(ITER, t,"CHN") = S.m(T,"CHN");
marg_DAM(ITER, t,"CHN") = DAMFRACEQ.m(T,"CHN");
marg_ABA(ITER, t,"CHN") = abatefraceq.m(T,"CHN");
marg_K(ITER, t,"CHN") = KK.m(T,"CHN");


SOLVE  RICE MAXIMIZING UT2_IND USING NLP;
marginal_miu(T,"IND") = MIU.m(T,"IND");
marg_S(ITER, t,"IND") = S.m(T,"IND");
marg_DAM(ITER, t,"IND") = DAMFRACEQ.m(T,"IND");
marg_ABA(ITER, t,"IND") = abatefraceq.m(T,"IND");
marg_K(ITER, t,"IND") = KK.m(T,"IND");


SOLVE  RICE MAXIMIZING UT2_BRZ USING NLP;
marginal_miu(T,"BRZ") = MIU.m(T,"BRZ");
marg_S(ITER, t,"BRZ") = S.m(T,"BRZ");
marg_DAM(ITER, t,"BRZ") = DAMFRACEQ.m(T,"BRZ");
marg_ABA(ITER, t,"BRZ") = abatefraceq.m(T,"BRZ");
marg_K(ITER, t,"BRZ") = KK.m(T,"BRZ");


SOLVE  RICE MAXIMIZING UT2_SAF USING NLP;
marginal_miu(T,"SAF") = MIU.m(T,"SAF");
marg_S(ITER, t,"SAF") = S.m(T,"SAF");
marg_DAM(ITER, t,"SAF") = DAMFRACEQ.m(T,"SAF");
marg_ABA(ITER, t,"SAF") = abatefraceq.m(T,"SAF");
marg_K(ITER, t,"SAF") = KK.m(T,"SAF");


SOLVE  RICE MAXIMIZING UT2_OEU USING NLP;
marginal_miu(T,"OEU") = MIU.m(T,"OEU");
marg_S(ITER, t,"OEU") = S.m(T,"OEU");
marg_DAM(ITER, t,"OEU") = DAMFRACEQ.m(T,"OEU");
marg_ABA(ITER, t,"OEU") = abatefraceq.m(T,"OEU");
marg_K(ITER, t,"OEU") = KK.m(T,"OEU");


SOLVE  RICE MAXIMIZING UT2_REF USING NLP;
marginal_miu(T,"REF") = MIU.m(T,"REF");
marg_S(ITER, t,"REF") = S.m(T,"REF");
marg_DAM(ITER, t,"REF") = DAMFRACEQ.m(T,"REF");
marg_ABA(ITER, t,"REF") = abatefraceq.m(T,"REF");
marg_K(ITER, t,"REF") = KK.m(T,"REF");


SOLVE  RICE MAXIMIZING UT2_MAF USING NLP;
marginal_miu(T,"MAF") = MIU.m(T,"MAF");
marg_S(ITER, t,"MAF") = S.m(T,"MAF");
marg_DAM(ITER, t,"MAF") = DAMFRACEQ.m(T,"MAF");
marg_ABA(ITER, t,"MAF") = abatefraceq.m(T,"MAF");
marg_K(ITER, t,"MAF") = KK.m(T,"MAF");


SOLVE  RICE MAXIMIZING UT2_LAM USING NLP;
marginal_miu(T,"LAM") = MIU.m(T,"LAM");
marg_S(ITER, t,"LAM") = S.m(T,"LAM");
marg_DAM(ITER, t,"LAM") = DAMFRACEQ.m(T,"LAM");
marg_ABA(ITER, t,"LAM") = abatefraceq.m(T,"LAM");
marg_K(ITER, t,"LAM") = KK.m(T,"LAM");


SOLVE  RICE MAXIMIZING UT2_ASIA0 USING NLP;
marginal_miu(T,"ASIA0") = MIU.m(T,"ASIA0");
marg_S(ITER, t,"ASIA0") = S.m(T,"ASIA0");
marg_DAM(ITER, t,"ASIA0") = DAMFRACEQ.m(T,"ASIA0");
marg_ABA(ITER, t,"ASIA0") = abatefraceq.m(T,"ASIA0");
marg_K(ITER, t,"ASIA0") = KK.m(T,"ASIA0");


SOLVE  RICE MAXIMIZING UT2_ASIA1 USING NLP;
marginal_miu(T,"ASIA1") = MIU.m(T,"ASIA1");
marg_S(ITER, t,"ASIA1") = S.m(T,"ASIA1");
marg_DAM(ITER, t,"ASIA1") = DAMFRACEQ.m(T,"ASIA1");
marg_ABA(ITER, t,"ASIA1") = abatefraceq.m(T,"ASIA1");
marg_K(ITER, t,"ASIA1") = KK.m(T,"ASIA1");


SOLVE  RICE MAXIMIZING UT2_ASIA2 USING NLP;
marginal_miu(T,"ASIA2") = MIU.m(T,"ASIA2");
marg_S(ITER, t,"ASIA2") = S.m(T,"ASIA2");
marg_DAM(ITER, t,"ASIA2") = DAMFRACEQ.m(T,"ASIA2");
marg_ABA(ITER, t,"ASIA2") = abatefraceq.m(T,"ASIA2");
marg_K(ITER, t,"ASIA2") = KK.m(T,"ASIA2");


SOLVE  RICE MAXIMIZING UT2_ASIA3 USING NLP;
marginal_miu(T,"ASIA3") = MIU.m(T,"ASIA3");
marg_S(ITER, t,"ASIA3") = S.m(T,"ASIA3");
marg_DAM(ITER, t,"ASIA3") = DAMFRACEQ.m(T,"ASIA3");
marg_ABA(ITER, t,"ASIA3") = abatefraceq.m(T,"ASIA3");
marg_K(ITER, t,"ASIA3") = KK.m(T,"ASIA3");


SOLVE  RICE MAXIMIZING UT2_ASIA4 USING NLP;
marginal_miu(T,"ASIA4") = MIU.m(T,"ASIA4");
marg_S(ITER, t,"ASIA4") = S.m(T,"ASIA4");
marg_DAM(ITER, t,"ASIA4") = DAMFRACEQ.m(T,"ASIA4");
marg_ABA(ITER, t,"ASIA4") = abatefraceq.m(T,"ASIA4");
marg_K(ITER, t,"ASIA4") = KK.m(T,"ASIA4");


SOLVE  RICE MAXIMIZING UT2_ASIA5 USING NLP;
marginal_miu(T,"ASIA5") = MIU.m(T,"ASIA5");
marg_S(ITER, t,"ASIA5") = S.m(T,"ASIA5");
marg_DAM(ITER, t,"ASIA5") = DAMFRACEQ.m(T,"ASIA5");
marg_ABA(ITER, t,"ASIA5") = abatefraceq.m(T,"ASIA5");
marg_K(ITER, t,"ASIA5") = KK.m(T,"ASIA5");


SOLVE  RICE MAXIMIZING UT2_ASIA6 USING NLP;
marginal_miu(T,"ASIA6") = MIU.m(T,"ASIA6");
marg_S(ITER, t,"ASIA6") = S.m(T,"ASIA6");
marg_DAM(ITER, t,"ASIA6") = DAMFRACEQ.m(T,"ASIA6");
marg_ABA(ITER, t,"ASIA6") = abatefraceq.m(T,"ASIA6");
marg_K(ITER, t,"ASIA6") = KK.m(T,"ASIA6");


SOLVE  RICE MAXIMIZING UT2_ASIA7 USING NLP;
marginal_miu(T,"ASIA7") = MIU.m(T,"ASIA7");
marg_S(ITER, t,"ASIA7") = S.m(T,"ASIA7");
marg_DAM(ITER, t,"ASIA7") = DAMFRACEQ.m(T,"ASIA7");
marg_ABA(ITER, t,"ASIA7") = abatefraceq.m(T,"ASIA7");
marg_K(ITER, t,"ASIA7") = KK.m(T,"ASIA7");


SOLVE  RICE MAXIMIZING UT2_ASIA8 USING NLP;
marginal_miu(T,"ASIA8") = MIU.m(T,"ASIA8");
marg_S(ITER, t,"ASIA8") = S.m(T,"ASIA8");
marg_DAM(ITER, t,"ASIA8") = DAMFRACEQ.m(T,"ASIA8");
marg_ABA(ITER, t,"ASIA8") = abatefraceq.m(T,"ASIA8");
marg_K(ITER, t,"ASIA8") = KK.m(T,"ASIA8");


SOLVE  RICE MAXIMIZING UT2_ASIA9 USING NLP;
marginal_miu(T,"ASIA9") = MIU.m(T,"ASIA9");
marg_S(ITER, t,"ASIA9") = S.m(T,"ASIA9");
marg_DAM(ITER, t,"ASIA9") = DAMFRACEQ.m(T,"ASIA9");
marg_ABA(ITER, t,"ASIA9") = abatefraceq.m(T,"ASIA9");
marg_K(ITER, t,"ASIA9") = KK.m(T,"ASIA9");






put /"SCENARIO: High Damage"
put /"REGION: USA"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"USA"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"USA"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"USA")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"USA"));
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
put / "Regional welfare";
Loop(T, put UT2_USA.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"USA"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "USA"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "USA"));put / "Population (exogenous)" ;
Loop (T, put L(T,"USA"));
put / "Carbon price";
Loop(T, put cprice.l(T,"USA"));
put / "Saving rate";
Loop(T, put S.l(T,"USA"));
put /"REGION: RUS"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"RUS"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"RUS"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"RUS")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"RUS"));
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
put / "Regional welfare";
Loop(T, put UT2_RUS.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"RUS"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "RUS"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "RUS"));put / "Population (exogenous)" ;
Loop (T, put L(T,"RUS"));
put / "Carbon price";
Loop(T, put cprice.l(T,"RUS"));
put / "Saving rate";
Loop(T, put S.l(T,"RUS"));
put /"REGION: JAP"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"JAP"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"JAP"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"JAP")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"JAP"));
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
put / "Regional welfare";
Loop(T, put UT2_JAP.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"JAP"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "JAP"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "JAP"));put / "Population (exogenous)" ;
Loop (T, put L(T,"JAP"));
put / "Carbon price";
Loop(T, put cprice.l(T,"JAP"));
put / "Saving rate";
Loop(T, put S.l(T,"JAP"));
put /"REGION: CAN"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"CAN"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"CAN"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"CAN")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"CAN"));
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
put / "Regional welfare";
Loop(T, put UT2_CAN.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"CAN"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "CAN"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "CAN"));put / "Population (exogenous)" ;
Loop (T, put L(T,"CAN"));
put / "Carbon price";
Loop(T, put cprice.l(T,"CAN"));
put / "Saving rate";
Loop(T, put S.l(T,"CAN"));
put /"REGION: OAB"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"OAB"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"OAB"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"OAB")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"OAB"));
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
put / "Regional welfare";
Loop(T, put UT2_OAB.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"OAB"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "OAB"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "OAB"));put / "Population (exogenous)" ;
Loop (T, put L(T,"OAB"));
put / "Carbon price";
Loop(T, put cprice.l(T,"OAB"));
put / "Saving rate";
Loop(T, put S.l(T,"OAB"));
put /"REGION: EU"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"EU"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"EU"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"EU")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"EU"));
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
put / "Regional welfare";
Loop(T, put UT2_EU.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"EU"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "EU"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "EU"));put / "Population (exogenous)" ;
Loop (T, put L(T,"EU"));
put / "Carbon price";
Loop(T, put cprice.l(T,"EU"));
put / "Saving rate";
Loop(T, put S.l(T,"EU"));
put /"REGION: CHN"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"CHN"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"CHN"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"CHN")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"CHN"));
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
put / "Regional welfare";
Loop(T, put UT2_CHN.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"CHN"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "CHN"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "CHN"));put / "Population (exogenous)" ;
Loop (T, put L(T,"CHN"));
put / "Carbon price";
Loop(T, put cprice.l(T,"CHN"));
put / "Saving rate";
Loop(T, put S.l(T,"CHN"));
put /"REGION: IND"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"IND"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"IND"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"IND")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"IND"));
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
put / "Regional welfare";
Loop(T, put UT2_IND.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"IND"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "IND"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "IND"));put / "Population (exogenous)" ;
Loop (T, put L(T,"IND"));
put / "Carbon price";
Loop(T, put cprice.l(T,"IND"));
put / "Saving rate";
Loop(T, put S.l(T,"IND"));
put /"REGION: BRZ"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"BRZ"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"BRZ"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"BRZ")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"BRZ"));
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
put / "Regional welfare";
Loop(T, put UT2_BRZ.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"BRZ"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "BRZ"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "BRZ"));put / "Population (exogenous)" ;
Loop (T, put L(T,"BRZ"));
put / "Carbon price";
Loop(T, put cprice.l(T,"BRZ"));
put / "Saving rate";
Loop(T, put S.l(T,"BRZ"));
put /"REGION: SAF"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"SAF"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"SAF"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"SAF")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"SAF"));
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
put / "Regional welfare";
Loop(T, put UT2_SAF.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"SAF"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "SAF"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "SAF"));put / "Population (exogenous)" ;
Loop (T, put L(T,"SAF"));
put / "Carbon price";
Loop(T, put cprice.l(T,"SAF"));
put / "Saving rate";
Loop(T, put S.l(T,"SAF"));
put /"REGION: OEU"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"OEU"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"OEU"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"OEU")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"OEU"));
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
put / "Regional welfare";
Loop(T, put UT2_OEU.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"OEU"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "OEU"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "OEU"));put / "Population (exogenous)" ;
Loop (T, put L(T,"OEU"));
put / "Carbon price";
Loop(T, put cprice.l(T,"OEU"));
put / "Saving rate";
Loop(T, put S.l(T,"OEU"));
put /"REGION: REF"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"REF"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"REF"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"REF")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"REF"));
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
put / "Regional welfare";
Loop(T, put UT2_REF.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"REF"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "REF"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "REF"));put / "Population (exogenous)" ;
Loop (T, put L(T,"REF"));
put / "Carbon price";
Loop(T, put cprice.l(T,"REF"));
put / "Saving rate";
Loop(T, put S.l(T,"REF"));
put /"REGION: MAF"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"MAF"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"MAF"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"MAF")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"MAF"));
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
put / "Regional welfare";
Loop(T, put UT2_MAF.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"MAF"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "MAF"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "MAF"));put / "Population (exogenous)" ;
Loop (T, put L(T,"MAF"));
put / "Carbon price";
Loop(T, put cprice.l(T,"MAF"));
put / "Saving rate";
Loop(T, put S.l(T,"MAF"));
put /"REGION: LAM"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"LAM"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"LAM"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"LAM")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"LAM"));
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
put / "Regional welfare";
Loop(T, put UT2_LAM.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"LAM"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "LAM"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "LAM"));put / "Population (exogenous)" ;
Loop (T, put L(T,"LAM"));
put / "Carbon price";
Loop(T, put cprice.l(T,"LAM"));
put / "Saving rate";
Loop(T, put S.l(T,"LAM"));
put /"REGION: ASIA0"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA0"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA0"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA0")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA0"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA0.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA0"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA0"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA0"));put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA0"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA0"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA0"));
put /"REGION: ASIA1"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA1"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA1"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA1")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA1"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA1.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA1"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA1"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA1"));put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA1"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA1"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA1"));
put /"REGION: ASIA2"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA2"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA2"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA2")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA2"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA2.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA2"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA2"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA2"));put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA2"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA2"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA2"));
put /"REGION: ASIA3"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA3"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA3"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA3")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA3"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA3.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA3"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA3"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA3"));put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA3"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA3"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA3"));
put /"REGION: ASIA4"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA4"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA4"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA4")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA4"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA4.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA4"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA4"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA4"));put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA4"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA4"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA4"));
put /"REGION: ASIA5"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA5"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA5"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA5")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA5"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA5.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA5"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA5"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA5"));put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA5"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA5"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA5"));
put /"REGION: ASIA6"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA6"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA6"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA6")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA6"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA6.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA6"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA6"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA6"));put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA6"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA6"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA6"));
put /"REGION: ASIA7"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA7"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA7"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA7")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA7"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA7.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA7"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA7"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA7"));put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA7"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA7"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA7"));
put /"REGION: ASIA8"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA8"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA8"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA8")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA8"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA8.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA8"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA8"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA8"));put / "Population (exogenous)" ;
Loop (T, put L(T,"ASIA8"));
put / "Carbon price";
Loop(T, put cprice.l(T,"ASIA8"));
put / "Saving rate";
Loop(T, put S.l(T,"ASIA8"));
put /"REGION: ASIA9"
put / "TFP (exogenous)" ;
Loop (T, put AL(T,"ASIA9"));
put / "Output, net net trill 2019$" ;
Loop (T, put Y.l(T,"ASIA9"));
put / "Industrial CO2 GtCO2/yr" ;
Loop (T, put EIND.l(T,"ASIA9")) ;
put / "Emissions control rate";
Loop(T, put MIU.l(T,"ASIA9"));
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
put / "Regional welfare";
Loop(T, put UT2_ASIA9.l);
put / "Marginal regional welfare";
Loop(T, put marginal_miu(T,"ASIA9"));
put / "Marginal Cost of Damages (Shadow Price)";
Loop(T, put marg_DAM("1", T, "ASIA9"));put / "Marginal Cost of Abatement (Shadow Price)";
Loop(T, put marg_ABA("1", T, "ASIA9"));put / "Population (exogenous)" ;
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


