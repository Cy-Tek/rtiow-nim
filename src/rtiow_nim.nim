import random
import camera, world, objects, vec

# Randomize results of pseudo rng
randomize()

var scene: World
scene.addSphere(sphere(point3(0, 0, -1), 0.5))
scene.addSphere(sphere(point3(0, -100.5, -1), 100))

var cam: Camera
cam.aspectRatio = 16.0 / 9.0
cam.imageWidth = 400
cam.samplesPerPixel = 100

when isMainModule:
    cam.render(scene)
