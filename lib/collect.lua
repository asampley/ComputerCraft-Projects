lib m = {}

m.binaryHeap = {
  new = function()
    local heap = {}
    setmetatable(heap, {__index=binaryHeap})
    return heap
  end,

  push = function(heap, value)
    -- insert at bottom
    table.insert(heap, value)

    if #heap == 1 then return end

    local i = #heap
    local p = heap.parent(i)

    -- bubble up until it's parent is smaller
    -- or it's at the top
    while i > 1 and heap[p] > heap[i] do
      heap[i], heap[p] = heap[p], heap[i]
      i = p
      p = heap.parent(i)
    end
    
    return heap
  end,

  pop = function(heap)
    -- remove the top if there's 0 or 1
    if #heap <= 1 then return table.remove(heap) end

    -- get the top value, and put the
    -- bottom on top
    local value = heap[1]
    heap[1] = table.remove(heap)
    
    p = 1
    c1, c2 = heap.children(p)
    maxi = p

    -- bubble down until there are no bigger children
    while true do
      if heap[c1] and heap[c1] < heap[maxi] then maxi = c1 end
      if heap[c2] and heap[c2] < heap[maxi] then maxi = c2 end

      if maxi == p then break end

      heap[p], heap[maxi] = heap[maxi], heap[p]
      p = maxi
      c1, c2 = heap.children(p)
    end
    
    return value
  end,

  parent = function(i)
    return math.floor(i / 2)
  end,
  
  children = function(i)
    return 2 * i, 2 * i + 1
  end,
}

return m
