' Efecto precio y efecto cantidad
' Unidad de Análisis y Estudios Fiscales (UAEF)
' Elaborado por Cesar Ramos
' x valor monetario (en millones de $us)
' y volumen (en miles de toneladas)
' z precios (en millones de $us / en miles de toneladas)
close @all

cd "D:\UAEF_RAF\Efecto precio y efecto cantidad\Database_bob\Efecto volumen y precio Balanza Comercial"

'%%%%%%%%%%%%%%%%%%%%
' %%%% ___Import dataset ___%%%%
'%%%%%%%%%%%%%%%%%%%%

import "Efecto precios y volumen Balanza Comercial.xlsx" range=sheet_dataset!$A$1:$E$24 colhead=1 na="#N/A" @freq A 2000 @smpl @all
delete tiempo 
wfdetails

'Calculamos el valor unitario
	series precio_x = valor_x / volumen_x
	series precio_m = valor_m / volumen_m

' Variación period-to-period for all variables
	series growth_valor_x=(valor_x / valor_x(-1)-1)*100
	series growth_valor_m=(valor_m / valor_m(-1)-1)*100

' % Variación en el valor monetario del producto "s"
'------------ Var_Valor_s = P_s1 * Q_s1 - P_s0 * Q_s0
   	series var_valor_x=precio_x * volumen_x - precio_x(-1) * volumen_x(-1)
	series var_valor_m=precio_m * volumen_m - precio_m(-1) * volumen_m(-1)

' Efecto de la variación en la cantidad comerciada sobre el cambio en el valor comerciado
'------------ efec_volum_s = P_s0 * [ Q_s1 - Q_s0 ]
   	series efec_volum_x=precio_x(-1) * ( volumen_x - volumen_x(-1) ) 
	series efec_volum_m=precio_m(-1) * ( volumen_m - volumen_m(-1) ) 
	
' Efecto de la variación en el precio sobre el cambio en el valor comerciado
'------------ efec_preci_s = Q_s1 * [ P_s1 - P_s0 ]
	series efec_preci_x=volumen_x * (precio_x - precio_x(-1) ) 
	series efec_preci_m=volumen_m * (precio_m - precio_m(-1) ) 

' Participación Efecto Volumen en la variación total del Valor del producto "s"
	series part_x = efec_volum_x / var_valor_x
	series part_m = efec_volum_m / var_valor_m
	series efecto_volumen_x = part_x * growth_valor_x
	series efecto_volumen_m = part_m * growth_valor_m

' Participación Efecto Precios en la variación total del Valor del producto "s"
	series part_xx = efec_preci_x / var_valor_x
	series part_mm = efec_preci_m / var_valor_m
	series efecto_precio_x = part_xx * growth_valor_x
	series efecto_precio_m = part_mm * growth_valor_m


' Valor total de la balanza comercial (Saldo Comercial)

'		Delta_SC_{t+n,t} = Delta_X_{t+n,t} - Delta_M_{t+n,t} 
'		Delta_SC_{t+n,t} = (PX_1 * QX_1 - PX_0 * QX_0) - (PM_1 * QM_1 - PM_0 * QM_0)
'		Delta_SC_{t+n,t} = PX_0 * [ QX_1 - QX_0 ] + QX_1 * [ PX_1 - PX_0 ] - PM_0 * [ QM_1 - QM_0 ] - QM_1 * [ PM_1 - PM_0 ]
'		----------------------------------------------------------------------
'		efec_volumen_X = PX_0 * [ QX_1 - QX_0 ]
'		efec_precio_X = QX_1 * [ PX_1 - PX_0 ]
'		efec_volumen_M = PM_0 * [ QM_1 - QM_0 ]
'		efec_precio_M = QM_1 * [ PM_1 - PM_0 ]

' Efecto volumen de las exportaciones e importaciones
	series effect_volume_x=precio_x(-1) * ( volumen_x - volumen_x(-1) ) 
	series effect_volume_m=precio_m(-1) * ( volumen_m - volumen_m(-1) ) 
' Efecto precio de las exportaciones e importaciones
	series effect_price_x=volumen_x * (precio_x - precio_x(-1) ) 
	series effect_price_m=volumen_m * (precio_m - precio_m(-1) ) 
' Valor total de la balanza comercial (Saldo Comercial)
	series saldo_comercial = ( precio_x * volumen_x - precio_x(-1) * volumen_x(-1) ) - ( precio_m * volumen_m - precio_m(-1) * volumen_m(-1) )

' Año de incio quitar, por missing values
'pagestruct(start = 2001)
pagestruct(start=2000 +1)

' Exportar resultados de la hoja de trabajo - Para solapar todas las hojas
' wfsave(type=excel, mode=update) test_new.xls byrow @keep au_gdpr
alpha misfechas = @datestr(@date, "YYYY")
wfsave(type=excelxml, mode=update) price_quantity_effect.xlsx range="ef_volumen!a1" @keep misfechas efecto_volumen_*
wfsave(type=excelxml, mode=update) price_quantity_effect.xlsx range="ef_precio!a1" @keep misfechas efecto_precio_*
wfsave(type=excelxml, mode=update) price_quantity_effect.xlsx range="var_valor!a1" @keep misfechas growth_valor_*

' Guardamos los datos
	wfsave(type=excelxml, mode=update) price_quantity_effect.xlsx range="saldo_comercial!a1" @keep misfechas  effect_volume_*  effect_price_*  saldo_comercial 
