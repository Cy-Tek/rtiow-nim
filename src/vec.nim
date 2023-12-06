import std/[typetraits, math, strformat, random]
import interval, basetypes

proc vec3*(x, y, z: float): Vec3 {.inline.} = Vec3([x, y, z])
proc color*(r, g, b: float): Color {.inline.} = Color(vec3(r, g, b))
proc point3*(x, y, z: float): Point3 {.inline.} = Point3(vec3(x, y, z))

proc `[]`*(v: Vec3, ix: int): float {.inline.} = distinctBase(v)[ix]
proc `[]`*(v: var Vec3, ix: int): var float {.inline.} = distinctBase(v)[ix]
proc `[]=`*(v: var Vec3, ix: int, val: float) {.inline.} = distinctBase(v)[ix] = val

proc x*(v: Vec3): float {.inline.} = distinctBase(v)[0]
proc y*(v: Vec3): float {.inline.} = distinctBase(v)[1]
proc z*(v: Vec3): float {.inline.} = distinctBase(v)[2]

proc `+`*(v, u: Vec3): Vec3 {.inline.} =
    result[0] = v[0] + u[0]
    result[1] = v[1] + u[1]
    result[2] = v[2] + u[2]

proc `-`*(v: Vec3): Vec3 {.inline.} =
    result[0] = -v[0]
    result[1] = -v[1]
    result[2] = -v[2]

proc `-`*(v, u: Vec3): Vec3 {.inline.} =
    result[0] = v[0] - u[0]
    result[1] = v[1] - u[1]
    result[2] = v[2] - u[2]

proc `+=`*(v: var Vec3, u: Vec3) {.inline.} =
    v[0] += u[0]
    v[1] += u[1]
    v[2] += u[2]

proc `-=`*(v: var Vec3, u: Vec3) {.inline.} =
    v[0] -= u[0]
    v[1] -= u[1]
    v[2] -= u[2]

proc `*=`*(v: var Vec3, t: float) {.inline.} =
    v[0] *= t
    v[1] *= t
    v[2] *= t

proc `*`*(v, u: Vec3): Vec3 {.inline.} =
    result[0] = v[0] * u[0]
    result[1] = v[1] * u[1]
    result[2] = v[2] * u[2]

proc `*`*(v: Vec3, t: float): Vec3 {.inline.} =
    result[0] = v[0] * t
    result[1] = v[1] * t
    result[2] = v[2] * t

proc `*`*(t: float, v: Vec3): Vec3 {.inline.} =
    result[0] = v[0] * t
    result[1] = v[1] * t
    result[2] = v[2] * t

proc `/=`*(v: var Vec3, t: float) {.inline.} = v *= 1 / t
proc `/`*(v: Vec3, t: float): Vec3 {.inline.} = (1 / t) * v

proc lengthSquared*(v: Vec3): float {.inline.} = v.x * v.x + v.y * v.y + v.z * v.z
proc length*(v: Vec3): float {.inline.} = sqrt(v.lengthSquared)
proc unit*(v: Vec3): Vec3 {.inline.} = v / v.length

proc dot*(v, u: Vec3): float {.inline.} =
    v[0] * u[0] +
    v[1] * u[1] +
    v[2] * u[2]

proc cross*(v, u: Vec3): Vec3 {.inline.} =
    result[0] = v[1] * u[2] - v[2] * u[1]
    result[1] = v[2] * u[0] - v[0] * u[2]
    result[2] = v[0] * u[1] - v[1] * u[0]

proc reflect*(v, normal: Vec3): Vec3 {.inline.} =
    v - 2 * v.dot(normal) * normal

proc refract*(uv, normal: Vec3, etaiOverEtat: float): Vec3 {.inline.} =
    let
        cosTheta = min(dot(-uv, normal), 1.0)
        rOutPerp = etaiOverEtat * (uv + cosTheta * normal)
        rOutParallel = -sqrt(abs(1.0 - rOutPerp.lengthSquared)) * normal

    return rOutPerp + rOutParallel


proc nearZero*(v: Vec3): bool =
    let s = 1e-8
    return abs(v[0]) < s and abs(v[1]) < s and abs(v[2]) < s

# Functions to produce randomized vectors
proc randomVec*(): Vec3 {.inline.} =
    vec3(rand(1.0), rand(1.0), rand(1.0))

proc randomVec*(min, max: float): Vec3 {.inline.} =
    vec3(rand(min..max), rand(min..max), rand(min..max))

proc randomInUnitSphere*(): Vec3 {.inline.} =
    while true:
        let p = randomVec(-1, 1)
        if p.lengthSquared < 1:
            return p

proc randomUnitVector*(): Vec3 {.inline.} = randomInUnitSphere().unit()

proc randomOnHemisphere*(normal: Vec3): Vec3 {.inline.} =
    let onUnitSphere = randomUnitVector()
    if onUnitSphere.dot(normal) > 0:
        return onUnitSphere
    else:
        return -onUnitSphere

# String operations for vectors and colors
proc linearToGamma(linearCopmonent: float): float {.inline.} = sqrt(linearCopmonent)

proc `$`*(v: Vec3): string {.inline.} = &"{v.x} {v.y} {v.z}"
proc writeColor*(c: Color, samplesPerPixel: int): string {.inline.} =
    let scaleFactor = 1.0 / float(samplesPerPixel)
    let pixel = c * scaleFactor
    let intensity = initInterval(0, 0.999)

    let r = intensity.clamp(linearToGamma(pixel.x)) * 256
    let g = intensity.clamp(linearToGamma(pixel.y)) * 256
    let b = intensity.clamp(linearToGamma(pixel.z)) * 256

    &"{int(r)} {int(g)} {int(b)}"
