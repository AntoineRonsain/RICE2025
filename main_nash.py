from tools.nash_files import *




if __name__ == '__main__':


    repo = "spatial_consistency/"
    data = multiscenarios({"Medium Damage": repo + 'inputs/medium_dam.csv',
                           "High Damage": repo + 'inputs/high_dam.csv',
                           })
    get_optim_file(repo, data)

    data = multiscenarios({"Low Damage": repo + 'inputs/low_dam.csv'
                           })
    get_optim_file(repo, data, dam ="Quadratic")

    data = multiscenarios({"Medium Damage": repo + 'inputs/medium_dam_10asia.csv',
                           "High Damage": repo + 'inputs/high_dam_10asia.csv',
                           })
    get_optim_file(repo, data, mode= "10Asia")

    data = multiscenarios({"Low Damage": repo + 'inputs/low_dam_10asia.csv'
                           })
    get_optim_file(repo, data, mode= "10Asia", dam ="Quadratic")

