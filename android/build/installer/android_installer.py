#!/usr/bin/python

import sys
import commands

args = sys.argv[1:]
args = [arg for arg in args if arg.endswith(".apk")]

devices = commands.getoutput("adb devices | grep -v List").strip().split('\n')
devices = [device.split('\t')[0] for device in devices]

for arg in args:
    for device in devices:
        print "\tinstalling %s to %s" % (arg, device)
        print "\t", commands.getoutput("adb -s %s install -r %s" % (device, arg))
