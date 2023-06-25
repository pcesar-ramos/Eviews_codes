close @all
cd "D:\Paulo Ramos\Nueva carpeta (3)\Unidad de Análisis y Estudios Fiscales UAEF\Investigador Econométrico\Balance discrecional SPNF\Ciclos componentes"
wfopen "spnf_1.wf1"
'Hallamos su filtro HP 
'==================================================================
'==================================================================
'  SOLO PARA EL CICLO
'==================================================================
'==================================================================
' Copiamos en una nueva carpeta
pagecreate(page=ciclo) a 1990 2020
%grupo = "B_S E_TC EC EK GNI HIDRO I_TC I_TRI IC IK IMP_HIDRO INT_D_INT INT_DEXT O_EC O_IC OTRA_EMP PENS SPERS PIB "
for %v {%grupo}
	copy Spnf_anual1\{%v} *
next
' Componentes cíclico y tendenciales HP de las variables
%variables = "B_S E_TC EC EK GNI HIDRO I_TC I_TRI IC IK IMP_HIDRO INT_D_INT INT_DEXT O_EC O_IC OTRA_EMP PENS SPERS PIB"
for %i {%variables}
	{%i}.hpf trend_{%i} @ cycle_{%i}
	group series11 cycle_{%i}
	freeze(ciclo_{%i}) cycle_{%i}.line
next
'perido de referencia
' Donde el PIB Potencial iguale al PIB Efectivo (Y_t=Y^*)
series ABS_GAP = @abs(cycle_PIB)
scalar min_gap = @min(abs_gap)
' Es el año 1993 con un valor de 9.34 CICLO 
' El año 2008 es con un valor de 60.72 
'================================================================'
								scalar u = @dtoo("2008")
' __________________Estableciendo la fecha de año base___________________________ 
for %i {%variables}
scalar sc_{%i}= @elem({%i}, @otod(u))
next
delete u
for %i {%variables}
scalar t0_{%i}= sc_{%i}/sc_pib
next
'__________________________________________________________________________________
'Elegir un año Base (donde el pib observado coincida con el tendencial)
'Gasto año base
'Ingreso año base
'PIB observado en el año base
'PIB tendencial en el año base
'============Calculando las tendencias de cada serie=====================
for %i {%variables}
series tend_{%i}=t0_{%i}*trend_pib
next
'==================================================================='
'============Calcuclando los ciclos de cada serie========================='
for %i {%variables}
series ciclo0_{%i}=t0_{%i}*cycle_pib
next
'============Calculando la parte discrecional de cada serie=====================
'==================================================================='
'==================================================================='
for %i {%variables}
series discre_{%i} = {%i} - ciclo0_{%i} - tend_{%i}
next
'===============Gráfico de los tres componentes=========================='
'=================================================================='
for %i {%variables}
group plot_{%i} discre_{%i} {%i} ciclo0_{%i} tend_{%i}
freeze(graf_{%i}) plot_{%i}.line
next


pagecreate(page=graficos) a 1990 2020
%grupito = "B_S E_TC EC EK GNI HIDRO I_TC I_TRI IC IK IMP_HIDRO INT_D_INT INT_DEXT O_EC O_IC OTRA_EMP PENS SPERS"
for %v {%grupito}
	copy ciclo\ciclo0_{%v} *
	copy ciclo\tend_{%v} *
		copy ciclo\discre_{%v} *
next
' Exportar gráficos
wfsave(type=excelxml) graficos.xlsx


'=================================================================='
stop

'=================================================================='
'=================================================================='
'=================================================================='
stop
'=================================================================='
pagecreate(page=series_anuales) a 1990 2020
%grupito = "B_S E_TC EC EK GNI HIDRO I_TC I_TRI IC IK IMP_HIDRO INT_D_INT INT_DEXT O_EC O_IC OTRA_EMP PENS SPERS"
for %v {%grupito}
	copy ciclo\tend_{%v} *
	copy ciclo\ciclo0_{%v} *
next

'Hacemos la participación relativa entre (DD+DT) y (DC)
for %v {%grupito}
	SERIES ciclo_{%v} = (ciclo0_{%v}/(tend_{%v}+ciclo0_{%v}))*100
	SERIES tede_{%v} = (tend_{%v}/(tend_{%v}+ciclo0_{%v}))*100
next

' creamos y exportamos las participaciones de cada item
pagecreate(page=participa) a 1990 2020
%grupito = "B_S E_TC EC EK GNI HIDRO I_TC I_TRI IC IK IMP_HIDRO INT_D_INT INT_DEXT O_EC O_IC OTRA_EMP PENS SPERS"
for %v {%grupito}
	copy series_anuales\ciclo_{%v} *
	copy series_anuales\tede_{%v} *
next

wfsave(type=excel) participa.xls



for 
GROUP prueba_{%i} CICL_{%i} CICLE_{%i} TEND_{%i} TENDE_{%i} {%i} CYCLE_{%i}  TREND_{%i} 
prueba_{%i}.line(m)
next

'*********************************************************************************
pagecreate(page=graficos) a 1990 2020
%grupito = "B_S E_TC EC EK GNI HIDRO I_TC I_TRI IC IK IMP_HIDRO INT_D_INT INT_DEXT O_EC O_IC OTRA_EMP PENS SPERS"
for %v {%grupito}
	copy ciclo\ciclo0_{%v} *
	copy ciclo\tend_{%v} *
		copy ciclo\discre_{%v} *
next




'''' hasta aca
stop



'==================================================================='
'Aca vamos a observar cada serrie en gráfico'
for 
GROUP prueba_{%i} CICL_{%i} CICLE_{%i} TEND_{%i} TENDE_{%i} {%i} CYCLE_{%i}  TREND_{%i} 
prueba_{%i}.line(m)
next



pagecreate(page=trend_obs) a 1990 2020
%grupo = "B_S E_TC EC EK GNI HIDRO I_TC I_TRI IC IK IMP_HIDRO INT_D_INT INT_DEXT O_EC O_IC OTRA_EMP PENS SPERS PIB"
for %k {%grupo}
	copy Spnf_anual1\{%k} *
next

' Gráfico de la Tendencia y la variable observada
%varian = "B_S E_TC EC EK GNI HIDRO I_TC I_TRI IC IK IMP_HIDRO INT_D_INT INT_DEXT O_EC O_IC OTRA_EMP PENS SPERS PIB"

for %j {%varian}
	{%j}.hpf trend_{%j} @ cycle_{%j}
	group serie_{%j} {%j} trend_{%j}
	freeze(tendencia_{%j}) serie_{%j}.line
next


