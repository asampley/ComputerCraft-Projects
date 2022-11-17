local BR = require("/lib/BR")
local stats = require("/lib/stats")

while true do
  local reactorsActive = stats.trueCount(BR.allReactors.getActive())
  local reactorCount = #BR.allReactors.getConnected()

  local turbinesActive = stats.trueCount(BR.allTurbines.getActive())
  local turbineCount = #BR.allTurbines.getConnected()

  local fuelpertick_mBpertick = stats.sum(BR.allReactors.getFuelConsumedLastTick())
  local energypertick_kRFpertick = stats.sum(BR.allTurbines.getEnergyProducedLastTick()) / 1000
  local energyperfuel_kRFperB = energypertick_kRFpertick / fuelpertick_mBpertick * 1000

  local maxturbinespeed_RPM = stats.max(BR.allTurbines.getRotorSpeed())
  local minturbinespeed_RPM = stats.min(BR.allTurbines.getRotorSpeed())

  -- Note: counts buckets for actively cooled
  -- otherwise, counts power
  -- Assumes 2B consumption on each turbine
  local bucketpertick_B = stats.sum(BR.allReactors.getEnergyProducedLastTick()) / 1000
  local maxbucketpertick_B = turbineCount * 2

  term.clear()
  term.setCursorPos(1, 1)
  print(string.format([[
Reactors:
  Active: %d/%d
  Fuel Usage: %.3f mB/t
Turbines:
  Active: %d/%d
  Power Output: %d kRF/t
  RPM: %d(max) %d(min)
Overall:
  Energy per Yellorium: %d kRF
  Steam Production: %d/%d B (%d%%)]],
    reactorsActive, reactorCount,
    fuelpertick_mBpertick,
    turbinesActive, turbineCount,
    energypertick_kRFpertick,
    maxturbinespeed_RPM, minturbinespeed_RPM,
    energyperfuel_kRFperB,
    bucketpertick_B,
    maxbucketpertick_B,
    bucketpertick_B / maxbucketpertick_B * 100
  ))
  sleep(10)
end
