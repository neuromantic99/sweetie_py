#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov  1 14:26:44 2017

@author: jamesrowland
"""
import sys
import os


sys.path.append('/home/jamesrowland/anaconda3/pkgs/numpy-1.13.3-py36ha12f23b_0/lib/python3.6/site-packages/')

for p in sys.path:
    print(p)
    pass

print(os.access('/home/jamesrowland/anaconda3/pkgs/', os.W_OK))