import strformat, options, random
import vec, world, ray, interval, basetypes

type
    Camera* = object
        aspectRatio*: float = 1.0
        imageWidth*: int = 400
        samplesPerPixel*: int = 10
        maxDepth*: int = 10

        imageHeight: int
        center, pixel00Loc: Point3
        pixelDeltaU, pixelDeltaV: Vec3

proc initCamera(cam: var Camera) =
    cam.imageHeight = block:
        let height = int(float(cam.imageWidth) / cam.aspectRatio)
        if height < 1: 1 else: height
    
    cam.center = point3(0, 0, 0)
    
    let focalLength = 1.0
    let viewportHeight = 2.0
    let viewportWidth = viewportHeight * float(cam.imageWidth) / float(cam.imageHeight)

    # Calculate the vectors across the horizontal and down the vertical viewport edges.
    let viewportU = vec3(viewportWidth, 0, 0)
    let viewportV = vec3(0, -viewportHeight, 0)

    # Calculate the horizontal and vertical delta vectors from pixel to pixel
    cam.pixelDeltaU = viewportU / float(cam.imageWidth)
    cam.pixelDeltaV = viewportV / float(cam.imageHeight)

    # Calculate the location of the upper left pixel
    let viewportUpperLeft = cam.center - vec3(0, 0, focalLength) - viewportU / 2 - viewportV / 2
    cam.pixel00Loc = viewportUpperLeft + 0.5 * (cam.pixelDeltaU + cam.pixelDeltaV)

proc rayColor(r: Ray, depth: int, scene: World): Color =
    if depth <= 0:
        return color(0, 0, 0)

    let rec = scene.hit(r, initInterval(0.001, Inf))
    if rec.isSome:
        let rec = rec.get()
        let direction = rec.normal + randomUnitVector()
        return 0.5 * rayColor(Ray(origin: rec.point, direction: direction), depth - 1, scene)

    let unitDirection = r.direction.unit
    let a = 0.5 * (unitDirection.y + 1)
    return (1 - a) * color(1, 1, 1) + a * color(0.5, 0.7, 1)

proc pixelSampleSquare(cam: Camera): Vec3 =
    let px = -0.5 + rand(1.0)
    let py = -0.5 + rand(1.0)
    return (px * cam.pixelDeltaU) + (py * cam.pixelDeltaV)

proc getRay(cam: Camera, i, j: int): Ray =
    # Get a randomly sampled camera ray for the pixel at location i,j
    let pixelCenter = cam.pixel00Loc + (float(i) * cam.pixelDeltaU) + (float(j) * cam.pixelDeltaV)
    let pixelSample = pixelCenter + cam.pixelSampleSquare()

    let rayOrigin = cam.center
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

