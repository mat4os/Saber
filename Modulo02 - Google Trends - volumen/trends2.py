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
    ticker =  row[2]
    ticker_id = row[0]
    url_trends = "http://ec2-52-211-38-109.eu-west-1.compute.amazonaws.com/score?ticker='"+row[2]+"'"

    response_trends = requests.get(url_trends)
    vol = response_trends.text.replace("[","").replace("]","")

    
    
    # Tabla DF_VALORES, con features globales
    print "Insertando volumen %s " % (ticker)
    query_vol = "insert into DF_VALORES(ID_TICKER, ID_MODULO, FECHA,VALOR) values ("+  str(ticker_id) +  ",20,'"+str_now+"',"+vol+")"
    print(query_vol)

    cur.execute(query_vol)

    
    db.commit()


db.close()
