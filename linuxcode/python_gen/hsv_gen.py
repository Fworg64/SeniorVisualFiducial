#!/usr/bin/python

import sys, os, math

minRed =250
maxRed = 14 
minGreen = 50
maxGreen = 150
minBlue = 150
maxBlue = 220
minSat = 9
minVal = 3

def getrgbtrip (inputbyte):
  r = (0xF800 & inputbyte) >> 11
  g = (0x07E0 & inputbyte) >> 5
  b = (0x001F & inputbyte)
  return (r,g,b)


def packhsv (hsv_trip):
  h = hsv_trip[0]
  s = hsv_trip[1]
  v = hsv_trip[2]
  h = (h & 0x00FF) << 8 
  s = (s & 0x000F) << 4
  v = (v & 0x000F)
  return(h | s | v)


def rgb2hsv(rgb_trip):
  r, g, b = rgb_trip[0]/31.0, rgb_trip[1]/63.0, rgb_trip[2]/31.0
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

def print_list_to_lookup (file_ref,lookup, name, entries_per_line):
  lookup_size = len(lookup)
  size_const_name = name.upper() + '_SIZE'
  size_def_str = '#define ' + size_const_name + ' ' + str(lookup_size)
  headerfile.write('\n \n \n')
  headerfile.write(size_def_str + ' \n')
  headerfile.write('\n \n \n')
  headerfile.write('unsigned int ' +name+ ' [' + size_const_name + '] = { \n')

  for x in range(lookup_size):
    headerfile.write(str(lookup[x]))
    if (x != (lookup_size-1)):
      headerfile.write(',')
    else:
      headerfile.write('};' +' \n')
    if (((x % entries_per_line)==0) and x != 0):
      headerfile.write('\n')

def is_red (hsv_trip):
  h=hsv_trip[0]
  s=hsv_trip[1]
  v=hsv_trip[2]
  global minSat
  global minRed
  global maxRed
  global minVal
  if ((h < maxRed or h > minRed) and s > minSat and v > minVal):
    return 1
  else:
    return 0

def is_green (hsv_trip):
  h=hsv_trip[0]
  s=hsv_trip[1]
  v=hsv_trip[2]
  global minSat
  global minGreen
  global maxGreen
  global minVal
  if (h < maxGreen and h > minGreen and s > minSat and v > minVal):
    return 1
  else:
    return 0

def is_blue (hsv_trip):
  h=hsv_trip[0]
  s=hsv_trip[1]
  v=hsv_trip[2]
  global minSat
  global minBlue
  global maxBlue
  global minVal
  if (h < maxBlue and h > minBlue and s > minSat and v > minVal):
    return 1
  else:
    return 0



#arguments are min saturation, min_value, red_min, red_max, green_min, green_max, blue_min, blue_max
file_name = 'hsv_lookup.h'
header_guard_name = '__'+ file_name.upper().replace('.','_')+'__' 
header_guard_start = '#ifndef ' + header_guard_name + '\n'
header_guard_start += '#define ' + header_guard_name + '\n'
header_guard_end = '#endif'

path_to_file = os.path.dirname(os.path.abspath(__file__))
path_to_include = path_to_file + '/../include/'

headerfile = open (path_to_include+file_name, 'w')
headerfile.write (header_guard_start)

rgb_trips = [getrgbtrip(x) for x in range(65536)]
hsv_trips = [rgb2hsv(x) for x in rgb_trips]
hsv_packed = [packhsv(x) for x in hsv_trips]
hsv_red = [is_red(x) for x in hsv_trips]
hsv_green = [is_green(x) for x in hsv_trips]
hsv_blue = [is_blue(x) for x in hsv_trips]


print_list_to_lookup (headerfile, hsv_packed, 'hsv_lookup', 24)
print_list_to_lookup (headerfile, hsv_red, 'red_lookup', 60)
print_list_to_lookup (headerfile, hsv_blue, 'blue_lookup',60)
print_list_to_lookup (headerfile, hsv_green, 'green_lookup', 60)

headerfile.write(header_guard_end)
headerfile.close ()
