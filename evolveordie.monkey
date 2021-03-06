Import Mojo

Const BASE_SIZE:Int = 5
Const SCREEN_WIDTH:Int = 640
Const SCREEN_HEIGHT:Int = 480

Class Vec2D
	' Vec2D class shamelessly borrowed from Jim's Small Time Outlaws
	' Youtube channel on creating basic games with Monkey X
	
	Field x:Float
	Field y:Float
	
	Method New(x:Float, y:Float)
		Set(x, y)
	End
	
	Method Set(x:Float, y:Float)
		Self.x = x
		Self.y = y
	End
	
	' My own personal touch to Jim's code
	' Calculates Euclidean Distance
	Method Distance(point:Vec2D)
		Local xdelta:Float = point.x - Self.x
		Local ydelta:Float = point.y - Self.y
		
		Return Sqrt(xdelta * xdelta + ydelta * ydelta)		
	End
	
End

Class Player

	Field name:String
	Field position:Vec2D
	Field old_position:Vec2D
	Field velocity:Vec2D
	Field target:Vec2D
	Field distance:Float

	Field size:Int
	Field exp:Int
	Field speed:Float
	Field base_speed:Float
	Field rotation:Float
	Field box:Box
	Field is_enemy:Bool
	
	Method New(name:String, x:Float, y:Float, speed:Float, size:Int=2, is_enemy:Bool=false)
		Self.name = name
		Self.position = New Vec2D(x, y)
		Self.old_position = New Vec2D(x, y)
		Self.speed = speed
		Self.base_speed = speed
		
		Self.velocity = New Vec2D(0, 0)
		Self.size = size
		Self.exp = 0
		Self.rotation = 0
		Self.distance = 0
		Self.box = New Box(x, y, size * BASE_SIZE, size * BASE_SIZE)
		Self.is_enemy = is_enemy
	End
	
	Method Draw()
		If is_enemy
			SetColor(255, 255, 0)
		Else
			SetColor(0, 255, 0)
		End
		DrawRect(position.x, position.y, size * BASE_SIZE, size * BASE_SIZE)
		SetColor(255, 255, 255)
	End
	
	Method Update(map_width:Float, map_height:Float)
		' update position
		Self.old_position.Set(position.x, position.y)
		Self.position.Set(position.x + velocity.x, position.y + velocity.y)
		' update velocity
		If (target <> Null)
			If (position.Distance(target)) < distance
				distance = position.Distance(target)
			Else
				' we are not getting closer to the target anymore so stop moving
				velocity.Set(0, 0)
			End
				
		End
		
		
		' Don't go outside boundaries
		If (position.y < 0)
			velocity.Set(velocity.x, 0)
			position.y = 0
		End
		If (position.y + size * BASE_SIZE > map_height)
			velocity.Set(velocity.x, 0)
			position.y = map_height - size * BASE_SIZE
		End
		If (position.x < 0)
			velocity.Set(0, velocity.y)
			position.x = 0
		End
		If (position.x + size * BASE_SIZE > map_width)
			velocity.Set(0, velocity.y)
			position.x = map_width - size * BASE_SIZE
		End
		
		
		' update size
		If exp >= 10
			size += 1
			exp -= 10
		End
		
		' update speed
		speed = base_speed - (0.1 * size)
		' update box
		Self.box.Set(position.x, position.y, size * BASE_SIZE, size * BASE_SIZE)
	End
	
	Method SetTarget(x:Float, y:Float)
		Self.target = New Vec2D(x - size * BASE_SIZE/2, y - size * BASE_SIZE/2)
		
		distance = position.Distance(target)
		
		Local deltax:Float = Abs(target.x - position.x)
		Local deltay:Float = Abs(target.y - position.y)
		Local sum_delta:Float = deltax + deltay
		
		If (target.x > position.x)
			velocity.x = speed * (deltax / sum_delta)
		Else If (target.x < position.x)
			velocity.x = -speed * (deltax / sum_delta)
		End
		
		If (target.y > position.y)
			velocity.y = speed * (deltay / sum_delta)
		Else If (target.y < position.y)
			velocity.y = -speed * (deltay / sum_delta)
		End
		
	End

End

Class PlantLife
	Field name:String
	Field position:Vec2D
	Field exp:Int
	Field size:Int
	Field poisonous:Int
	Field box:Box
	
	Method New(name:String, x:Float, y:Float, size:Int, exp:Int, poisonous:Int)
		Self.name = name
		Self.position = New Vec2D(x, y)
		Self.size = size
		Self.exp = exp
		Self.poisonous = poisonous
		Self.box = New Box(x, y, size * BASE_SIZE, size * BASE_SIZE)
	End
	
	Method Draw()
		If poisonous = 1
			SetColor(255, 0, 0)
		Else
			SetColor(0, 100, 255)
		End
		DrawRect(position.x, position.y, size * BASE_SIZE, size * BASE_SIZE)
		SetColor(255, 255, 255)
	End
	
End

Class Box
	Field position:Vec2D
	Field width:Int
	Field height:Int
	
	Method New(x:Float, y:Float, wide:Int, high:Int)
		Self.position = New Vec2D(x, y)
		Self.width = wide
		Self.height = high
	End
	
	Method Set(x, y, width, height)
		position.Set(x, y)
		Self.width = width
		Self.height = height
	End
	
	Method Collide(other_box:Box)
		If (Self.position.x < other_box.position.x + other_box.width And
		   Self.position.x + Self.width > other_box.position.x And
		   Self.position.y < other_box.position.y + other_box.height And
		   Self.height + Self.position.y > other_box.position.y)
			Return True
		Else
			Return False
		End
	End

End

Class Camera
	' Camera class alos shamelessly borrowed from Jim's Small Time Outlaws
	' Youtube channel on creating basic games with Monkey X 
	' Great stuff you should seriously check it out
	Field original_pos:Vec2D
	Field position:Vec2D
	
	Method New(x:Float=0, y:Float=0)
		Self.position = New Vec2D(x, y)
		Self.original_pos = New Vec2D(x, y)
	End
	
	Method Reset()
		Self.position.Set(original_pos.x, original_pos.y)
	End
	
	' My own take on the update method though
	' This is what we use to follow the player around
	Method Update(velocity:Vec2D)
		Self.position.x -= velocity.x
		Self.position.y -= velocity.y
	End
End
