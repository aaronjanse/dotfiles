#!/usr/bin/env python3


from threading import Timer
import i3ipc
import json
import os
import psutil
import subprocess
import time
import urllib.request

timer = None

statsIntervalSec = 5
counter = 0

workspaceStatus = "         " #          
batteryStatus = "" # full, charging, discharging
batteryCharge = 1.0 # out of 1.0

centerStats = ''
rightStats = ''
song = ''


def render():
  statusText = workspaceStatus
  if batteryStatus != "full":
    secondaryColor = "ffb86c" if batteryStatus == "discharging" else "8be9fd"
    batteryWidth = round(batteryCharge * len(workspaceStatus))
    statusText = "%{U#f8f8f8}%{+o}" + statusText[:batteryWidth] \
           + "%{U#" + secondaryColor + "}" \
           + statusText[batteryWidth:] + "%{-o}" \
           + " {0:.0%}".format(batteryCharge)

  if song is not None:
    statusText += f"  %{{F#42b983}}{song}%{{F-}}"

  print(' '+statusText+'%{c}'+centerStats+'%{r}'+rightStats+' ')


i3 = i3ipc.Connection()

def updateWorkspaceStatus():
  global workspaceStatus

  activeWorkspaces = []
  focusedWorkspace = -1
  for j in i3.get_workspaces():
    activeWorkspaces.append(j.num)
    if j.focused:
      focusedWorkspace = j.num
  statusText = ""
  for i in range(1, 11):
    if i == focusedWorkspace:
      statusText += " "
    elif i in activeWorkspaces:
      statusText += " "
    else:
      statusText += " "
  workspaceStatus = statusText.strip()

# Subscribe to events
def handleWorkspaceUpdate(self, e):
  updateWorkspaceStatus()
  render()

def get_song():
  try:
    out = subprocess.check_output(['playerctl', 'status'], stderr=open(os.devnull, 'wb')).decode()
    if not out.lower().startswith("playing"):
      return None
    return subprocess.check_output(['playerctl', 'metadata', 'title'], stderr=open(os.devnull, 'wb')).decode().strip()
  except:
    return None

def is_muted():
  out = subprocess.check_output(['amixer', 'cset', 'numid=3'], stderr=open(os.devnull, 'wb')).decode()
  return 'values=0,0' in out

def using_vpn():
  try:
    out = subprocess.check_output(['mullvad', 'status'], stderr=open(os.devnull, 'wb')).decode()
    return out.startswith('Tunnel status: Connected to WireGuard')
  except:
    return False

def updateStats():
  global batteryStatus, batteryCharge, centerStats, rightStats, timer, counter, song

  counter += 1

  song = get_song()

  with open("/sys/class/power_supply/BAT0/status", 'r') as f:
    batteryStatus = f.readlines()[0].lower().strip()

  if batteryStatus != "full":
    with open("/sys/class/power_supply/BAT0/charge_full", 'r') as f:
      chargeFull = int(f.readlines()[0].strip())
    with open("/sys/class/power_supply/BAT0/charge_now", 'r') as f:
      chargeNow = int(f.readlines()[0].strip())

    batteryCharge = chargeNow / chargeFull

  cpu = round(sum(psutil.cpu_percent(percpu=True))/2) # two vCPUs per CPU
  try:
    temps = psutil.sensors_temperatures()['coretemp']
  except:
    temps = [0]
  temp = round(max([t.current for t in temps]))
  ram = psutil.virtual_memory().used/1000/1000/1000

  centerStats = '{:3}% {:2}° {:2.2f} GB'.format(cpu, temp, ram)

  rightStats = ''
  if not is_muted():
    rightStats += ' 🎶'
  if using_vpn():
    rightStats += ' 🔒'
  rightStats += '  {}'.format(time.strftime('%Y-%m-%d %H:%M'))

  timer = Timer(statsIntervalSec, updateStats)
  timer.start()
  render()

updateWorkspaceStatus()
updateStats()

i3.on('workspace::focus', handleWorkspaceUpdate)

try:
  i3.main()
except KeyboardInterrupt:
  timer.cancel()
