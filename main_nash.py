from tools.nash_files import *




if __name__ == '__main__':


    repo = "spatial_consistency/"


    data = automatic_multiscenarios(repo)
    # data = multiscenarios({"Standard": repo + 'inputs/inputs.csv',
    #                        "Nordhaus": repo + 'inputs/inputs_n.csv',
    #                        "Middle-Damage": repo + 'inputs/inputs_n2.csv',
    #                        })
    data = multiscenarios({"Nordhaus": repo + 'inputs/inputs_n.csv'
                           })
    get_optim_file(repo, data)



