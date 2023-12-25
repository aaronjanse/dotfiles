#!/usr/bin/env python3


from threading import Timer
import i3ipc
import json
import psutil
import time
import urllib.request

timer = None

statsIntervalSec = 5
covidInterval = 600/statsIntervalSec
counter = 0

covidCases = 0

workspaceStatus = "         " #          
batteryStatus = "" # full, charging, discharging
batteryCharge = 1.0 # out of 1.0

centerStats = ''
rightStats = ''




def render():
  statusText = workspaceStatus
  if batteryStatus != "full":
    secondaryColor = "ffb86c" if batteryStatus == "discharging" else "8be9fd"
    batteryWidth = round(batteryCharge * len(workspaceStatus))
    statusText = "%{U#ffffff}%{+o}" + statusText[:batteryWidth] \
           + "%{U#" + secondaryColor + "}" \
           + statusText[batteryWidth:] + "%{-o}" \
           + " {0:.0%}".format(batteryCharge)

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


def updateStats():
  global batteryStatus, batteryCharge, centerStats, rightStats, timer, counter, covidCases

  if counter % covidInterval == 0:
    try:
      web = urllib.request.urlopen("https://coronavirus-19-api.herokuapp.com/all")
      covidCases = json.loads(web.read().decode())["cases"]
    except:
      pass

  counter += 1

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
  # '127% 10* ziggy 12.64 GB'
  centerStats = '{:3}% {:2}° {} {:2.2f} GB'.format(cpu, temp, 'ziggy', ram)
  rightStats = '{:,}'.format(covidCases) + '   ' + time.strftime('%Y-%m-%d %H:%M')

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


