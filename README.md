# Carbon Emissions Analysis of Commercial Office Buildings

R-based regression analysis identifying which characteristics of commercial office buildings drive carbon emissions, and quantifying whether energy retrofits become more or less effective as building size grows. Prepared for the Kansas City Office of Sustainability.

## Business Problem

The Kansas City Office of Sustainability is evaluating policies to reduce CO₂ emissions from large commercial office buildings. The city wants to know which building characteristics are most closely associated with annual emissions, and whether energy retrofits change how building size affects emissions.

**Research Questions:**
1. Which characteristics of commercial buildings are most closely associated with carbon emissions?
2. Is an energy retrofit an effective way to reduce emissions when compared with other building characteristics?

## Dataset

120 commercial office buildings, one response variable and five predictors:

| Variable | Type | Description |
|---|---|---|
| `Emissions_tons` | Continuous (response) | Annual CO₂ emissions, in metric tons |
| `FloorArea_kSqFt` | Continuous | Building size, in thousands of sq ft |
| `EnergyStarScore` | Continuous | Energy efficiency rating |
| `RetrofitStatus` | Categorical (nominal) | Whether the building has undergone an energy retrofit (dummy-coded, "Retrofit" as reference) |
| `TransitScore` | Continuous | Public transit accessibility score |
| `OccupancyRate` | Continuous | Average annual occupancy rate |

Data were cleaned (missing/null values removed, types corrected) and `RetrofitStatus` was dummy-coded for regression.

## Methodology

Three models were fit in R, in increasing order of complexity:

1. **Simple linear regression** — emissions ~ floor area only
2. **Multiple regression (main effects)** — emissions ~ floor area + Energy Star score + retrofit status + transit score + occupancy rate
3. **Interaction model** — main effects plus a floor area × retrofit status interaction, to test whether retrofit effectiveness depends on building size

## Results

| Model | R² | Adj. R² | Key Result |
|---|---|---|---|
| Simple linear regression (floor area only) | 0.364 | 0.359 | Floor area alone explains 36.4% of emissions variance |
| Multiple regression (main effects) | 0.599 | 0.582 | Floor area, Energy Star score, and retrofit status all statistically significant (p < 0.05) |
| Interaction model (floor area × retrofit) | 0.743 | 0.729 | Interaction term highly significant (p = 1.71e-12); best-fitting model |

**Correlations with emissions:** floor area 0.603 · occupancy rate 0.148 · transit score 0.060 · Energy Star score −0.072

**Interaction model equation:**
`Yhat = 37.30 + 1.125(floor area) + 36.99(retrofit) − 0.624(Energy Star score) − 0.036(transit score) − 0.055(occupancy rate) − 0.798(floor area × retrofit)`

The negative interaction coefficient (−0.798) means the emissions-reducing effect of a retrofit grows as building size increases — retrofits deliver a bigger benefit in larger buildings.

**Example — marginal retrofit effect at 150,000 sq ft:**
`36.99 + (−0.798 × 150) = −82.66 tons` — retrofitting a building this size is predicted to cut emissions by ~82.7 tons.

**Example — full prediction** for a 150,000 sq ft, retrofitted building with an Energy Star score of 80, transit score of 85, and 90% occupancy: **≈65.5 tons of predicted annual emissions.**

## Key Findings

- **Square footage and retrofit status are the two strongest drivers of emissions.** Square footage is consistently associated with higher emissions; retrofit status is consistently associated with lower emissions.
- **Retrofit effectiveness scales with building size.** The interaction model shows retrofits reduce emissions more in larger buildings than in smaller ones — a >80-ton reduction for a 150,000 sq ft building.
- **A single-predictor model is not sufficient for policy decisions.** Floor area alone explains only 36.4% of emissions variance; the full interaction model raises this to 74.3%.
- Transit score and occupancy rate were not statistically significant predictors once other variables were controlled for.

## City Planning Recommendations

- **Prioritize retrofit programs for buildings larger than 100,000 sq ft**, where retrofits produce the greatest emissions reductions.
- **For smaller buildings, focus on reducing square footage or improving space efficiency** rather than mandating retrofits, since the emissions benefit is smaller at this scale.
- **Consider Energy Star Score as an additional screening variable** when identifying buildings most likely to benefit from intervention, since higher scores are associated with lower emissions.

## Repo Contents

| File | Description |
|---|---|
| `Carbon_Emissions_R_Code_and_Math_Functions.docx` | Full write-up: R code, model output, statistical interpretation, and hand-calculated predictions |
| `Carbon_Emissions_R_Data_Analysis.pptx` | Executive summary slide deck |

## Tools

R · `lm()` linear/multiple regression · `model.matrix()` dummy coding · base R plotting

## Author

Colin Haley — July 2026
