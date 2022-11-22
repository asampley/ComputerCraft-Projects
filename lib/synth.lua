local m = {}

local samples_per_sec = 48000
local pi2 = 2 * math.pi

m.buffer = function(buffer, waveFunctions, i, j)
  local sample = i or 1

  for b = i or 1, j or #buffer do
    buffer[b] = 0
    for _,f in pairs(waveFunctions) do
      buffer[b] = buffer[b] + f(sample)
    end
    buffer[b] = math.min(127, math.max(-127, math.floor(buffer[b])))
    sample = sample + 1
  end
end

m.sine = function(frequency, amplitude, decay)
  local f_sample = frequency / samples_per_sec

  return function(sample)
    amplitude = amplitude * (decay or 1)
    return math.sin((sample * f_sample % 1.0) * pi2) * amplitude
  end
end

m.sawtooth = function(frequency, amplitude, decay)
  local f_sample = frequency / samples_per_sec

  return function(sample)
    amplitude = amplitude * (decay or 1)
    return ((sample * f_sample % 1.0) - 0.5) * 2 * amplitude
  end
end

m.triangle = function(frequency, amplitude, decay)
  local f_sample = frequency / samples_per_sec

  return function(sample)
    amplitude = amplitude * (decay or 1)
    return (math.abs((sample * f_sample % 1.0) - 0.5) * 2 * amplitude)
  end
end

m.square = function(frequency, amplitude, decay)
  local f_sample = frequency / samples_per_sec

  return function(sample)
    amplitude = amplitude * (decay or 1)
    return (sample * f_sample % 1.0) < 0.5 and amplitude or -amplitude
  end
end

m.softtooth = function(frequency, amplitude, decay)
  local f_sample = frequency / samples_per_sec

  return function(sample)
    amplitude = amplitude * (decay or 1)
    local x = sample * f_sample % 1.0 - 0.5

    if x < -0.25 then
      return -amplitude
    elseif x < 0.25 then
      return x * 4 * amplitude
    else
      return amplitude
    end
  end
end

m.trapezoid = function(frequency, amplitude, decay)
  local f_sample = frequency / samples_per_sec

  return function(sample)
    amplitude = amplitude * (decay or 1)

    local x = sample * f_sample % 1.0 - 0.5

    return math.min(1, math.max(-1, math.abs(x) * 2)) * amplitude
  end
end

return m
