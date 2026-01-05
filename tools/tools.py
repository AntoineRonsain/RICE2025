import os

import pandas as pd
from tabulate import tabulate



def input_to_dict(filename):
    data_dict = {}
    data = pd.read_csv(filename)
    inputs_name, region = list(data.keys())[0], list(data.keys())[1:]
    nb_rows = len(data[region[0]])
    for r in region:
        if r not in data_dict.keys():
            data_dict[r] = {}
        for i in range(nb_rows):
            data_dict[r][data[inputs_name][i]] = data[r][i]
    return data_dict


def multiscenarios(filename_dict):
    data_dict = {}
    for i in filename_dict.keys():
        data_dict[i] = input_to_dict(filename_dict[i])
    return data_dict

def automatic_multiscenarios(repo):

    repo += 'inputs/'
    files = os.listdir(repo)
    scenarios = {}
    for f in files :
        csv_file = f.split('.')
        if csv_file[-1]=='csv':
            csv_file= csv_file[0].split('_')
            if len(csv_file) ==1:
                scenarios["medium"] = repo + f
            elif len(csv_file) ==2:
                scenarios[csv_file[1]] = repo + f
            else :
                scenarios[str(tuple(csv_file[1:]))] = repo + f
    return multiscenarios(scenarios)


def read_results(filename):
    "from a csv result file give the data under dictionary form"
    out = {}
    scenario = "none"

    with open(filename, 'r') as file:
        for line in file:
            if "SCENARIO:" in line:
                words = line.strip().split(':')
                scenario = words[1].strip().split(',')[0].replace('"','')
                out[scenario] = {}
            elif "REGION:" in line:
                words = line.strip().split(':')
                region = words[1].strip().split(',')[0].replace('"','')
                out[scenario][region] = {}
            else:
                words = line.strip().split(',')
                while len(words) >= 1 and len(words[0]) >= 1 and words[0][0] == '"' and words[0][-1] != '"':
                    words = [words[0]+","+words[1]] + words[2:]
                while (len(words) > 102):
                    words = [words[0]+","+words[1]] + words[2:]
                words = [x for x in words if len(x) != 0]
                if len(words) >= 2:
                    key = words[0].replace('"','').strip()
                    if key not in ["yr0     =","fco22x  =","a2      ="]:
                        out[scenario][region][key] = [float(x) for x in words[1:] if x != '']
    return out



def read_uncerainties_results(filename):
    "from a csv result file give the data under dictionary form"
    out = {}
    scenario = "none"

    with open(filename, 'r') as file:
        for line in file:
            if "SCENARIO:" in line:
                words = line.strip().split(':')
                if len(words[1].strip().split(','))== 1 :
                    scenario = words[1].strip().split(',')[0].replace('"', '')
                else:
                    scenario = ""
                    N = len(words[1].strip().split(','))
                    for i in range(N):
                        scenario += words[1].split()[i].replace("'",'').replace('"',"")
                out[scenario] = {}
            elif "REGION:" in line:
                words = line.strip().split(':')
                region = words[1].strip().split(',')[0].replace('"','')
                out[scenario][region] = {}
            else:
                words = line.strip().split(',')
                while len(words) >= 1 and len(words[0]) >= 1 and words[0][0] == '"' and words[0][-1] != '"':
                    words = [words[0]+","+words[1]] + words[2:]
                while (len(words) > 102):
                    words = [words[0]+","+words[1]] + words[2:]
                words = [x for x in words if len(x) != 0]
                if len(words) >= 2:
                    key = words[0].replace('"','').strip()
                    if key not in ["yr0     =","fco22x  =","a2      ="]:
                        out[scenario][region][key] = [float(x) for x in words[1:] if x != '']
    return out

def write_results(filename, results, scenario_name = ""):
    "from a csv result file give the data under dictionary form"
    try :
        file_read = open(filename, "r")
        content = file_read.read()
        content += '\n\n\n'
    except :
        file_read = open(filename, "w")
        content = ""

    for sce in results :
        content += '"SCENARIO: ' + sce + '"\n'

        for k in results[sce].keys():
            content += '"REGION:' + k + '"\n'
            for param in results[sce][k].keys():
                content += '"' + param + '"'
                if param == "welfare":
                    content += ',' + str(results[sce][k][param])
                else:
                    for val in results[sce][k][param]:
                        content += ','+ str(val)
                content += '\n'
    file_read.write(content)
    file_read.close()




def find_flag(content, word = 'flag'):
    start = 0
    index_start = []
    all_flag_found = True
    while all_flag_found:
        start = content.find(word, start)
        if start == -1:
            all_flag_found = False
        else :
            index_start.append(start)
            start += len(word)
    index_list = []
    for i in index_start:
        j = len(word)
        while (i+j < len(content)) and (content[i+j] not in ["\n", " ", "\t", ";"]):
            j+=1
        index_list.append((i,i+j))
    return index_list




def create_table(dict,name):


    regions = list(dict.keys())
    params = list(dict[regions[0]].keys())

    string_table = "SETS " +str(name) +"T\n"
    string_table += "/"
    for p in params:
        string_table +=  str(p) + ", "
    string_table = string_table[:-2]
    string_table +=('/\n\n')

    string_table += ("TABLE " +str(name) +"(" +str(name) +"T,N)\n")
    table = []
    headers = [""]
    for r in regions:
        headers.append(r)
    for p in params:
        table.append([p])
        for r in regions:
            table[-1].append(dict[r][p])
    string_table += tabulate(table, headers, tablefmt="plain",  numalign="left")
    string_table +=(';\n')
    return string_table


def modif_table(dict, memory, sce):

    string_table = ""
    for r in dict[sce].keys():
        for p in dict[sce][r].keys() :
            if dict[sce][r][p] != dict[memory][r][p]:
                string_table += f'ECO("{p}","{r}") = {dict[sce][r][p]};\n'
                if p == "lambdaM" :
                    string_table += f'miuup("1","{r}")= .05 * ECO("lambdaM","{r}");\n'
                    string_table += f'miuup("2","{r}")= .10 * ECO("lambdaM","{r}");\n'
                    string_table += f'miuup(t,"{r}")$(t.val > 2) = ( delmiumax*(t.val-1))* ECO("lambdaM","{r}");\n'
                    string_table += f'miuup(t,"{r}")$(t.val > 8) = 0.85+.05*(t.val-8)* ECO("lambdaM","{r}");\n'
                    string_table += f'miuup(t,"{r}")$(t.val > 11) = limmiu2070* ECO("lambdaM","{r}");\n'
                    string_table += f'miuup(t,"{r}")$(t.val > 20) = limmiu2120* ECO("lambdaM","{r}");\n'
                    string_table += f'miu.up(t,n) = miuup(t,n);\n'
                if p == "lambdaB":
                    string_table += f'pbacktime(t,"{r}")= pback2050* ECO("lambdaB","{r}")*exp(-5*(.01)*(t.val-7)) ;\n'
                    string_table += f'pbacktime(t,"{r}")$(t.val > 7) =  pback2050* ECO("lambdaB","{r}")*exp(-5*(.001)*(t.val-7)) ;\n'
                    string_table += f'cost1tot(t,"{r}") = pbacktime(T,"{r}") * sigmatot(T,"{r}") / expcost2 / 1000; \n'
    return string_table



def introduce_flag_impl(input_file, dict, func_dict, mortality = False):
    file_read = open(input_file, "r")
    content = file_read.read()
    file_read.close()
    dict = dict.copy()
    flag_pos = find_flag(content)
    final_doc = ""
    for f in range(len(flag_pos)):
        if f == 0:
            final_doc += content[:flag_pos[f][0]]
        else :
            final_doc += content[flag_pos[f-1][1]:flag_pos[f][0]]

        flag_type = content[flag_pos[f][0]:flag_pos[f][1]]

        if flag_type == "flag_solve":
            string = func_dict[flag_type](dict, mortality  = mortality)
        else :
            string = func_dict[flag_type](dict)

        final_doc += string

        if f == len(flag_pos)-1:
            final_doc += content[flag_pos[f][1]:]
    return final_doc


def flag_def_regions_impl(dict):

    scenarios = list(dict.keys())
    regions = list(dict[scenarios[0]].keys())
    string_table = ""
    string_table += ('N /')
    for a in regions:
        string_table +=  str(a) + ", "
    string_table = string_table[:-2]
    string_table +=('/\n')
    return string_table


def flag_nb_regions_impl(dict):

    scenarios = list(dict.keys())
    string_table = ""
    string_table += (' '+ str(len(list(dict[scenarios[0]].keys()))) +' ')

    return string_table


def flag_table_inputs_impl(dict):
    scenarios = list(dict.keys())
    string_table = create_table(dict[scenarios[0]], "ECO")
    return string_table


def solver_intro_model(string, string2):
    text = ""
    output_file = open("buffer", "w")
    output_file.write(string)
    output_file.close()
    with open("buffer",'r') as file:
        for line in file:
            words = line.strip().split()
            if (len(words) >= 2) and words[0] == "$include":
                text += string2
            else :
                text += line
    os.remove("buffer")
    return text


def write_gams_self_contained(filename, text):
    output_file = open(filename, "w")
    output_file.write(text)
    output_file.close()