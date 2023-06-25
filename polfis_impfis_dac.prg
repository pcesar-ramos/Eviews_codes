'=================================================================
'=================================================================
'___________Deficit ajustado por el ciclo (Orientación de la Política Fiscal)___________
'=================================================================
'=================================================================
'Se utilizaron datos en términos nominales en millones de Bolivianos corrientes trim
close @all
cd "D:\UAEF_RAF\MEB2022\ciclicidad_polfis\impulso_fiscal" 
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'________________________IMPORTACIÓN DE LOS DATOS___________________________
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'_____________________________________________________________________
'Importamos la base de datos en excel (Variables en millones de Bolivianos corrientes)
import "Sector_fiscal 1990m01 2018m12.xlsx" range=DAC_FMI colhead=1 na="#N/A" @freq M 1990M01 @smpl @all
pagerename Untitled def_sup_glob_mensual

'Editamos y renombramos las variables 
delete mes ano ingresos_de_capital
'##################### PARA EL DEFICIT GLOBAL ############################# 
rename EGRESOS_TOTALES g 			'Egresos Totales
rename INGRESOS_TOTALES i			'Ingresos Totales
rename SUP__DEF__GLOBAL def		'Superavit y deficit global
delete def
'###################DETENTE ACA UN MOMENTO Y VE LA DEFINICION DEL DEFICIT OBSERVADO
'series defglob = i - g
series defglob = g - i
'##################### PARA EL DEFICIT CORRIENT########################### 
rename EGRESOS_CORRIENTES gcte
rename INGRESOS_CORRIENTES icte 
rename SUP__DEF__CORRIENTE defp 
rename EGRESOS_DE_CAPITAL gcap
delete defp gcap
series defprim =gcte - icte
series gcap = i - gcte  + defglob	
'#######################################################################
' Verificando si cuadran las cifras
series cero0=gcte - icte - defprim
series cero1=g - i - defglob
series cero2=gcte+gcap-i-defglob 

'TODAS LAS VARIABLES ESTAN EXPRESADAS EN MILLONES DE BOLIVIANOS (NOMINAL)
pagecreate(page=def_sup_glob_trimestre) q 1990Q1 2020Q4

copy(c=s) def_sup_glob_mensual\DEFGLOB *
copy(c=s) def_sup_glob_mensual\DEFPRIM * 
copy(c=s) def_sup_glob_mensual\I *
copy(c=s) def_sup_glob_mensual\G * 
copy(c=s) def_sup_glob_mensual\GCAP * 
copy(c=s) def_sup_glob_mensual\GCTE * 
copy(c=s) def_sup_glob_mensual\ICTE * 

'_____________________________________________________________________
'COPIAMOS EL PIB NOMINAL (LADO DEL GASTO) EN MILES DE BOLIVIANOS (NOMINAL)
pageload "DAC_model.xlsx" range=pib_nominal colhead=1 na="#N/A" @freq Q 1990Q1 @smpl @all
series ap_com = ((x + m)/pib)*100 
delete m x fbkf con01 g ve t
' Convirtiendo la serie a millones de Bs
series pibn = pib/1000
delete pib

pageselect def_sup_glob_trimestre
copy Dac_model\PIBN *
copy Dac_model\AP_COM *
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'_____________________TRATAMIENTO DE LAS VARIABLES_________________________
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'__________________________________________________________________________
'AJUSTE ESTACIONAL
pageselect def_sup_glob_trimestre
DEFGLOB.x13(save="d11", tf=1, arimasmpl="1990Q1 2020Q2")  @x11() 
DEFPRIM.x13(save="d11", tf=1, arimasmpl="1990Q1 2020Q2")  @x11() 
G.x13(save="d11", tf=1, arimasmpl="1990Q1 2020Q2")  @x11() 
GCAP.x13(save="d11", tf=1, arimasmpl="1990Q1 2020Q2")  @x11() 
GCTE.x13(save="d11", tf=1, arimasmpl="1990Q1 2020Q2")  @x11() 
I.x13(save="d11", tf=1, arimasmpl="1990Q1 2020Q2")  @x11() 
ICTE.x13(save="d11", tf=1, arimasmpl="1990Q1 2020Q2")  @x11() 
PIBN.x13(save="d11", tf=1, arimasmpl="1990Q1 2020Q2")  @x11()
AP_COM.x13(save="d11", tf=1, arimasmpl="1990Q1 2020Q2")  @x11()

delete DEFGLOB DEFPRIM G GCAP GCTE I ICTE PIBN ap_com

rename DEFGLOB_D11 defglob 
rename DEFPRIM_D11 defprim 
rename G_D11 g 
rename GCAP_D11 gcap 
rename GCTE_D11 gcte 
rename I_D11 i 
rename ICTE_D11 icte 
rename PIBN_D11 pib 
rename ap_com_d11 ap_com

'_________________________________________________________________________
'Trabajamos con estas variables en trimestrales

'_________________________________________________________________________
'pib.hpf(power=na) pibt @ pibc
'pib.hpf(lambda=900) pibt @ pibc
'pib.hpf(lambda=200) pibt @ pibc
pib.hpf(lambda=100) pibt @ pibc
'pib.hpf(lambda=1600) pibt @ pibc
'group series01 pib pibt
'freeze(PIB_ver) series01.line

'#######################################################
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'__________________________DEFICIT GLOBAL________________________________________
'__________________________________________________________________________________
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'#######################################################

pagecreate(page=DEF_GLOBAL) q 1990Q1 2020Q4
copy def_sup_glob_trimestre\DEFGLOB *
copy def_sup_glob_trimestre\G *
copy def_sup_glob_trimestre\I *
copy def_sup_glob_trimestre\PIB *
copy def_sup_glob_trimestre\PIBC *
copy def_sup_glob_trimestre\PIBT *
pageselect DEF_GLOBAL
series output_gap=((pib-pibt)/pibt)*100
'smpl 2006q1 2020q2

'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'_________________________DEFICIT AJUSTADO AL CICLO___________________________
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

'=================================================================
'Año base 2015q2 (Antes 2011q2)
'GT	IT	PIB	PIBT
'2015Q2  29619.399322506	 27721.136174115	 57449.5800989393	57415.0711542643
'---------------------------------------------------------------------------------------------------------------------------------
'=================================================================
'######################################################
'scalar a_0 =@elem(pib, @otod(2))
' Para crear un dato de un serie de fecha especifica
'================================================================'
'--------------------------------------------------------------------------------------------------------------------------------'
								scalar u = @dtoo("2013:4")
'--------------------------------------------------------------------------------------------------------------------------------'
'================================================================'
'######################################################
' __________________Estableciendo la fecha de año base___________________________ 
'######################################################
'G (g_0) 
scalar g_0 = @elem(g, @otod(u))
'I	(i_0) 
scalar i_0= @elem(i, @otod(u))
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

series dd = defglob - ((g_0/pibt_0)*pibt - (i_0/pib_0)*pib)

series def_dac=defglob-dd

def_dac.hpf dtt @ dct

'DEFICIT ESTRUCTURAL
series det = dd + dtt

' Gráfico Barras Apiladas
group barras dd dct dtt
freeze(Barras_api) barras.mixed stackedbar(1,2,3)



'__________________________________________________________________________
'##########################################################################
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'__________________________DEFICIT PRIMARIO_________________________________
'__________________________________________________________________________
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'##########################################################################
pagecreate(page=DEF_PRIMARIO) q 1990Q1 2020Q4
copy def_sup_glob_trimestre\DEFPRIM *
copy def_sup_glob_trimestre\GCTE *
copy def_sup_glob_trimestre\ICTE *
copy def_sup_glob_trimestre\PIB *
copy def_sup_glob_trimestre\PIBC *
copy def_sup_glob_trimestre\PIBT *
pageselect DEF_PRIMARIO
series output_gap=((pib-pibt)/pibt)*100
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
'________________________DEFICIT AJUSTADO AL CICLO_________________________
'%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

'=======================================================================
'Año base 2011q2
'GCTE ICTE	PIB	PIBT
'2011Q2	12209.8206644571	17500.9134027677	40675.69611065241	40700.56482718801
'----------------------------------------------------------------------------------------------------------------------------
'=======================================================================
' Definimos la fecha de año base 
								scalar u = @dtoo("2013:4")
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
'Elegir un año Base (donde el pib observado coincida con el tendencial)
'Gasto año base
'Ingreso año base
'PIB observado en el año base
'PIB tendencial en el año base

'GENERAMOS EL DEFICIT DISCRECIONAL EN TRIMESTRES

series dd = defprim - ((gcte_0/pibt_0)*pibt - (icte_0/pib_0)*pib)

series def_dac = defprim - dd

def_dac.hpf dtt @ dct

'DEFICIT ESTRUCTURAL
series det = dd + dtt



'================================================================='
'================================================================='
'===================== DÉFICIT GLOBAL Y PRIMARIO % PIB ================'
'================================================================='
'================================================================='

'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
'___________________________DEF_GLOBAL__________________________________________
'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

pagecreate(page=DEF_GLOBAL_PIB) q 1990Q1 2020Q4
pageselect DEF_GLOBAL
pageselect DEF_GLOBAL_PIB
copy DEF_GLOBAL\DCT *
copy DEF_GLOBAL\DD *
copy DEF_GLOBAL\DEFGLOB *
copy DEF_GLOBAL\DET *
copy DEF_GLOBAL\DTT *
copy DEF_GLOBAL\OUTPUT_GAP *
copy DEF_GLOBAL\PIB *
copy DEF_GLOBAL\PIBC *
copy DEF_GLOBAL\PIBT *

delete dct dtt pibc pibt

series dd_pib = ( dd / pib )*100
series defglob_pib = ( defglob / pib )*100
series det_pib = ( det / pib )*100
delete pib dd defglob det

group grupo01 dd_pib defglob_pib det_pib output_gap
freeze(Def_glob_PIB) grupo01.line

smpl 2011q1 2020q4
group grupo02 dd_pib defglob_pib
freeze(Discr_glob) grupo02.line

smpl 2011q1 2020q4
group series03 defglob_pib det_pib
freeze(graphi) series03.line 

'group barras dd_PIB dct_PIB 
'freeze(Barras_api) barras.mixed stackedbar(1,2,3)

'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
'___________________________DEF_PRIMARIO________________________________________
'$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
pagecreate(page=DEF_PRIM_PIB) q 1990Q1 2020Q4
pageselect DEF_PRIMARIO
pageselect DEF_PRIM_PIB
copy DEF_PRIMARIO\DCT *
copy DEF_PRIMARIO\DD *
copy DEF_PRIMARIO\DEFPRIM *
copy DEF_PRIMARIO\DET *
copy DEF_PRIMARIO\DTT *
copy DEF_PRIMARIO\OUTPUT_GAP *
copy DEF_PRIMARIO\PIB *
copy DEF_PRIMARIO\PIBC *
copy DEF_PRIMARIO\PIBT *

delete dct dtt pibc pibt

series dd_pib = ( dd / pib )*100
series defprim_pib = ( defprim / pib )*100
series det_pib = ( det / pib )*100
delete pib dd defprim det

group grupo01 dd_pib defprim_pib det_pib output_gap
freeze(Def_prim_PIB) grupo01.line

smpl 2011q1 2020q4
group grupo02 dd_pib defprim_pib
freeze(Discre_prim) grupo02.line

smpl 2011q1 2020q4
group series03 defprim_pib det_pib
freeze(graphi) series03.line 


'#######################################################'
'#######################################################'
'___________________________   Impulso Fiscal  ____________________________'
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


' Datos Anuales
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
def_des.mixed stackedbar(1,2,3) line(4)

group def_barra dd dct dtt defglob 
def_barra.mixed bar(1,2,3) line(4)

' Prueba Déficit Global menos sus componentes
series prueba = defglob - dct - dd - dtt
copy(link, c=s) DEF_PRIMARIO\PIB *
series dct_y=dct/pib*100
series dtt_y=dtt/pib*100
series dd_y=dd/pib*100
series dg_y=defglob/pib*100

stop
'_____________________________________________________________'
'_____________________________________________________________'
'________________Datos Anuales - Déficit Global________________'
'_____________________________________________________________'
'_____________________________________________________________'
pagecreate(page=Anual_Defglob_comp) a 1990 2020
copy(link, c=s) DEF_GLOBAL\DCT *
copy(link, c=s) DEF_GLOBAL\DD *
copy(link, c=s) DEF_GLOBAL\DEFGLOB *
copy(link, c=s) DEF_GLOBAL\DET *
copy(link, c=s) DEF_GLOBAL\DTT *
copy(link, c=s) DEF_GLOBAL\PIB *
copy(link, c=s) DEF_GLOBAL\PIBT *
copy(link, c=s) DEF_GLOBAL\PIBC *
wfsave(type=excelxml) "anual_defglob_comp.xlsx"
'===================================================================='
'===================================================================='
wfsave(2) "Modelo_def_est_dis.WF1"
'===================================================================='
'===================================================================='


