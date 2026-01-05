import numpy as np


def compute_mean(mu_dict):
    mean_mu = []
    region = list(mu_dict.keys())
    for t in range(len(mu_dict[region[0]])):
        sum = 0
        count = 0
        for r in region:
            sum += mu_dict[r][t]
            count += 1
        mean = sum / count
        mean_mu.append(mean)
    return mean_mu


def compute_norm_euclide(mu_dict):
    mean_mu = compute_mean(mu_dict)
    region = list(mu_dict.keys())
    norm_euclide = {}
    for r in region :
        sum = 0
        for t in range(len(mu_dict[r])):
            sum += (mean_mu[t] - mu_dict[r][t])**2
        sum = np.sqrt(sum)
        norm_euclide[r] = sum
    return norm_euclide


def compute_dispersion(mu_dict):
    norm_euclide = compute_norm_euclide(mu_dict)
    region = list(mu_dict.keys())
    sum = 0
    for r in region :
        sum += norm_euclide[r]
    dispersion = sum/len(region)
    return dispersion


