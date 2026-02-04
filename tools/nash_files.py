from .tools import *


def flag_nash_utility(dict):

    string_table = ""
    scenarios = list(dict.keys())
    regions = list(dict[scenarios[0]].keys())
    for r in regions:
        string_table += f"NUT_{r}         Nash Utility of {r}\n"
    return string_table

def flag_nash_utility_init(dict):
    string_table = ""
    scenarios = list(dict.keys())
    regions = list(dict[scenarios[0]].keys())
    for r in regions:
        string_table += f"NUT_{r} = ININUT;\n"
    return string_table

def flag_nash_welfare(dict):
    string_table = ""
    scenarios = list(dict.keys())
    regions = list(dict[scenarios[0]].keys())
    for r in regions:
        string_table += f"UT_{r} Social welfare function of {r}\n"
        string_table += f"UT1_{r} Social welfare function of {r}\n"
        string_table += f"UT2_{r} Social welfare function of {r}\n"
    return string_table


def flag_nash_welfare_func(dict):
    string_table = ""
    string_table += ('EQUATIONS\n')

    scenarios = list(dict.keys())
    regions = list(dict[scenarios[0]].keys())
    for r in regions:
        string_table += f"OBJ_{r}\n"
        string_table += f"OBJ1_{r}\n"
        string_table += f"OBJ2_{r}\n"
    string_table += ";\n"

    for r in regions:
        string_table += f"OBJ_{r}..    UT_{r} =E= Q* SUM(t, CEMUTOTPER(t,\"{r}\"));\n"
        string_table += f"OBJ1_{r}..    UT1_{r} =E= Q1* SUM(t, CEMUTOTPER(t,\"{r}\"));\n"
        string_table += f"OBJ2_{r}..    UT2_{r} =E= Q2* SUM(t, CEMUTOTPER(t,\"{r}\"));\n"

    return string_table



def flag_loop_nash_solver(dict):

    string_table = ""
    string_table += "MIU.FX(t, n) = miuup(t, n);\n"
    string_table += "S.FX(t, n) = optlrsav;\n"

    string_table += "LOOP(ITER,\n"

    k = 1
    scenarios = list(dict.keys())
    regions = list(dict[scenarios[0]].keys())
    for r in regions:
        string_table += f'MIE(ITER,"{k}",t,n)=MIU.L(t,n);\n'
        string_table += f'SE(ITER,"{k}",t,n)=S.L(t,n);\n'
        string_table += 'MIU.LO(t,n) = 0;\nMIU.UP(t,n) = miuup(t,n);\nMIU.FX("1",n) = ECO("MIU0",N);\n'
        string_table += 'S.LO(t,n) = 0.1;\nS.UP(t,n) = 0.6;\n'
        string_table += f'MIU.FX(t,n)$(ORD(n) NE {k})=MIE(ITER,"{k}",t,n);\n'
        string_table += f'S.FX(t,n)$(ORD(n) NE {k})=SE(ITER,"{k}",t,n);\n'
        string_table += f'SOLVE  RICE MAXIMIZING UT2_{r} USING NLP;\n'
        string_table += f'marginal_miu(T,"{r}") = MIU.m(T,"{r}");\n'
        string_table += f'marg_S(ITER, t,"{r}") = S.m(T,"{r}");\n'
        string_table += f'marg_DAM(ITER, t,"{r}") = DAMFRACEQ.m(T,"{r}");\n'
        string_table += f'marg_ABA(ITER, t,"{r}") = abatefraceq.m(T,"{r}");\n'
        string_table += f'marg_K(ITER, t,"{r}") = KK.m(T,"{r}");\n'
        k+=1

    string_table += f'*Reset for the next iteration.\n'
    string_table += f'MIE(ITER, "{k}", t, n) = MIU.L(t, n);\n'
    string_table += f'SE(ITER, "{k}", t, n) = S.L(t, n);\n'
    string_table += f'MIE(ITER + 1, "1", t, n) = MIE(ITER, "{k}", t, n);\n'
    string_table += f'SE(ITER + 1, "1", t, n) = SE(ITER, "{k}", t, n);\n'
    string_table += ');\n'

    return string_table

def flag_def_regions(dict):
    return flag_def_regions_impl(dict)


def flag_nb_regions(dict):
    return flag_nb_regions_impl(dict)


def flag_table_inputs(dict):
    return flag_table_inputs_impl(dict)



def flag_solve(dict):

    scenarios = list(dict.keys())
    regions = list(dict[scenarios[0]].keys())
    string_table = "\n"

    memory = ""
    for sce in scenarios:
        if sce != scenarios[0]:
            string_table += modif_table(dict, memory, sce)
        memory = sce


        string_table += '$include S-Nash-FX1.gms\n'
        string_table += f'put /"SCENARIO: {sce}"\n'

        for r in regions :
            string_table += f'put /"REGION: {r}"\n'
            string_table += 'put / "TFP (exogenous)" ;\n'
            string_table += f'Loop (T, put AL(T,"{r}"));\n'
            string_table += 'put / "Output, net net trill 2019$" ;\n'
            string_table += f'Loop (T, put Y.l(T,"{r}"));\n'
            string_table += 'put / "Industrial CO2 GtCO2/yr" ;\n'
            string_table += f'Loop (T, put EIND.l(T,"{r}")) ;\n'
            string_table += 'put / "Emissions control rate";\n'
            string_table += f'Loop(T, put MIU.l(T,"{r}"));\n'
            string_table += 'put / "Output, gross-net, 2019$";\n'
            string_table += f'Loop(T, put ynet.l(t,"{r}"));\n'
            string_table += 'put / "Output, gross-gross, 2019$";\n'
            string_table += f'Loop(T, put YGROSS.L(t,"{r}"));\n'
            string_table += 'put / "Capital stock, 2019$" ;\n'
            string_table += f'Loop (T, put k.l(t,"{r}"));\n'
            string_table += 'put / "Climate damages, fraction of output" ;\n'
            string_table += f'Loop (T, put DAMFRAC.l(T,"{r}"));\n'
            string_table += 'put / "Abatement, 2019$" ;\n'
            string_table += f'Loop (T, put abatecost.l(t,"{r}"));\n'
            string_table += 'put / "Abatement/0utput" ;\n'
            string_table += f'Loop (T, put ABATECOSTFRAC.l(t,"{r}"));\n'
            string_table += 'put / "Sigma,(CO2/output, no controls, all CO2)";\n'
            string_table += f'Loop(T, put sigma(t,"{r}"));\n'
            string_table += 'put / "Regional welfare";\n'
            string_table += f'Loop(T, put UT2_{r}.l);\n'
            string_table += 'put / "Marginal regional welfare";\n'
            string_table += f'Loop(T, put marginal_miu(T,"{r}"));\n'
            string_table += f'put / "Marginal Cost of Damages (Shadow Price)";\n'
            string_table += f'Loop(T, put marg_DAM("5", T, "{r}"));'
            string_table += f'put / "Marginal Cost of Abatement (Shadow Price)";\n'
            string_table += f'Loop(T, put marg_ABA("5", T, "{r}"));'
            string_table += 'put / "Population (exogenous)" ;\n'
            string_table += f'Loop (T, put L(T,"{r}"));\n'
            string_table += 'put / "Carbon price";\n'
            string_table += f'Loop(T, put cprice.l(T,"{r}"));\n'
            string_table += 'put / "Saving rate";\n'
            string_table += f'Loop(T, put S.l(T,"{r}"));\n'


        string_table += 'put /"REGION: World"\n'
        string_table += 'put / "Total CO2 Emissions, GTCO2/year" ;\n'
        string_table += 'Loop (T, put Eco2.l(T));\n'
        string_table += 'put / "Actual other abatable GHG forcings w/m2" ;\n'
        string_table += 'Loop (T, put F_GHGabate.L(t) );\n'
        string_table += 'put / "Atmospheric temperature (deg c above preind)";\n'
        string_table += 'Loop(T, put TATM.l(T));\n'
        string_table += 'put / "MIU global";\n'
        string_table += 'Loop(T, put MIU_GLOBAL.l(T));\n'

        # for r in regions :
        #     for k in range(5):
        #         string_table += 'put / "('+str(r) +','+str(k) +')";\n'
        #         string_table += 'Loop(T, put MIE("'+str(k+1)+'","16",t,"'+str(r)+'"));\n'

    return string_table

def introduce_flag(input_file, dict):
    return introduce_flag_impl(input_file, dict, globals())





def get_optim_file(repo,data, mode = "", dam = "S-curve"):

    if dam == "S-curve":
        optim_file_init = repo + "gams_code/type_files/rice2023_nash_tf.gms"
        rice_code = repo+f"gams_code/optim_files/rice2023_nash{mode}.gms"

    else :
        optim_file_init = repo +"gams_code/type_files/rice2023_nash_quad_tf.gms"
        rice_code = repo+f"gams_code/optim_files/rice2023_nash_quad{mode}.gms"


    rice2023_code = introduce_flag(optim_file_init, data)

    optim_file_init = "tools/solver/s_nash.gms"
    solver_code = introduce_flag(optim_file_init, data)
    text = solver_intro_model(rice2023_code, solver_code)
    write_gams_self_contained(rice_code, text)
