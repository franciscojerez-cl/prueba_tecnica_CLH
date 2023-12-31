/*
* =============================================
*	Nombre : Francisco Jerez
*	Fecha : 29-09-2023
* =============================================
*/

use DB_lh_fjerez
go 


--A.	Listado de cuantas licencias m�dicas ha tenido cada trabajador con COVID por cada empresa con contrato vigente. 
--(Columnas resultantes: nombre empresa, nombre trabajador, cantidad licencias).

SELECT B.NOMBRE_TRABAJADOR , C.NOMBRE_EMPRESA , COUNT(DISTINCT L.ID_LICENCIA_MEDICA) CANTIDAD_LICENCIAS
FROM REL_TRABAJADOR_EMPRESA A
INNER JOIN TBL_LICENCIA_MEDICA L ON A.ID_TRABAJADOR_EMPRESA = L.ID_TRABAJADOR_EMPRESA
INNER JOIN TBL_TRABAJADOR B ON A.ID_TRABAJADOR = B.ID_TRABAJADOR
INNER JOIN TBL_EMPRESA C ON A.ID_EMPRESA = C.ID_EMPRESA
WHERE FECHA_FIN_CONTRATO >= GETDATE() 
AND CODIGO_ENFERMEDAD = 123 -- COD. COVID 
GROUP BY B.NOMBRE_TRABAJADOR , C.NOMBRE_EMPRESA 
ORDER BY 3 DESC

--B.	Listar empresas las cuales no tienen trabajadores vigentes, pero si han tenido al menos una licencia m�dica. 
--(Columnas resultantes: rut empresa, nombre empresa).

SELECT  DISTINCT C.RUT_EMPRESA , C.NOMBRE_EMPRESA 
FROM REL_TRABAJADOR_EMPRESA A
INNER JOIN TBL_LICENCIA_MEDICA L ON A.ID_TRABAJADOR_EMPRESA = L.ID_TRABAJADOR_EMPRESA
INNER JOIN TBL_EMPRESA C ON A.ID_EMPRESA = C.ID_EMPRESA
WHERE FECHA_FIN_CONTRATO < GETDATE() 

--C.	Listar cantidad de licencias m�dicas y el monto reembolsado, por cada empresa, por a�o a partir del 2015. 
--(Columnas resultantes: nombre empresa, a�o, cantidad licencias, monto reembolsado).

SELECT  C.NOMBRE_EMPRESA 
,YEAR(L.FECHA_FIN) A�O 
, COUNT(DISTINCT L.ID_LICENCIA_MEDICA) CANTIDAD_LICENCIAS
, SUM(L.MONTO_REEMBOLSO) MONTO_REEMBOLSADO
FROM REL_TRABAJADOR_EMPRESA A
INNER JOIN TBL_LICENCIA_MEDICA L ON A.ID_TRABAJADOR_EMPRESA = L.ID_TRABAJADOR_EMPRESA
INNER JOIN TBL_EMPRESA C ON A.ID_EMPRESA = C.ID_EMPRESA
WHERE YEAR(L.FECHA_FIN) >= 2015
GROUP BY C.NOMBRE_EMPRESA ,YEAR(L.FECHA_FIN)
ORDER BY 1, 2

--D.	Lista de trabajadores que tienen contrato vigente, en al menos una empresa, y han tenido licencia m�dica continua 
--desde el inicio del a�o actual junto con la cantidad de licencias que lleva. (Columnas resultantes: rut trabajador, nombre trabajador, cantidad licencias).

SELECT B.RUT_TRABAJADOR , B.NOMBRE_TRABAJADOR , COUNT(DISTINCT L.ID_LICENCIA_MEDICA) CANTIDAD_LICENCIAS
FROM REL_TRABAJADOR_EMPRESA A
INNER JOIN TBL_LICENCIA_MEDICA L ON A.ID_TRABAJADOR_EMPRESA = L.ID_TRABAJADOR_EMPRESA
INNER JOIN TBL_TRABAJADOR B ON A.ID_TRABAJADOR = B.ID_TRABAJADOR
WHERE FECHA_FIN_CONTRATO >= GETDATE() 
AND L.FECHA_INICIO >= '2023-01-01' AND L.FECHA_FIN <= GETDATE()
GROUP BY B.RUT_TRABAJADOR , B.NOMBRE_TRABAJADOR 

--E.	Promedio de renta pagada por cada empresa, asumiendo que las rentas se almacenan con la key �renta1� a �rentaN�.
--(Columnas resultantes: rut empresa, nombre empresa, promedio de rentas).

SELECT C.RUT_EMPRESA
,C.NOMBRE_EMPRESA 
,AVG(CASE WHEN ISNUMERIC(M.VALUE) = 1 THEN M.VALUE ELSE 0 END) 
FROM REL_TRABAJADOR_EMPRESA A
INNER JOIN TBL_LICENCIA_MEDICA L ON A.ID_TRABAJADOR_EMPRESA = L.ID_TRABAJADOR_EMPRESA
INNER JOIN TBL_METADATOS M ON L.ID_LICENCIA_MEDICA = M.ID_LICENCIA_MEDICA
INNER JOIN TBL_EMPRESA C ON A.ID_EMPRESA = C.ID_EMPRESA
GROUP BY  C.RUT_EMPRESA ,C.NOMBRE_EMPRESA 

--F.	Listado de cada empresa, solo con los 3 trabajadores que han tenido los mayores reembolsos, orden�ndolos de 
--mayor a menor e indicando su posici�n (1,2 o 3). (Columnas resultantes: nombre empresa, rut trabajador, nombre trabajador, monto reembolsado, posici�n).

DROP TABLE IF EXISTS #TEMPORAL
SELECT NOMBRE_EMPRESA , RUT_TRABAJADOR , MONTO_REEMBOLSADO 
, POSICION = ROW_NUMBER() OVER(PARTITION BY NOMBRE_EMPRESA  ORDER BY MONTO_REEMBOLSADO DESC )
INTO #TEMPORAL
FROM (
SELECT C.NOMBRE_EMPRESA , B.RUT_TRABAJADOR , SUM(L.MONTO_REEMBOLSO) MONTO_REEMBOLSADO
FROM REL_TRABAJADOR_EMPRESA A
INNER JOIN TBL_LICENCIA_MEDICA L ON A.ID_TRABAJADOR_EMPRESA = L.ID_TRABAJADOR_EMPRESA
INNER JOIN TBL_TRABAJADOR B ON A.ID_TRABAJADOR = B.ID_TRABAJADOR
INNER JOIN TBL_EMPRESA C ON A.ID_EMPRESA = C.ID_EMPRESA
GROUP BY C.NOMBRE_EMPRESA , B.RUT_TRABAJADOR
) X

SELECT NOMBRE_EMPRESA , RUT_TRABAJADOR , MONTO_REEMBOLSADO  , POSICION
FROM #TEMPORAL
WHERE POSICION <= 3
ORDER BY NOMBRE_EMPRESA ,POSICION

--G.	Lista de trabajadores que tienen licencia medica vigente, con su monto reembolsado y las 3 primeras rentas que se almacenaron 
--para el calculo de su reembolso. (Columnas resultantes: rut trabajador, nombre trabajador, monto reembolsado, renta1, renta2, renta3).

SELECT RUT_TRABAJADOR , NOMBRE_TRABAJADOR , MONTO_REEMBOLSO 
, CASE WHEN ISNUMERIC([renta1]) = 1 THEN [renta1] ELSE '-' END RENTA1
, CASE WHEN ISNUMERIC([renta2]) = 1 THEN [renta2] ELSE '-' END RENTA2
, CASE WHEN ISNUMERIC([renta3]) = 1 THEN [renta3] ELSE '-' END RENTA3
FROM (
SELECT B.RUT_TRABAJADOR , B.NOMBRE_TRABAJADOR , L.MONTO_REEMBOLSO , M.[KEY] , M.[VALUE]
FROM REL_TRABAJADOR_EMPRESA A
INNER JOIN TBL_LICENCIA_MEDICA L ON A.ID_TRABAJADOR_EMPRESA = L.ID_TRABAJADOR_EMPRESA
INNER JOIN TBL_METADATOS M ON L.ID_LICENCIA_MEDICA = M.ID_LICENCIA_MEDICA
INNER JOIN TBL_TRABAJADOR B ON A.ID_TRABAJADOR = B.ID_TRABAJADOR
WHERE M.[KEY] IN ('renta1', 'renta2', 'renta3')  AND L.FECHA_FIN <= GETDATE()
) X 
PIVOT (
MAX([VALUE]) FOR [KEY] IN ([renta1],[renta2],[renta3])
) PVT;

