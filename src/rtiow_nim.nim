import random
import camera, world, objects, vec, material

# Randomize results of pseudo rng
randomize()

var scene: World

let groundMaterial = lambertian(color(0.5, 0.5, 0.5))
scene.addSphere(sphere(point3(0, -1000, 0), 1000, groundMaterial))

for a in -11..<11:
    for b in -11..<11:
        let chooseMat = rand(1.0)
        let center = point3(float(a) + 0.9 * rand(1.0), 0.2, float(b) + 0.9 * rand(1.0))

        if (center - point3(4, 0.2, 0)).length > 0.9:
            let sphereMaterial = if chooseMat < 0.8:
                let albedo = randomVec() * randomVec()
                lambertian(albedo)
            elif chooseMat < 0.95:
                let albedo = randomVec() * randomVec()
                let fuzz = rand(0.0..0.5)
                metal(albedo, fuzz)
            else:
                dielectric(1.5)
            
            scene.addSphere(sphere(center, 0.2, sphereMaterial))

let 
    material1 = dielectric(1.5)
    material2 = lambertian(color(0.4, 0.2, 0.1))
    material3 = metal(color(0.7, 0.6, 0.5), 0.0)

scene.addSphere(sphere(point3(0, 1, 0), 1.0, material1))
scene.addSphere(sphere(point3(-4, 1, 0), 1.0, material2))
scene.addSphere(sphere(point3(4, 1, 0), 1.0, material3))


var cam: Camera
cam.aspectRatio = 16.0 / 9.0
cam.imageWidth = 1200
cam.samplesPerPixel = 500
cam.maxDepth = 50

cam.vfov = 20
cam.lookFrom = point3(13, 2, 3)
cam.lookAt = point3(0, 0, 0)
cam.vUp = vec3(0, 1, 0)

cam.defocusAngle = 0.6
cam.focusDist = 10

when isMainModule:
    cam.render(scene)
