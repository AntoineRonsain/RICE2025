from tools.negishi_files import *




if __name__ == '__main__':

    repo = "spatial_consistency/"
    data = automatic_multiscenarios(repo)
    data = multiscenarios({"Nordhaus": repo + 'inputs/inputs.csv'
                           })
    get_optim_file(repo, data)

