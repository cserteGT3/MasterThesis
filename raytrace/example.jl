using LinearAlgebra
using ImageView
using Images
using ColorVectorSpace
using Colors
using Dates
using SignedDistanceFields
using Parameters: @unpack

using Revise
includet(joinpath(@__DIR__, "raytracer.jl"))
using .RayTracer

## camera.jl
## scene

## shaders
function render(scene, sizet, camera=:iso)
    @unpack x, y = sizet
    isocam = IsometricCamera(space(25.0,0.0,0.0),
                             space(-1.0,0,0),
                             x/600*35*normalize(space(0.0,1.0,0.0)),
                             y/600*35*normalize(space(0.0,0.0,1.0)),x,y)

    pincam = PinholeCamera(space(25.0,0.0,0.0),
                             space(-1.0,0,0),
                             x/600*35*normalize(space(0.0,1.0,0.0)),
                             y/600*35*normalize(space(0.0,0.0,1.0)),x,y,90.0)
    cam = camera === :iso ? isocam : pincam
    return render(scene, sizet, cam)
end

function render(scene, sizet, cam::AbstractCamera)
    @unpack x, y = sizet
    #Höhe Breite - x
    #Heigth Width - y

    #frame = Array{RayResults}(undef,x,y);
    myPic = Array{RGB}(undef,x,y);
    ShaderArray = [
            (x::RayResults)->RGB(0.35,0.35,0.35),
            (x::RayResults)->(RGB(0.8,0.8,0.8)*10*clamp01(1/norm(x.Position))),
            (x::RayResults)->(RGB(x.Grad[1]/2+0.5,x.Grad[2]/2+0.5,x.Grad[3]/2+0.5)),
            (x::RayResults)->RGB(0.22,0.545,0.133)*(abs(x.Position[1]/(5*sqrt(2)))),
            (x::RayResults)->RGB(0.584,0.345,0.689)*(abs(x.Position[1]/(5*sqrt(2)))),
            (x::RayResults)->RGB(0.796,0.235,0.2)*(abs(x.Position[1]/(5*sqrt(2)))),
            (x::RayResults)->RGB(0.35,0.35,0.55)]
    ## Max length of array is 2^16
    ## A sharder is (currenty) (subject to change due to unhandled reflections) a function that takes a RayResults struct and returns a RGB value


    ## render

    for i=1:x ## loop able to produce more than 1 gigapixel per hour per core on my laptop if fed correctly
        for j=1:y
            a = los(cam,i,j)
            #frame[i,j]
            temp = raymarch(a[1],a[2],scene,1000.0) ## upto 3x over head due to excessive copying
            ## Stencils on this ^ would be fun :)

            myPic[i,j] = ShaderArray[temp.Shader](temp) ##TODO:reflections have no place in this model
            ## some improvement possible with the shader
        end
    end
    return myPic
end

z = to_code(
            SUnion(
            (
            Trans(Sphere(5*sqrt(2),4),space(0.0,-10.0,0.0)),
            Trans(Ball(5*sqrt(2),5,1),space(0.0,5.0,8.66)),
            Trans(Ball(5*sqrt(2),6,0.5),space(0.0,5.0,-8.66)),
            Plane(space(1.0,0.0,0.0),2),
            RepQ(Trans(Ball(0.5,1,3.5),space(2.5,2.5,2.5)),5.0),
            Trans(Ball(5,3,2.5),space(0.0,0.0,0.0)))
            )
            )

scene = func(z,:space)

scene2 = func(to_code(Sphere(5*sqrt(2),4)), :space)

scene3 = func(to_code(Trans(Sphere(5*sqrt(2),4),space(0.0,0.0,0.0))), :space)

scene4 = func(to_code(
            SUnion((Trans(Sphere(5*sqrt(2),4),space(0.0,0.0,0.0)),Plane(space(1.0,0.0,0.0),2)))), :space)

p = render(scene2, (x=1080, y=1920), :pincam)
imshow(p[270:810,480:1440])

p2 = render(scene2, (x=2160, y=3840), :pincam);
imshow(p2[810:1350,1440:2400]);

fname = joinpath(@__DIR__, "rendered", "first.png")
save(fname, p)


function testrender(scene, sizet)
    @unpack x, y = sizet

    bname = joinpath(@__DIR__, "rendered")

    isocam = IsometricCamera(space(25.0,0.0,0.0),
                             space(-1.0,0,0),
                             x/600*35*normalize(space(0.0,1.0,0.0)),
                             y/600*35*normalize(space(0.0,0.0,1.0)),x,y)

    p = render(scene, sizet, isocam)
    save(joinpath(bname, "isocam.png"), p)

    pincam90 = PinholeCamera(space(25.0,0.0,0.0),
                             space(-1.0,0,0),
                             x/600*35*normalize(space(0.0,1.0,0.0)),
                             y/600*35*normalize(space(0.0,0.0,1.0)),x,y,90.0)
    p = render(scene, sizet, pincam90)
    save(joinpath(bname, "pincam90.png"), p)

    pincam45 = PinholeCamera(space(25.0,0.0,0.0),
                             space(-1.0,0,0),
                             x/600*35*normalize(space(0.0,1.0,0.0)),
                             y/600*35*normalize(space(0.0,0.0,1.0)),x,y,45.0)
    p = render(scene, sizet, pincam45)
    save(joinpath(bname, "pincam45.png"), p)

    pincam180 = PinholeCamera(space(25.0,0.0,0.0),
                             space(-1.0,0,0),
                             x/600*35*normalize(space(0.0,1.0,0.0)),
                             y/600*35*normalize(space(0.0,0.0,1.0)),x,y,180.0)
    p = render(scene, sizet, pincam180)
    save(joinpath(bname, "pincam180.png"), p)
    return nothing
end

testrender(scene2, (x=1080, y=1920))

function pinrend(scene, sizet)
    @unpack x, y = sizet

    bname = joinpath(@__DIR__, "rendered")
    pincam180 = PinholeCamera(space(15.0,0.0,0.0),
                             space(-1.0,0,0),
                             x/600*35*normalize(space(0.0,1.0,0.0)),
                             y/600*35*normalize(space(0.0,0.0,1.0)),x,y,720.0)
    p = render(scene, sizet, pincam180)
    save(joinpath(bname, "pincam720mod.png"), p)
    return nothing
end

pinrend(scene2, (x=1080, y=1920))

function isorend(scene, sizet)
    @unpack x, y = sizet

    bname = joinpath(@__DIR__, "rendered")

    isocam = IsometricCamera(space(25.0,0.0,0.0),
                             space(-1.0,0,0),
                             x/600*35*normalize(space(0.0,1.0,0.0)),
                             y/600*35*normalize(space(0.0,0.0,1.0)),x,y)

    p = render(scene, sizet, isocam)
    save(joinpath(bname, "isocammod.png"), p)
    return nothing
end

isorend(scene2, (x=1080, y=1920))
