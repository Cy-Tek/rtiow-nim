import vec, basetypes, ray

# Material scattering functions
proc scatterLambertian(l: Lambertian, rIn: Ray, rec: HitRecord, attenuation: var Color, scattered: var Ray): bool =
    let scatterDirection = rec.normal + randomUnitVector()
    scattered = Ray(origin: rec.point, direction: scatterDirection)
    attenuation = l.albedo
    return true

proc scatter*(mat: Material, rIn: Ray, rec: HitRecord, attenuation: var Color, scattered: var Ray): bool =
    case mat.kind
    of mkLambertian: scatterLambertian(mat.lambertian, rIn, rec, attenuation, scattered)
