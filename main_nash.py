from tools.nash_files import *




if __name__ == '__main__':


    repo = "spatial_consistency/"
    data = multiscenarios({"Low Damage": repo + 'inputs/low_dam.csv',
                           "Medium Damage": repo + 'inputs/medium_dam.csv',
                           "High Damage": repo + 'inputs/high_dam.csv',
                           })
    get_optim_file(repo, data)



