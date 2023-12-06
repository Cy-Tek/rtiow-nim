# Vector related types
type
    Vec3* = distinct array[3, float]
    Color* = Vec3
    Point3* = Vec3
    
# Material related types
type
    Lambertian* = object
        albedo*: Color
    MaterialKind* = enum
        mkLambertian
    Material* = object
        case kind*: MaterialKind
        of mkLambertian: lambertian*: Lambertian

# World object types
type
    Sphere* = object
        center*: Point3
        radius*: float
        mat*: Material

# Hittable types
type
    HitRecord* = object
        point*: Point3
        normal*: Vec3
        distance*: float
        frontFace*: bool
        mat*: Material