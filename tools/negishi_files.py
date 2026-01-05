from .tools import *



def flag_def_regions(dict):
    return flag_def_regions_impl(dict)


def flag_nb_regions(dict):
    return flag_nb_regions_impl(dict)


def flag_table_inputs(dict):
    return flag_table_inputs_impl(dict)



def flag_solve(dict, mortality = False):

    scenarios = list(dict.keys())
    regions = list(dict[scenarios[0]].keys())
    string_table = "\n"

    memory = ""
    for sce in scenarios:
        if sce != scenarios[0]:
            string_table += modif_table(dict, memory, sce)
        memory = sce





        string_table += '$include S-NegishiOptimal.gms\n'
        string_table += f'put /"SCENARIO: {sce}"\n'

        for r in regions :
            string_table += f'put / "REGION: {r}"\n'
            string_table += 'put / "TFP (exogenous)" ;\n'
            string_table += f'Loop (T, put AL(T,"{r}"));\n'
            string_table += 'put / "Output, net net trill 2019$" ;\n'
            string_table += f'Loop (T, put Y.l(T,"{r}"));\n'
            string_table += 'put / "Emissions control rate";\n'
            string_table += f'Loop(T, put MIU.l(T,"{r}"));\n'
            string_table += 'put / "Weight";\n'
            string_table += f'Loop(T, put LB(T,"{r}"));\n'
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
            string_table += 'put / "Social cost of carbon $/tCO2";\n'
            string_table += f'scc(t,n) = -1000 * eco2eq.m(t) / (.00001 + cc.m(t,"{r}"));\n'
            string_table += f'scc("1","{r}") = scc("2","{r}") * .85;\n'
            string_table += f'Loop(T, put scc(t,"{r}"));\n'

            if mortality :
                string_table += 'put / "Population" ;\n'
                string_table += f'Loop (T, put L.l(T,"{r}"));\n'
                string_table += 'put / "Mortality" ;\n'
                string_table += f'Loop (T, put mort.l(T,"{r}"));\n'
            else :
                string_table += 'put / "Population (exogenous)" ;\n'
                string_table += f'Loop (T, put L(T,"{r}"));\n'


        string_table += 'put /"REGION: World"\n'
        string_table += 'put / "Total CO2 Emissions, GTCO2/year" ;\n'
        string_table += 'Loop (T, put Eco2.l(T));\n'
        string_table += 'put / "Actual other abatable GHG forcings w/m2" ;\n'
        string_table += 'Loop (T, put F_GHGabate.L(t) );\n'
        string_table += 'put / "Atmospheric temperature (deg c above preind)";\n'
        string_table += 'Loop(T, put TATM.l(T));\n'
        string_table += 'put / "Saving rate";\n'
        string_table += 'Loop(T, put S.l(T));\n'
        string_table += 'put / "MIU global";\n'
        string_table += 'Loop(T, put MIU_GLOBAL.l(T));\n'
    return string_table




def introduce_flag(input_file, dict, mortality = False):
    return introduce_flag_impl(input_file, dict, globals(), mortality = mortality)



def get_optim_file(repo,data):

    nordhaus = 1
    if nordhaus:
        optim_file_init = repo + "gams_code/type_files/rice2023_nordhaus_negishi_type_file.gms"
        rice_code = repo+"gams_code/optim_files/rice2023_nordhaus_negishi.gms"
    else:
        optim_file_init = repo + "gams_code/type_files/rice2023_negishi_type_file.gms"
        rice_code = repo+"gams_code/optim_files/rice2023_negishi.gms"

    rice2023_code = introduce_flag(optim_file_init, data)
    optim_file_init = "tools/solver/S-NegishiOptimal_type_file.gms"

    solver_code = introduce_flag(optim_file_init, data)
    text = solver_intro_model(rice2023_code, solver_code)
    write_gams_self_contained(rice_code, text)
