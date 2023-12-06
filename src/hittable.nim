import vec
import material

type
    HitRecord* = object
        point*: Point3
        normal*: Vec3
        distance*: float
        frontFace*: bool
        mat*: Material
