import math, random
import vec, basetypes, ray

# Material initialization functions
proc lambertian*(albedo: Color): Material {.inline.} =
    Material(kind: mkLambertian, lambertian: Lambertian(albedo: albedo))

proc metal*(albedo: Color, fuzziness: float): Material {.inline.} =
    Material(kind: mkMetal, metal: Metal(albedo: albedo, fuzz: fuzziness))

proc dielectric*(indexOfRefraction: float): Material {.inline.} =
    Material(kind: mkDielectric, dielectric: Dielectric(ior: indexOfRefraction))

# Material scattering functions

# Lambertian procedures

proc scatterLambertian(l: Lambertian, rIn: Ray, rec: HitRecord,
        attenuation: var Color, scattered: var Ray): bool {.inline.} =
    var scatterDirection = rec.normal + randomUnitVector()

    if scatterDirection.nearZero():
        scatterDirection = rec.normal

    scattered = Ray(origin: rec.point, direction: scatterDirection)
    attenuation = l.albedo
    return true

# Metal procedures

proc scatterMetal(m: Metal, rIn: Ray, rec: HitRecord, attenuation: var Color,
        scattered: var Ray): bool {.inline.} =
    let reflected = reflect(rIn.direction.unit(), rec.normal)
    scattered = Ray(origin: rec.point, direction: reflected + m.fuzz *
            randomUnitVector())
    attenuation = m.albedo
    return scattered.direction.dot(rec.normal) > 0

# Dielectric procedures

proc reflectance(cosine, refIdx: float): float =
    # Use Schlick's approximation for reflectance
    let r0 = block:
        let temp = (1 - refIdx) / (1 + refIdx)
        temp * temp
    
    return r0 + (1 - r0) * pow(1 - cosine, 5)

proc scatterDielectric(d: Dielectric, rIn: Ray, rec: HitRecord,
        attenuation: var Color, scattered: var Ray): bool {.inline.} =
    attenuation = color(1, 1, 1)
    let refractionRatio = if rec.frontFace: 1.0 / d.ior else: d.ior

    let unitDirection = rIn.direction.unit()
    let cosTheta = min(dot(-unitDirection, rec.normal), 1.0)
    let sinTheta = sqrt(1.0 - cosTheta * cosTheta)

    let cannotRefract = refractionRatio * sinTheta > 1
    let direction = 
        if cannotRefract or reflectance(cosTheta, refractionRatio) > rand(1.0): 
            reflect(unitDirection, rec.normal)
        else: refract(unitDirection, rec.normal, refractionRatio)


    scattered = Ray(origin: rec.point, direction: direction)
    return true

# Scatter dispatch procedure

proc scatter*(mat: Material, rIn: Ray, rec: HitRecord, attenuation: var Color,
        scattered: var Ray): bool {.inline.} =
    case mat.kind
    of mkLambertian: scatterLambertian(mat.lambertian, rIn, rec, attenuation, scattered)
    of mkMetal: scatterMetal(mat.metal, rIn, rec, attenuation, scattered)
    of mkDielectric: scatterDielectric(mat.dielectric, rIn, rec, attenuation, scattered)
