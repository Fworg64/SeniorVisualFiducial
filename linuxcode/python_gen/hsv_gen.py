#!/usr/bin/python

import sys, os, math

def getrgbtrip (inputbyte):
  r = (0xF800 & inputbyte) >> 11
  g = (0x07E0 & inputbyte) >> 5
  b = (0x001F & inputbyte)
  return (r,g,b)


def packhsv (h,s,v):
  h = (h & 0x00FF) << 8 
  s = (s & 0x000F) << 4
  v = (v & 0x000F)
  return(h | s | v)


def rgb2hsv(r, g, b):
  r, g, b = r/31.0, g/63.0, b/31.0
  mx = max(r, g, b)
  mn = min(r, g, b)
  df = mx-mn
  if mx == mn:
      h = 0
  elif mx == r:
      h = (42 * ((g-b)/df) + 252) % 252
  elif mx == g:
      h = (42 * ((b-r)/df) + 84) % 252
  elif mx == b:
      h = (42 * ((r-g)/df) + 168) % 252
  if mx == 0:
      s = 0
  else:
      s = df/mx
  h = int (h)
  v = mx
  s = s*16
  s = round (s)
  s = int (s)
  v = v * 16
  v = round (16)
  v = int (v)
  return h, s, v

def check_code (r,g,b):
  print ('r equals ' + r)
  print ('g equals ' + g)
  print ('b equals ' + b)


#arguments are min saturation, min_value, red_min, red_max, green_min, green_max, blue_min, blue_max
minRed = 350
maxRed = 10
minGreen = 50
maxGreen = 100
minBlue = 100
maxBlue = 300
minSat = 10
minVal = 200

file_name = 'hsv_lookup.h'
header_guard_name = '__'+ file_name.upper().replace('.','_')+'__' 
header_guard_start = '#ifndef __' + header_guard_name + '\n'
header_guard_start += '#define ' + header_guard_name + '\n'
header_guard_end = '#endif'

path_to_file = os.path.dirname(os.path.abspath(__file__))
path_to_include = path_to_file + '/../include/'
#print(path_to_include)

headerfile = open (path_to_include+file_name, 'w')
headerfile.write (header_guard_start)

l_val = [x for x in range(65536)]


headerfile.write('#define HSV_VAL_SIZE 65536 \n')

headerfile.write('unsigned int hsv_val[HSV_VAL_SIZE] = { \n')

#print (len(l_val))
for x in range(0,len(l_val)):
  r,g,b = getrgbtrip(x)
  h,s,v = rgb2hsv (r,g,b)
  bytepacked=packhsv (h,s,v)
  headerfile.write(str(bytepacked))
  if (x != (len(l_val)-1)):
    headerfile.write(',')
  else:
    headerfile.write('} + \n')
  if ((x % 16)==0):
    headerfile.write('\n')

headerfile.write(header_guard_end)
headerfile.close ()
