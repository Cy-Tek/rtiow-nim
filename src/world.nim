import std/options
import objects, ray, interval, basetypes

type
    World* = object
        spheres: seq[Sphere]

proc hit*(world: World, r: Ray, rayT: Interval): Option[HitRecord] {.inline.} =
    var rec: HitRecord
    var hitAnything = false
    var closestSoFar = rayT.max

    for sphere in world.spheres:
        let temp = sphere.hit(r, initInterval(rayT.min, closestSoFar))
        if temp.isSome():
            let res = temp.get()
            hitAnything = true
            closestSoFar = res.distance 
            rec = res
    
    if not hitAnything:
        return none(HitRecord)
    
    return some(rec)

proc addSphere*(world: var World, sphere: Sphere) {.inline.} =
    world.spheres.add(sphere)