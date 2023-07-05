'*******************************************************************'
'--------------------------------------------------------------------------------'
'--- Estimación del efecto Crowding in para Bolivia ---'
'--------------------------------------------------------------------------------'
'*******************************************************************'
close @all
cd "C:\Users\Admin\Desktop\Modelo Crowding In Bolivia\Crowding in estimation"
'_______________________________________________________________________'
' Importamos las variables
import "crowding_in.xlsx" range=Sheet1 colhead=1 na="#N/A" @freq Q @id @date(_date_) @smpl @all
delete _date_

'_______________________________________________________________________'
' Renombramos las variables
rename G_CAP_R_D11 g_cap 
rename G_CTE_R_D11 g_cte
rename I_PRIV_R_D11 i_priv 
rename PIBR_D11 pib 
rename TRANSF_R_D11 transf 
rename G_R_D11 G_R
rename I_PUB_R_D11 I_PUB

'_______________________________________________________________________'
'Realizamos el gráfico de las variables con ajuste estacional
'%variables = " G_CAP G_CTE g_interes I_PRIV PIB TRANSF  "
'	for %j {%variables}
'		freeze(graph_{%j}) {%j}.line
'	next

'_______________________________________________________________________'
'Transformamos las variables en Logaritmos 
%variables = "int_deu G_CAP G_CTE I_PRIV PIB TRANSF  I_PUB G_R"
	for %j {%variables}
		series l_{%j} = log({%j})
	next

'_______________________________________________________________________'
' Gráficos de las variables en NIVELES
SMPL 2006Q1 2019Q4
group series01 G_CAP G_CTE I_PRIV PIB TRANSF int_deu I_PUB G_R
freeze(graph_niveles) series01.line
' Gráficos de las variables en LOGARITMOS
group series02 L_G_CAP L_G_CTE l_int_deu L_I_PRIV L_PIB L_TRANSF  L_I_PUB L_G_R
freeze(graph_log) series02.line

'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
' ESTIMACIÓN DEL CROWDING IN - VARIABLES EN LOGARITMOS
pagecreate(page=Crowding_in_log) q 1990Q1 2020Q2
copy Crowding_in\L_G_CAP *
copy Crowding_in\L_G_CTE *
copy Crowding_in\L_I_PRIV *
copy Crowding_in\L_PIB *
copy Crowding_in\L_TRANSF *
copy Crowding_in\l_int_deu *
copy Crowding_in\L_I_PUB 
copy Crowding_in\L_G_R

pagestruct(start=2006Q1, end=2019Q4)

' Regresión MCO
equation eq_ols.ls l_i_priv c L_G_CAP L_G_CTE L_PIB L_TRANSF l_int_deu 
' Regresión GMM
equation eq_gmm.gmm(method=converge, instwgt=hac) l_i_priv l_int_deu l_g_cte l_g_cap l_pib l_transf  l_i_priv(-1) @  l_int_deu l_g_cte l_g_cap l_pib l_transf   l_i_priv(-1)
'_______________________________________________________________________'
' Causalidad de Granger
'group series_granger L_I_PRIV L_G_CAP L_G_CTE L_G_INTERES L_PIB L_TRANSF 
'series_granger.cause(5)
'series_granger.save(t=tex, texspec, clipboard) "d:\paulo ramos\nueva carpeta (3)\crowding in estimation\tabla_granger.tex"
'series_granger.save(t=csv) "d:\paulo ramos\nueva carpeta (3)\crowding in estimation\tabla_granger.csv"
equation eq_gmm.gmm(method=converge, instwgt=hac) l_i_priv c l_int_deu l_g_cte l_g_cap l_pib l_transf  l_i_priv(-1) @   l_int_deu l_g_cte l_g_cap l_pib l_transf   l_i_priv(-1)   l_g_cap(-1) l_g_cte(-1)
'***********************************************************************************'
'***********************************************************************************'
' Modelo VAR Crowding In
var var_1.ls 1 1 l_i_priv l_g_cap l_g_cte l_pib  @ c l_transf l_int_deu 
'var_1.impulse(20, imp=gen) l_i_priv @imp l_g_cap l_g_cte l_pib
'var_1.impulse(16, imp=gen) l_i_priv @imp l_g_cap l_g_cte l_pib
freeze(VAR_FIR_1) var_1.impulse(20) l_i_priv @imp l_g_cap l_g_cte l_pib
freeze(VAR_FIR__) var_1.impulse(20, g) l_i_priv @imp l_g_cap l_g_cte l_pib
'-----------------------------------------------------------------------------------------------------'
'************************************************************************************'
' Modelo VAR 01 Crowding in - estimación del VAR con dos rezagos
var var01.ls 1 2 d(l_i_priv) d(l_g_cap) d(l_g_cte) d(l_pib)  @ c l_transf l_int_deu 
' Selección de rezagos para el modelo VAR
	for !j=2 to 8
		freeze(lag_criteria_!j) var01.laglen(!j)
	next
' Rezago óptimo el 2 rezagos
var var02.ls 1 2 d(l_i_priv) d(l_g_cap) d(l_g_cte) d(l_pib)  @ c l_transf l_int_deu 
freeze(VAR02_FIR) var02.impulse(12, g, imp=gen) d(l_i_priv) @imp d(l_g_cap) d(l_g_cte) d(l_pib)
	for !j=2 to 8
		freeze(lag_criteria!j) var02.laglen(!j)
	next

'**********************************************************************************
' ESTIMACIÓN DEL MODELO VAR Y VEC PARA EL CROWDING IN
'**********************************************************************************
'---------------------------------------------------------------------------------------------------------'
'Estimación VAR con dos rezagos
var var03.ls 1 2  l_i_priv l_i_pub l_g_r l_pib  @ c l_transf l_int_deu 
' Impulsos generalizados - gráfico multiple
'freeze(FIR_VAR03) var03.impulse(20, imp=gen) l_i_priv @imp l_i_pub l_g_r l_pib
' Tosdos los gráficos en uno
freeze(FIR_VAR_3) var03.impulse(20, g, imp=gen) l_i_priv @imp l_i_pub l_g_r l_pib
'---------------------------------------------------------------------------------------------------------'
' Estimación del una Modelos VEC con una ecuación de cointegración
var vec01.ec(c,1) 1 2  l_i_priv l_i_pub l_g_r l_pib  @ l_transf l_int_deu 
freeze(FIR_VEC_1) vec01.impulse(20, g, imp=gen) l_i_priv @imp l_i_pub l_g_r l_pib
'---------------------------------------------------------------------------------------------------------'
' Estimación VAR con FIR suavizadas con Variables Fiscales
freeze(FIR_VAR_1) var_1.impulse(20, imp=gen, se=a) l_i_priv @imp l_g_cap l_g_cte l_pib
freeze(FIR_VAR_1_M) var_1.impulse(20, g, imp=gen) l_i_priv @imp l_g_cap l_g_cte l_pib
'---------------------------------------------------------------------------------------------------------'
' Estimación VEC con 3 rezagos  sin transferencias ni intereses de deuda
var vec02.ec(c,1) 1 3 l_i_priv l_i_pub l_g_r l_pib  @ @trend 
freeze(FIR_VEC_2) vec01.impulse(g) l_i_priv @imp l_i_pub l_g_r l_pib
'Estimación SVEC con 3 rezagos con restricciones 
var vec03.ec(c,1) 1 3  l_i_priv l_i_pub l_pib 
vec03.append(coint) B(1,3)=0
var vec03.ec(c,1, restrict) 1 3  l_i_priv l_i_pub l_pib 
FREEZE(FIR_VEC_3) vec03.impulse(20, imp=gen) l_i_priv @imp l_i_pub l_pib


'**********************************************************************************
' ESTIMACIÓN ECUACIÓN DE COINTEGRACIÓN
'**********************************************************************************
GROUP SERIES_COINT L_PIB  L_I_PUB L_I_PRIV
freeze(Cointegration) SERIES_COINT.COINT(C, 1 8)


' Ecuación OLS estimada para el "Crawling In" de la inversión pública sobre la inversión privada
equation eq_ols_1.ls l_i_priv c l_g_cap  l_pib
equation eq_ols_hac.ls(cov=hac) l_i_priv c l_g_cap  l_pib

var01.ls 1 2  d(l_i_priv) d(l_g_cap) d(l_g_cte) d(l_pib)  @ c l_transf l_int_deu 
' VAR Converge
var var_1_raiz.ls 1 2 d(l_i_priv) d(l_g_cap) d(l_g_cte) d(l_pib) 
freeze(var_fi_var) var_1_raiz.impulse(20, a, g) d(l_i_priv) @imp d(l_g_cap) d(l_g_cte) d(l_pib)

' Var Modelo final
var var01_con_ajustado.impulse(20, a, g) d(l_i_priv) @imp d(l_g_cap) d(l_pib)


