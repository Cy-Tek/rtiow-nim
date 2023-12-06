import options, math
import vec, ray, interval, basetypes

proc sphere*(center: Point3, radius: float, material: Material): Sphere =
    Sphere(center: center, radius: radius, mat: material)

proc setFaceNormal(rec: var HitRecord, r: Ray, outwardNormal: Vec3) {.inline.} =
    rec.frontFace = r.direction.dot(outwardNormal) < 0
    rec.normal = if rec.frontFace: outwardNormal else: -outwardNormal

proc hit*(sphere: Sphere, r: Ray, rayT: Interval): Option[
        HitRecord] {.inline.} =
    let oc = r.origin - sphere.center
    let a = r.direction.lengthSquared
    let halfB = oc.dot(r.direction)
    let c = oc.lengthSquared - sphere.radius * sphere.radius

    let discriminant = halfB * halfB - a * c
    if discriminant < 0:
        return none(HitRecord)

    # Find the nearest root that lies in the acceptable range
    let sqrtd = sqrt(discriminant)
    var root = (-halfB - sqrtd) / a
    if not rayT.surrounds(root):
        root = (-halfB + sqrtd) / a
        if not rayT.surrounds(root):
            return none(HitRecord)

    var rec: HitRecord
    rec.distance = root
    rec.point = r.at(rec.distance)
    rec.mat = sphere.mat

    let outwardNormal = (rec.point - sphere.center) / sphere.radius
    rec.setFaceNormal(r, outwardNormal)

    return some(rec)
