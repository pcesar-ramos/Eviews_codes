' DESCOMPOSICION DEL CICLO, TENDENCIA Y DISCRECIONAL
close @all

cd "D:\Paulo Ramos\Nueva carpeta (3)\Descomp_Def"

import "D:\Paulo Ramos\Nueva carpeta (3)\Descomp_Def\update_spnf.xlsx" range="High to low" colhead=1 na="#N/A" @freq M 1990M01 @smpl @all
pagerename Update_spnf spnf_mensual
'_____________________________________________________________________'
'###############################################
' DATOS ANUALES  
pagecreate(page=spnf_anual) a 1990 2020
%variables = "X11 X12 X13 X14 X15 X16 X17 X18 X19 X20 X21 X22 X23 X24 X25 X26 X27 X28 X29 X30 X31 X32 X33 X34 "
	for %j {%variables}
		'series l_{%j} = log({%j})
		copy(link, c=s) spnf_mensual\{%j} *
	next

wfsave(type=excelxml) spnf_anual.xlsx


