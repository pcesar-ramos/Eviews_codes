' Estimaciones de la Brecha del Ahorro
' By: Cesar Ramos
close @all

wfopen "D:\UAEF_RAF\Brecha Ahorro interno\Modelo Brechas\estimaciones_review.wf1"

'Creating some variables
series infla = (ipc/ipc(-4)-1)*100
infla.displayname Inflación generada en Eviews

'ooo...$$$

'======================='
'===== Funciones de Ahorro ====='
'======================='
' Estimación del ahorro público
equation sg01.ls d(aho_gob) c d(cnsp) log(yn) 
equation sg02.ls d(aho_gob) c d(cnsp) log(yn) log(petro) log(mine)
equation sg03.ls d(aho_gob) c d(cnsp) log(yn) log(petro) log(mine) @isperiod("2020q2")
sg03.fit(e, g) ahorro_gob_f
' Estimación del ahorro privado
equation sp01.ls d(aho_priv) c d(yn) d(aho_priv(-1))
equation sp02.ls d(aho_priv) c d(yn) d(aho_priv(-1))  @isperiod("2019q4")
equation sp03.ls d(aho_priv) c d(yn) d(aho_priv(-1))  @isperiod("2019q4") d(tcr)
equation sp04.ls d(aho_priv) c d(yn) d(aho_priv(-1))  @isperiod("2019q4") d(log(tcr)) i_act(-4)
equation sp05.ls d(aho_priv) c d(yn) d(aho_priv(-1))  @isperiod("2019q4") 
sp05.fit(e, g) ahorro_pri_f
'======================='
'==== Funciones de Inversión ====='
'======================='
' Estimación de la inversión pública
equation ig01.ls log(ig_no) c log(rec) d(cnsp(-2)) log(yn) log(ig_no(-1))
equation ig02.ls log(ig_no) c log(rec) d(cnsp(-2)) log(yn) log(ig_no(-1)) @isperiod("2020q2")
equation ig03.ls log(ig_no) c log(rec) d(cnsp) log(yn) log(ig_no(-1)) @isperiod("2020q2")
ig03.fit(e, g) inversion_gob_f
' Estimación de la inversión privada 
equation ip01.ls log(ip_no) c log(yn) log(ip_no(-1)) @isperiod("2020q2") i_act(-2)
equation ip02.ls log(ip_no) c log(yn) log(ip_no(-1)) @isperiod("2020q2") i_act(-2) log(comer(-3))
equation ip03.ls log(ip_no) c log(yn) log(ip_no(-1)) @isperiod("2020q2") i_act(-2) log(comer(-3)) d(log(const))
equation ip04.ls log(ip_no) c log(yn) log(ip_no(-1)) @isperiod("2020q2") i_act(-2)  d(log(const)) log(trans)
equation ip05.ls log(ip_no) c log(yn) log(ip_no(-1)) @isperiod("2020q2") i_act(-2)  d(log(const))
ip05.fit(e, g) inversion_pri_f
' ooo---ooo---ooo---ooo






stop
stop
stop
'======================='
'===== Funciones de Ahorro ====='
'======================='
' Estimación del ahorro público
equation sg01.ls d(sg) c d(cnsp) log(yn) 
equation sg02.ls d(sg) c d(cnsp) log(yn) log(petro) log(mine)
equation sg03.ls d(sg) c d(cnsp) log(yn) log(petro) log(mine) log(tcr)

' Estimación del ahorro privado
equation sp01.ls log(sp) c log(yn)
equation sp02.ls log(sp) c log(yn) log(sp(-1))  @isperiod("2015q3")
equation sp03.ls log(sp) c log(yn) log(sp(-1))  @isperiod("2015q3") log(tcr)
equation sp04.ls log(sp) c log(yn) log(sp(-1))  @isperiod("2015q3") d(log(tcr)) i_act(-4)
equation sp05.ls log(sp) c log(yn) log(sp(-1))  @isperiod("2015q3") log(tcr) log(const)
'======================='
'==== Funciones de Inversión ====='
'======================='
' Estimación de la inversión pública
equation ig01.ls log(ig_no) c log(rec) d(cnsp(-2)) log(yn) log(ig_no(-1))
equation ig02.ls log(ig_no) c log(rec) d(cnsp(-2)) log(yn) log(ig_no(-1)) @isperiod("2020q2")
equation ig03.ls log(ig_no) c log(rec) d(cnsp) log(yn) log(ig_no(-1)) @isperiod("2020q2")
' Estimación de la inversión privada 
equation ip01.ls log(ip_no) c log(yn) log(ip_no(-1)) @isperiod("2020q2") i_act(-2)
equation ip02.ls log(ip_no) c log(yn) log(ip_no(-1)) @isperiod("2020q2") i_act(-2) log(comer(-3))
equation ip03.ls log(ip_no) c log(yn) log(ip_no(-1)) @isperiod("2020q2") i_act(-2) log(comer(-3)) d(log(const))
equation ip04.ls log(ip_no) c log(yn) log(ip_no(-1)) @isperiod("2020q2") i_act(-2)  d(log(const)) log(trans)
equation ip05.ls log(ip_no) c log(yn) log(ip_no(-1)) @isperiod("2020q2") i_act(-2)  d(log(const))



