--[[
	
	Goal:
	We have to create a scanner that can scan the surroundings with dots indicating structures and depth. The dots should be color coded based on whether the surface 
	is a wall, an interactable, or an entity.
	
	Requirements:
	1. There should be two modes:
		a. Left click will scan an area based the radius which should be changable with scroll wheel. 
		b. Right Click will have an intense scan of the visible area for the player, covering the area with dots. 
	2. The player should not be able to see anything without using the scanner
	3. The game should be runnable (optional if its parth's computer)
	
	
	Steps:
	1. We need to create a tool or model to be our scanner
	2. We need to create a part that would be the origin point for the ray
	2. We need to create an area that is pitch black, where nothing is visible
	3. We need to create a scanning system 
		a. We use Roblox's inbuilt :Raycast() function. This function takes in 3 arguments, the origin point of the ray, which is that part, the direction vector 
		([the player's orientation].Unit * render distance), and raycastparams (only important parts are FilterDescendantsInstances (an array) and FilterType (Enum.RaycastFilterType,
		which can have two values, 0 or 1, where 0 is a blacklist and 1 is a whitelist))
		b. The :Raycast() function returns a RaycastResult, which is an object that has 5 properties. The only relevant properties are the last one, which is the position of the intersection 
		and the normal vector of the intersected face. 
		c. We will then copy a part from ServerStorage (which will serve as the "dot" that we're copying), and set its position to the position of the intersection and set its orientation to
		the normal vector of the intersected face 
		
	4. Randomizing dot placement
		a. This will primarily be done by modifying the direction vector. The direction vector initially will be the player's orientation, but we'll add a random offset to it. We will add a 
		wiggle value to each of the coordinates, and it doesn't matter if this would change the length of the vector becauseee we'll turn it into a unit vector then multiply that by the
		render distance. This wiggle value will be a random number between 0 and 1, and we'll divide that by some kind of dampening value. This is necessary because we want the code to 
		behave the same, regardless of whether the direction vector has components of 1, 2, 3 or 10000, 20000, 30000. This means we need to turn the direction vector into a unit vector,
		then add the wiggle value divided by a dampening value (because the maximum value of a component of a unit vector is 1, so adding 1 would drastically change the vector). After that,
		the resultant vector is turned into a unit vector then multiplied by the render distance. This shouldn't work if the radius is currently being changed.
			i. Check when mousebutton1 held down
			ii. Check if "scannable" variable is true
			iii. Get direction vector from player orientation
			iv. Turn direction vector into unit vector
			v. Instantiate a new Random object
			vi. Call the NextNumber() method of the Random object, which takes in a min value of -1 and a max value of 1. This will return a real number between the min and the max.
			vii. Divide the number by some dampening value, and store that as a variable called wiggle. 
			viii. Get two more wiggle values, for each of the components
			ix. Add wiggle values to components of unit direction vector
			x. Turn the resultant vector into a unit vector
			xi. Multiply the resultant vector by the render distance
			
	5. Changing the radius of the scanner
		a. This will be done using the keys "v" and "c". The "v" key will increase the radius by a set amount (keep it at 0.01 per 10 ms) until it reaches a cap of a certain value 
		(call it MAX_RADIUS). The "c" will do the same thing in the opposite direction until MIN_RADIUS. Once we have the radius, we'll modify the dampening value to achieve the 
		effect we want when we use the scanner. We also have to disable using the scanner while changing the radius. 
			i. Check when keys "v" or "c" held down
			ii. Set "scannable" variable to false
			iii. If "v" held down, increment radius by 0.01 until key stopped or until MAX_RADIUS reached, every 10 ms
			iv. Vice versa for "c" 
			v. Use event when key released 
			vi. Set "scannable" variable to true
			vii. Change the dampening value to reflect the new radius 
	
	6. Create the right click functionality
		a. This will be done by looking at the camera's viewpoint ray. With this, we can create a ray of 1 stud long based off a 2D vector of the view. The function has two parameters, 
		X and Y of the screen. This starts from 0,0 (being top left) and camera.ViewportSize.X (being top right). From there, we can create viewpoint rays and increment it in the x 
		direction until it matches the viewportsize.x. With each of those viewpoint rays, we use it as the origin of a raycast and cast that with the direction vector of the camera's
		look vector and create dots accordingly. Then go down an increment of y until its greater than ViewportSize.Y (bottom of the screen). While this is happening, the players's speed
		goes to 0 to prevent the player from moving until the scan is done. In order to do this, we will set the scannable variable from before to true (which will also prevent players from left
		clicking during the right click) and set it to false after the scan is complete. We will also check scanning to make sure the size of the m1 isn't messed with during this scan
		to completely immobilize any actions of the player. Finally, the camera will be locked to make sure that none of the values change.
		
		Note, after testing, the camera's viewport size is not indicative of how big the physical area is. This means that if you get very close to a wall and hit right click, it will 
		scan a very tiny area with a very very high density of dots, creating significant lag (possibly causing a crash on less powerful devices). A way to get around this is by shooting
		out 3 rays. One at the top left, one at the top right, and one at the bottom left. Then, I will get the ray.Position from each and then get the magnitude of the 
		difference between the top left and top right, and the top left and the bottom left. This will give the height and length of the physical area, which should then be used
		for the step value. 
			i. Check if "scannable" is  true and "scanning" is false
			ii. Set "scanning" to true
			iii. Set "scannable" to false
			iv. Lock the players camera
			v. Set the player's walkspeed to 0
			vi. Get the viewport size
			vii. Create 3 viewportPointToRays with the parameters of (0, 0), (ViewportSize.X, 0), and (0, ViewportSize.Y)
			viii. Subtract (0,0).Position from (ViewportSize.X, 0).Position and (0, 0).Position from (0, ViewportSize.Y).Position
			ix. Get the magnitude of both of these differences and save them to the variables "length" and "height"
			x. In the scaledstepsize function, return a vector2 with the values of the viewportsize divided by length and height. 
			xi. Create a viewportPointToRay start with parameters of (0,0)
			xii. Get the origin of the ray that is returned (Ray.Origin)
			xiii. Create a raycast with origin of the ray and direction of the ray
			xiv. If result ~= nil then create dot
			xv. Increment the X value from step v by X step value, repeat steps vi to x until the X value is greater than ViewportSize.X
			xvi. Increment the Y value from step v by Y step value, repeat steps vi to x until the Y value is greater than ViewportSize.Y
			xvii. Set Scanning to false
			xviii. Set scannable to true
			xix. Unlock Camera

	7. Create a red ray animation that will be played when left clicking or right clicking. 
		a. This will be done by copying a laser part that is stored in ServerStorage, and just adding it to a folder in the workspace that is called lasers. Whenever the
		raycast is called, I would clone the laser part then set its size property to Vector3.new(Size.X * raycastResult.Distance, Size.Y, Size.Z), and then set its CFrame
		to CFrame.new(position of "ScanningPortion", raycastResult.Position):ToWorldSpace(CFrame.Angles(0, math.rad(90), 0))	
	Scripts and their functions:
	
	1. Server script inside the handler
		a. This script will be the main script that handles the scanner's functionality
	2. Local script for detecting key presses
		
	Function breakdown:
		1. SendRaycast(modifiedDirectionVector : Vector3, raycastParams : RaycastParams) -> raycastResult : RaycastResult 
		2. GetWiggle(dampeningValue : Number) -> wiggleValue : Number
		3. GetParams() -> raycastParams : RaycastParams
		4. RandomizeDirectionVector(directionVector : Vector3) -> modifiedDirectionVector : Vector3
		5. PlaceDot(position : Vector3, orientation : Vector3)
		
	Event breakdown:
		1. MouseButton1Click held down
			a. Check "scannable" variable, if true continue
			b. Set "scanning" variable to true
			c. Get player's direction vector
			d. Call RandomizeDirectionVector() -> modifiedDirectionVector
				i. Call GetWiggle(dampeningValue) for each component
			e. Call GetParams() -> raycastParams
			f. Call SendRaycast(modifiedDirectionVector, raycastParams) -> raycastResult
			g. Call PlaceDot(raycastResult.Position, raycastResult.normal)
			h. Repeat loop while MouseButton1Click held down
		2. MouseButton1Click Released
			a. Set "scanning" to false
		3.	Key "v" or "c" held down 
			a. Check if "scanning" variable is false, if so continue
			b. Set "scannable" variable to false
			c. If statement to see if radius is < MAX_RADIUS or > MIN_RADIUS
			d. Increment or Decrement value
		4. Key "v" or "c" released
			a. Set "scannable" variable to true
		5.  MouseButton2Click held down
			a. Check "scannable" variable, if true continue
			b. Set "scanning" variable to true
			c. Call LockCamera()
			d. Get ViewportSize
			e. Get player's direction vector
			f. Call viewpointRayOrigin(0,0) -> viewpointOriginPosition
			g. Call ScaledStepSize(ViewportSize) -> stepSize
			h. Start YLoop here, until viewpointOriginPosition.Y < ViewportSize.Y
			i. Start XLoop here, until viewpointOriginPosition.X < ViewportSize.X
			j. Call SendRaycast(viewpointOriginPosition, directionVector) -> raycastResult
			k. Call PlaceDot(raycastResult.Position, raycastResult.normal)
			l. Call viewpointRayOrigin(viewpointOriginPosition.X + stepSize.X, viewpointOriginPosition.Y) -> viewpointOriginPosition
			m. End XLoop Here 
			n. Call viewpointRayOrigin(0, viewpointOriginPosition.Y + stepSize.Y) -> viewpointOriginPosition
			o. End YLoop Here
			p. Set "scanning" to false
			q. Call UnlockCamera()
			
		
		6. Key "b" held down	
			
			
	Global Variables:
		1. "scanning" : boolean
		2. "scannable" : boolean
		3. MAX_RADIUS : number
		4. MIN_RADIUS : number
		5. dampeningValue : number
]]

