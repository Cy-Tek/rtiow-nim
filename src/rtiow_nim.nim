import random
import camera, world, objects, vec, material

# Randomize results of pseudo rng
randomize()

let
    materialGround = lambertian(color(0.8, 0.8, 0.0))
    materialCenter = lambertian(color(0.1, 0.2, 0.5))
    materialLeft = dielectric(1.5)
    materialRight = metal(color(0.8, 0.6, 0.2), 0)

var scene: World
scene.addSphere(sphere(point3(0, -100.5, -1), 100, materialGround))
scene.addSphere(sphere(point3(0, 0, -1), 0.5, materialCenter))
scene.addSphere(sphere(point3(-1, 0, -1), 0.5, materialLeft))
scene.addSphere(sphere(point3(-1, 0, -1), -0.4, materialLeft))
scene.addSphere(sphere(point3(1, 0, -1), 0.5, materialRight))

var cam: Camera
cam.aspectRatio = 16.0 / 9.0
cam.imageWidth = 400
cam.samplesPerPixel = 100
cam.maxDepth = 50

cam.vfov = 20
cam.lookFrom = point3(-2, 2, 1)
cam.lookAt = point3(0, 0, -1)
cam.vUp = vec3(0, 1, 0)

cam.defocusAngle = 10
cam.focusDist = 3.4

when isMainModule:
    cam.render(scene)
