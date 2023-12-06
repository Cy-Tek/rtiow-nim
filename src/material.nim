import vec, basetypes, ray

# Material initialization functions
proc lambertian*(albedo: Color): Material {.inline.} =
    Material(kind: mkLambertian, lambertian: Lambertian(albedo: albedo))

proc metal*(albedo: Color, fuzziness: float): Material {.inline.} =
    Material(kind: mkMetal, metal: Metal(albedo: albedo, fuzz: fuzziness))

# Material scattering functions
proc scatterLambertian(l: Lambertian, rIn: Ray, rec: HitRecord, attenuation: var Color, scattered: var Ray): bool {.inline.} =
    var scatterDirection = rec.normal + randomUnitVector()
    
    if scatterDirection.nearZero():
        scatterDirection = rec.normal
    
    scattered = Ray(origin: rec.point, direction: scatterDirection)
    attenuation = l.albedo
    return true

proc scatterMetal(m: Metal, rIn: Ray, rec: HitRecord, attenuation: var Color, scattered: var Ray): bool {.inline.} =
    let reflected = reflect(rIn.direction.unit(), rec.normal)
    scattered = Ray(origin: rec.point, direction: reflected + m.fuzz * randomUnitVector())
    attenuation = m.albedo
    return scattered.direction.dot(rec.normal) > 0

proc scatter*(mat: Material, rIn: Ray, rec: HitRecord, attenuation: var Color, scattered: var Ray): bool {.inline.} =
    case mat.kind
    of mkLambertian: scatterLambertian(mat.lambertian, rIn, rec, attenuation, scattered)
    of mkMetal: scatterMetal(mat.metal, rIn, rec, attenuation, scattered)
