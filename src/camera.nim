import strformat, options, random, math
import vec, world, ray, interval, basetypes, material

type
    Camera* = object
        aspectRatio*: float = 1.0
        imageWidth*: int = 400
        samplesPerPixel*: int = 10
        maxDepth*: int = 10
        vfov*: float = 90

        lookFrom*: Point3 = point3(0, 0, -1)
        lookAt*: Point3 = point3(0, 0, 0)
        vUp*: Vec3 = vec3(0, 1, 0)
        
        defocusAngle*: float = 0
        focusDist*: float = 10

        # Private variables
        
        imageHeight: int
        center, pixel00Loc: Point3
        pixelDeltaU, pixelDeltaV: Vec3
        u, v, w: Vec3
        defocusDiskU, defocusDiskV: Vec3

proc initCamera(cam: var Camera) =
    cam.imageHeight = block:
        let height = int(float(cam.imageWidth) / cam.aspectRatio)
        if height < 1: 1 else: height

    cam.center = cam.lookFrom

    let theta = degToRad(cam.vfov)
    let h = tan(theta / 2)
    let viewportHeight = 2 * h * cam.focusDist
    let viewportWidth = viewportHeight * float(cam.imageWidth) / float(
            cam.imageHeight)
    
    # Calculate the u,v,w unit basis vectors for the camera coordinate frame
    cam.w = unit(cam.lookFrom - cam.lookAt)
    cam.u = unit(cross(cam.vUp, cam.w))
    cam.v = cross(cam.w, cam.u)

    # Calculate the vectors across the horizontal and down the vertical viewport edges.
    let viewportU = viewportWidth * cam.u
    let viewportV = viewportHeight * -cam.v

    # Calculate the horizontal and vertical delta vectors from pixel to pixel
    cam.pixelDeltaU = viewportU / float(cam.imageWidth)
    cam.pixelDeltaV = viewportV / float(cam.imageHeight)

    # Calculate the location of the upper left pixel
    let viewportUpperLeft = cam.center - (cam.focusDist * cam.w) - viewportU /
            2 - viewportV / 2
    cam.pixel00Loc = viewportUpperLeft + 0.5 * (cam.pixelDeltaU +
            cam.pixelDeltaV)
    
    # Calculate the camera defocus disk basis vectors
    let defocusRadius = cam.focusDist * tan(degToRad(cam.defocusAngle / 2.0))
    cam.defocusDiskU = cam.u * defocusRadius
    cam.defocusDiskV = cam.v * defocusRadius

proc rayColor(r: Ray, depth: int, scene: World): Color =
    if depth <= 0:
        return color(0, 0, 0)

    let rec = scene.hit(r, initInterval(0.001, Inf))
    if rec.isSome:
        let rec = rec.get()
        var scattered: Ray
        var attenuation: Color

        if rec.mat.scatter(r, rec, attenuation, scattered):
            return attenuation * rayColor(scattered, depth - 1, scene)

        return color(0, 0, 0)

    let unitDirection = r.direction.unit
    let a = 0.5 * (unitDirection.y + 1)
    return (1 - a) * color(1, 1, 1) + a * color(0.5, 0.7, 1)

proc pixelSampleSquare(cam: Camera): Vec3 =
    let px = -0.5 + rand(1.0)
    let py = -0.5 + rand(1.0)
    return (px * cam.pixelDeltaU) + (py * cam.pixelDeltaV)

proc defocusDiskSample(cam: Camera): Point3 =
    let p = randomInUnitDisk()
    return cam.center + (p[0] * cam.defocusDiskU) + (p[1] * cam.defocusDiskV)

proc getRay(cam: Camera, i, j: int): Ray =
    # Get a randomly sampled camera ray for the pixel at location i,j
    let pixelCenter = cam.pixel00Loc + (float(i) * cam.pixelDeltaU) + (float(
            j) * cam.pixelDeltaV)
    let pixelSample = pixelCenter + cam.pixelSampleSquare()

    let rayOrigin = if cam.defocusAngle <= 0: cam.center else: cam.defocusDiskSample()
    let rayDirection = pixelSample - rayOrigin

    return Ray(origin: rayOrigin, direction: rayDirection)

proc render*(cam: var Camera, scene: World) =
    initCamera(cam)

    write(stdout, &"P3\n{cam.imageWidth} {cam.imageHeight}\n255\n")

    for j in 0..<cam.imageHeight:
        write(stderr, &"\rScanlines remaining: {cam.imageHeight-j} ")

        for i in 0..<cam.imageWidth:
            var pixelColor: Color
            for sample in 0..<cam.samplesPerPixel:
                let r = cam.getRay(i, j)
                pixelColor += rayColor(r, cam.maxDepth, scene)

            write(stdout, &"{writeColor(pixelColor, cam.samplesPerPixel)}\n")

    writeLine(stderr, "\rDone.                                         ")

