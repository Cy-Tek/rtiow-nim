import std/[typetraits, math, strformat]
import interval

type
    Vec3* = distinct array[3, float]
    Color* = Vec3
    Point3* = Vec3

proc vec3*(x, y, z: float): Vec3 {.inline.} = Vec3([x, y, z])
proc color*(r, g, b: float): Color {.inline.} = Color(vec3(r,g,b))
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

proc `$`*(v: Vec3): string {.inline.} = &"{v.x} {v.y} {v.z}"
proc writeColor*(c: Color, samplesPerPixel: int): string {.inline.} =
    let scaleFactor = 1.0 / float(samplesPerPixel)
    let pixel = c * scaleFactor
    let intensity = initInterval(0, 0.999)
    
    let r = intensity.clamp(pixel.x) * 256
    let g = intensity.clamp(pixel.y) * 256
    let b = intensity.clamp(pixel.z) * 256
    
    &"{int(r)} {int(g)} {int(b)}))"