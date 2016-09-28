#!/usr/bin/python

import MySQLdb
import requests
import json
import datetime

now = datetime.datetime.now()
now = datetime.datetime.now()
str_now = now.date().isoformat()

db = MySQLdb.connect(host = 'mat4os.c7nqt0xzukjh.eu-west-1.rds.amazonaws.com', user = 'mat4os', passwd='vivarbet1', db = 'saber')

cur = db.cursor()

# Getting tickets
cur.execute("SELECT * FROM DF_TICKERS")

# Building rows for database
for row in cur.fetchall():
    
    ticker =  row[1]
    ticker_id = row[0]
    url_scoring_sentiment = "http://ec2-52-209-211-168.eu-west-1.compute.amazonaws.com/scoring?ticker='"+row[1]+"'"
    url_scoring_syuzhet = "http://ec2-52-209-211-168.eu-west-1.compute.amazonaws.com/scoring?ticker='"+row[1]+"'&met=syuzhet"

    url_scoring_sentiment = "http://ec2-52-209-211-168.eu-west-1.compute.amazonaws.com/scoring?ticker='"+row[1]+"'"
    url_scoring_syuzhet = "http://ec2-52-209-211-168.eu-west-1.compute.amazonaws.com/scoring?ticker='"+row[1]+"'&met=syuzhet"
    url_porcentaje_sentiment = "http://ec2-52-209-211-168.eu-west-1.compute.amazonaws.com/porcentaje?ticker='"+row[1]+"'"
    url_porcentaje_syuzhet = "http://ec2-52-209-211-168.eu-west-1.compute.amazonaws.com/porcentaje?ticker='"+row[1]+"'&met=syuzhet"

    response_scoring_sentiment = requests.get(url_scoring_sentiment)
    response_scoring_syuzhet = requests.get(url_scoring_syuzhet)
    response_porcentaje_sentiment = requests.get(url_porcentaje_sentiment)
    response_porcentaje_syuzhet = requests.get(url_porcentaje_syuzhet)

    sst = response_scoring_sentiment.text.replace("[","").replace("]","")
    ssy = response_scoring_syuzhet.text.replace("[","").replace("]","")
    pst = response_porcentaje_sentiment.text.replace("[","").replace("]","")
    psy = response_porcentaje_syuzhet.text.replace("[","").replace("]","")

    # Tabla DF_NLP, con columna para cada feature
    query =  "insert into DF_NLP (ticker, sen_polaridad, sen_porcentaje, syu_polaridad, syu_porcentaje, fecha) values ('" + ticker + "'," +str(sst)+","+str(pst)+","+str(ssy)+","+str(psy)+",'"+str_now+"')"
    print(query)
    print "Insertado ticket %s %s %s %s %s  "  % (ticker, sst, pst, ssy, psy) 
    cur.execute(query)
    
    # Tabla DF_VALORES, con features globales
    query_sst = "insert into DF_VALORES(ID_TICKER, ID_MODULO, FECHA,VALOR) values ("+  str(ticker_id) +  ",16,'"+str_now+"',"+sst+")"
    print(query_sst)
    query_ssy = "insert into DF_VALORES(ID_TICKER, ID_MODULO, FECHA,VALOR) values ("+  str(ticker_id) +  ",18,'"+str_now+"',"+ssy+")"
    print(query_ssy)
    query_pst = "insert into DF_VALORES(ID_TICKER, ID_MODULO, FECHA,VALOR) values ("+  str(ticker_id) +  ",17,'"+str_now+"',"+pst+")"
    print(query_pst)
    query_psy = "insert into DF_VALORES(ID_TICKER, ID_MODULO, FECHA,VALOR) values ("+  str(ticker_id) +  ",19,'"+str_now+"',"+psy+")"
    print(query_psy)
    cur.execute(query_sst)
    cur.execute(query_ssy)
    cur.execute(query_pst)
    cur.execute(query_psy)
    
    db.commit()


db.close()
