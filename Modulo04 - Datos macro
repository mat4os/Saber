#################################################################################
#                                                                               #
#                               Conexiones BBDD                                 #
#                                                                               #
#################################################################################


def nombreModulos():
    sql = "select * From DF_MODULOS"
        
    try:
        # Ejecutamos el comando
        cursor.execute(sql)
        bd.commit()
        # Devolvemos los resultados
        resultados = []
        resultados = cursor.fetchall()
        return resultados

    except:
        # Si se genero algun error revertamos la operacion
        bd.rollback()

        
def contruirDF(fechaIni, fechaFin):
    sql = "Select TICKER"
    query = nombreModulos()
    auxiliar = " "
    for i in range(len(query)):
        sql = sql + ', ' + query[i][1]
        auxiliar = auxiliar + ", AVG(if(ID_MODULO = " + str(query[i][0]) + ", VALOR, null)) AS " + query[i][1]
    
    sql = sql + ", CEE, TDP, DES, DGC, EBS, EPAT, IBS, IVA, IFHN, IFDL, IPC_, INVA, PIB, PU, PRP, SCC, TIR, TTT, UI"
    sql = sql + ' From saber.DF_TICKERS as T LEFT JOIN (Select ID_TICKER' + auxiliar
    
    
    sql = sql + " from saber.DF_VALORES where fecha between '" + fechaIni + "' and '" + fechaFin + "' group by ID_TICKER"
    sql = sql + " ) AS Valores on Valores.ID_TICKER = T.ID_TICKER LEFT JOIN ("
    sql = sql + " SELECT * from saber.DF_DatosMacro WHERE year(Fecha) = year('" + fechaFin + "')-1) AS DM ON DM.Pais = T.PAIS"
    
    try:
        # Ejecutamos el comando
        cursor.execute(sql)
        bd.commit()
        # Devolvemos los resultados
        resultados = []
        resultados = cursor.fetchall()
        return resultados

    except:
        # Si se genero algun error revertamos la operacion
        bd.rollback()


#################################################################################
#                                                                               #
#                               Yahoo Finance                                   #
#                                                                               #
#################################################################################


# pip install yahoo-finance

import numpy as np
import urllib2
import time
import yahoo_finance as yf
import MySQLdb

def extraerHistorico(ticker):
    
    try:
        modulo = 5
        urlVisitar = 'http://chartapi.finance.yahoo.com/instrument/1.0/' + ticker + '/chartdata;type=quote;range=1y/csv'
        codigoFuente = urllib2.urlopen(urlVisitar).read()
        separarFuente = codigoFuente.split('\n')
        
        for cadaLinea in separarFuente:
            separarLineas = cadaLinea.split(',')
            if len(separarLineas) == 6:
                if 'values' not in cadaLinea:
                    resultados = bandaBollinger(separarLineas[0],ticker)
                    if resultados == None : resultados  = []
                    else: resultados = [float(i[0]) for i in resultados]
                    resultados.append(float(separarLineas[1]))
                    media = np.mean(resultados)
                    bandaExtremo = 2 * np.std(resultados)
                    guardarBBDD_Data(separarLineas[0], ticker, separarLineas[1], separarLineas[2], separarLineas[3], separarLineas[4], separarLineas[5], str(media), str(media + bandaExtremo), str(media - bandaExtremo))
                    
                    # La valoracion del Target va en funcion de su cercania a las bandas
                    target = (media + bandaExtremo - float(separarLineas[1])) / (2 * np.where(bandaExtremo == 0, 1, bandaExtremo))
                    if target < 0: 
                        target = 0
                    elif target > 1: 
                        target = 1
                    else: 
                        target = target
                    guardarBBDD_Ticker(separarLineas[0], modulo, ticker, target)
                    
    except Exception, e:
        escribirLog('extraerHistorico', 'No ha funcionado la extraccion del historico por un error en: ' + str(e))

        
def extraerUltimoDatoYahooF(ticker):
    
    try:
        fecha =  time.strftime("%Y%m%d")
        modulo = 5
        cierre = yf.Share(ticker).get_price() # cierre
        maximo = yf.Share(ticker).get_days_high() # maximo
        minimo = yf.Share(ticker).get_days_low() # minimo
        apertura = yf.Share(ticker).get_open() # apetura
        volumen = yf.Share(ticker).get_volume() # volumen
        
        # Calculo sus puntos de la Banda de Bollinger
        resultados = bandaBollinger(fecha,ticker)
        resultados = [float(i[0]) for i in resultados]
        resultados.append(float(cierre))
        media = np.mean(resultados)
        bandaExtremo = 2 * np.std(resultados)
        guardarBBDD_Data(fecha, ticker, cierre, maximo, minimo, apertura, volumen, str(media), str(media + bandaExtremo), str(media - bandaExtremo))
        # La valoracion del Target va en funcion de su cercania a las bandas
        target = (media + bandaExtremo - float(cierre)) / (2 * np.where(bandaExtremo == 0, 1, bandaExtremo))
        if target < 0: 
            target = 0
        elif target > 1: 
            target = 1
        else: 
            target = target
        guardarBBDD_Ticker(fecha, modulo, ticker, target)

        
    except Exception, e:
        escribirLog('extraerUltimoDatoYahooF','No ha funcionado la extraccion del dato de hoy por un error en: ' + str(e))



#################################################################################
#                                                                               #
#                           Datos Maroeconomicos                                #
#                                                                               #
#################################################################################


# pip instal wbdata

import wbdata
import datetime
import time
import MySQLdb
import math

def macro(countries):
    # Indicadores (ver documentacion para saber cual es cual)
    indicators = {'EG.USE.ELEC.KH.PC':'CEE','SL.UEM.TOTL.ZS':'DES','GC.DOD.TOTL.GD.ZS':'DGC','EN.POP.DNST':'DP',
                  'NE.EXP.GNFS.ZS':'EBS','TX.VAL.TECH.MF.ZS':'EPAT','NE.IMP.GNFS.ZS':'IBS','IC.LGL.CRED.XQ':'IFDL',
                  'IC.BUS.EASE.XQ':'IFHN','NV.IND.TOTL.ZS':'INVA','FP.CPI.TOTL':'IPC','GC.TAX.YPKG.ZS':'IVA',
                  'NY.GDP.MKTP.CD':'PIB','FR.INR.RISK':'PRP','SP.URB.TOTL.IN.ZS':'PU','BN.CAB.XOKA.CD':'SCC',
                  'FR.INR.RINR':'TIR','IC.TAX.TOTL.CP.ZS':'TTT','IT.NET.USER.P2':'UI'}
    
    date = datetime.datetime(int(time.strftime("%Y"))-1,1,1)

    df = wbdata.get_dataframe(indicators, country=countries, convert_date=False, data_date = date)
    
    for i in range(len(df)):
        guardarBBDD_Macro(str(date), df.index[i], esNulo(df.iat[i,0]), esNulo(df.iat[i,1]), esNulo(df.iat[i,2]), esNulo(df.iat[i,3]), esNulo(df.iat[i,4]), esNulo(df.iat[i,5]), esNulo(df.iat[i,6]), esNulo(df.iat[i,7]), esNulo(df.iat[i,8]), esNulo(df.iat[i,9]), esNulo(df.iat[i,10]), esNulo(df.iat[i,11]), esNulo(df.iat[i,12]), esNulo(df.iat[i,13]), esNulo(df.iat[i,14]), esNulo(df.iat[i,15]), esNulo(df.iat[i,16]), esNulo(df.iat[i,17]), esNulo(df.iat[i,18]))
        
        
def esNulo(nulidad):
    if nulidad == None or math.isnan(nulidad): return "null"
    else: return nulidad


        
