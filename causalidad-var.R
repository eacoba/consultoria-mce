library(vars)
library(forecast)
library(tseries)
library(imputeTS)
library(zoo)

# Cargar las librerías
library(ggplot2)
library(dplyr)
library(ggnetwork)
library(grid)


path <- "C:/Users/ecoba/Desktop/SIMU-RESULT/"

datos <- read.csv(paste(path, "descriptors-5dim-GROMOS54a7-2.csv", sep = ""))
datos <- datos[seq(1, nrow(clima_full), by = 5), ]

colnames(datos)

### ¿La temperatura y la precipicitación son causales en el sentido de Granger?

pc1 <- datos[,"PC1"]
pc2 <- datos[, "PC2"]
rg <- datos[, "rg"]
sasa <- datos[, "sasa"]
distmean <- datos[, "dist.mean"]
K <- ncol(datos)

png(paste(path, "descriptors2.png", sep = ""), width = 5400, height = 400 * K, res = 300)
layout(matrix(1:(K * 2), nrow = 2, ncol = K, byrow = TRUE))
for(i in 1:K){
  ts.plot(datos[,i]) # graficamos las series originales
  title(colnames(datos)[i])
}

for(i in 1:K){
  ts.plot(diff(datos[,i])) # graficamos la primera diferencia de las series
  title(colnames(datos)[i])
}
dev.off()

# 1.2 eliminamos la estacionalidad de las series

pc1_diff <- datos[,"PC1"]
pc2_diff <- datos[, "PC2"]
rg_diff <- datos[, "rg"]
sasa_diff <- datos[, "sasa"]
distmean_diff <- datos[, "dist.mean"]

# 1.3 verificamos estacionalidad

adf_test1 <- adf.test(pc1_diff)
adf_test2 <- adf.test(pc2_diff)
adf_test3 <- adf.test(rg_diff)
adf_test4 <- adf.test(sasa_diff)
adf_test5 <- adf.test(distmean_diff)

adf_test1
adf_test2
adf_test3
adf_test4
adf_test5

data_var <- ts(data.frame(pc1_diff, pc2_diff, rg_diff, sasa_diff, distmean_diff))

# 2. seleccionar los rezagos optimos con las variables en niveles
lag_max <- 20
type <- "const" # el regresor incluye el término constante pues 
crit <- "AIC(n)"
p <- VARselect(data_var, lag.max = lag_max, type = type)$selection[crit]
p

# 3. estimar el VAR
varm <- VAR(data_var, p = p, type = type)
summary(varm)

# 4. pruebas de residuos
serial.test(varm, lags.pt = 2*p) # hay correlación serial

# 5. pruebas de causalidad de granger
arch.test(varm) # no hay homocedasticidad serial

# Número de variables
K <- ncol(datos)
nombres <- colnames(varm$y)

# Inicializar listas para almacenar resultados
var1 <- c()
var2 <- c()
p_values <- c()


# Evaluar la causalidad de cada variable sobre las demás
for (i in 1:K) {
  for (j in 1:K) {
    if (i != j) {
      resultado <- causality(varm, cause = nombres[i])$Granger$p.value
      var1 <- c(var1, nombres[i])
      var2 <- c(var2, nombres[j])
      p_values <- c(p_values, resultado)
    }
  }
}

# Crear dataframe de resultados
df_causalidad <- data.frame(
  causa = var1,
  efecto = var2,
  p_value = p_values
)

# Graficar relaciones de causalidad entre variables
grafico <- df_causalidad %>%
  ggplot(aes(x = causa, y = efecto)) +
  geom_point(aes(size = -log10(p_value), color = p_value < 0.05)) +
  geom_segment(aes(x = causa, xend = causa, y = efecto, yend = efecto),
               arrow = arrow(length = unit(0.2, "inches")),
               size = 0.3) +
  scale_color_manual(values = c("red", "blue"),
                     labels = c("No Significativo", "Significativo")) +
  labs(title = "Relaciones de Causalidad de Granger",
       x = "Variable Causante",
       y = "Variable Causada",
       color = "Causalidad",
       size = "Significancia\n(-log10 p-value)") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Guardar la figura
ggsave(paste0(path, "causalidad_granger.png"), plot = grafico, width = 8, height = 6, dpi = 300)


# Gráfico de red simple
grafico <- dfcausalidad %>%
  ggplot(aes(x = variable1, y = variable2)) +
  geom_point(aes(size = -log10(p_value), color = p_value < 0.05)) +
  geom_segment(aes(xend = variable2, yend = variable1), 
               arrow = arrow(length = unit(0.2, "inches"))) +
  scale_color_manual(values = c("red", "blue"), 
                     labels = c("No Significativo", "Significativo")) +
  labs(title = "Causalidad de Granger",
       x = "Variable Causante",
       y = "Variable Causada",
       size = "Significancia (-log10 p-value)") +
  theme_minimal()

ggsave(paste(path, "causalidad_granger.png", sep = "") , plot = grafico, width = 8, height = 6, dpi = 300)

