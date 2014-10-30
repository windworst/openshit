#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import re

def help():
  print('   Config file Merger')
  print('usage:')
  print('   python conf_editor in.conf < setting.conf > out.conf')

section_re = re.compile("\[(.*?)\]")

DEFAULT_SECTION = '[DEFAULT]'

def make_conf_dict(f_in):
  dict = {}
  section = DEFAULT_SECTION
  while True:
    line = f_in.readline()
    if not line:
      break;
    line = line.strip()
    if section_re.match(line):
      section = line
    else:
      index = line.find('=')
      if index<=0 or index+1>=len(line):
        continue
      if section not in dict:
        dict[section] = {}
      dict[section].update({line[0:index].strip():line[index+1:len(line)].strip()})
  return dict

def merge_config(f_source,f_in,f_out):
  dict = make_conf_dict(f_in)
  section = ""
  section_dict = {}
  while True:
    line = f_source.readline()
    if not line:
      break;
    line_value = line.strip()
    if len(line_value)==0 or line_value[0] == '#':
      f_out.write(line)
    elif section_re.match(line_value):
      if section_dict:
        for k,v in section_dict.items():
          f_out.write("%s = %s\n"%(k,v))
        del dict[section]
        sys.stdout.write('\n')
      section = line_value
      section_dict = {}
      if section in dict :
        section_dict = dict[section]
      f_out.write(line);
    elif section_dict:
      items = line_value.split('=')
      if len(items)<1:
        continue
      key = items[0].strip()
      if key in section_dict:
        f_out.write("%s = %s\n"%(key,section_dict[key]))
        del section_dict[key]
      else:
        f_out.write(line)
    else:
      f_out.write(line)
  if section_dict:
    sys.stdout.write('\n')
    for k,v in section_dict.items():
      f_out.write("%s = %s\n"%(k,v))
    del dict[section]
  for s,d in dict.items():
    if len(d)>0:
      f_out.write("\n"+s+"\n")
    for k,v in d.items():
      f_out.write("%s = %s\n"%(k,v))

if __name__ == '__main__':
  if len(sys.argv) <= 1:
    help()
    exit
  try:
    f_source = open(sys.argv[1])
    merge_config(f_source,sys.stdin,sys.stdout)
  except:
    print("Open "+ sys.argv[1] + " Failed")

