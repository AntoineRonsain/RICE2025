import matplotlib.pyplot as plt
import numpy as np

TEMP_MAX = 8
POINTS = 50


def calibrate_damage_params(t1, t2, p1=0.5, p2=0.99, a2=0.00284):
    """
    Calibrates the higher-order damage function parameters (n3, a3) based on two
    arbitrary temperature/damage reference points.

    The damage function is defined as:
        D(T) = 1 - 1 / (1 + a2 * T^2 + a3 * T^n3)

    This function solves the system of equations to find n3 and a3 such that
    the curve passes exactly through (t1, p1) and (t2, p2).

    Args:
        t1 (float): First reference temperature in °C.
        t2 (float): Second reference temperature in °C.
        p1 (float): Damage fraction at t1 (0.0 to 1.0).
        p2 (float): Damage fraction at t2 (0.0 to 1.0).
        a2 (float, optional): The base quadratic coefficient. Defaults to 0.00284.

    Returns:
        tuple: A tuple containing the calculated exponent (n3) and coefficient (a3).
    """
    b1 = 1. / (1. - p1) - 1. - a2 * t1 ** 2
    b2 = 1. / (1. - p2) - 1. - a2 * t2 ** 2

    n3 = np.log(b1 / b2) / np.log(t1 / t2)
    a3 = b1 / (t1 ** n3)

    return n3, a3


def calculate_damage(temps, a2, a3=0, n3=0):
    """
    Computes the economic damage fraction for a given array of temperatures.

    Formula:
        Damage = 1 - 1 / (1 + a2 * T^2 + a3 * T^n3)

    Args:
        temps (np.ndarray): Array of atmospheric temperatures.
        a2 (float): Quadratic coefficient.
        a3 (float, optional): Higher-order coefficient. Defaults to 0.
        n3 (float, optional): Higher-order exponent. Defaults to 0.

    Returns:
        np.ndarray: Array of damage fractions ranging from 0.0 (no damage) to 1.0 (total loss).
    """
    return 1 - 1 / (1 + a2 * temps ** 2 + a3 * temps ** n3)


def plot_damages(temperature_axis, scenarios):
    """
    Visualizes the comparison between different damage function scenarios using Matplotlib.
    Updated for high visibility (larger fonts, solid lines).

    Args:
        temperature_axis (np.ndarray): The x-axis data representing temperatures.
        scenarios (dict): A dictionary where keys are scenario names (str) and
                          values are the corresponding damage arrays (np.ndarray).
    """
    fig, ax = plt.subplots(figsize=(10, 6))

    # Iterate over scenarios
    for name, damages in scenarios.items():
        ax.plot(temperature_axis, damages * 100,
                linewidth=3,  # Thicker lines for better visibility
                linestyle='-',  # All lines are solid
                label=name)

    # --- Styling Updates ---

    # Axis Labels (Bigger)
    ax.set_xlabel('Atmospheric temperature (°C)', fontsize=20)
    ax.set_ylabel('Damages (% of GDP)', fontsize=20)
    ax.set_title('Climate Damage Functions Comparison', fontsize=22)

    # Ticks (Bigger numbers on axes)
    ax.tick_params(axis='both', which='major', labelsize=18)

    # Legend (Bigger text)
    ax.legend(fontsize=18, loc='upper left', frameon=True, framealpha=0.9)

    # Grid
    ax.grid(axis='y', linestyle='--', alpha=0.7)
    ax.grid(axis='x', linestyle=':', alpha=0.5)

    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    temperatures = np.linspace(0, TEMP_MAX, POINTS)

    p_low = {'a2': 0.003467, 'a3': 0, 'n3': 0}
    p_high = {'a2': 0.00284, 'a3': 1.570397e-05, 'n3': 7.315027067}

    n3_mid, a3_mid = calibrate_damage_params(t1=7, t2=15, a2=0.003467)
    p_middle = {'a2': 0.003467, 'a3': a3_mid, 'n3': n3_mid}


    results = {
        'Low Damage': calculate_damage(temperatures, **p_low),
        'Middle Damage': calculate_damage(temperatures, **p_middle),
        'High Damage': calculate_damage(temperatures, **p_high)
    }

    plot_damages(temperatures, results)