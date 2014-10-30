Animation = {}
Animation.stack = {}
Animation.play = (block, type) ->
    if type is 'shake'
      count = 0
      shake = () =>
        block.position.x += if count % 4 < 2 then 2 else -2
        count += 1
        if count > 20
          Animation.stack['shake'] = null
      Animation.stack['shake'] = shake
