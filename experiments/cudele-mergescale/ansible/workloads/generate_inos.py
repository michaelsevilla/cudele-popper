#!/usr/bin/python

inos = []
# default start ino 1099511627780
start = 1099511627780 + 100000
for i in range(0, 30):
  inos.append(i*100000000 + start)

for i in inos:
  print i
print inos 
