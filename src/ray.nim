import vec

type
    Ray* = object
        origin*: Point3
        direction*: Vec3

proc at*(ray: Ray, distance: float): Point3 = ray.origin + distance * ray.direction
proc init*(origin: Point3, direction: Vec3): Ray = Ray(origin: origin, direction: direction)