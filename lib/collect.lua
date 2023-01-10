local m = {}

m.binaryHeap = {
  new = function()
    local heap = {}
    setmetatable(heap, {__index=m.binaryHeap})
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

    local p = 1
    local c1, c2 = heap.children(p)
    local maxi = p

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

m.deque = {
  new = function()
    return setmetatable({ front = 0, back = -1 }, {__index = m.deque})
  end,

  empty = function(self)
    return self.front > self.back
  end,

  push_front = function(self, value)
    self.front = self.front - 1
    self[self.front] = value
  end,

  push_back = function(self, value)
    self.back = self.back + 1
    self[self.back] = value
  end,

  pop_front = function(self)
    if self:empty() then return nil end

    local value = self[self.front]

    self[self.front] = nil
    self.front = self.front + 1

    return value
  end,

  pop_back = function(self)
    if self:empty() then return nil end

    local value = self[self.back]

    self[self.back] = nil
    self.back = self.back - 1

    return value
  end,

  peek_front = function(self)
    return self[self.front]
  end,

  peek_back = function(self)
    return self[self.front]
  end
}

return m
