# 3DOF Injera Dispensing Manipulator

Design, simulation, and manuscript materials for a three-degree-of-freedom (3DOF) SCARA-style manipulator intended for automated injera batter dispensing. The project covers mechanical CAD, MATLAB/Simulink control simulation, and publication-ready results.

## Overview

The manipulator has two revolute joints (\(\theta_1\), \(\theta_2\)) and one prismatic joint (\(d_3\)) for vertical nozzle motion. Simulink models compare three sliding-mode controllers:

| Controller | Description |
|------------|-------------|
| **SMC** | Conventional sliding-mode control |
| **STSMC** | Super-twisting sliding-mode control |
| **ASTSMC** | Adaptive super-twisting sliding-mode control |

Test scenarios include step and spiral Cartesian trajectories, with optional external disturbances and payload/parameter variation.

## Repository Structure
.
├── 01_SolidWorks_CAD/                # Mechanical design (SolidWorks)
│   ├── Assemblies/                   # Full robot assembly and drawing
│   └── Parts/                        # Individual components (links, nozzle, housings)
├── 02_MATLAB_Simulink/               # Dynamic model and control simulation
│   ├── Injera_Dispensing_Manipulator.slx
│   ├── Generate_Publication_Figures.m
│   └── Results/                      # Exported figures and performance tables
│       ├── figures_export_Step/
│       ├── figures_export_Step_Disturbance/
│       ├── figures_export_Spiral/
│       ├── figures_export_Spiral_Disturbance/
│       └── figures_export_ParamVariation_20pct/
└── 03_Manuscript/                     # Research paper
    ├── 3DOF_Injera_Dispensing_Manipulator.docx
    ├── 3DOF_Injera_Dispensing_Manipulator.pdf
    └── LaTeX/                         # LaTeX source (to be added)

## Requirements

- **SolidWorks** — to open and edit CAD files (`.SLDPRT`, `.SLDASM`, `.SLDDRW`)
- **MATLAB** (R2020b or later recommended)
- **Simulink**

## Running Simulations

1. Open MATLAB and set the current folder to `02_MATLAB_Simulink/`.
2. Open `Injera_Dispensing_Manipulator.slx`.
3. Configure the desired test scenario in the model (step, spiral, disturbance, or parameter variation).
4. Run the simulation. When it finishes, the workspace should contain a `SimulationOutput` object named `out`.

## Generating Publication Figures

After a simulation run:

1. Open `Generate_Publication_Figures.m`.
2. Set the `scenario` variable to match the test you just ran. This string is used directly as the output folder name, so it must match exactly:
```matlab
   scenario = 'Spiral';   % one of:
                          % 'Step', 'Step_Disturbance',
                          % 'Spiral', 'Spiral_Disturbance',
                          % 'ParamVariation_20pct'
```
3. Run the script. Outputs are written to:
02_MATLAB_Simulink/Results/figures_export_<scenario>/

Each scenario folder contains vector PDF and 600 dpi PNG figures plus a CSV performance table (`Table1_ITAE_ControlEffort_<scenario>.csv`).

### Generated Figures

| Figure | Content |
|--------|---------|
| Joint Tracking | Desired vs. actual joint positions |
| Tracking Error | Per-joint tracking error over time |
| Sliding Surface | Sliding variables \(s_1, s_2, s_3\) |
| Torque | Control inputs \(\tau_1, \tau_2, F_3\) |
| Adaptive Gain | Disturbance vs. adaptive gain \(k_1\) (ASTSMC) |
| Cartesian Tracking | End-effector \(X\), \(Y\), and \(d_3\) |
| Spiral Tracking | XY path comparison (spiral scenarios) |

Performance metrics computed per controller: ITAE (per joint and total) and control effort (L2 norm and RMS).

## CAD

The SolidWorks assembly in `01_SolidWorks_CAD/Assemblies/` includes the base, two links, prismatic shaft/housing, joint housings, and dispensing nozzle. Individual components are in `01_SolidWorks_CAD/Parts/`.

## Manuscript

The primary write-up is in `03_Manuscript/`, provided as both `.docx` and `.pdf`. LaTeX source will be added under `03_Manuscript/LaTeX/` in a future update.

## Notes

- Simulink build artifacts (`slprj/`, `*.slxc`) are excluded via `.gitignore` and should not be committed.
- Always set `scenario` in `Generate_Publication_Figures.m` before running so outputs from different test runs do not overwrite each other.
