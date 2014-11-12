Animation = {}
Animation.stack = {}
Animation.play = (target, type) ->
    if type is 'shake'
      count = 0
      shake = () =>
        target.position.x += if count % 4 < 2 then 2 else -2
        count += 1
        if count > 20
          Animation.stack['shake'] = null
      Animation.stack['shake'] = shake

    else if type is 'explode'
      explode = () =>
        target.scale.x += .1
        target.scale.y += .1
        if target.scale.x > 20
          Animation.stack['explode'] = null
      Animation.stack['explode'] = explode
