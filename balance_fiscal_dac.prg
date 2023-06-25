'=================================================================
'___________Deficit ajustado por el ciclo (Orientación de la Política Fiscal)___________
'=================================================================
'Se utilizaron datos en términos nominales en millones de Bolivianos corrientes trim
'close @all
'cd "D:\Paulo Ramos\Nueva carpeta (3)\Modelo Déficit Estructural y Discresional" 
%path = @runpath
cd %path
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'________________________IMPORTACIÓN DE LOS DATOS___________________________
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'Importamos la base de datos en excel (Variables en millones de Bolivianos corrientes 1990m01 - 2020m12)
import "Dataspnf.xlsx" range=Hoja2 colhead=1 na="#N/A" @freq M 1990M01 @smpl @all

'Editamos y renombramos las variables 
	delete cuenta
'################### PARA EL DEFICIT GLOBAL, CORRIENTE Y DE CAPITAL##################### 
	rename EGRESOS_TOTALES gtot 		'Egresos Totales
	rename INGRESOS_TOTALES itot			'Ingresos Totales
	rename egresos_corrientes gcte			'Egresos corrientes
	rename ingresos_corrientes icte 			'Ingresos corrientes
	rename egresos_de_capital gcap		'Egresis de capital
	rename ingresos_DE_CAPITAL icap  	'Ingresos de capitalss
'################### GENERAMOS LAS SERIES DE LOS BALANCES #######################
'series defglob = i - g
	series defglob = gtot - itot
	series defcte = gcte - icte
	series defcap = gcap - icap
' Verificando si cuadran las cifras
	series prueba_0 = defglob + SUP__DEF__GLOBAL 
	series prueba_1 = defcte + SUP__DEF__CORRIENTE 
'#######################################################################
'		TODAS LAS VARIABLES ESTAN EXPRESADAS EN MILLONES DE BOLIVIANOS (NOMINAL) EN TRIMESTRES
'#######################################################################
pagecreate(page=def_all_trim) q 1990Q1 2020Q4

copy(link, c=s) Dataspnf\DEFCAP *
copy(link, c=s) Dataspnf\DEFCTE *
copy(link, c=s) Dataspnf\DEFGLOB *
copy(link, c=s) Dataspnf\GCAP *
copy(link, c=s) Dataspnf\GCTE *
copy(link, c=s) Dataspnf\GTOT *
copy(link, c=s) Dataspnf\ICAP *
copy(link, c=s) Dataspnf\ICTE *
copy(link, c=s) Dataspnf\ITOT *
group series_deficit DEFCAP DEFCTE 
freeze(graphs) series_deficit.line
'_____________________________________________________________________
'COPIAMOS EL PIB NOMINAL (LADO DEL GASTO) EN MILES DE BOLIVIANOS (NOMINAL)
pageload "DAC_model.xlsx" range=pib_nominal colhead=1 na="#N/A" @freq Q 1990Q1 @smpl @all
delete m x fbkf con01 g ve t
' Convirtiendo la serie a millones de Bs
series pibn = pib/1000
' Eliminamos la variable en miles y nos quedamos en millones de bolivianos
delete pib
' Copiamos el PIB a la Página con la que estamos trabajando
pageselect def_all_trim
copy Dac_model\PIBN *
' Renombramos la variable PIBN a PIB
rename pibn pib
'_________________________________________________________________________
'Trabajamos con estas variables en trimestrales
'==========================================================
'                 Calculamos el PIB tendencia y el PIB  ciclo mediante el HP Filter
'==========================================================
'_________________________________________________________________________
pib.hpf(lambda=100) pibt @ pibc
' Para cambiar la etiqueta de las variables
pib.displayname Producto Interno Bruto
pibt.displayname Producto tendencial
' Renombramos al PIB como PIBT y PIBC
group series01 pib pibt
freeze(PIB_ver) series01.line
'pib.label
PIB_ver.axis font("Arial", 12) textcolor(black) 
' Cambiar color de cuadricula
'pib_VER.OPTIONS gridcolor(blue)
' Cambiar color de linea %%%%----------------%%%%%%%%%%
pib_ver.setelem(2) linecolor(@rgb(175,238,238))
'pib_ver.setelem(2) linecolor(orange)
pib_ver.setelem(1) linecolor(orange)
' Para agrega sombreaod a la serie en una determinanda fecha
pib_ver.draw(shade, bottom, @rgb(255,0,0)) 2006 2019
' Agregar una line horizontal con valores del eje izquierdo
'pib_ver.draw(line, left, @rgb(255,0,0)) 50000
pib_ver.draw(line, left) 55000
' Agregar una linea verticial con valores en el eje del fondo
pib_ver.draw(line, bottom) 2005
stop
'#######################################################
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'__________________________DEFICIT GLOBAL________________________________________
'__________________________________________________________________________________
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'#######################################################
pagecreate(page=DEF_GLOBAL) q 1990Q1 2020Q4
copy def_all_trim\DEFGLOB *
copy def_all_trim\GTOT *
copy def_all_trim\ITOT *
copy def_all_trim\PIB *
copy def_all_trim\PIBC *
copy def_all_trim\PIBT *
pageselect DEF_GLOBAL
series gap=((pib-pibt)/pibt)*100
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'_________________________CORRECCIÓN CÍCLICA AL DEF___________________________
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'=================================================================
'######################################################
'scalar a_0 =@elem(pib, @otod(2))
' Para crear un dato de un serie de fecha especifica
'================================================================'
'--------------------------------------------------------------------------------------------------------------------------------'
								scalar u = @dtoo("2013:3")
'--------------------------------------------------------------------------------------------------------------------------------'
'================================================================'
'######################################################
' __________________Estableciendo la fecha de año base___________________________ 
'######################################################
'G (g_0) 
scalar gtot_0 = @elem(gtot, @otod(u))
'I	(i_0) 
scalar itot_0= @elem(itot, @otod(u))
'PIB (pib_0) 
scalar pib_0= @elem(pib, @otod(u))
'PIBT (pibt_0)   
scalar pibt_0= @elem(pibt, @otod(u))
delete u
'__________________________________________________________________________________
'Elegir un año Base (donde el pib observado coincida con el tendencial)
'Gasto año base
'Ingreso año base
'PIB observado en el año base
'PIB tendencial en el año base

'GENERAMOS EL DEFICIT DISCRECIONAL EN TRIMESTRES
series dd = defglob - ((gtot_0/pibt_0)*pibt - (itot_0/pib_0)*pib)
series def_dac=defglob-dd
def_dac.hpf dtt @ dct
'DEFICIT ESTRUCTURAL
series det = dd + dtt

' Gráfico DÉFICIT DISCRECIONAL, CÍCLICO Y TENDENCIAL 
smpl 2012q1 2020q4
group barras_defglob dd dct dtt defglob
freeze(bar_plot_global) barras_defglob.mixed bar(1,2,3) line(4)
'__________________________________________________________________________
'################################################
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'__________________________DEFICIT CORRIENTE_____________________________
'__________________________________________________________________________
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'################################################
pagecreate(page=DEF_CORRIENTE) q 1990Q1 2020Q4
copy def_all_trim\DEFCTE *
copy def_all_trim\GCTE *
copy def_all_trim\ICTE *
copy def_all_trim\PIB *
copy def_all_trim\PIBC *
copy def_all_trim\PIBT *
pageselect DEF_CORRIENTE
series gap=((pib-pibt)/pibt)*100
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'_________________________CORRECCIÓN CÍCLICA AL DEF___________________________
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'=======================================================================
' Definimos la fecha de año base 
								scalar u = @dtoo("2013:3")
'#################################################
'G (gcte_0) 
scalar gcte_0=@elem(gcte, @otod(u))
'I	(icte_0) 
scalar icte_0=@elem(icte, @otod(u))
'PIB (pib_0) 
scalar pib_0=@elem(pib, @otod(u))
'PIBT (pibt_0)   
scalar pibt_0=@elem(pibt, @otod(u))
delete u
'_________________________________________________________________________
'GENERAMOS EL DEFICIT DISCRECIONAL EN TRIMESTRES
series dd = defcte - ((gcte_0/pibt_0)*pibt - (icte_0/pib_0)*pib)
series def_dac = defcte - dd
def_dac.hpf dtt @ dct
'DEFICIT ESTRUCTURAL
series det = dd + dtt

' Gráfico DÉFICIT DISCRECIONAL, CÍCLICO Y TENDENCIAL 
smpl 2012q1 2020q4
group barras_defcte dd dct dtt defcte
freeze(bar_plot_corriente) barras_defcte.mixed bar(1,2,3) line(4)
'__________________________________________________________________________
'##########################################################################
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'__________________________DEFICIT CAPITAL_____________________________
'__________________________________________________________________________
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'##########################################################################
pagecreate(page=DEF_CAPITAL) q 1990Q1 2020Q4
copy def_all_trim\DEFCAP *
copy def_all_trim\ICAP *
copy def_all_trim\GCAP *
copy def_all_trim\PIB *
copy def_all_trim\PIBC *
copy def_all_trim\PIBT *
pageselect DEF_CAPITAL
series gap=((pib-pibt)/pibt)*100
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'_________________________CORRECCIÓN CÍCLICA AL DEF___________________________
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'=======================================================================
' Definimos la fecha de año base 
								scalar u = @dtoo("2013:3")
'#################################################
'G (gcte_0) 
scalar gcap_0=@elem(gcap, @otod(u))
'I	(icte_0) 
scalar icap_0=@elem(icap, @otod(u))
'PIB (pib_0) 
scalar pib_0=@elem(pib, @otod(u))
'PIBT (pibt_0)   
scalar pibt_0=@elem(pibt, @otod(u))
delete u
'_________________________________________________________________________
'GENERAMOS EL DEFICIT DISCRECIONAL EN TRIMESTRES
series dd = defcap - ((gcap_0/pibt_0)*pibt - (icap_0/pib_0)*pib)
series def_dac = defcap - dd
def_dac.hpf dtt @ dct
'DEFICIT ESTRUCTURAL
series det = dd + dtt
'================================================================='
' Gráfico DÉFICIT DISCRECIONAL, CÍCLICO Y TENDENCIAL 
smpl 2012q1 2020q4
group barras_defcap dd dct dtt defcap
freeze(bar_plot_capital) barras_defcap.mixed bar(1,2,3) line(4)

'======================================================================================'
'======================================================================================'
'======================================================================================'
'=========================== DÉFICIT GLOBAL Y CORRIENTE EN % PIB ============================'
'================================= EN PORCENTAJE DEL PIB ================================='
'======================================================================================'

'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
'___________________________DEF_GLOBAL EN % DEL PIB______________________________
'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

pagecreate(page=DEF_GLOBAL_PIB) q 1990Q1 2020Q4
pageselect DEF_GLOBAL
pageselect DEF_GLOBAL_PIB
copy DEF_GLOBAL\DCT *
copy DEF_GLOBAL\DD *
copy DEF_GLOBAL\DEFGLOB *
copy DEF_GLOBAL\DET *
copy DEF_GLOBAL\DTT *
copy DEF_GLOBAL\GAP *
copy DEF_GLOBAL\PIB *
copy DEF_GLOBAL\PIBC *
copy DEF_GLOBAL\PIBT *

series dd_pib = ( dd / pib )*100
series dct_pib = (dct/pib)*100
series dtt_pib = (dtt/pib)*100
series defglob_pib = ( defglob / pib )*100
series det_pib = ( det / pib )*100

delete dct dd defglob det dtt pibc pibt

' Gráfica para toda la muestra
smpl 2012q1 2020q4
group barras_defglob dd_pib dct_pib dtt_pib defglob_pib
freeze(bar_plot_def_global) barras_defglob.mixed bar(1,2,3) line(4)


wfsave(type=excel) "graphics\def_global_pib_trim.xls"
'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
'___________________________DEF_CORRIENTE % PIB____________________________________
'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
pagecreate(page=DEF_CORRIENTE_PIB) q 1990Q1 2020Q4
copy DEF_CORRIENTE\DCT *
copy DEF_CORRIENTE\DD *
copy DEF_CORRIENTE\DEFCTE *
copy DEF_CORRIENTE\DET *
copy DEF_CORRIENTE\DTT *
copy DEF_CORRIENTE\GAP *
copy DEF_CORRIENTE\PIB *
copy DEF_CORRIENTE\PIBC *
copy DEF_CORRIENTE\PIBT *

series dd_pib = ( dd / pib )*100
series dct_pib = (dct/pib)*100
series dtt_pib = (dtt/pib)*100
series defcte_pib = ( defcte / pib )*100
series det_pib = ( det / pib )*100

delete dct dtt dd defcte det pibc pibt

' Gráfica para toda la muestra
smpl 2012q1 2020q4
group barras_defcte dd_pib dct_pib dtt_pib defcte_pib
freeze(bar_plot_def_corriente) barras_defcte.mixed bar(1,2,3) line(4)

wfsave(type=excel) "graphics\def_corriente_pib_trim.xls"
'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
'_____________________________DEF_CAPITAL________________________________________
'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
pagecreate(page=DEF_CAPITAL_PIB) q 1990Q1 2020Q4
copy DEF_CAPITAL\DCT *
copy DEF_CAPITAL\DD *
copy DEF_CAPITAL\DEFCAP *
copy DEF_CAPITAL\DET *
copy DEF_CAPITAL\DTT *
copy DEF_CAPITAL\GAP *
copy DEF_CAPITAL\PIB *
copy DEF_CAPITAL\PIBC *
copy DEF_CAPITAL\PIBT *

series dd_pib = ( dd / pib )*100
series dct_pib = (dct/pib)*100
series dtt_pib = (dtt/pib)*100
series defcap_pib = ( defcap / pib )*100
series det_pib = ( det / pib )*100

delete dct dtt dd defcap det pibc pibt

' Gráfica para toda la muestra
smpl 2012q1 2020q4
group barras_defcap dd_pib dct_pib dtt_pib defcap_pib
freeze(bar_plot_def_capital) barras_defcap.mixed bar(1,2,3) line(4)

wfsave(type=excel) "graphics\def_capital_pib_trim.xls"


'#######################################################'
'#######################################################'
'#######################################################'
'#######################################################'
'__________________________________________________________________________________'
'____________________   LLEVAMOS TODO A DATOS ANUALES ________________________'
'__________________________________________________________________________________'
'#######################################################'
'#######################################################'
'#######################################################'
'_______________DEFICIT GLOBAL_EN AÑOS
pagecreate(page=D_GLOBAL) a 1990 2020


pagecreate(page=D_CORRIENTE) a 1990 2020


pagecreate(page=D_CAPITAL) a 1990 2020



' DATOS ANULES



'#######################################################'
'#######################################################'
'#######################################################'
'#######################################################'
'___________________________   Impulso Fiscal  ____________________________'
'#######################################################'
'#######################################################'
'#######################################################'
'#######################################################'
'__________________________________________________________________________________'
'___________________ IMPULSO FISCAL DEFICIT GLOBAL ______________________________'
' =================================================================='
pagecreate(page=ImpFis_Glob) q 2006Q1 2020Q4
' =================================================================='
copy DEF_GLOBAL_PIB\DD_PIB *
copy DEF_GLOBAL_PIB\OUTPUT_GAP *
series imp_fis_glob = d(dd_pib)
smpl 2011q1 2020q4
GROUP series01 imp_fis_glob output_gap
freeze(Impulso_fiscal) series01.mixed bar(1) line(2)


'____________________________________________________________________________________'
'_______________________IMPULSO FISCAL DEFICIT CORRIENTE__________________________'
' ==================================================================='
pagecreate(page=ImpFis_Prim) q 2006Q1 2020Q4
' ==================================================================='
copy DEF_PRIM_PIB\DD_PIB *
copy DEF_PRIM_PIB\OUTPUT_GAP *
series imp_fis_prim = d(dd_pib)
smpl 2011q1 2020q4
GROUP series01 imp_fis_prim output_gap
freeze(impulso_fiscal) series01.mixed bar(1) line(2)



'---------------------------------------------------------------------------------------------------------------------------------------'
pagecreate(page=Defglob_anual) a 1990 2020
copy(link, c=s) DEF_GLOBAL\DCT *
copy(link, c=s) DEF_GLOBAL\DD *
copy(link, c=s) DEF_GLOBAL\DEFGLOB *
copy(link, c=s) DEF_GLOBAL\DET *
copy(link, c=s) DEF_GLOBAL\DTT *
' Gráfica Barras apiladas anuales
smpl 1990 2020
group def_desco dd dct dtt 
freeze(barra_1) def_desco.mixed stackedbar(1,2,3)

group def_des dd dct dtt defglob 
freeze(graph_1) def_des.mixed stackedbar(1,2,3) line(4)

group def_barra dd dct dtt defglob 
FREEZE(GRAPH_2) def_barra.mixed bar(1,2,3) line(4)

' Prueba Déficit Global menos sus componentes
series prueba = defglob - dct - dd - dtt
copy(link, c=s) DEF_PRIMARIO\PIB *
series dct_y=dct/pib*100
series dtt_y=dtt/pib*100
series dd_y=dd/pib*100
series dg_y=defglob/pib*100
'===================================================================='
'===================================================================='
wfsave(2) "Modelo_def_est_dis.WF1"
'===================================================================='
'===================================================================='

