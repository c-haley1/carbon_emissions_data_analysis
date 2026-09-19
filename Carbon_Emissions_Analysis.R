# Carbon Emissions Analysis of Commercial Office Buildings
# Prepared for the Kansas City Office of Sustainability
# Author: Colin Haley
#
# Research Questions:
#   1. Which characteristics of commercial buildings are most closely
#      associated with carbon emissions?
#   2. Is an energy retrofit an effective way to reduce emissions when
#      compared with other building characteristics?


# install.packages("readxl")  
library(readxl)

# Update this path to point to your local copy of the data file
building_emissions_sustainability_Final <- read_excel("building_emissions_sustainability_Final.xlsx")

# ------------------------------------------------------------------------------
# 1. Data Preprocessing
# ------------------------------------------------------------------------------

# Remove missing/null values
building_emissions_sustainability_Final <- na.omit(building_emissions_sustainability_Final)

# Ensure correct data types
building_emissions_sustainability_Final$RetrofitStatus <- as.character(building_emissions_sustainability_Final$RetrofitStatus)

# ------------------------------------------------------------------------------
# 2. Exploratory Data Analysis
# ------------------------------------------------------------------------------

summary(building_emissions_sustainability_Final)

sd(building_emissions_sustainability_Final$Emissions_tons)
sd(building_emissions_sustainability_Final$FloorArea_kSqFt)
sd(building_emissions_sustainability_Final$EnergyStarScore)
sd(building_emissions_sustainability_Final$TransitScore)
sd(building_emissions_sustainability_Final$OccupancyRate)

# ------------------------------------------------------------------------------
# 3. Scatterplots and Visual Analysis
# ------------------------------------------------------------------------------

# Emissions by Square Footage: Strong Positive Relationship
plot(building_emissions_sustainability_Final$Emissions_tons,
     building_emissions_sustainability_Final$FloorArea_kSqFt,
     main = "Emissions by Square Footage", xlab = "Emissions",
     ylab = "Square Footage", col = "blue")

# Emissions by Energy Star Score: Weak Negative Relationship
plot(building_emissions_sustainability_Final$Emissions_tons,
     building_emissions_sustainability_Final$EnergyStarScore,
     main = "Emissions by Energy Star Score", xlab = "Emissions",
     ylab = "Energy Star Score", col = "blue")

# Emissions by Transit Score: Weak Positive Relationship
plot(building_emissions_sustainability_Final$Emissions_tons,
     building_emissions_sustainability_Final$TransitScore,
     main = "Emissions by Transit Score", xlab = "Emissions",
     ylab = "Transit Score", col = "blue")

# Emissions by Occupancy Rate: Weak Positive Relationship
plot(building_emissions_sustainability_Final$Emissions_tons,
     building_emissions_sustainability_Final$OccupancyRate,
     main = "Emissions by Occupancy Rate", xlab = "Emissions",
     ylab = "Occupancy Rate", col = "blue")

# ------------------------------------------------------------------------------
# 4. Correlation Analysis
# ------------------------------------------------------------------------------

# Correlation between emissions and square footage
cor(building_emissions_sustainability_Final$Emissions_tons,
    building_emissions_sustainability_Final$FloorArea_kSqFt)

# Correlation between emissions and Energy Star Score
cor(building_emissions_sustainability_Final$Emissions_tons,
    building_emissions_sustainability_Final$EnergyStarScore)

# Correlation between emissions and transit score
cor(building_emissions_sustainability_Final$Emissions_tons,
    building_emissions_sustainability_Final$TransitScore)

# Correlation between emissions and occupancy rate
cor(building_emissions_sustainability_Final$Emissions_tons,
    building_emissions_sustainability_Final$OccupancyRate)

# ------------------------------------------------------------------------------
# 5. Simple Linear Regression
# ------------------------------------------------------------------------------
# Regression equation: Yhat = 21.9775 + 0.60963 * (building size)

slr <- lm(Emissions_tons ~ FloorArea_kSqFt,
          data = building_emissions_sustainability_Final)
summary(slr)

# Slope interpretation: for every one square foot increase in building floor
# area, total emissions are estimated to increase by 0.60963 tons, holding
# all else constant.
#
# R-squared interpretation: R-squared = 0.364, meaning 36.4% of the variation
# in emissions can be explained solely by building square footage.
#
# Model sufficiency: this single-predictor model is NOT sufficient on its
# own for sustainability policy decisions. Additional predictors are needed.

# ------------------------------------------------------------------------------
# 6. Multiple Regression: Main Effects Model
# ------------------------------------------------------------------------------
# Regression equation: Yhat = 70.937 + 0.70045*(square footage)
#                            - 0.61628*(Energy Star Score) - 69.88*(No Retrofit)
#                            - 0.18029*(transit score) + 0.28365*(occupancy rate)

RetrofitDummy <- model.matrix(~RetrofitStatus,
                               data = building_emissions_sustainability_Final)

Model1 <- lm(Emissions_tons ~ FloorArea_kSqFt + EnergyStarScore +
               RetrofitStatus + TransitScore + OccupancyRate,
             data = building_emissions_sustainability_Final)
summary(Model1)

# Coefficient interpretations:
#   - Square footage: +1 unit -> +0.70045 tons of emissions, holding others constant
#   - Energy Star Score: +1 unit -> -0.61628 tons of emissions, holding others constant
#   - Retrofit status: a retrofitted building emits ~69.88 fewer tons than a
#     non-retrofitted building
#   - Transit score: +1 unit -> -0.18029 tons (not statistically significant)
#   - Occupancy rate: +1 unit -> +0.28365 tons (not statistically significant)
#
# Statistical significance: square footage, Energy Star Score, and retrofit
# status are all statistically significant at the 0.05 level.

# ------------------------------------------------------------------------------
# 7. Interaction Model: Does Retrofit Moderate the Size Effect?
# ------------------------------------------------------------------------------
# Regression equation: Yhat = 37.30354 + 1.12474*(square footage)
#                            + 36.99*(retrofit) - 0.62373*(Energy Star Score)
#                            - 0.03592*(transit score) - 0.05466*(occupancy rate)
#                            - 0.79772*(square footage x retrofit)

Model2 <- lm(Emissions_tons ~ FloorArea_kSqFt * RetrofitStatus +
               EnergyStarScore + TransitScore + OccupancyRate,
             data = building_emissions_sustainability_Final)
summary(Model2)

# Interpretation of key coefficients:
#   - Square footage: +1 unit -> +1.12474 tons of emissions, holding others constant
#   - Retrofit status: +36.99425 tons before accounting for the interaction
#     with square footage
#   - Interaction (square footage x retrofit): the square footage slope is
#     reduced by 0.79772 for retrofitted buildings, meaning the emissions
#     benefit of a retrofit grows as building size increases
#
# The interaction term is highly significant (p = 1.71e-12), and the
# interaction model is the best-fitting of the three (R-squared = 0.7426,
# Adjusted R-squared = 0.729).

# ------------------------------------------------------------------------------
# 8. Policy Interpretation of Retrofits
# ------------------------------------------------------------------------------
# Marginal effect of a retrofit on a 150,000 sq ft building
# (FloorArea_kSqFt = 150)

marginal_retrofit_effect <- 36.99425 + (-0.79772 * 150)
marginal_retrofit_effect
# Yhat = -82.66375
# Interpretation: applying a retrofit to a 150,000 sq ft building is expected
# to decrease emissions by approximately 82.66 tons. This large a reduction
# should strongly influence the city to incentivize retrofit programs for
# large buildings.

# ------------------------------------------------------------------------------
# 9. Prediction and Uncertainty
# ------------------------------------------------------------------------------
# Predicted emissions for a building with:
#   Floor area: 150,000 sq ft | Energy Star Score: 80 | Retrofit: Yes
#   Transit score: 85 | Occupancy rate: 90%

predicted_emissions <- 37.30354 + (1.12474 * 150) + (36.99425 * 1) +
  (-0.62373 * 80) + (-0.03592 * 85) + (-0.05466 * 90) + (-0.79772 * 150 * 1)
predicted_emissions
# Yhat = ~65.48 tons of predicted annual emissions

# Alternatively, using predict() with the fitted interaction model:
new_building <- data.frame(
  FloorArea_kSqFt = 150,
  RetrofitStatus = "Retrofit",
  EnergyStarScore = 80,
  TransitScore = 85,
  OccupancyRate = 90
)
predict(Model2, newdata = new_building)

# ------------------------------------------------------------------------------
# 10. Conclusion and Recommendations
# ------------------------------------------------------------------------------
# - Square footage and retrofit status are the two strongest drivers of
#   emissions. Square footage is consistently associated with higher
#   emissions; retrofit status is consistently associated with lower
#   emissions, and this benefit grows as building size increases.
#
# City Planning Recommendations:
#   1. Prioritize retrofit programs for buildings larger than 100,000 sq ft,
#      where retrofits produce the greatest emissions reductions.
#   2. For smaller buildings, focus on reducing square footage or improving
#      space efficiency rather than mandating retrofits.
#   3. Consider Energy Star Score as an additional screening variable when
#      identifying buildings most likely to benefit from intervention.
